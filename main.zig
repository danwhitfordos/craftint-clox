const std = @import("std");
const Io = std.Io;
const assert = std.debug.assert;
const c = @import("c");

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
            _ = c.interpret(&c_buf);             
        }        
    }
}

fn runFile(io: std.Io, alloc: std.mem.Allocator, path: [:0]const u8) !c.InterpretResult {
    const cwd = std.Io.Dir.cwd();
    const file = try cwd.openFile(io, path, .{ .mode = .read_only });
    defer file.close(io);

    var buffer: [1024]u8 = undefined;
    var file_reader = file.reader(io, &buffer);
    const file_size = try file_reader.getSize();
    var source: [:0]u8 = try alloc.allocSentinel(u8, file_size, 0);
    const n = try file_reader.interface.readSliceShort(source);
    assert(n == file_size);
    return c.interpret(source.ptr);
}

pub fn main(init: std.process.Init) !void {
    c.initVM();
    defer c.freeVM();

    const arena: std.mem.Allocator = init.arena.allocator();    
    const args = try init.minimal.args.toSlice(arena);

    const io = init.io;

    if (args.len == 1) {
        repl(io);
    } else if (args.len == 2) {
        const path = args[1];
        const res = try runFile(io, arena, path);
        switch (res) {
            c.INTERPRET_OK => return,
            c.INTERPRET_COMPILE_ERROR => return error.CompileError,
            c.INTERPRET_RUNTIME_ERROR => return error.RuntimeError,
            else => return error.UnknownError,
        }
    } else {
        std.debug.print("Usage: {s} [path]\n", .{args[0]});
        return error.InvalidArguments;
    }
}
