const std = @import("std");
const c = @import("c");

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
