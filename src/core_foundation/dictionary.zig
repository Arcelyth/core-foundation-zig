const std = @import("std");
const c = @import("c");

pub const CFDictionary = std.meta.Child(c.CFDictionaryRef);
