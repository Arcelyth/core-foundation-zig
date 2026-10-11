const CFString = @This();

const std = @import("std");
const c = @import("c");
const toCFIndex = @import("index.zig").toCFIndex;

pub const StringError = error{
    InvalidUtf8,
    OutOfMemory,
    InputTooLong,
};

ref: c.CFStringRef,

pub fn fromRef(ref: c.CFStringRef) CFString {
    return .{ .ref = ref };
}

pub fn asCFTypeRef(self: CFString) c.CFTypeRef {
    return @ptrCast(self.ref);
}

pub fn retain(self: CFString) CFString {
    _ = c.CFRetain(@ptrCast(self.ref));
    return self;
}

pub fn deinit(self: CFString) void {
    c.CFRelease(@ptrCast(self.ref));
}

pub fn getTypeID() c.CFTypeID {
    return c.CFStringGetTypeID();
}

/// Creates a CFString from UTF-8 bytes.
pub fn init(bytes: []const u8) StringError!CFString {
    if (!std.unicode.utf8ValidateSlice(bytes))
        return error.InvalidUtf8;

    const length = try toCFIndex(bytes.len);

    const ref = c.CFStringCreateWithBytes(
        c.kCFAllocatorDefault,
        bytes.ptr,
        length,
        c.kCFStringEncodingUTF8,
        0,
    ) orelse return error.OutOfMemory;

    return .{ .ref = ref };
}

/// Converts the CFString to an owned UTF-8 byte slice.
pub fn to(self: CFString, allocator: std.mem.Allocator) StringError![]u8 {
    const range: c.CFRange = .{
        .location = 0,
        .length = c.CFStringGetLength(self.ref),
    };

    var length: c.CFIndex = 0;
    const converted = c.CFStringGetBytes(
        self.ref,
        range,
        c.kCFStringEncodingUTF8,
        0,
        0,
        null,
        0,
        &length,
    );

    if (converted != range.length) return error.InvalidUtf8;

    const bytes = try allocator.alloc(u8, @intCast(length));
    errdefer allocator.free(bytes);

    if (length != 0) {
        const written = c.CFStringGetBytes(
            self.ref,
            range,
            c.kCFStringEncodingUTF8,
            0,
            0,
            bytes.ptr,
            length,
            null,
        );
        if (written != range.length) return error.InvalidUtf8;
    }

    return bytes;
}

/// Returns the string length in UTF-16 code units.
pub fn len(self: CFString) usize {
    return @intCast(c.CFStringGetLength(self.ref));
}

/// Compares string contents.
pub fn eq(self: CFString, other: CFString) bool {
    return c.CFStringCompare(
        self.ref,
        other.ref,
        0,
    ) == c.kCFCompareEqualTo;
}

test "core_foundation CFString: init and to" {
    const input = "A\x00é😀";

    var string = try CFString.init(input);
    defer string.deinit();

    const bytes = try string.to(std.testing.allocator);
    defer std.testing.allocator.free(bytes);

    try std.testing.expectEqualStrings(input, bytes);
}

test "core_foundation CFString: rejects invalid UTF-8" {
    try std.testing.expectError(
        error.InvalidUtf8,
        CFString.init("\xff"),
    );
}

test "core_foundation CFString: len and eq" {
    var a = try CFString.init("hello");
    defer a.deinit();

    var b = try CFString.init("hello");
    defer b.deinit();

    var c_string = try CFString.init("world");
    defer c_string.deinit();

    try std.testing.expectEqual(@as(usize, 5), a.len());
    try std.testing.expect(a.eq(b));
    try std.testing.expect(!a.eq(c_string));
}
