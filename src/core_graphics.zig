pub const geometry = @import("core_graphics/geometry.zig");
pub const types = @import("core_graphics/types.zig");
pub const CGContext = @import("core_graphics/CGContext.zig");
pub const CGColorSpace = @import("core_graphics/CGColorSpace.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
