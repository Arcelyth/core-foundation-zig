const std = @import("std");
const c = @import("c");
const toCFIndex = @import("CFIndex.zig").fromUsize;

/// An array of CF wrappers.
pub fn CFArray(comptime T: type) type {
    return struct {
        const Self = @This();

        ref: c.CFArrayRef,

        pub fn fromRef(ref: c.CFArrayRef) Self {
            return .{ .ref = ref };
        }

        pub fn asCFTypeRef(self: Self) c.CFTypeRef {
            return @ptrCast(self.ref);
        }

        pub fn retain(self: Self) Self {
            _ = c.CFRetain(self.asCFTypeRef());
            return self;
        }

        pub fn deinit(self: Self) void {
            c.CFRelease(self.asCFTypeRef());
        }

        pub fn getTypeID() c.CFTypeID {
            return c.CFArrayGetTypeID();
        }

        /// Creates an owned array that retains each CF object.
        pub fn init(values: []const T) error{ InputTooLong, OutOfMemory }!Self {
            const temporary = c.CFArrayCreateMutable(
                c.kCFAllocatorDefault,
                try toCFIndex(values.len),
                &c.kCFTypeArrayCallBacks,
            ) orelse return error.OutOfMemory;
            defer c.CFRelease(temporary);

            for (values) |value| c.CFArrayAppendValue(temporary, @ptrCast(value.ref));
            const ref = c.CFArrayCreateCopy(c.kCFAllocatorDefault, temporary) orelse return error.OutOfMemory;
            return .{ .ref = ref };
        }

        pub fn len(self: Self) usize {
            return @intCast(c.CFArrayGetCount(self.ref));
        }

        /// Returns a borrowed element, or null when index is out of bounds.
        /// Retain the element before keeping it beyond the array's lifetime.
        pub fn get(self: Self, index: usize) ?T {
            if (index >= self.len()) return null;
            const value = c.CFArrayGetValueAtIndex(self.ref, @intCast(index));
            return T.fromRef(@ptrCast(@alignCast(@constCast(value))));
        }

        /// Allocates a slice of borrowed elements. Free the slice with allocator.free().
        /// Keep the array alive while using the elements, or retain them separately.
        pub fn toSlice(self: Self, allocator: std.mem.Allocator) error{OutOfMemory}![]T {
            const values = try allocator.alloc(T, self.len());
            for (values, 0..) |*value, index| value.* = self.get(index).?;
            return values;
        }
    };
}

test "core_foundation CFArray: strings, indexing and slice conversion" {
    const CFString = @import("CFString.zig");
    const Array = CFArray(CFString);
    const array = blk: {
        const first = try CFString.init("Helvetica");
        defer first.deinit();

        const second = try CFString.init("字体");
        defer second.deinit();
        break :blk try Array.init(&.{ first, second });
    };
    defer array.deinit();

    try std.testing.expectEqual(@as(usize, 2), array.len());
    try std.testing.expect(array.get(2) == null);

    const values = try array.toSlice(std.testing.allocator);
    defer std.testing.allocator.free(values);
    for (values, [_][]const u8{ "Helvetica", "字体" }, 0..) |value, expected, index| {
        try std.testing.expect(value.eq(array.get(index).?));
        const text = try value.toSlice(std.testing.allocator);
        defer std.testing.allocator.free(text);

        try std.testing.expectEqualStrings(expected, text);
    }
}
