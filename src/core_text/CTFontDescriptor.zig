const CTFontDescriptor = @This();

const std = @import("std");
const c = @import("c");
const types = @import("types.zig");

pub const CTFontDescriptorRef = std.meta.Child(c.CTFontDescriptorRef);

ref: CTFontDescriptorRef,
