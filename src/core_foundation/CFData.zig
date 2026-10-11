const CFData = @This();

const std = @import("std");
const c = @import("c");
const index = @import("CFIndex.zig");

ref: c.CFDataRef,

pub fn fromRef(ref: c.CFDataRef) CFData {
    return .{ .ref = ref };
}

pub fn asCFTypeRef(self: CFData) c.CFTypeRef {
    return @ptrCast(self.ref);
}

pub fn retain(self: CFData) CFData {
    _ = c.CFRetain(self.asCFTypeRef());
    return self;
}

pub fn deinit(self: CFData) void {
    c.CFRelease(self.asCFTypeRef());
}

pub fn getTypeID() c.CFTypeID {
    return c.CFDataGetTypeID();
}

pub fn init(bytes: []const u8) error{ InputTooLong, OutOfMemory }!CFData {
    const ref = c.CFDataCreate(
        c.kCFAllocatorDefault,
        bytes.ptr,
        try index.fromUsize(bytes.len),
    ) orelse return error.OutOfMemory;

    return .{ .ref = ref };
}

pub fn len(self: CFData) usize {
    return @intCast(c.CFDataGetLength(self.ref));
}

pub fn toSlice(self: CFData, allocator: std.mem.Allocator) error{OutOfMemory}![]u8 {
    const bytes = try allocator.alloc(u8, self.len());
    if (bytes.len != 0)
        c.CFDataGetBytes(
            self.ref,
            .{ .location = 0, .length = @intCast(bytes.len) },
            bytes.ptr,
        );
    return bytes;
}

test "core_foundation CFData: copied input and owned output" {
    const bytes = blk: {
        var input = [_]u8{ 0, 1, 0xff, 0 };
        const data = try CFData.init(&input);
        defer data.deinit();
        input[1] = 42;
        try std.testing.expectEqual(@as(usize, 4), data.len());
        break :blk try data.toSlice(std.testing.allocator);
    };
    defer std.testing.allocator.free(bytes);

    try std.testing.expectEqualSlices(u8, &.{ 0, 1, 0xff, 0 }, bytes);
}
