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
const CFRange = cf.range.CFRange;
const CFArray = cf.array.CFArray;
const CFDictionary = cf.dictionary.CFDictionary;
const CFCharacterSet = cf.character_set.CFCharacterSet;
const CFStringEncoding = cf_string.CFStringEncoding;
const cg = @import("../core_graphics.zig");
const CGRect = cg.geometry.CGRect;
const CGAffineTransform = cg.geometry.CGAffineTransform;
const CGSize = cg.geometry.CGSize;
const CGGlyph = cg.types.CGGlyph;
const CGFont = cg.types.CGFont;
const CGPath = cg.types.CGPath;
const CGContext = cg.types.CGContext;
const CGPoint = cg.geometry.CGPoint;
const CFData = cf.data.CFData;
const TableTag = types.TableTag;
const TableOptions = types.TableOptions;

pub const CTFontRef = std.meta.Child(c.CTFontRef);

ref: CTFontRef,

pub fn fromRef(reference: c.CTFontRef) CTFont {
    return .{
        .ref = reference orelse @panic("Attempt to create a null object."),
    };
}

// Creating Fonts

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
    return fromRef(c.CTFontCreateCopyWithAttributes(
        font.ref,
        size,
        null,
        if (attributes) |descriptor| descriptor.ref else null,
    ));
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
        null,
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
        null,
        string,
    ) orelse return null);
}

pub fn initForString(font: CTFont, text: []const u8, range: CFRange) StringError!CTFont {
    const string = try toCFString(text);
    defer cf.release(string);

    return fromRef(c.CTFontCreateForString(font.ref, string, range));
}

pub fn initForStringWithLanguage(
    font: CTFont,
    text: []const u8,
    range: CFRange,
    language: ?[]const u8,
) StringError!CTFont {
    const string = try toCFString(text);
    defer cf.release(string);
    const language_string = if (language) |value| try toCFString(value) else null;
    defer if (language_string) |value| cf.release(value);

    return fromRef(c.CTFontCreateForStringWithLanguage(
        font.ref,
        string,
        range,
        language_string,
    ));
}

// Getting Font Data

pub fn copyFontDescriptor(font: CTFont) CTFontDescriptor {
    return .{
        .ref = c.CTFontCopyFontDescriptor(font.ref) orelse @panic("Attempt to create a null object."),
    };
}

pub fn copyFontAttribute(font: CTFont, attribute: []const u8) StringError!CTFontDescriptor {
    const string = try toCFString(attribute);
    defer cf.release(string);

    return c.CTFontCopyAttribute(font.ref, string);
}

pub fn getSize(font: CTFont) f64 {
    return c.CTFontGetSize(font.ref);
}

pub fn getMatrix(font: CTFont) CGAffineTransform {
    return c.CTFontGetMatrix(font.ref);
}

pub fn getSymbolicTraits(font: CTFont) SymbolicTraits {
    return @fromBackingInt(c.CTFontGetSymbolicTraits(font.ref));
}

pub fn copyTraits(font: CTFont) CFDictionary {
    return c.CTFontCopyTraits(font.ref);
}

pub fn copyDefaultCascadeListForLanguage(font: CTFont, languages: CFArray) CFArray {
    return c.CTFontCopyDefaultCascadeListForLanguages(font.ref, languages);
}

// Getting Font Names

pub fn copyPostScriptName(font: CTFont) CFString {
    return c.CTFontCopyPostScriptName(font.ref);
}

pub fn copyFamilyName(font: CTFont) CFString {
    return c.CTFontCopyFamilyName(font.ref);
}

pub fn copyFullName(font: CTFont) CFString {
    return c.CTFontCopyFullName(font.ref);
}

pub fn copyDisplayName(font: CTFont) CFString {
    return c.CTFontCopyDisplayName(font.ref);
}

pub fn copyName(font: CTFont, name_key: []const u8) StringError!CFString {
    const string = try toCFString(name_key);
    defer cf.release(string);

    return c.CTFontCopyName(font.ref, string);
}

pub fn copyLocalizedName(font: CTFont, name_key: []const u8, actual_language: ?*CFString) StringError!CFString {
    const string = try toCFString(name_key);
    defer cf.release(string);

    return c.CTFontCopyLocalizedName(font.ref, string, actual_language);
}

// Working With Encoding

pub fn copyCharacterSet(font: CTFont) CFCharacterSet {
    return c.CTFontCopyCharacterSet(font.ref);
}

pub fn getStringEncoding(font: CTFont) CFStringEncoding {
    return c.CTFontGetStringEncoding(font.ref);
}

pub fn copySupportedLanguages(font: CTFont) CFArray {
    return c.CTFontCopySupportedLanguages(font.ref);
}

// Getting Font Metrics

pub fn getAscent(font: CTFont) f64 {
    return c.CTFontGetAscent(font.ref);
}

pub fn getDescent(font: CTFont) f64 {
    return c.CTFontGetDescent(font.ref);
}

pub fn getLeading(font: CTFont) f64 {
    return c.CTFontGetLeading(font.ref);
}

pub fn getUnitsPerEm(font: CTFont) u32 {
    return c.CTFontGetUnitsPerEm(font.ref);
}

pub fn getGlyphCount(font: CTFont) CFIndex {
    return c.CTFontGetGlyphCount(font.ref);
}

pub fn getBoundingBox(font: CTFont) CGRect {
    return c.CTFontGetBoundingBox(font.ref);
}

pub fn getUnderlinePosition(font: CTFont) f64 {
    return c.CTFontGetUnderlinePosition(font.ref);
}

pub fn getUnderlineThickness(font: CTFont) f64 {
    return c.CTFontGetUnderlineThickness(font.ref);
}

pub fn getSlantAngle(font: CTFont) f64 {
    return c.CTFontGetSlantAngle(font.ref);
}

pub fn getCapHeight(font: CTFont) f64 {
    return c.CTFontGetCapHeight(font.ref);
}

pub fn getXHeight(font: CTFont) f64 {
    return c.CTFontGetXHeight(font.ref);
}

pub fn createPathForGlyph(font: CTFont, glyph: CGGlyph, matrix: ?*const CGAffineTransform) CGPath {
    return c.CTFontCreatePathForGlyph(font.ref, glyph, matrix);
}

pub fn getGlyphWithName(font: CTFont, name: []const u8) StringError!CGGlyph {
    const string = try toCFString(name);
    defer cf.release(string);

    return c.CTFontGetGlyphWithName(font.ref, string);
}

pub fn copyNameForGlyph(font: CTFont, glyph: CGGlyph) CFString {
    return c.CTFontCopyNameForGlyph(font.ref, glyph);
}

pub fn getBoundingRectsForGlyphs(
    font: CTFont,
    orientation: Orientation,
    glyphs: []const CGGlyph,
    rects: ?[]CGRect,
) CGRect {
    if (rects) |out| std.debug.assert(out.len >= glyphs.len);

    return c.CTFontGetBoundingRectsForGlyphs(
        font.ref,
        @backingInt(orientation),
        glyphs.ptr,
        if (rects) |out| out.ptr else null,
        @intCast(glyphs.len),
    );
}

pub fn getAdvancesForGlyphs(
    font: CTFont,
    orientation: Orientation,
    glyphs: []const CGGlyph,
    advances: ?[]CGSize,
) f64 {
    if (advances) |out| std.debug.assert(out.len >= glyphs.len);

    return c.CTFontGetAdvancesForGlyphs(
        font.ref,
        @backingInt(orientation),
        glyphs.ptr,
        if (advances) |out| out.ptr else null,
        @intCast(glyphs.len),
    );
}

pub fn getOpticalBoundsForGlyphs(font: CTFont, glyphs: []const CGGlyph, rects: ?[]CGRect) CGRect {
    if (rects) |out| std.debug.assert(out.len >= glyphs.len);

    return c.CTFontGetOpticalBoundsForGlyphs(
        font.ref,
        glyphs.ptr,
        if (rects) |out| out.ptr else null,
        @intCast(glyphs.len),
        0,
    );
}

pub fn getVerticalTranslationsForGlyphs(font: CTFont, glyphs: []const CGGlyph, translations: []CGSize) void {
    std.debug.assert(translations.len >= glyphs.len);
    if (glyphs.len == 0) return;
    c.CTFontGetVerticalTranslationsForGlyphs(font.ref, glyphs.ptr, translations.ptr, @intCast(glyphs.len));
}

// Working With Font Variations

pub fn copyVariationAxes(font: CTFont) CFArray {
    return c.CTFontCopyVariationAxes(font.ref);
}

pub fn copyVariation(font: CTFont) CFDictionary {
    return c.CTFontCopyVariation(font.ref);
}

// Getting Font Features

pub fn copyFeatures(font: CTFont) CFArray {
    return c.CTFontCopyFeatures(font.ref);
}

pub fn copyFeatureSettings(font: CTFont) CFArray {
    return c.CTFontCopyFeatureSettings(font.ref);
}

// Working With Glyphs

pub fn getGlyphsForCharacters(font: CTFont, characters: []const u16, glyphs: []CGGlyph) bool {
    std.debug.assert(glyphs.len >= characters.len);
    if (characters.len == 0) return true;

    return c.CTFontGetGlyphsForCharacters(font.ref, characters.ptr, glyphs.ptr, @intCast(characters.len));
}

pub fn drawGlyphs(
    font: CTFont,
    glyphs: []const CGGlyph,
    positions: []const CGPoint,
    context: CGContext,
) void {
    std.debug.assert(positions.len >= glyphs.len);
    if (glyphs.len == 0) return;
    c.CTFontDrawGlyphs(font.ref, glyphs.ptr, positions.ptr, glyphs.len, context);
}

/// Null queries the count; the returned count may exceed the output capacity.
pub fn getLigatureCaretPositions(font: CTFont, glyph: CGGlyph, positions: ?[]f64) CFIndex {
    const count = if (positions) |out| out.len else 0;

    return c.CTFontGetLigatureCaretPositions(
        font.ref,
        glyph,
        if (positions) |out| (if (out.len == 0) null else out.ptr) else null,
        @intCast(count),
    );
}

// Converting Fonts

pub fn copyGraphicsFont(font: CTFont, attributes: ?*?CTFontDescriptor) CGFont {
    var reference: c.CTFontDescriptorRef = null;
    const graphics_font = c.CTFontCopyGraphicsFont(font.ref, if (attributes != null) &reference else null);
    if (attributes) |out| out.* = if (reference) |value| .{ .ref = value } else null;

    return graphics_font;
}

pub fn initWithGraphicsFont(
    graphics_font: CGFont,
    size: f64,
    matrix: ?*const CGAffineTransform,
    attributes: ?CTFontDescriptor,
) CTFont {
    return fromRef(c.CTFontCreateWithGraphicsFont(
        graphics_font,
        size,
        matrix,
        if (attributes) |descriptor| descriptor.ref else null,
    ));
}

// Getting Font Table Data

pub fn copyAvailableTables(font: CTFont, options: TableOptions) CFArray {
    return c.CTFontCopyAvailableTables(font.ref, @backingInt(options));
}

pub fn copyTable(font: CTFont, tag: TableTag, options: TableOptions) CFData {
    return c.CTFontCopyTable(font.ref, tag, @backingInt(options));
}

pub fn hasTable(font: CTFont, tag: TableTag) bool {
    return c.CTFontHasTable(font.ref, tag);
}

// Getting Font Identifiers

pub fn getTypeID() cf.CFTypeID {
    return c.CTFontGetTypeID();
}

pub fn getUiFontType(font: CTFont) UiFontType {
    return @fromBackingInt(c.CTFontGetUIFontType(font.ref));
}

// Adaptive Images

pub fn getTypographicBoundsForAdaptiveImageProvider(font: CTFont, provider: cf.CFType) CGRect {
    return c.CTFontGetTypographicBoundsForAdaptiveImageProvider(font.ref, provider);
}

pub fn drawImageFromAdaptiveImageProviderAtPoint(
    font: CTFont,
    provider: cf.CFType,
    point: CGPoint,
    context: CGContext,
) void {
    c.CTFontDrawImageFromAdaptiveImageProviderAtPoint(font.ref, provider, point, context);
}

test "core_text CTFont: constructors" {
    const f = try CTFont.initWithName("Helvetica", 16.0);
    defer cf.release(f.ref);

    const font = try initWithNameAndOptions("Helvetica", 16, .{ .prevent_auto_activation = true });
    defer cf.release(font.ref);
    const descriptor = font.copyFontDescriptor();
    defer cf.release(descriptor.ref);

    const described = initWithDescriptor(descriptor, 20);
    defer cf.release(described.ref);
    try std.testing.expectEqual(@as(f64, 20), described.getSize());
    const with_options = initWithDescriptorAndOptions(descriptor, 24, .{});
    defer cf.release(with_options.ref);
    try std.testing.expectEqual(@as(f64, 24), with_options.getSize());

    const resized = initCopyWithAttributes(font, 32, null);
    defer cf.release(resized.ref);
    try std.testing.expectEqual(@as(f64, 32), resized.getSize());
    const with_attributes = initCopyWithAttributes(font, 0, descriptor);
    defer cf.release(with_attributes.ref);
    try std.testing.expectEqual(font.getSize(), with_attributes.getSize());

    const bold = initCopyWithSymbolicTraits(font, 0, .{ .bold = true }, .{ .bold = true });
    defer cf.release(bold.ref);
    try std.testing.expect(bold.getSymbolicTraits().bold);
    const family = (try initCopyWithFamily(font, 18, "Helvetica")) orelse return error.NoFont;
    defer cf.release(family.ref);
    try std.testing.expectEqual(@as(f64, 18), family.getSize());

    const ui_font = try initUiFontForLanguage(.system, 14, "en");
    defer cf.release(ui_font.ref);
    try std.testing.expectEqual(@as(f64, 14), ui_font.getSize());
    const default_ui_font = try initUiFontForLanguage(.system, 14, null);
    defer cf.release(default_ui_font.ref);
    try std.testing.expectEqual(@as(f64, 14), default_ui_font.getSize());
}
