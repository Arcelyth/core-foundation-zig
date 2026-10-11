const CFNumber = @This();

const std = @import("std");
const c = @import("c");

ref: c.CFNumberRef,

pub fn fromRef(ref: c.CFNumberRef) CFNumber {
    return .{ .ref = ref };
}

pub fn asCFTypeRef(self: CFNumber) c.CFTypeRef {
    return @ptrCast(self.ref);
}

pub fn retain(self: CFNumber) CFNumber {
    _ = c.CFRetain(@ptrCast(self.ref));
    return self;
}

pub fn deinit(self: CFNumber) void {
    c.CFRelease(@ptrCast(self.ref));
}

pub fn getTypeID() c.CFTypeID {
    return c.CFNumberGetTypeID();
}

/// Creates a CFNumber from a supported Zig numeric type.
pub fn init(value: anytype) error{OutOfMemory}!CFNumber {
    const T = @TypeOf(value);

    const number_type: c.CFNumberType = comptime numberType(T);
    const number = value;

    const ref = c.CFNumberCreate(
        c.kCFAllocatorDefault,
        number_type,
        @ptrCast(@constCast(&number)),
    ) orelse return error.OutOfMemory;

    return .{ .ref = ref };
}

/// Converts the number to a requested Zig numeric type.
pub fn to(self: CFNumber, comptime T: type) ?T {
    const number_type: c.CFNumberType = comptime numberType(T);

    var value: T = 0;

    const success = c.CFNumberGetValue(
        self.ref,
        number_type,
        @ptrCast(&value),
    );

    return if (success != 0) value else null;
}

fn numberType(comptime T: type) c.CFNumberType {
    return switch (T) {
        i8 => c.kCFNumberSInt8Type,
        i16 => c.kCFNumberSInt16Type,
        i32 => c.kCFNumberSInt32Type,
        i64 => c.kCFNumberSInt64Type,
        f32 => c.kCFNumberFloat32Type,
        f64 => c.kCFNumberFloat64Type,
        else => @compileError(
            "Unsupported CFNumber type: " ++ @typeName(T),
        ),
    };
}

test "core_foundation CFNumber: init and to i32 i64 f32 f64" {
    var num_i32 = try CFNumber.init(@as(i32, 42));
    defer num_i32.deinit();

    try std.testing.expectEqual(@as(?i32, 42), num_i32.to(i32));
    try std.testing.expectEqual(@as(?i64, 42), num_i32.to(i64));

    var num_i64 = try CFNumber.init(@as(i64, -123456789));
    defer num_i64.deinit();

    try std.testing.expectEqual(
        @as(?i64, -123456789),
        num_i64.to(i64),
    );

    var num_f32 = try CFNumber.init(@as(f32, 3.5));
    defer num_f32.deinit();

    try std.testing.expectEqual(@as(?f32, 3.5), num_f32.to(f32));

    var num_f64 = try CFNumber.init(@as(f64, 3.14159));
    defer num_f64.deinit();

    try std.testing.expectEqual(@as(?f64, 3.14159), num_f64.to(f64));
}
