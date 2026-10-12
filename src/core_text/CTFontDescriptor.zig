const CTFontDescriptor = @This();

const std = @import("std");
const c = @import("c");
const cf = @import("../core_foundation.zig");
const Attributes = cf.CFDictionary(cf.CFString, c.CFTypeRef);
const AttributeNames = cf.CFSet(cf.CFString);

ref: c.CTFontDescriptorRef,

pub fn fromRef(ref: c.CTFontDescriptorRef) CTFontDescriptor {
    return .{ .ref = ref };
}

pub fn asCFTypeRef(self: CTFontDescriptor) c.CFTypeRef {
    return @ptrCast(self.ref);
}

pub fn retain(self: CTFontDescriptor) CTFontDescriptor {
    _ = c.CFRetain(self.asCFTypeRef());
    return self;
}

pub fn deinit(self: CTFontDescriptor) void {
    c.CFRelease(self.asCFTypeRef());
}

pub fn getTypeID() c.CFTypeID {
    return c.CTFontDescriptorGetTypeID();
}

/// Creates an owned descriptor from a UTF-8 font name and point size.
pub fn initWithNameAndSize(name: []const u8, size: f64) cf.CFString.StringError!CTFontDescriptor {
    const string = try cf.CFString.init(name);
    defer string.deinit();
    return .fromRef(c.CTFontDescriptorCreateWithNameAndSize(string.ref, size));
}

/// Creates an owned descriptor with the supplied font attributes.
pub fn initWithAttributes(attributes: Attributes) CTFontDescriptor {
    return .fromRef(c.CTFontDescriptorCreateWithAttributes(attributes.ref));
}

/// Copies the descriptor with added or updated attributes.
pub fn initCopyWithAttributes(self: CTFontDescriptor, attributes: Attributes) CTFontDescriptor {
    return .fromRef(c.CTFontDescriptorCreateCopyWithAttributes(self.ref, attributes.ref));
}

/// Returns an owned dictionary of the descriptor's attributes.
pub fn copyAttributes(self: CTFontDescriptor) Attributes {
    return .fromRef(c.CTFontDescriptorCopyAttributes(self.ref));
}

/// Returns an owned CF wrapper, or null if the attribute is absent or has another CF type.
pub fn copyAttribute(self: CTFontDescriptor, comptime T: type, attribute: cf.CFString) ?T {
    const ref = c.CTFontDescriptorCopyAttribute(self.ref, attribute.ref) orelse return null;
    if (c.CFGetTypeID(ref) != T.getTypeID()) {
        c.CFRelease(ref);
        return null;
    }
    return T.fromRef(@ptrCast(@alignCast(ref)));
}

/// Returns owned matching descriptors. Mandatory keys must match exactly.
pub fn createMatchingFontDescriptors(self: CTFontDescriptor, mandatory_attributes: ?AttributeNames) ?cf.CFArray(CTFontDescriptor) {
    return .fromRef(c.CTFontDescriptorCreateMatchingFontDescriptors(
        self.ref,
        if (mandatory_attributes) |attributes| attributes.ref else null,
    ) orelse return null);
}

/// Returns the owned preferred match, or null when no descriptor matches.
pub fn createMatchingFontDescriptor(self: CTFontDescriptor, mandatory_attributes: ?AttributeNames) ?CTFontDescriptor {
    return .fromRef(c.CTFontDescriptorCreateMatchingFontDescriptor(
        self.ref,
        if (mandatory_attributes) |attributes| attributes.ref else null,
    ) orelse return null);
}

test "core_text CTFontDescriptor: ownership and typed attributes" {
    const descriptor = blk: {
        const original = try initWithNameAndSize("Helvetica", 16);
        defer original.deinit();
        break :blk CTFontDescriptor.fromRef(original.ref).retain();
    };
    defer descriptor.deinit();
    const attributes = descriptor.copyAttributes();
    defer attributes.deinit();
    const name_key = cf.CFString.fromRef(c.kCTFontNameAttribute);
    const size_key = cf.CFString.fromRef(c.kCTFontSizeAttribute);

    const name = descriptor.copyAttribute(cf.CFString, name_key).?;
    defer name.deinit();
    const size = descriptor.copyAttribute(cf.CFNumber, size_key).?;
    defer size.deinit();
    const missing_key = try cf.CFString.init("core-foundation-zig-missing-attribute");
    defer missing_key.deinit();

    try std.testing.expectEqual(getTypeID(), c.CFGetTypeID(descriptor.asCFTypeRef()));
    try std.testing.expect(descriptor.copyAttribute(cf.CFString, missing_key) == null);
    try std.testing.expect(descriptor.copyAttribute(cf.CFNumber, name_key) == null);
    try std.testing.expectEqual(@as(?f64, 16), size.to(f64));
    try std.testing.expect(attributes.contains(name_key));
    const bytes = try name.toSlice(std.testing.allocator);
    defer std.testing.allocator.free(bytes);
    try std.testing.expectEqualStrings("Helvetica", bytes);
    try std.testing.expectError(error.InvalidUtf8, initWithNameAndSize("\xff", 16));
}
