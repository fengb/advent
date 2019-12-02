const std = @import("std");

pub fn readSegment(stream: var, buf: *std.Buffer, comptime sep: u8) ![]u8 {
    const start = buf.len();
    while (stream.readByte()) |byte| {
        switch (byte) {
            sep => return buf.toSlice()[start..],
            else => try buf.appendByte(byte),
        }
    } else |err| switch (err) {
        error.EndOfStream => {
            return if (start == buf.len()) error.EndOfStream else buf.toSlice()[start..];
        },
        else => return err,
    }
}

const Op = enum(u32) {
    Add = 1,
    Multiply = 2,
    Halt = 99,
};

const CpuState = enum {
    Op,
    Src0,
    Src1,
    Dest,

    fn next(self: CpuState) CpuState {
        return switch (self) {
            .Op => .Src0,
            .Src0 => .Src1,
            .Src1 => .Dest,
            .Dest => .Op,
        };
    }
};

pub fn main() !void {
    const file = try std.fs.Dir.cwd().openRead("02.input");

    var ramBuilder = std.ArrayList(u32).init(std.heap.page_allocator);

    var buf = try std.Buffer.initSize(std.heap.page_allocator, 64);
    var file_in_stream = file.inStream();
    while (readSegment(&file_in_stream.stream, &buf, ',')) |segment| {
        const value = try std.fmt.parseUnsigned(u32, segment, 10);
        try ramBuilder.append(value);
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    var ram = ramBuilder.toOwnedSlice();
    // Magic numbers come from problem definition.
    ram[1] = 12;
    ram[2] = 2;

    var cpu = CpuState.Op;
    var op: Op = undefined;
    var reg0: u32 = 0;
    var reg1: u32 = 0;
    for (ram) |val| {
        switch (cpu) {
            .Op => {
                op = @intToEnum(Op, val);
                if (op == .Halt) {
                    break;
                }
            },
            .Src0 => reg0 = ram[val],
            .Src1 => reg1 = ram[val],
            .Dest => {
                ram[val] = switch (op) {
                    .Add => reg0 + reg1,
                    .Multiply => reg0 * reg1,
                    else => unreachable,
                };
            },
        }
        cpu = cpu.next();
    }

    for (ram) |val| {
        std.debug.warn("{},", val);
    }
    std.debug.warn("\n");
}
