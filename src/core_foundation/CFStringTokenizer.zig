const CFStringTokenizer = @This();
const c = @import("c");
const CFString = @import("CFString.zig");
const CFRange = @import("CFRange.zig");

ref: c.CFStringTokenizerRef,

pub fn fromRef(ref: c.CFStringTokenizerRef) CFStringTokenizer {
    return .{ .ref = ref };
}

pub fn asCFTypeRef(self: CFStringTokenizer) c.CFTypeRef {
    return @ptrCast(self.ref);
}

pub fn retain(self: CFStringTokenizer) CFStringTokenizer {
    _ = c.CFRetain(self.asCFTypeRef());
    return self;
}

pub fn deinit(self: CFStringTokenizer) void {
    c.CFRelease(self.asCFTypeRef());
}

pub fn getTypeID() c.CFTypeID {
    return c.CFStringTokenizerGetTypeID();
}

/// Tokenizes the entire string using the platform's default locale.
pub fn init(string: CFString, options: c.CFOptionFlags) error{ InputTooLong, OutOfMemory }!CFStringTokenizer {
    return .fromRef(c.CFStringTokenizerCreate(
        c.kCFAllocatorDefault,
        string.ref,
        try CFRange.init(0, string.len()),
        options,
        null,
    ) orelse return error.OutOfMemory);
}

pub fn advanceToNextToken(self: CFStringTokenizer) c.CFStringTokenizerTokenType {
    return c.CFStringTokenizerAdvanceToNextToken(self.ref);
}

/// Returns the current token's range in UTF-16 code units.
pub fn getCurrentTokenRange(self: CFStringTokenizer) CFRange.CFRange {
    return c.CFStringTokenizerGetCurrentTokenRange(self.ref);
}
