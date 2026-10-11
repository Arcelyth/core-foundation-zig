const std = @import("std");
const c = @import("c");

pub const CFSet = std.meta.Child(c.CFSetRef);
