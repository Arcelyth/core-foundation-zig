const std = @import("std");
const c = @import("c");
const index = @import("CFIndex.zig");

/// Keys and values are CF wrappers or native CF references.
/// The dictionary retains its objects. Returned objects are borrowed.
pub fn CFDictionary(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();
        pub const Key = K;
        pub const Value = V;
        pub const Entry = struct { key: K, value: V };

        ref: c.CFDictionaryRef,

        pub fn fromRef(ref: c.CFDictionaryRef) Self {
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
            return c.CFDictionaryGetTypeID();
        }

        /// Creates an owned dictionary. Later entries replace earlier equal keys.
        pub fn init(entries: []const Entry) error{ InputTooLong, OutOfMemory }!Self {
            const temporary = try CFMutableDictionary(K, V).init(entries);
            defer temporary.deinit();
            return temporary.copy();
        }

        pub fn len(self: Self) usize {
            return @intCast(c.CFDictionaryGetCount(self.ref));
        }

        pub fn contains(self: Self, key: K) bool {
            return c.CFDictionaryContainsKey(self.ref, nativeRef(key)) != 0;
        }

        /// Returns a borrowed value, or null when the key is absent.
        pub fn get(self: Self, key: K) ?V {
            const value = c.CFDictionaryGetValue(self.ref, nativeRef(key)) orelse return null;
            return wrap(V, value);
        }

        /// Creates an independent mutable dictionary retaining the same CF objects.
        pub fn mutableCopy(self: Self) error{OutOfMemory}!CFMutableDictionary(K, V) {
            const ref = c.CFDictionaryCreateMutableCopy(c.kCFAllocatorDefault, 0, self.ref) orelse return error.OutOfMemory;
            return .{ .ref = ref };
        }

        /// Allocates unordered pairs of borrowed objects. Free with allocator.free().
        /// Retain objects before removing/replacing them or releasing the dictionary.
        pub fn toSlice(self: Self, allocator: std.mem.Allocator) error{OutOfMemory}![]Entry {
            const entries = try allocator.alloc(Entry, self.len());
            var output: Collect = .{ .entries = entries };
            c.CFDictionaryApplyFunction(self.ref, Collect.append, &output);
            return entries;
        }

        const Collect = struct {
            entries: []Entry,
            next: usize = 0,

            fn append(key: c.CFTypeRef, value: c.CFTypeRef, context: ?*anyopaque) callconv(.c) void {
                const output: *Collect = @ptrCast(@alignCast(context.?));
                output.entries[output.next] = .{ .key = wrap(K, key), .value = wrap(V, value) };
                output.next += 1;
            }
        };
    };
}

pub fn CFMutableDictionary(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();
        const Immutable = CFDictionary(K, V);
        pub const Key = K;
        pub const Value = V;
        pub const Entry = Immutable.Entry;

        ref: c.CFMutableDictionaryRef,

        /// Wraps a native mutable dictionary without retaining it.
        pub fn fromRef(ref: c.CFMutableDictionaryRef) Self {
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
            return c.CFDictionaryGetTypeID();
        }

        /// Creates an owned dictionary retaining its keys and values.
        pub fn init(entries: []const Entry) error{ InputTooLong, OutOfMemory }!Self {
            const ref = c.CFDictionaryCreateMutable(
                c.kCFAllocatorDefault,
                try index.fromUsize(entries.len),
                &c.kCFTypeDictionaryKeyCallBacks,
                &c.kCFTypeDictionaryValueCallBacks,
            ) orelse return error.OutOfMemory;

            const self: Self = .{ .ref = ref };
            for (entries) |entry| self.set(entry.key, entry.value);
            return self;
        }

        /// Returns a borrowed view of this dictionary. Do not deinit the view.
        pub fn asDictionary(self: Self) Immutable {
            return .{ .ref = self.ref };
        }

        /// Creates an owned immutable snapshot.
        pub fn copy(self: Self) error{OutOfMemory}!Immutable {
            const ref = c.CFDictionaryCreateCopy(c.kCFAllocatorDefault, self.ref) orelse return error.OutOfMemory;
            return .{ .ref = ref };
        }

        pub fn len(self: Self) usize {
            return self.asDictionary().len();
        }

        pub fn contains(self: Self, key: K) bool {
            return self.asDictionary().contains(key);
        }

        /// Returns a borrowed value. Retain it before replacing or removing it.
        pub fn get(self: Self, key: K) ?V {
            return self.asDictionary().get(key);
        }

        /// Returns allocated pairs of borrowed objects, as in CFDictionary.toSlice.
        pub fn toSlice(self: Self, allocator: std.mem.Allocator) error{OutOfMemory}![]Entry {
            return self.asDictionary().toSlice(allocator);
        }

        /// Inserts or updates a value.
        pub fn set(self: Self, key: K, value: V) void {
            c.CFDictionarySetValue(self.ref, nativeRef(key), nativeRef(value));
        }

        /// Inserts only when the key is absent.
        pub fn add(self: Self, key: K, value: V) void {
            c.CFDictionaryAddValue(self.ref, nativeRef(key), nativeRef(value));
        }

        /// Updates only when the key is present.
        pub fn replace(self: Self, key: K, value: V) void {
            c.CFDictionaryReplaceValue(self.ref, nativeRef(key), nativeRef(value));
        }

        pub fn remove(self: Self, key: K) void {
            c.CFDictionaryRemoveValue(self.ref, nativeRef(key));
        }

        pub fn clear(self: Self) void {
            c.CFDictionaryRemoveAllValues(self.ref);
        }
    };
}

fn nativeRef(value: anytype) c.CFTypeRef {
    const ref: c.CFTypeRef = if (@typeInfo(@TypeOf(value)) == .@"struct")
        @ptrCast(value.ref)
    else
        @ptrCast(value);
    std.debug.assert(ref != null);
    return ref;
}

fn wrap(comptime T: type, ref: c.CFTypeRef) T {
    if (@typeInfo(T) == .@"struct") return T.fromRef(@ptrCast(@alignCast(@constCast(ref))));
    return @ptrCast(@alignCast(@constCast(ref)));
}

test "core_foundation CFDictionary: equality, ownership and entry conversion" {
    const CFString = @import("CFString.zig");
    const CFNumber = @import("CFNumber.zig");
    const Dictionary = CFDictionary(CFString, CFNumber);
    const dictionary = blk: {
        const key = try CFString.init("weight");
        defer key.deinit();

        const equal_key = try CFString.init("weight");
        defer equal_key.deinit();

        const first = try CFNumber.init(@as(i32, 400));
        defer first.deinit();

        const last = try CFNumber.init(@as(i32, 700));
        defer last.deinit();

        const original = try Dictionary.init(&.{
            .{ .key = key, .value = first },
            .{ .key = equal_key, .value = last },
        });
        defer original.deinit();
        break :blk Dictionary.fromRef(original.ref).retain();
    };
    defer dictionary.deinit();

    const key = try CFString.init("weight");
    defer key.deinit();
    const missing = try CFString.init("missing");
    defer missing.deinit();

    try std.testing.expectEqual(@as(usize, 1), dictionary.len());
    try std.testing.expect(dictionary.contains(key));
    try std.testing.expect(!dictionary.contains(missing));
    try std.testing.expect(dictionary.get(missing) == null);
    try std.testing.expectEqual(@as(?i32, 700), dictionary.get(key).?.to(i32));

    const entries = try dictionary.toSlice(std.testing.allocator);
    defer std.testing.allocator.free(entries);
    try std.testing.expectEqual(@as(usize, 1), entries.len);
    try std.testing.expect(entries[0].key.eq(key));
    try std.testing.expectEqual(@as(?i32, 700), entries[0].value.to(i32));
    try std.testing.expectEqual(Dictionary.getTypeID(), c.CFGetTypeID(dictionary.asCFTypeRef()));
}
