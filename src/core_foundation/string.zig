const std = @import("std");
const c = @import("c");
const toCFIndex = @import("index.zig").toCFIndex;
pub const CFString = c.CFStringRef;

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
