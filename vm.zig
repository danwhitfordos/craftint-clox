const std = @import("std");
const c = @import("c");

pub const InterpretResult = enum {
    OK,
    COMPILE_ERROR,
    RUNTIME_ERROR,
    FUBAR,
};

pub fn initVM() void {
    c.initVM();
}

pub fn freeVM() void {
    _ = c.fflush(c.vm.outfile);
    c.freeVM();
}

pub fn setOutfile(buf: []u8) void {
    const f = c.fmemopen(buf.ptr, buf.len, "w");
    if (f == null) {
        std.debug.print("oops", .{});
    }
    c.vm.outfile = f;
}

pub fn interpret(src: [*:0]const u8) InterpretResult {
    return switch (c.interpret(src)) {
        c.INTERPRET_OK => InterpretResult.OK,
        c.INTERPRET_COMPILE_ERROR => InterpretResult.COMPILE_ERROR,
        c.INTERPRET_RUNTIME_ERROR => InterpretResult.RUNTIME_ERROR,
        else => InterpretResult.FUBAR,
    };
}

test "test vm" {
    c.initVM();
    defer c.freeVM();
    const chunk = std.heap.c_allocator.create(c.Chunk) catch unreachable;
    defer c.freeChunk(chunk);
    c.initChunk(chunk);

    var constantLoc = c.addConstant(chunk, c.NUMBER_VAL(123));
    c.writeChunk(chunk, c.OP_CONSTANT, 1);
    c.writeChunk(chunk, @as(u8, @intCast(constantLoc)), 1);

    constantLoc = c.addConstant(chunk, c.NUMBER_VAL(6.7));
    c.writeChunk(chunk, c.OP_CONSTANT, 2);
    c.writeChunk(chunk, @as(u8, @intCast(constantLoc)), 2);

    c.writeChunk(chunk, c.OP_RETURN, 3);
    const res = c.interpret("123 + 67;");
    try std.testing.expect(res == c.INTERPRET_OK);
}

test "test hello world" {
    var buf: [50]u8 = undefined;
    {
        initVM();
        defer freeVM();

        setOutfile(&buf);

        const res = interpret("print \"Hello, world!\";");
        try std.testing.expect(InterpretResult.OK == res);
    }

    try std.testing.expectStringStartsWith(&buf, "Hello, world!\n");
}

test "test global var" {
    var buf: [50]u8 = undefined;
    {
        initVM();
        defer freeVM();
        setOutfile(&buf);

        const res = interpret("var m = \"FOO\";  var a = 10;  var b = 2; print m; print a/b;");
        try std.testing.expect(InterpretResult.OK == res);
    }

    try std.testing.expectStringStartsWith(&buf, "FOO\n5\n");
}
