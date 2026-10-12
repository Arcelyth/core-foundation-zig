const CTRun = @This();

const std = @import("std");
const c = @import("c");
const cf = @import("../core_foundation.zig");
const cg = @import("../core_graphics.zig");

pub const Attributes = cf.CFDictionary(cf.CFString, c.CFTypeRef);

ref: c.CTRunRef,

pub fn fromRef(ref: c.CTRunRef) CTRun {
    return .{ .ref = ref };
}

pub fn asCFTypeRef(self: CTRun) c.CFTypeRef {
    return @ptrCast(self.ref);
}

pub fn retain(self: CTRun) CTRun {
    _ = c.CFRetain(self.asCFTypeRef());
    return self;
}

pub fn deinit(self: CTRun) void {
    c.CFRelease(self.asCFTypeRef());
}

pub fn getTypeID() c.CFTypeID {
    return c.CTRunGetTypeID();
}

pub fn getGlyphCount(self: CTRun) usize {
    return @intCast(c.CTRunGetGlyphCount(self.ref));
}

/// Returns borrowed attributes, including the actual font used after substitution.
/// Retain the dictionary before keeping it beyond the run's lifetime.
pub fn getAttributes(self: CTRun) Attributes {
    return .fromRef(c.CTRunGetAttributes(self.ref));
}

pub fn getStatus(self: CTRun) c.CTRunStatus {
    return c.CTRunGetStatus(self.ref);
}

pub fn getGlyphs(self: CTRun, allocator: std.mem.Allocator) error{OutOfMemory}![]cg.types.CGGlyph {
    const values = try allocator.alloc(cg.types.CGGlyph, self.getGlyphCount());
    if (values.len != 0) c.CTRunGetGlyphs(
        self.ref,
        .{ .location = 0, .length = 0 },
        values.ptr,
    );

    return values;
}

pub fn getPositions(self: CTRun, allocator: std.mem.Allocator) error{OutOfMemory}![]cg.geometry.CGPoint {
    const values = try allocator.alloc(cg.geometry.CGPoint, self.getGlyphCount());
    if (values.len != 0) c.CTRunGetPositions(
        self.ref,
        .{ .location = 0, .length = 0 },
        values.ptr,
    );

    return values;
}

pub fn getAdvances(self: CTRun, allocator: std.mem.Allocator) error{OutOfMemory}![]cg.geometry.CGSize {
    const values = try allocator.alloc(cg.geometry.CGSize, self.getGlyphCount());
    if (values.len != 0) c.CTRunGetAdvances(
        self.ref,
        .{ .location = 0, .length = 0 },
        values.ptr,
    );

    return values;
}

pub fn getStringIndices(self: CTRun, allocator: std.mem.Allocator) error{OutOfMemory}![]cf.CFIndex.CFIndex {
    const values = try allocator.alloc(c.CFIndex, self.getGlyphCount());
    if (values.len != 0) c.CTRunGetStringIndices(
        self.ref,
        .{ .location = 0, .length = 0 },
        values.ptr,
    );

    return values;
}

/// Returns the source range in UTF-16 code units.
pub fn getStringRange(self: CTRun) cf.CFRange.CFRange {
    return c.CTRunGetStringRange(self.ref);
}

/// Returns the text matrix needed to draw the run.
pub fn getTextMatrix(self: CTRun) cg.geometry.CGAffineTransform {
    return c.CTRunGetTextMatrix(self.ref);
}
