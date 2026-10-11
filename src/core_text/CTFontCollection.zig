const CTFontCollection = @This();
const std = @import("std");
const c = @import("c");
const cf = @import("../core_foundation.zig");
const CTMutableFontCollection = @import("CTMutableFontCollection.zig");
const CFArray = cf.array.CFArray;
const CFDictionary = cf.dictionary.CFDictionary;
const CFSet = cf.set.CFSet;
const StringError = cf.string.StringError;

pub const CTFontCollectionRef = std.meta.Child(c.CTFontCollectionRef);
pub const CopyOptions = c.CTFontCollectionCopyOptions;
pub const SortDescriptorsCallback = std.meta.Child(c.CTFontCollectionSortDescriptorsCallback);

ref: CTFontCollectionRef,

pub fn fromRef(reference: ?CTFontCollectionRef) CTFontCollection {
    return .{ .ref = reference orelse @panic("Attempt to create a null object.") };
}

pub fn retain(collection: CTFontCollection) CTFontCollection {
    _ = cf.retain(collection.ref);
    return collection;
}

pub fn release(collection: CTFontCollection) void {
    cf.release(collection.ref);
}

pub fn getTypeID() usize {
    return c.CTFontCollectionGetTypeID();
}

// Creating Font Collections

pub fn initFromAvailableFonts(options: ?CFDictionary) CTFontCollection {
    return fromRef(c.CTFontCollectionCreateFromAvailableFonts(options));
}

pub fn initWithFontDescriptors(descriptors: ?CFArray, options: ?CFDictionary) CTFontCollection {
    return fromRef(c.CTFontCollectionCreateWithFontDescriptors(descriptors, options));
}

pub fn initCopyWithFontDescriptors(original: CTFontCollection, descriptors: ?CFArray, options: ?CFDictionary) CTFontCollection {
    return fromRef(c.CTFontCollectionCreateCopyWithFontDescriptors(original.ref, descriptors, options));
}

// Excluding and Including Font Descriptors

pub fn createMutableCopy(collection: CTFontCollection) CTMutableFontCollection {
    return .fromRef(c.CTFontCollectionCreateMutableCopy(collection.ref));
}

pub fn copyQueryDescriptors(collection: CTFontCollection) ?CFArray {
    return c.CTFontCollectionCopyQueryDescriptors(collection.ref);
}

pub fn copyExclusionDescriptors(collection: CTFontCollection) ?CFArray {
    return c.CTFontCollectionCopyExclusionDescriptors(collection.ref);
}

pub fn createMatchingFontDescriptors(collection: CTFontCollection) ?CFArray {
    return c.CTFontCollectionCreateMatchingFontDescriptors(collection.ref);
}

pub fn createMatchingFontDescriptorsSortedWithCallback(
    collection: CTFontCollection,
    callback: ?SortDescriptorsCallback,
    context: ?*anyopaque,
) ?CFArray {
    return c.CTFontCollectionCreateMatchingFontDescriptorsSortedWithCallback(collection.ref, callback, context);
}

pub fn createMatchingFontDescriptorsWithOptions(collection: CTFontCollection, options: ?CFDictionary) ?CFArray {
    return c.CTFontCollectionCreateMatchingFontDescriptorsWithOptions(collection.ref, options);
}

pub fn createMatchingFontDescriptorsForFamily(collection: CTFontCollection, family: []const u8, options: ?CFDictionary) StringError!?CFArray {
    const string = try cf.string.toCFString(family);
    defer cf.release(string);

    return c.CTFontCollectionCreateMatchingFontDescriptorsForFamily(collection.ref, string, options);
}

pub fn copyFontAttribute(collection: CTFontCollection, attribute: []const u8, options: CopyOptions) StringError!CFArray {
    const string = try cf.string.toCFString(attribute);
    defer cf.release(string);

    return c.CTFontCollectionCopyFontAttribute(collection.ref, string, options).?;
}

pub fn copyFontAttributes(collection: CTFontCollection, attributes: CFSet, options: CopyOptions) CFArray {
    return c.CTFontCollectionCopyFontAttributes(collection.ref, attributes, options).?;
}
