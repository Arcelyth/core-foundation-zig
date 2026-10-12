const std = @import("std");
const c = @import("c");
pub const CFString = @import("core_foundation/CFString.zig");
pub const CFIndex = @import("core_foundation/CFIndex.zig");
pub const array = @import("core_foundation/array.zig");
pub const CFArray = @import("core_foundation/array.zig").CFArray;
pub const dictionary = @import("core_foundation/dictionary.zig");
pub const CFDictionary = @import("core_foundation/dictionary.zig").CFDictionary;
pub const CFMutableDictionary = @import("core_foundation/dictionary.zig").CFMutableDictionary;
pub const CFData = @import("core_foundation/CFData.zig");
pub const CFNumber = @import("core_foundation/CFNumber.zig");
pub const set = @import("core_foundation/set.zig");
pub const CFSet = @import("core_foundation/set.zig").CFSet;
pub const CFURL = @import("core_foundation/CFURL.zig");
pub const CFAttributeString = @import("core_foundation/CFAttributeString.zig");
pub const CFStringTokenizer = @import("core_foundation/CFStringTokenizer.zig");
pub const CFRange = @import("core_foundation/CFRange.zig");
pub const CFCharacterSet = @import("core_foundation/CFCharacterSet.zig");

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
