const std = @import("std");

pub fn main() !void {
    const file = try std.fs.Dir.cwd().openRead("01.input");

    var buf = try std.Buffer.initSize(std.heap.page_allocator, 64);
    var file_in_stream = file.inStream();
    var total: usize = 0;
    while (std.io.readLineFrom(&file_in_stream.stream, &buf)) |line| {
        const mass = try std.fmt.parseUnsigned(u32, line, 10);
        const fuel = @divFloor(mass, 3) - 2;
        total += fuel;
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    std.debug.warn("Total: {}\n", total);
}
