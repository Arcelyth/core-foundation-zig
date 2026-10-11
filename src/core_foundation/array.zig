const std = @import("std");
const c = @import("c");
const CFAllocator = std.meta.Child(c.CFAllocatorRef);
const CFIndex = @import("index.zig").CFIndex;
const toCFIndex = @import("index.zig").toCFIndex;
const CFRange = @import("range.zig").CFRange;

pub const CFArray = std.meta.Child(c.CFArrayRef);
pub const CFMutableArray = std.meta.Child(c.CFMutableArrayRef);
pub const CallBacks = c.CFArrayCallBacks;
pub const ApplierFunction = std.meta.Child(c.CFArrayApplierFunction);
pub const ComparatorFunction = std.meta.Child(c.CFComparatorFunction);

pub fn getTypeID() usize {
    return c.CFArrayGetTypeID();
}

pub fn create(
    allocator: ?CFAllocator,
    values: []const ?*const anyopaque,
    callbacks: ?*const CallBacks,
) error{ InputTooLong, OutOfMemory }!CFArray {
    return c.CFArrayCreate(
        allocator,
        if (values.len == 0) null else @constCast(values.ptr),
        try toCFIndex(values.len),
        callbacks,
    ) orelse error.OutOfMemory;
}

pub fn createCopy(allocator: ?CFAllocator, array: CFArray) error{OutOfMemory}!CFArray {
    return c.CFArrayCreateCopy(allocator, array) orelse error.OutOfMemory;
}

pub fn createMutable(
    allocator: ?CFAllocator,
    capacity: usize,
    callbacks: ?*const CallBacks,
) error{ InputTooLong, OutOfMemory }!CFMutableArray {
    return c.CFArrayCreateMutable(allocator, try toCFIndex(capacity), callbacks) orelse error.OutOfMemory;
}

pub fn createMutableCopy(
    allocator: ?CFAllocator,
    capacity: usize,
    array: CFArray,
) error{ InputTooLong, OutOfMemory }!CFMutableArray {
    return c.CFArrayCreateMutableCopy(allocator, try toCFIndex(capacity), array) orelse error.OutOfMemory;
}

pub fn bSearchValues(
    array: CFArray,
    range: CFRange,
    value: ?*const anyopaque,
    comparator: ComparatorFunction,
    context: ?*anyopaque,
) CFIndex {
    return c.CFArrayBSearchValues(
        array,
        range,
        value,
        comparator,
        context,
    );
}

pub fn containsValue(array: CFArray, range: CFRange, value: ?*const anyopaque) bool {
    return c.CFArrayContainsValue(array, range, value) != 0;
}

pub fn getCount(array: CFArray) CFIndex {
    return c.CFArrayGetCount(array);
}

pub fn getCountOfValue(array: CFArray, range: CFRange, value: ?*const anyopaque) CFIndex {
    return c.CFArrayGetCountOfValue(array, range, value);
}

/// Returns null when no value matches.
pub fn getFirstIndexOfValue(array: CFArray, range: CFRange, value: ?*const anyopaque) ?CFIndex {
    const res = c.CFArrayGetFirstIndexOfValue(array, range, value);
    if (res == -1) return null else return res;
}

/// Returns null when no value matches.
pub fn getLastIndexOfValue(array: CFArray, range: CFRange, value: ?*const anyopaque) ?CFIndex {
    const res = c.CFArrayGetLastIndexOfValue(array, range, value);
    if (res == -1) return null else return res;
}

pub fn getValueAtIndex(array: CFArray, index: CFIndex) ?*const anyopaque {
    return c.CFArrayGetValueAtIndex(array, index);
}

pub fn getValues(array: CFArray, range: CFRange, values: []?*const anyopaque) void {
    std.debug.assert(range.length >= 0);
    std.debug.assert(@as(usize, @intCast(range.length)) <= values.len);
    if (range.length == 0) return;
    c.CFArrayGetValues(array, range, values.ptr);
}

pub fn applyFunction(array: CFArray, range: CFRange, applier: ApplierFunction, context: ?*anyopaque) void {
    c.CFArrayApplyFunction(array, range, applier, context);
}

pub fn appendValue(array: CFMutableArray, value: ?*const anyopaque) void {
    c.CFArrayAppendValue(array, value);
}

pub fn insertValueAtIndex(array: CFMutableArray, index: CFIndex, value: ?*const anyopaque) void {
    c.CFArrayInsertValueAtIndex(array, index, value);
}

pub fn setValueAtIndex(array: CFMutableArray, index: CFIndex, value: ?*const anyopaque) void {
    c.CFArraySetValueAtIndex(array, index, value);
}

pub fn removeValueAtIndex(array: CFMutableArray, index: CFIndex) void {
    c.CFArrayRemoveValueAtIndex(array, index);
}

pub fn removeAllValues(array: CFMutableArray) void {
    c.CFArrayRemoveAllValues(array);
}

pub fn replaceValues(array: CFMutableArray, range: CFRange, values: []const ?*const anyopaque) error{InputTooLong}!void {
    c.CFArrayReplaceValues(
        array,
        range,
        if (values.len == 0) null else @constCast(values.ptr),
        try toCFIndex(values.len),
    );
}

pub fn exchangeValuesAtIndices(array: CFMutableArray, first: CFIndex, second: CFIndex) void {
    c.CFArrayExchangeValuesAtIndices(array, first, second);
}

pub fn sortValues(array: CFMutableArray, range: CFRange, comparator: ComparatorFunction, context: ?*anyopaque) void {
    c.CFArraySortValues(array, range, comparator, context);
}

pub fn appendArray(array: CFMutableArray, other: CFArray, range: CFRange) void {
    c.CFArrayAppendArray(array, other, range);
}
