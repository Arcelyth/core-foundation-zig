const CFURL = @This();

const std = @import("std");
const c = @import("c");
const toCFIndex = @import("CFIndex.zig").fromUsize;
const CFString = @import("CFString.zig");

ref: c.CFURLRef,

pub fn fromRef(ref: c.CFURLRef) CFURL {
    return .{ .ref = ref };
}

pub fn asCFTypeRef(self: CFURL) c.CFTypeRef {
    return @ptrCast(self.ref);
}

pub fn retain(self: CFURL) CFURL {
    _ = c.CFRetain(self.asCFTypeRef());
    return self;
}

pub fn deinit(self: CFURL) void {
    c.CFRelease(self.asCFTypeRef());
}

pub fn getTypeID() c.CFTypeID {
    return c.CFURLGetTypeID();
}

/// Creates a file URL from native font-path bytes, which need not be UTF-8.
pub fn init(path: []const u8) error{ InputTooLong, CreationFailed }!CFURL {
    const ref = c.CFURLCreateFromFileSystemRepresentation(
        c.kCFAllocatorDefault,
        path.ptr,
        try toCFIndex(path.len),
        0,
    ) orelse return error.CreationFailed;

    return .{ .ref = ref };
}

/// Converts the CFURL to CFString.
pub fn toString(self: CFURL) CFString {
    return CFString.fromRef(c.CFURLGetString(self.ref));
}

test "core_foundation CFURL: font file paths" {
    const testing = std.testing;

    const cases = .{
        .{ "/tmp/font family/字体.ttf", "file:///tmp/font%20family/%E5%AD%97%E4%BD%93.ttf" },
        .{ "/tmp/fonts/\xc0.ttf", "file:///tmp/fonts/%C0.ttf" },
    };
    inline for (cases) |case| {
        const url = try CFURL.init(case[0]);
        defer url.deinit();
        const text = try url.toString().toSlice(testing.allocator);
        defer testing.allocator.free(text);

        try testing.expectEqualStrings(case[1], text);
    }
}
