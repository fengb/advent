const std = @import("std");

pub fn fuelFor(mass: u32) u32 {
    const div = @divFloor(mass, 3);
    return if (div > 2) div - 2 else 0;
}

pub fn main() !void {
    const file = try std.fs.Dir.cwd().openRead("01.input");

    var buf = try std.Buffer.initSize(std.heap.page_allocator, 64);
    var file_in_stream = file.inStream();
    var initial_total: u32 = 0;
    var adjusted_total: u32 = 0;
    while (std.io.readLineFrom(&file_in_stream.stream, &buf)) |line| {
        const mass = try std.fmt.parseUnsigned(u32, line, 10);
        var delta_fuel = fuelFor(mass);
        initial_total += delta_fuel;

        while (delta_fuel > 0) : (delta_fuel = fuelFor(delta_fuel)) {
            adjusted_total += delta_fuel;
        }
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    std.debug.warn("Initial total: {}\n", initial_total);
    std.debug.warn("Adjusted total: {}\n", adjusted_total);
}
