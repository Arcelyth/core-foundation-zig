const std = @import("std");
const c = @import("c");
pub const string = @import("core_foundation/string.zig");
pub const index = @import("core_foundation/index.zig");
pub const array = @import("core_foundation/array.zig");
pub const dictionary = @import("core_foundation/dictionary.zig");
pub const range = @import("core_foundation/range.zig");
pub const data = @import("core_foundation/data.zig");
pub const number = @import("core_foundation/number.zig");
pub const set = @import("core_foundation/set.zig");
pub const character_set = @import("core_foundation/character_set.zig");

pub const CFType = c.CFTypeRef;

pub fn release(object: CFType) void {
    c.CFRelease(object);
}

test {
    @import("std").testing.refAllDecls(@This());
}
