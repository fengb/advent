const std = @import("std");

fn hasAdjacent(buf: []const u8) bool {
    for (buf[1..]) |val, i| {
        if (val == buf[i]) {
            return true;
        }
    }

    return false;
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

    var count: usize = 0;
    while (i <= 616942) : (i += 1) {
        const str = try std.fmt.bufPrint(buf[0..], "{}", i);
        if (hasAdjacent(str) and allIncreasing(str)) {
            count += 1;
        }
    }

    std.debug.warn("Count: {}\n", count);
}
