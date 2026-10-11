const std = @import("std");
const c = @import("c");

pub const CGFloat = f64;
pub const CGGlyph = c.CGGlyph;
pub const CGFont = std.meta.Child(c.CGFontRef);
pub const CGPath = std.meta.Child(c.CGPathRef);
pub const CGContext = std.meta.Child(c.CGContextRef);
