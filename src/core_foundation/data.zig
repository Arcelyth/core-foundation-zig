const std = @import("std");
const c = @import("c");

pub const CFData = std.meta.Child(c.CFDataRef);
