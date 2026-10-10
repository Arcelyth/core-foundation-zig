const std = @import("std");
const c = @import("c");
const toCFIndex = @import("index.zig").toCFIndex;
pub const CFString = c.CFStringRef;
pub const CFStringEncoding = c.CFStringEncoding;

pub const StringError = error{
    InvalidUtf8,
    OutOfMemory,
    InputTooLong,
};

pub fn toCFString(bytes: []const u8) StringError!CFString {
    if (!std.unicode.utf8ValidateSlice(bytes))
        return error.InvalidUtf8;

    return c.CFStringCreateWithBytes(
        null,
        bytes.ptr,
        try toCFIndex(bytes.len),
        c.kCFStringEncodingUTF8,
        0,
    ) orelse error.OutOfMemory;
}

pub fn toUtf8(allocator: std.mem.Allocator, string: CFString) StringError![]u8 {
    const range: c.CFRange = .{
        .location = 0,
        .length = c.CFStringGetLength(string),
    };
    var length: c.CFIndex = 0;
    if (c.CFStringGetBytes(
        string,
        range,
        c.kCFStringEncodingUTF8,
        0,
        0,
        null,
        0,
        &length,
    ) != range.length)
        return error.InvalidUtf8;
    const bytes = try allocator.alloc(u8, @intCast(length));
    errdefer allocator.free(bytes);

    if (length != 0 and c.CFStringGetBytes(
        string,
        range,
        c.kCFStringEncodingUTF8,
        0,
        0,
        bytes.ptr,
        length,
        null,
    ) != range.length)
        return error.InvalidUtf8;
    return bytes;
}

test "core_foundation string: toUTF-8" {
    const input = "A\x00é😀";
    const string = try toCFString(input);
    defer c.CFRelease(string);

    const bytes = try toUtf8(std.testing.allocator, string);
    defer std.testing.allocator.free(bytes);

    try std.testing.expectEqualStrings(input, bytes);
    try std.testing.expectError(error.InvalidUtf8, toCFString("\xff"));
}
