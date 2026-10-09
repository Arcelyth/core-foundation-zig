const CTFont = @This();
const std = @import("std");
const c = @import("c");
const types = @import("types.zig");
const Options = types.Options;
const Orientation = types.Orientation;

pub const CTFontRef = std.meta.Child(c.CTFontRef);

pub const StringError = error{
    InvalidUtf8,
    OutOfMemory,
    InputTooLong,
};

ref: CTFontRef,

pub fn fromRef(reference: c.CTFontRef) CTFont {
    return .{
        .ref = reference orelse @panic("Attempt to create a null object."),
    };
}

pub fn initWithName(name: []const u8, size: f64) StringError!CTFont {
    const string = try toCFString(name);
    defer c.CFRelease(string);

    return fromRef(c.CTFontCreateWithName(
        string,
        size,
        null,
    ));
}

pub fn initWithNameAndOptions(name: []const u8, size: f64, options: Options) StringError!CTFont {
    const string = try toCFString(name);
    defer c.CFRelease(string);

    return fromRef(c.CTFontCreateWithNameAndOptions(
        string,
        size,
        null,
        @backingInt(options),
    ));
}

pub fn toCFString(bytes: []const u8) StringError!c.CFStringRef {
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

pub fn toCFIndex(length: usize) error{InputTooLong}!c.CFIndex {
    return std.math.cast(c.CFIndex, length) orelse error.InputTooLong;
}

test "core_text CTFont: initial with name" {
    const font = try CTFont.initWithName("Helvetica", 16.0);
    defer c.CFRelease(font.ref);

    try std.testing.expect(c.CTFontGetSize(font.ref) == 16.0);
    try std.testing.expect(c.CTFontGetAscent(font.ref) > 0.0);
    try std.testing.expect(c.CTFontGetDescent(font.ref) >= 0.0);
}
