const CTFontCollection = @This();

const std = @import("std");
const c = @import("c");
const cf = @import("../core_foundation.zig");
const CTFontDescriptor = @import("CTFontDescriptor.zig");
const Descriptors = cf.CFArray(CTFontDescriptor);
const Options = cf.CFDictionary(cf.CFString, cf.CFNumber);

ref: c.CTFontCollectionRef,

pub fn fromRef(ref: c.CTFontCollectionRef) CTFontCollection {
    return .{ .ref = ref };
}

pub fn asCFTypeRef(self: CTFontCollection) c.CFTypeRef {
    return @ptrCast(self.ref);
}

pub fn retain(self: CTFontCollection) CTFontCollection {
    _ = c.CFRetain(self.asCFTypeRef());
    return self;
}

pub fn deinit(self: CTFontCollection) void {
    c.CFRelease(self.asCFTypeRef());
}

pub fn getTypeID() c.CFTypeID {
    return c.CTFontCollectionGetTypeID();
}

/// Creates an owned collection of fonts available to the application.
pub fn initFromAvailableFonts(options: ?Options) CTFontCollection {
    return .fromRef(c.CTFontCollectionCreateFromAvailableFonts(
        if (options) |value| value.ref else null,
    ));
}

/// Creates an owned collection matching the supplied descriptors. Null creates an empty collection.
pub fn initWithFontDescriptors(descriptors: ?Descriptors, options: ?Options) CTFontCollection {
    return .fromRef(c.CTFontCollectionCreateWithFontDescriptors(
        if (descriptors) |value| value.ref else null,
        if (options) |value| value.ref else null,
    ));
}

/// Returns an owned array of matching descriptors, or null when there are no matches.
pub fn createMatchingFontDescriptors(self: CTFontCollection) ?Descriptors {
    return .fromRef(c.CTFontCollectionCreateMatchingFontDescriptors(self.ref) orelse return null);
}

/// Returns owned descriptors for a UTF-8 family name, or null when the family is absent.
pub fn createMatchingFontDescriptorsForFamily(self: CTFontCollection, family: []const u8, options: ?Options) cf.CFString.StringError!?Descriptors {
    const string = try cf.CFString.init(family);
    defer string.deinit();
    return .fromRef(c.CTFontCollectionCreateMatchingFontDescriptorsForFamily(
        self.ref,
        string.ref,
        if (options) |value| value.ref else null,
    ) orelse return null);
}
