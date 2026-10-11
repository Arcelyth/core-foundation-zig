const std = @import("std");
const c = @import("c");

pub const CFArray = std.meta.Child(c.CFArrayRef);
