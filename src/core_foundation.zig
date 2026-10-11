const std = @import("std");
const c = @import("c");
pub const CFString = @import("core_foundation/CFString.zig");
pub const string = @import("core_foundation/string.zig");
pub const index = @import("core_foundation/index.zig");
pub const array = @import("core_foundation/array.zig");
pub const cf_array = @import("core_foundation/cf_array.zig");
pub const dictionary = @import("core_foundation/dictionary.zig");
pub const range = @import("core_foundation/range.zig");
pub const data = @import("core_foundation/data.zig");
pub const CFNumber = @import("core_foundation/CFNumber.zig");
pub const set = @import("core_foundation/set.zig");
pub const CFURL = @import("core_foundation/CFURL.zig");
pub const url = @import("core_foundation/url.zig");
pub const character_set = @import("core_foundation/character_set.zig");

pub const CFType = c.CFTypeRef;

pub fn release(object: CFType) void {
    c.CFRelease(object);
}

pub fn retain(object: CFType) CFType {
    return c.CFRetain(object);
}

test {
    @import("std").testing.refAllDecls(@This());
}
