const std = @import("std");
const c = @import("c");

test "test init" {
    const chunk = std.heap.c_allocator.create(c.Chunk) catch unreachable;
    defer c.freeChunk(chunk);

    c.initChunk(chunk);
    try std.testing.expect(chunk.count == 0);
    try std.testing.expect(chunk.capacity == 0);
    try std.testing.expect(chunk.code == null);
}

test "test expansion" {
    const chunk = std.heap.c_allocator.create(c.Chunk) catch unreachable;
    defer c.freeChunk(chunk);

    c.initChunk(chunk);
    var i: u8 = 0;
    while (i < 10) : (i += 1) {
        c.writeChunk(chunk, i, i);
    }
    try std.testing.expect(chunk.count == 10);
    try std.testing.expect(chunk.capacity == 16);

    i = 0;
    while (i < 10) : (i += 1) {
        try std.testing.expect(chunk.code[i] == i);
    }
}
