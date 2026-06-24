const std = @import("std");
const c = @import("c");

const InterpretError = error{
    Compiler,
    Runtime,
};

fn resetStack() void {
    c.vm.stackTop = &c.vm.stack;
}

pub fn initVM() void {
    resetStack();
    c.vm.objects = null;
    c.vm.outfile = c.stdout;
    c.vm.errfile = c.stderr;

    c.initTable(&c.vm.globals);
    c.initTable(&c.vm.strings);
}

pub fn freeVM() void {
    _ = c.fflush(c.vm.outfile);
    c.freeTable(&c.vm.globals);
    c.freeTable(&c.vm.strings);
    c.freeObjects();
}

fn setOutfileToBuf(buf: []u8) void {
    const f = c.fmemopen(buf.ptr, buf.len, "w");
    c.vm.outfile = f;
}

fn setErrfileToBuf(buf: []u8) void {
    const f = c.fmemopen(buf.ptr, buf.len, "w");
    c.vm.errfile = f;
}

pub fn setAllOutputToBuf(buf: []u8) void {
    setOutfileToBuf(buf);
    setErrfileToBuf(buf);
}

pub fn interpret(src: [*:0]const u8) !void {
    return switch (c.interpret(src)) {
        c.INTERPRET_OK => {},
        c.INTERPRET_COMPILE_ERROR => InterpretError.Compiler,
        c.INTERPRET_RUNTIME_ERROR => InterpretError.Runtime,
        else => unreachable,
    };
}

test "test vm" {
    initVM();
    defer freeVM();
    var buf: [50]u8 = undefined;
    setAllOutputToBuf(&buf);

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

        setAllOutputToBuf(&buf);

        try interpret("print \"Hello, world!\";");
    }

    try std.testing.expectStringStartsWith(&buf, "Hello, world!\n");
}

test "test global var" {
    var buf: [50]u8 = undefined;
    {
        initVM();
        defer freeVM();
        setAllOutputToBuf(&buf);

        try interpret("var m = \"FOO\";  var a = 10;  var b = 2; print m; print a/b;");
    }

    try std.testing.expectStringStartsWith(&buf, "FOO\n5\n");
}

test "interpret returns OK" {
    var buf: [50]u8 = undefined;

    initVM();
    defer freeVM();
    setAllOutputToBuf(&buf);

    try interpret("print 1 + 2;");
}

test "interpret returns compiler error" {
    var buf: [50]u8 = undefined;
    initVM();
    defer freeVM();
    setAllOutputToBuf(&buf);

    try std.testing.expectError(InterpretError.Compiler, interpret("var a = ;"));
}

test "interpret returns runtime error" {
    var buf: [50]u8 = undefined;
    initVM();
    defer freeVM();
    setAllOutputToBuf(&buf);

    try std.testing.expectError(InterpretError.Runtime, interpret("print unknownVar;"));
}
