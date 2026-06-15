const std = @import("std");
const Io = std.Io;
const assert = std.debug.assert;

const vm = @import("vm");

fn repl(io: std.Io) void {
    // Create a buffer and read a line into it
    var line_buffer: [1024]u8 = undefined;
    var c_buf: [1025:0]u8 = undefined;
    var stdin_reader: Io.File.Reader = std.Io.File.stdin().reader(io, &line_buffer);
    var stdin = &stdin_reader.interface;

    while (true) {
        std.debug.print("> ", .{});
        const line_opt = stdin.takeDelimiter('\n') catch {
            std.debug.print("Error reading input :(\n", .{});
            continue;
        };
        if (line_opt) |line| {
            @memcpy(c_buf[0..line.len], line);
            c_buf[line.len] = 0;
            vm.interpret(&c_buf) catch {
                std.debug.print("Error on line :(\n", .{});
                continue;
            };
        }
    }
}

fn runFile(io: std.Io, alloc: std.mem.Allocator, path: [:0]const u8) !void {
    const cwd = std.Io.Dir.cwd();
    const file = try cwd.openFile(io, path, .{ .mode = .read_only });
    defer file.close(io);

    var buffer: [1024]u8 = undefined;
    var file_reader = file.reader(io, &buffer);
    const file_size = try file_reader.getSize();
    var source: [:0]u8 = try alloc.allocSentinel(u8, file_size, 0);
    defer alloc.free(source);

    const n = try file_reader.interface.readSliceShort(source);
    assert(n == file_size);
    return vm.interpret(source.ptr);
}

pub fn main(init: std.process.Init) !void {
    vm.initVM();
    defer vm.freeVM();

    const arena: std.mem.Allocator = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);

    const io = init.io;

    if (args.len == 1) {
        repl(io);
    } else if (args.len == 2) {
        const path = args[1];        
        try runFile(io, arena, path);
    } else {
        std.debug.print("Usage: {s} [path]\n", .{args[0]});
        return error.InvalidArguments;
    }
}

fn test_file(fname: [:0]const u8, expected_output: [:0]const u8) !void {
    const arena: std.mem.Allocator = std.testing.allocator;
    const io = std.testing.io;    

    var buf: [1024]u8 = undefined;
    {
        vm.initVM();
        defer vm.freeVM();

        vm.setOutfile(&buf);
        try runFile(io, arena, fname);
    }
    try std.testing.expectStringStartsWith(&buf, expected_output);
}

test {
    try test_file("examples/hello_world.lox", "Hello, world!\n");
}
test {
    try test_file("examples/locals.lox", "10\n50\n");
}
test {
    try test_file("examples/jumping.lox", "two plus two is four\n");
}
