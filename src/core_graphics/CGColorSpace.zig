const CGColorSpace = @This();
const c = @import("c");
const CFString = @import("../core_foundation/CFString.zig");

ref: c.CGColorSpaceRef,

pub fn initWithName(name: CFString) error{CreateFailed}!CGColorSpace {
    return .{
        .ref = c.CGColorSpaceCreateWithName(name.ref) orelse return error.CreateFailed,
    };
}

pub fn deinit(self: CGColorSpace) void {
    c.CGColorSpaceRelease(self.ref);
}
