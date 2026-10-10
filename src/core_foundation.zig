const std = @import("std");
const c = @import("c");
pub const string = @import("core_foundation/string.zig");
pub const index = @import("core_foundation/index.zig");

pub const CFType = c.CFTypeRef;

pub fn release(object: CFType) void {
    c.CFRelease(object);
}

test {
    @import("std").testing.refAllDecls(@This());
}
