const CTFont = @This();
const std = @import("std");
const c = @import("c");
const types = @import("types.zig");
const Options = types.Options;
const Orientation = types.Orientation;
const UiFontType = types.UiFontType;
const SymbolicTraits = types.SymbolicTraits;
const CTFontDescriptor = @import("CTFontDescriptor.zig");
const cf = @import("../core_foundation.zig");
const cf_string = cf.string;
const CFString = cf_string.CFString;
const StringError = cf_string.StringError;
const toCFString = cf_string.toCFString;
const cf_index = cf.index;
const CFIndex = cf_index.CFIndex;
const toCFIndex = cf_index.toCFIndex;

pub const CTFontRef = std.meta.Child(c.CTFontRef);

ref: CTFontRef,

pub fn fromRef(reference: c.CTFontRef) CTFont {
    return .{
        .ref = reference orelse @panic("Attempt to create a null object."),
    };
}

pub fn initWithName(name: []const u8, size: f64) StringError!CTFont {
    const string = try toCFString(name);
    defer cf.release(string);

    return fromRef(c.CTFontCreateWithName(
        string,
        size,
        null,
    ));
}

pub fn initWithNameAndOptions(name: []const u8, size: f64, options: Options) StringError!CTFont {
    const string = try toCFString(name);
    defer cf.release(string);

    return fromRef(c.CTFontCreateWithNameAndOptions(
        string,
        size,
        null,
        @backingInt(options),
    ));
}

pub fn initWithDescriptor(desc: CTFontDescriptor, size: f64) CTFont {
    return fromRef(c.CTFontCreateWithFontDescriptor(desc.ref, size, null));
}

pub fn initWithDescriptorAndOptions(desc: CTFontDescriptor, size: f64, options: Options) CTFont {
    return fromRef(c.CTFontCreateWithFontDescriptorAndOptions(
        desc.ref,
        size,
        null,
        @backingInt(options),
    ));
}

pub fn initUiFontForLanguage(ui_type: UiFontType, size: f64, language: ?[]const u8) StringError!CTFont {
    const string = if (language) |value| try toCFString(value) else null;
    defer if (string) |value| cf.release(value);

    return fromRef(c.CTFontCreateUIFontForLanguage(@backingInt(ui_type), size, string));
}

pub fn initCopyWithAttributes(font: CTFont, size: f64, attributes: ?CTFontDescriptor) CTFont {
    return fromRef(c.CTFontCreateCopyWithAttributes(font.ref, size, attributes));
}

pub fn initCopyWithSymbolicTraits(
    font: CTFont,
    size: f64,
    sym_trait_value: SymbolicTraits,
    sym_trait_mask: SymbolicTraits,
) CTFont {
    return fromRef(c.CTFontCreateCopyWithSymbolicTraits(
        font.ref,
        size,
        @backingInt(sym_trait_value),
        @backingInt(sym_trait_mask),
    ));
}

pub fn initCopyWithFamily(
    font: CTFont,
    size: f64,
    family: []const u8,
) StringError!?CTFont {
    const string = try toCFString(family);
    defer cf.release(string);

    return fromRef(c.CTFontCreateCopyWithFamily(
        font.ref,
        size,
        string,
    ) orelse return null);
}

// TODO: need core foundation
pub fn initForString() void {}
pub fn initForStringWithLanguage() void {}

pub fn copyFontDescriptor(font: CTFont) CTFontDescriptor {
    return c.CTFontCopyFontDescriptor(font.ref);
}

pub fn copyFontAttribute(font: CTFont, attribute: []const u8) CTFontDescriptor {
    const string = try toCFString(attribute);
    defer cf.release(string);

    return c.CTFontCopyAttribute(font.ref, string);
}

pub fn getSize(font: CTFont) f64 {
    return c.CTFontGetSize(font.ref);
}

// TODO: need core foundation
pub fn getMatrix() void {}

pub fn getSymbolicTraits(font: CTFont) SymbolicTraits {
    return c.CTFontGetSymbolicTraits(font.ref);
}

// TODO: need core foundation
pub fn copyTraits() void {}
pub fn copyDefaultCascadeListForLanguage() void {}

test "core_text CTFont: initial with name" {
    const font = try CTFont.initWithName("Helvetica", 16.0);
    defer cf.release(font.ref);

    try std.testing.expect(c.CTFontGetSize(font.ref) == 16.0);
    try std.testing.expect(c.CTFontGetAscent(font.ref) > 0.0);
    try std.testing.expect(c.CTFontGetDescent(font.ref) >= 0.0);
}
