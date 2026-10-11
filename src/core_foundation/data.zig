const std = @import("std");
const c = @import("c");
const CFAllocator = std.meta.Child(c.CFAllocatorRef);
const CFIndex = @import("index.zig").CFIndex;
const toCFIndex = @import("index.zig").toCFIndex;
const CFRange = @import("range.zig").CFRange;

pub const CFData = std.meta.Child(c.CFDataRef);
pub const CFMutableData = std.meta.Child(c.CFMutableDataRef);
pub const SearchFlags = c.CFDataSearchFlags;

pub fn getTypeID() usize {
    return c.CFDataGetTypeID();
}

pub fn create(allocator: ?CFAllocator, bytes: []const u8) error{ InputTooLong, OutOfMemory }!CFData {
    return c.CFDataCreate(allocator, bytes.ptr, try toCFIndex(bytes.len)) orelse error.OutOfMemory;
}

/// A null deallocator uses the default allocator to free the bytes.
pub fn createWithBytesNoCopy(
    allocator: ?CFAllocator,
    bytes: []const u8,
    bytes_deallocator: ?CFAllocator,
) error{ InputTooLong, OutOfMemory }!CFData {
    return c.CFDataCreateWithBytesNoCopy(
        allocator,
        bytes.ptr,
        try toCFIndex(bytes.len),
        bytes_deallocator,
    ) orelse error.OutOfMemory;
}

pub fn createCopy(allocator: ?CFAllocator, data: CFData) error{OutOfMemory}!CFData {
    return c.CFDataCreateCopy(allocator, data) orelse error.OutOfMemory;
}

pub fn createMutable(allocator: ?CFAllocator, capacity: usize) error{ InputTooLong, OutOfMemory }!CFMutableData {
    return c.CFDataCreateMutable(allocator, try toCFIndex(capacity)) orelse error.OutOfMemory;
}

pub fn createMutableCopy(allocator: ?CFAllocator, capacity: usize, data: CFData) error{ InputTooLong, OutOfMemory }!CFMutableData {
    return c.CFDataCreateMutableCopy(allocator, try toCFIndex(capacity), data) orelse error.OutOfMemory;
}

pub fn getLength(data: CFData) CFIndex {
    return c.CFDataGetLength(data);
}

pub fn getBytePtr(data: CFData) ?[*]const u8 {
    return c.CFDataGetBytePtr(data);
}

pub fn getMutableBytePtr(data: CFMutableData) ?[*]u8 {
    return c.CFDataGetMutableBytePtr(data);
}

pub fn getBytes(data: CFData, range: CFRange, buffer: []u8) void {
    std.debug.assert(range.length >= 0);
    std.debug.assert(@as(usize, @intCast(range.length)) <= buffer.len);
    if (range.length == 0) return;
    c.CFDataGetBytes(data, range, buffer.ptr);
}

pub fn setLength(data: CFMutableData, length: usize) error{InputTooLong}!void {
    c.CFDataSetLength(data, try toCFIndex(length));
}

pub fn increaseLength(data: CFMutableData, extra_length: usize) error{InputTooLong}!void {
    c.CFDataIncreaseLength(data, try toCFIndex(extra_length));
}

pub fn appendBytes(data: CFMutableData, bytes: []const u8) error{InputTooLong}!void {
    c.CFDataAppendBytes(data, bytes.ptr, try toCFIndex(bytes.len));
}

pub fn replaceBytes(data: CFMutableData, range: CFRange, bytes: []const u8) error{InputTooLong}!void {
    c.CFDataReplaceBytes(data, range, bytes.ptr, try toCFIndex(bytes.len));
}

pub fn deleteBytes(data: CFMutableData, range: CFRange) void {
    c.CFDataDeleteBytes(data, range);
}

/// The returned range has location raw.kCFNotFound when there is no match.
pub fn find(data: CFData, needle: CFData, range: CFRange, options: SearchFlags) CFRange {
    return c.CFDataFind(data, needle, range, options);
}
