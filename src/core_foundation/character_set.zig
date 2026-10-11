const std = @import("std");
const c = @import("c");

pub const CFCharacterSet = std.meta.Child(c.CFCharacterSetRef);
