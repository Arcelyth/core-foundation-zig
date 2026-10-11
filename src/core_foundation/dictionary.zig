const std = @import("std");
const c = @import("c");
const CFAllocator = std.meta.Child(c.CFAllocatorRef);
const CFIndex = @import("index.zig").CFIndex;
const toCFIndex = @import("index.zig").toCFIndex;

pub const CFDictionary = std.meta.Child(c.CFDictionaryRef);
pub const CFMutableDictionary = std.meta.Child(c.CFMutableDictionaryRef);
pub const KeyCallBacks = c.CFDictionaryKeyCallBacks;
pub const ValueCallBacks = c.CFDictionaryValueCallBacks;
pub const ApplierFunction = std.meta.Child(c.CFDictionaryApplierFunction);

pub fn getTypeID() usize {
    return c.CFDictionaryGetTypeID();
}

pub fn create(
    allocator: ?CFAllocator,
    keys: []const ?*const anyopaque,
    values: []const ?*const anyopaque,
    key_callbacks: ?*const KeyCallBacks,
    value_callbacks: ?*const ValueCallBacks,
) error{ InputTooLong, OutOfMemory }!CFDictionary {
    std.debug.assert(keys.len == values.len);
    return c.CFDictionaryCreate(
        allocator,
        if (keys.len == 0) null else @constCast(keys.ptr),
        if (values.len == 0) null else @constCast(values.ptr),
        try toCFIndex(keys.len),
        key_callbacks,
        value_callbacks,
    ) orelse error.OutOfMemory;
}

pub fn createCopy(allocator: ?CFAllocator, dictionary: CFDictionary) error{OutOfMemory}!CFDictionary {
    return c.CFDictionaryCreateCopy(allocator, dictionary) orelse error.OutOfMemory;
}

pub fn createMutable(
    allocator: ?CFAllocator,
    capacity: usize,
    key_callbacks: ?*const KeyCallBacks,
    value_callbacks: ?*const ValueCallBacks,
) error{ InputTooLong, OutOfMemory }!CFMutableDictionary {
    return c.CFDictionaryCreateMutable(allocator, try toCFIndex(capacity), key_callbacks, value_callbacks) orelse error.OutOfMemory;
}

pub fn createMutableCopy(allocator: ?CFAllocator, capacity: usize, dictionary: CFDictionary) error{ InputTooLong, OutOfMemory }!CFMutableDictionary {
    return c.CFDictionaryCreateMutableCopy(allocator, try toCFIndex(capacity), dictionary) orelse error.OutOfMemory;
}

pub fn getCount(dictionary: CFDictionary) CFIndex {
    return c.CFDictionaryGetCount(dictionary);
}

pub fn getCountOfKey(dictionary: CFDictionary, key: ?*const anyopaque) CFIndex {
    return c.CFDictionaryGetCountOfKey(dictionary, key);
}

pub fn getCountOfValue(dictionary: CFDictionary, value: ?*const anyopaque) CFIndex {
    return c.CFDictionaryGetCountOfValue(dictionary, value);
}

pub fn containsKey(dictionary: CFDictionary, key: ?*const anyopaque) bool {
    return c.CFDictionaryContainsKey(dictionary, key) != 0;
}

pub fn containsValue(dictionary: CFDictionary, value: ?*const anyopaque) bool {
    return c.CFDictionaryContainsValue(dictionary, value) != 0;
}

/// Returns null for a missing key or a stored null value.
pub fn getValue(dictionary: CFDictionary, key: ?*const anyopaque) ?*const anyopaque {
    return c.CFDictionaryGetValue(dictionary, key);
}

/// Distinguishes a missing key from a stored null. The output pointer is optional.
pub fn getValueIfPresent(dictionary: CFDictionary, key: ?*const anyopaque, value: ?*?*const anyopaque) bool {
    return c.CFDictionaryGetValueIfPresent(dictionary, key, value) != 0;
}

/// Each supplied buffer must hold getCount() entries. Pair order is unspecified.
pub fn getKeysAndValues(dictionary: CFDictionary, keys: ?[]?*const anyopaque, values: ?[]?*const anyopaque) void {
    const count: usize = @intCast(getCount(dictionary));
    if (keys) |buffer| std.debug.assert(buffer.len >= count);
    if (values) |buffer| std.debug.assert(buffer.len >= count);
    if (count == 0) return;
    c.CFDictionaryGetKeysAndValues(
        dictionary,
        if (keys) |buffer| buffer.ptr else null,
        if (values) |buffer| buffer.ptr else null,
    );
}

pub fn applyFunction(dictionary: CFDictionary, applier: ApplierFunction, context: ?*anyopaque) void {
    c.CFDictionaryApplyFunction(dictionary, applier, context);
}

/// Adds a pair only when the key is absent.
pub fn addValue(dictionary: CFMutableDictionary, key: ?*const anyopaque, value: ?*const anyopaque) void {
    c.CFDictionaryAddValue(dictionary, key, value);
}

/// Adds a pair or replaces the value of an existing key.
pub fn setValue(dictionary: CFMutableDictionary, key: ?*const anyopaque, value: ?*const anyopaque) void {
    c.CFDictionarySetValue(dictionary, key, value);
}

/// Replaces the value only when the key is present.
pub fn replaceValue(dictionary: CFMutableDictionary, key: ?*const anyopaque, value: ?*const anyopaque) void {
    c.CFDictionaryReplaceValue(dictionary, key, value);
}

pub fn removeValue(dictionary: CFMutableDictionary, key: ?*const anyopaque) void {
    c.CFDictionaryRemoveValue(dictionary, key);
}

pub fn removeAllValues(dictionary: CFMutableDictionary) void {
    c.CFDictionaryRemoveAllValues(dictionary);
}
