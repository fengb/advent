const std = @import("std");

fn hasAdjacent(buf: []const u8) bool {
    for (buf[1..]) |val, i| {
        if (val == buf[i]) {
            return true;
        }
    }

    return false;
}

fn hasDouble(buf: []const u8) bool {
    var curr: u8 = 0;
    var size: usize = 1;
    for (buf) |val, i| {
        if (val == curr) {
            size += 1;
        } else {
            if (size == 2) {
                return true;
            }
            curr = val;
            size = 1;
        }
    }
    return size == 2;
}

fn allIncreasing(buf: []const u8) bool {
    for (buf[1..]) |val, i| {
        if (val < buf[i]) {
            return false;
        }
    }

    return true;
}

pub fn main() !void {
    var buf: [10]u8 = undefined;
    var i: usize = 145852;

    var part1: usize = 0;
    var part2: usize = 0;
    while (i <= 616942) : (i += 1) {
        const str = try std.fmt.bufPrint(buf[0..], "{}", i);
        if (hasAdjacent(str) and allIncreasing(str)) {
            part1 += 1;
        }
        if (hasDouble(str) and allIncreasing(str)) {
            part2 += 1;
        }
    }

    std.debug.warn("Part 1: {}\n", part1);
    std.debug.warn("Part 2: {}\n", part2);
}
