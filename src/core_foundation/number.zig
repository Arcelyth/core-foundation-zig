const std = @import("std");
const c = @import("c");

pub const CFNumber = std.meta.Child(c.CFNumberRef);
