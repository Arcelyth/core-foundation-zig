const std = @import("std");
const c = @import("c");
const CFAllocator = std.meta.Child(c.CFAllocatorRef);
const CFIndex = @import("index.zig").CFIndex;

pub const CFNumber = std.meta.Child(c.CFNumberRef);
pub const CFNumberType = c.CFNumberType;

pub fn getTypeID() usize {
    return c.CFNumberGetTypeID();
}

/// The value pointer must point to the numeric type specified by number_type.
pub fn create(allocator: ?CFAllocator, number_type: CFNumberType, value: *const anyopaque) error{OutOfMemory}!CFNumber {
    return c.CFNumberCreate(allocator, number_type, value) orelse error.OutOfMemory;
}

/// Returns the storage type, which can differ from the type used at creation.
pub fn getType(number: CFNumber) CFNumberType {
    return c.CFNumberGetType(number);
}

pub fn getByteSize(number: CFNumber) CFIndex {
    return c.CFNumberGetByteSize(number);
}

pub fn isFloatType(number: CFNumber) bool {
    return c.CFNumberIsFloatType(number) != 0;
}

/// The output must match number_type. Returns the native conversion status, which can be false after writing an approximate value.
pub fn getValue(number: CFNumber, number_type: CFNumberType, value: *anyopaque) bool {
    return c.CFNumberGetValue(number, number_type, value) != 0;
}

pub fn compare(number: CFNumber, other: CFNumber, context: ?*anyopaque) c.CFComparisonResult {
    return c.CFNumberCompare(number, other, context);
}

test "core_foundation number: integer creation and storage" {
    const value: i64 = std.math.maxInt(i64);
    const number = try create(null, c.kCFNumberSInt64Type, &value);
    defer c.CFRelease(number);

    try std.testing.expectEqual(getTypeID(), c.CFGetTypeID(number));
    try std.testing.expect(!isFloatType(number));
    try std.testing.expectEqual(@as(CFIndex, @sizeOf(i64)), getByteSize(number));

    var result: i64 = 0;
    try std.testing.expect(getValue(number, c.kCFNumberSInt64Type, &result));
    try std.testing.expectEqual(value, result);

    var storage: [@sizeOf(i64)]u8 align(@alignOf(i64)) = undefined;
    try std.testing.expect(getValue(number, getType(number), &storage));
    const copy = try create(null, getType(number), &storage);
    defer c.CFRelease(copy);
    try std.testing.expectEqual(c.kCFCompareEqualTo, compare(number, copy, null));
}
