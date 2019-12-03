const std = @import("std");

const Pair = struct {
    x: usize,
    y: usize,
};

pub fn Matrix(comptime T: type, width: usize, height: usize) type {
    return packed struct {
        const Self = @This();

        data: [height * width]T,

        pub fn width(self: Self) usize {
            return width;
        }

        pub fn height(self: Self) usize {
            return height;
        }

        pub fn reset(self: *Self, val: T) void {
            std.mem.set(T, self.data[0..], val);
        }

        pub fn get(self: Self, x: usize, y: usize) T {
            const i = self.idx(x, y);
            return self.data[i];
        }

        pub fn set(self: *Self, x: usize, y: usize, val: T) void {
            const i = self.idx(x, y);
            self.data[i] = val;
        }

        fn idx(self: Self, x: usize, y: usize) usize {
            std.debug.assert(x < width);
            std.debug.assert(y < height);
            return x + y * width;
        }

        fn pair(self: Self, i: usize) Pair {
            return Pair{
                .x = i % width,
                .y = i / width,
            };
        }
    };
}

const origin = Pair{ .x = 10000, .y = 10000 };
fn manhattanDistance(lhs: Pair, rhs: Pair) usize {
    return std.math.absCast(@bitCast(isize, lhs.x -% rhs.x)) + std.math.absCast(@bitCast(isize, lhs.y -% rhs.y));
}

pub fn main() !void {
    const file = try std.fs.cwd().openRead("03.input");

    var wires = try std.heap.page_allocator.create(Matrix(u8, origin.x * 2, origin.y * 2));
    defer std.heap.page_allocator.destroy(wires);
    wires.reset(0);

    var buf: [2000]u8 = undefined;
    var file_in_stream = file.inStream();
    var l: u8 = 1;
    while (file_in_stream.stream.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {
        if (line == null) break;

        var x: usize = origin.x;
        var y: usize = origin.y;
        var inner_buf: [10]u8 = undefined;
        var line_stream = std.io.SliceInStream.init(line.?);
        while (line_stream.stream.readUntilDelimiterOrEof(inner_buf[0..], ',')) |segment| {
            if (segment == null) break;

            var value = try std.fmt.parseUnsigned(u32, segment.?[1..], 10);
            while (value > 0) {
                value -= 1;
                switch (segment.?[0]) {
                    'R' => x += 1,
                    'L' => x -= 1,
                    'U' => y += 1,
                    'D' => y -= 1,
                    else => unreachable,
                }
                wires.set(x, y, wires.get(x, y) | l);
            }
        } else |err| return err;

        l <<= 1;
    } else |err| return err;

    var min: usize = std.math.maxInt(usize);
    for (wires.data) |val, i| {
        if (val & 0b11 == 0b11) {
            const p = wires.pair(i);
            const d = manhattanDistance(p, origin);
            if (d < min) {
                min = d;
            }
            std.debug.warn("({}, {}) Δ {}\n", p.x, p.y, d);
        }
    }

    std.debug.warn("Shortest: {}\n", min);
}
