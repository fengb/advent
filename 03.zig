const std = @import("std");

const Pair = struct {
    x: usize,
    y: usize,
};

pub fn Matrix(comptime T: type, width: usize, height: usize) type {
    return struct {
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

    var wire0 = try std.heap.page_allocator.create(Matrix(u32, origin.x * 2, origin.y * 2));
    defer std.heap.page_allocator.destroy(wire0);
    wire0.reset(0);

    var line_buf: [2000]u8 = undefined;
    var file_in_stream = file.inStream();

    {
        const line0 = try file_in_stream.stream.readUntilDelimiterOrEof(line_buf[0..], '\n');
        var x: usize = origin.x;
        var y: usize = origin.y;
        var step0: u32 = 0;
        var inner_buf: [10]u8 = undefined;
        var line_stream = std.io.SliceInStream.init(line0.?);
        while (line_stream.stream.readUntilDelimiterOrEof(inner_buf[0..], ',')) |segment| {
            if (segment == null) break;

            var value = try std.fmt.parseUnsigned(u32, segment.?[1..], 10);
            while (value > 0) {
                step0 += 1;
                value -= 1;
                switch (segment.?[0]) {
                    'R' => x += 1,
                    'L' => x -= 1,
                    'U' => y += 1,
                    'D' => y -= 1,
                    else => unreachable,
                }
                wire0.set(x, y, step0);
            }
        } else |err| return err;
    }

    var min_d: usize = std.math.maxInt(usize);
    var min_steps: usize = std.math.maxInt(usize);
    {
        const line1 = try file_in_stream.stream.readUntilDelimiterOrEof(line_buf[0..], '\n');
        var x: usize = origin.x;
        var y: usize = origin.y;
        var steps1: u32 = 0;
        var inner_buf: [10]u8 = undefined;
        var line_stream = std.io.SliceInStream.init(line1.?);
        while (line_stream.stream.readUntilDelimiterOrEof(inner_buf[0..], ',')) |segment| {
            if (segment == null) break;

            var value = try std.fmt.parseUnsigned(u32, segment.?[1..], 10);
            while (value > 0) {
                steps1 += 1;
                value -= 1;
                switch (segment.?[0]) {
                    'R' => x += 1,
                    'L' => x -= 1,
                    'U' => y += 1,
                    'D' => y -= 1,
                    else => unreachable,
                }
                const steps0 = wire0.get(x, y);
                if (steps0 > 0) {
                    min_steps = std.math.min(min_steps, steps0 + steps1);
                    min_d = std.math.min(min_d, manhattanDistance(origin, .{ .x = x, .y = y }));
                }
            }
        } else |err| return err;
    }

    std.debug.warn("Shortest distance: {}\n", min_d);
    std.debug.warn("Shortest steps: {}\n", min_steps);
}
