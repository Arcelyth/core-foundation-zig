const CTLine = @This();

const c = @import("c");
const cf = @import("../core_foundation.zig");
const CFAttributedString = cf.CFAttributeString;
const CTRun = @import("CTRun.zig");

ref: c.CTLineRef,

pub fn fromRef(ref: c.CTLineRef) CTLine {
    return .{ .ref = ref };
}

pub fn asCFTypeRef(self: CTLine) c.CFTypeRef {
    return @ptrCast(self.ref);
}

pub fn retain(self: CTLine) CTLine {
    _ = c.CFRetain(self.asCFTypeRef());
    return self;
}

pub fn deinit(self: CTLine) void {
    c.CFRelease(self.asCFTypeRef());
}

pub fn getTypeID() c.CFTypeID {
    return c.CTLineGetTypeID();
}

pub fn init(string: CFAttributedString) CTLine {
    return .fromRef(c.CTLineCreateWithAttributedString(string.ref));
}

pub fn getGlyphCount(self: CTLine) usize {
    return @intCast(c.CTLineGetGlyphCount(self.ref));
}

/// Returns a borrowed array. Retain it before keeping it beyond the line's lifetime.
pub fn getGlyphRuns(self: CTLine) cf.CFArray(CTRun) {
    return .fromRef(c.CTLineGetGlyphRuns(self.ref));
}

/// Returns the source range in UTF-16 code units, not UTF-8 bytes.
pub fn getStringRange(self: CTLine) cf.CFRange.CFRange {
    return c.CTLineGetStringRange(self.ref);
}

/// Returns the typographic width and optionally writes ascent, descent and leading.
pub fn getTypographicBounds(self: CTLine, ascent: ?*f64, descent: ?*f64, leading: ?*f64) f64 {
    return c.CTLineGetTypographicBounds(
        self.ref,
        ascent,
        descent,
        leading,
    );
}
