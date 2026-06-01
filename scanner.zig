const std = @import("std");
const c = @import("c");

test "empty scanner" {
    const input = "";
    const scanner = c.initScanner(input);
    _ = scanner;
    const token = c.scanToken();
    try std.testing.expect(token.type == c.TOKEN_EOF);
}

test "failing test" {
    try std.testing.expect(2 + 2 == 4);
}
