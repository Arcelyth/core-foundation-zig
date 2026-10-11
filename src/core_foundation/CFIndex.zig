const std = @import("std");
const c = @import("c");

pub const CFIndex = c.CFIndex;

pub fn fromUsize(value: usize) error{InputTooLong}!CFIndex {
    return std.math.cast(CFIndex, value) orelse error.InputTooLong;
}

/// Negative indices, including kCFNotFound, have no usize representation.
pub fn toUsize(value: CFIndex) ?usize {
    return std.math.cast(usize, value);
}
