const CTFont = @This();

const std = @import("std");
const c = @import("c");
const cf = @import("../core_foundation.zig");
const CTFontDescriptor = @import("CTFontDescriptor.zig");
const SymbolicTraits = @import("types.zig").SymbolicTraits;

ref: c.CTFontRef,

pub fn fromRef(ref: c.CTFontRef) CTFont {
    return .{ .ref = ref };
}

pub fn asCFTypeRef(self: CTFont) c.CFTypeRef {
    return @ptrCast(self.ref);
}

pub fn retain(self: CTFont) CTFont {
    _ = c.CFRetain(self.asCFTypeRef());
    return self;
}

pub fn deinit(self: CTFont) void {
    c.CFRelease(self.asCFTypeRef());
}

pub fn getTypeID() c.CFTypeID {
    return c.CTFontGetTypeID();
}

/// Creates a font matching a UTF-8 name, at the requested point size.
pub fn initWithName(name: []const u8, size: f64) cf.CFString.StringError!CTFont {
    const string = try cf.CFString.init(name);
    defer string.deinit();
    return .fromRef(c.CTFontCreateWithName(string.ref, size, null));
}

/// Creates a font from a descriptor. Zero preserves its size, or uses Core Text's default.
pub fn initWithDescriptor(descriptor: CTFontDescriptor, size: f64) CTFont {
    return .fromRef(c.CTFontCreateWithFontDescriptor(descriptor.ref, size, null));
}

/// Returns an owned descriptor.
pub fn copyFontDescriptor(self: CTFont) CTFontDescriptor {
    return .fromRef(c.CTFontCopyFontDescriptor(self.ref));
}

/// Returns an owned dictionary of native font traits.
pub fn copyTraits(self: CTFont) cf.CFDictionary(cf.CFString, cf.CFNumber) {
    return .fromRef(c.CTFontCopyTraits(self.ref));
}

pub fn copyFamilyName(self: CTFont) cf.CFString {
    return .fromRef(c.CTFontCopyFamilyName(self.ref));
}

pub fn copyPostScriptName(self: CTFont) cf.CFString {
    return .fromRef(c.CTFontCopyPostScriptName(self.ref));
}

/// Returns an owned set of the font's supported Unicode characters.
pub fn copyCharacterSet(self: CTFont) cf.CFCharacterSet {
    return .fromRef(c.CTFontCopyCharacterSet(self.ref));
}

/// Returns owned table data, or null when the table is absent.
pub fn copyTable(self: CTFont, tag: c.CTFontTableTag, options: c.CTFontTableOptions) ?cf.CFData {
    return .fromRef(c.CTFontCopyTable(self.ref, tag, options) orelse return null);
}

pub fn getSize(self: CTFont) f64 {
    return c.CTFontGetSize(self.ref);
}

pub fn getSymbolicTraits(self: CTFont) SymbolicTraits {
    return @fromBackingInt(c.CTFontGetSymbolicTraits(self.ref));
}

pub fn getUnitsPerEm(self: CTFont) u32 {
    return c.CTFontGetUnitsPerEm(self.ref);
}

pub fn getAscent(self: CTFont) f64 {
    return c.CTFontGetAscent(self.ref);
}

pub fn getDescent(self: CTFont) f64 {
    return c.CTFontGetDescent(self.ref);
}

pub fn getLeading(self: CTFont) f64 {
    return c.CTFontGetLeading(self.ref);
}

pub fn getXHeight(self: CTFont) f64 {
    return c.CTFontGetXHeight(self.ref);
}

pub fn getCapHeight(self: CTFont) f64 {
    return c.CTFontGetCapHeight(self.ref);
}

pub fn getUnderlinePosition(self: CTFont) f64 {
    return c.CTFontGetUnderlinePosition(self.ref);
}

pub fn getUnderlineThickness(self: CTFont) f64 {
    return c.CTFontGetUnderlineThickness(self.ref);
}

test "core_text CTFont: construction, retain and descriptor" {
    const font = blk: {
        const original = try CTFont.initWithName("Helvetica", 16);
        defer original.deinit();
        break :blk CTFont.fromRef(original.ref).retain();
    };
    defer font.deinit();
    try std.testing.expectEqual(CTFont.getTypeID(), c.CFGetTypeID(font.asCFTypeRef()));
    try std.testing.expectEqual(@as(f64, 16), font.getSize());

    const descriptor = font.copyFontDescriptor();
    defer descriptor.deinit();
    const resized = CTFont.initWithDescriptor(descriptor, 24);
    defer resized.deinit();

    try std.testing.expectEqual(@as(f64, 24), resized.getSize());
    const inherited = CTFont.initWithDescriptor(descriptor, 0);
    defer inherited.deinit();
    try std.testing.expectEqual(font.getSize(), inherited.getSize());
    try std.testing.expectError(error.InvalidUtf8, CTFont.initWithName("\xff", 16));
}

test "core_text CTFont: owned names and traits" {
    const font = try CTFont.initWithName("Helvetica-Bold", 16);
    const family = font.copyFamilyName();
    defer family.deinit();
    const postscript = font.copyPostScriptName();
    defer postscript.deinit();
    const traits = font.copyTraits();
    defer traits.deinit();
    const bold = font.getSymbolicTraits().bold;
    font.deinit();

    const family_bytes = try family.toSlice(std.testing.allocator);
    defer std.testing.allocator.free(family_bytes);
    try std.testing.expectEqualStrings("Helvetica", family_bytes);

    const postscript_bytes = try postscript.toSlice(std.testing.allocator);
    defer std.testing.allocator.free(postscript_bytes);
    try std.testing.expectEqualStrings("Helvetica-Bold", postscript_bytes);
    try std.testing.expect(bold);

    const weight = traits.get(cf.CFString.fromRef(c.kCTFontWeightTrait)).?;
    try std.testing.expect(weight.to(f64).? > 0);
}

test "core_text CTFont: metrics, character coverage and tables" {
    const font = try CTFont.initWithName("Helvetica", 16);
    defer font.deinit();
    try std.testing.expect(font.getUnitsPerEm() > 0);
    try std.testing.expect(font.getAscent() > 0);
    try std.testing.expect(font.getDescent() >= 0);
    try std.testing.expect(font.getLeading() >= 0);
    try std.testing.expect(font.getXHeight() > 0);
    try std.testing.expect(font.getCapHeight() >= font.getXHeight());
    try std.testing.expect(font.getUnderlinePosition() < 0);
    try std.testing.expect(font.getUnderlineThickness() > 0);

    const characters = font.copyCharacterSet();
    defer characters.deinit();
    try std.testing.expect(characters.contains('A'));
    const table = font.copyTable(c.kCTFontTableHead, c.kCTFontTableOptionNoOptions).?;
    defer table.deinit();
    const bytes = try table.toSlice(std.testing.allocator);
    defer std.testing.allocator.free(bytes);
    try std.testing.expect(bytes.len > 0);
    try std.testing.expect(font.copyTable(0, c.kCTFontTableOptionNoOptions) == null);
}
