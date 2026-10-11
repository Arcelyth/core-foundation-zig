const std = @import("std");
const c = @import("c");
const index = @import("CFIndex.zig");

/// A set of CF wrappers, such as the attribute names used for font matching.
pub fn CFSet(comptime T: type) type {
    return struct {
        const Self = @This();

        ref: c.CFSetRef,

        pub fn fromRef(ref: c.CFSetRef) Self {
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
            return c.CFSetGetTypeID();
        }

        pub fn init(values: []const T) error{ InputTooLong, OutOfMemory }!Self {
            const temporary = c.CFSetCreateMutable(
                c.kCFAllocatorDefault,
                try index.fromUsize(values.len),
                &c.kCFTypeSetCallBacks,
            ) orelse return error.OutOfMemory;
            defer c.CFRelease(temporary);

            for (values) |value| c.CFSetAddValue(temporary, @ptrCast(value.ref));
            const ref = c.CFSetCreateCopy(c.kCFAllocatorDefault, temporary) orelse return error.OutOfMemory;
            return .{ .ref = ref };
        }

        pub fn len(self: Self) usize {
            return @intCast(c.CFSetGetCount(self.ref));
        }

        pub fn contains(self: Self, value: T) bool {
            return c.CFSetContainsValue(self.ref, @ptrCast(value.ref)) != 0;
        }

        /// Allocates an unordered slice of borrowed elements. Free it with allocator.free().
        /// Keep the set alive while using the elements, or retain them separately.
        pub fn toSlice(self: Self, allocator: std.mem.Allocator) error{OutOfMemory}![]T {
            const values = try allocator.alloc(T, self.len());
            var output: Collect = .{ .values = values };
            c.CFSetApplyFunction(self.ref, Collect.append, &output);

            return values;
        }

        const Collect = struct {
            values: []T,
            next: usize = 0,

            fn append(value: ?*const anyopaque, context: ?*anyopaque) callconv(.c) void {
                const output: *Collect = @ptrCast(@alignCast(context.?));
                output.values[output.next] = T.fromRef(@ptrCast(@alignCast(@constCast(value))));
                output.next += 1;
            }
        };
    };
}

test "core_foundation CFSet: equality, membership and owned elements" {
    const CFString = @import("CFString.zig");
    const Set = CFSet(CFString);
    const set = blk: {
        const name = try CFString.init("family");
        defer name.deinit();
        const equal_name = try CFString.init("family");
        defer equal_name.deinit();

        const traits = try CFString.init("traits");
        defer traits.deinit();
        break :blk try Set.init(&.{ name, equal_name, traits });
    };
    defer set.deinit();
    try std.testing.expectEqual(@as(usize, 2), set.len());

    const name = try CFString.init("family");
    defer name.deinit();
    try std.testing.expect(set.contains(name));

    const missing = try CFString.init("missing");
    defer missing.deinit();
    try std.testing.expect(!set.contains(missing));

    const values = try set.toSlice(std.testing.allocator);
    defer std.testing.allocator.free(values);

    try std.testing.expectEqual(set.len(), values.len);
    try std.testing.expect(!values[0].eq(values[1]));
    for (values) |value| try std.testing.expect(set.contains(value));
}
