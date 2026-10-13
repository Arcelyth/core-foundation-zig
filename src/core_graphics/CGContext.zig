const CGContext = @This();
const std = @import("std");
const c = @import("c");
const CGColorSpace = @import("CGColorSpace.zig");
const geometry = @import("geometry.zig");

ref: c.CGContextRef,

/// Borrows data for the context's lifetime; null lets Core Graphics allocate it.
pub fn initBitmap(
    data: ?[]u8,
    width: usize,
    height: usize,
    bits_per_component: usize,
    bytes_per_row: usize,
    space: ?CGColorSpace,
    bitmap_info: c.CGBitmapInfo,
) error{ Overflow, BufferTooSmall, CreateFailed }!CGContext {
    if (data) |bytes| {
        if (bytes.len < try std.math.mul(usize, bytes_per_row, height))
            return error.BufferTooSmall;
    }

    return .{
        .ref = c.CGBitmapContextCreate(
            if (data) |bytes| bytes.ptr else null,
            width,
            height,
            bits_per_component,
            bytes_per_row,
            if (space) |value| value.ref else null,
            bitmap_info,
        ) orelse return error.CreateFailed,
    };
}

pub fn deinit(self: CGContext) void {
    c.CGContextRelease(self.ref);
}

pub fn clipToRect(self: CGContext, rect: geometry.CGRect) void {
    c.CGContextClipToRect(self.ref, rect);
}

pub fn translateCTM(self: CGContext, x: f64, y: f64) void {
    c.CGContextTranslateCTM(self.ref, x, y);
}

pub fn scaleCTM(self: CGContext, x: f64, y: f64) void {
    c.CGContextScaleCTM(self.ref, x, y);
}

pub fn setRGBFillColor(self: CGContext, red: f64, green: f64, blue: f64, alpha: f64) void {
    c.CGContextSetRGBFillColor(self.ref, red, green, blue, alpha);
}

pub fn setAlpha(self: CGContext, alpha: f64) void {
    c.CGContextSetAlpha(self.ref, alpha);
}

pub fn setShouldSmoothFonts(self: CGContext, smooth: bool) void {
    c.CGContextSetShouldSmoothFonts(self.ref, smooth);
}
