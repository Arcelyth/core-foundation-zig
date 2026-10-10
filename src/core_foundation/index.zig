const std = @import("std");
const c = @import("c");

pub const CFIndex = c.CFIndex;

pub fn toCFIndex(length: usize) error{InputTooLong}!CFIndex {
    return std.math.cast(c.CFIndex, length) orelse error.InputTooLong;
}
