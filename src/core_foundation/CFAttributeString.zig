const CFAttributedString = @This();

const std = @import("std");
const c = @import("c");
const CFString = @import("CFString.zig");

pub const Attributes = @import("dictionary.zig").CFDictionary(CFString, c.CFTypeRef);

ref: c.CFAttributedStringRef,

pub fn fromRef(ref: c.CFAttributedStringRef) CFAttributedString {
    return .{ .ref = ref };
}

pub fn asCFTypeRef(self: CFAttributedString) c.CFTypeRef {
    return @ptrCast(self.ref);
}

pub fn retain(self: CFAttributedString) CFAttributedString {
    _ = c.CFRetain(self.asCFTypeRef());
    return self;
}

pub fn deinit(self: CFAttributedString) void {
    c.CFRelease(self.asCFTypeRef());
}

pub fn getTypeID() c.CFTypeID {
    return c.CFAttributedStringGetTypeID();
}

pub fn init(text: []const u8) CFString.StringError!CFAttributedString {
    const string = try CFString.init(text);
    defer string.deinit();

    return .fromRef(c.CFAttributedStringCreate(
        c.kCFAllocatorDefault,
        string.ref,
        null,
    ) orelse return error.OutOfMemory);
}

pub fn initWithAttributes(text: []const u8, attributes: Attributes) CFString.StringError!CFAttributedString {
    const string = try CFString.init(text);
    defer string.deinit();

    return .fromRef(c.CFAttributedStringCreate(
        c.kCFAllocatorDefault,
        string.ref,
        attributes.ref,
    ) orelse return error.OutOfMemory);
}

/// Returns a borrowed string. Retain it before keeping it beyond this object's lifetime.
pub fn getString(self: CFAttributedString) CFString {
    return .fromRef(c.CFAttributedStringGetString(self.ref));
}

/// Returns the length in UTF-16 code units.
pub fn len(self: CFAttributedString) usize {
    return @intCast(c.CFAttributedStringGetLength(self.ref));
}
