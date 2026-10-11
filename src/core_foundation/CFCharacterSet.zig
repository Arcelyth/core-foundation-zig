const CFCharacterSet = @This();

const std = @import("std");
const c = @import("c");

ref: c.CFCharacterSetRef,

pub fn fromRef(ref: c.CFCharacterSetRef) CFCharacterSet {
    return .{ .ref = ref };
}

pub fn asCFTypeRef(self: CFCharacterSet) c.CFTypeRef {
    return @ptrCast(self.ref);
}

pub fn retain(self: CFCharacterSet) CFCharacterSet {
    _ = c.CFRetain(self.asCFTypeRef());
    return self;
}

pub fn deinit(self: CFCharacterSet) void {
    c.CFRelease(self.asCFTypeRef());
}

pub fn getTypeID() c.CFTypeID {
    return c.CFCharacterSetGetTypeID();
}

/// Creates a character set from UTF-8 text.
pub fn init(text: []const u8) error{ InvalidUtf8, OutOfMemory }!CFCharacterSet {
    const utf8 = std.unicode.Utf8View.init(text) catch return error.InvalidUtf8;
    const temporary = c.CFCharacterSetCreateMutable(c.kCFAllocatorDefault) orelse return error.OutOfMemory;
    defer c.CFRelease(temporary);

    // UTF-32 ranges preserve supplementary characters omitted by the native string constructor.
    var characters = utf8.iterator();
    while (characters.nextCodepoint()) |code_point|
        c.CFCharacterSetAddCharactersInRange(temporary, .{ .location = code_point, .length = 1 });

    const ref = c.CFCharacterSetCreateCopy(c.kCFAllocatorDefault, temporary) orelse return error.OutOfMemory;
    return .{ .ref = ref };
}

/// Checks a Unicode scalar, including characters outside the BMP.
pub fn contains(self: CFCharacterSet, code_point: u21) bool {
    if (!std.unicode.utf8ValidCodepoint(code_point)) return false;
    return c.CFCharacterSetIsLongCharacterMember(self.ref, code_point) != 0;
}

test "core_foundation CFCharacterSet: Unicode membership and ownership" {
    const characters = blk: {
        const original = try CFCharacterSet.init("A字😀");
        defer original.deinit();
        break :blk CFCharacterSet.fromRef(original.ref).retain();
    };
    defer characters.deinit();
    try std.testing.expect(characters.contains('A'));
    try std.testing.expect(characters.contains('字'));
    try std.testing.expect(characters.contains('😀'));
    try std.testing.expect(!characters.contains('B'));
    try std.testing.expect(!characters.contains(0xd800));
    try std.testing.expect(!characters.contains(0x110000));
    try std.testing.expectEqual(CFCharacterSet.getTypeID(), c.CFGetTypeID(characters.asCFTypeRef()));
    try std.testing.expectError(error.InvalidUtf8, CFCharacterSet.init("\xff"));
}
