const CTMutableFontCollection = @This();
const std = @import("std");
const c = @import("c");
const cf = @import("../core_foundation.zig");
const CTFontCollection = @import("CTFontCollection.zig");
const CFArray = cf.array.CFArray;

pub const CTMutableFontCollectionRef = std.meta.Child(c.CTMutableFontCollectionRef);

ref: CTMutableFontCollectionRef,

pub fn fromRef(reference: ?CTMutableFontCollectionRef) CTMutableFontCollection {
    return .{
        .ref = reference orelse @panic("Attempt to create a null object."),
    };
}

pub fn retain(collection: CTMutableFontCollection) CTMutableFontCollection {
    _ = cf.retain(collection.ref);
    return collection;
}

pub fn release(collection: CTMutableFontCollection) void {
    cf.release(collection.ref);
}

pub fn getTypeID() usize {
    return c.CTFontCollectionGetTypeID();
}

pub fn asCollection(collection: CTMutableFontCollection) CTFontCollection {
    return .fromRef(collection.ref);
}

pub fn setQueryDescriptors(collection: CTMutableFontCollection, descriptors: ?CFArray) void {
    c.CTFontCollectionSetQueryDescriptors(collection.ref, descriptors);
}

pub fn setExclusionDescriptors(collection: CTMutableFontCollection, descriptors: ?CFArray) void {
    c.CTFontCollectionSetExclusionDescriptors(collection.ref, descriptors);
}
