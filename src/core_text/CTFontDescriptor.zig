const CTFontDescriptor = @This();

const std = @import("std");
const c = @import("c");
const types = @import("types.zig");
const cf = @import("../core_foundation.zig");
const cf_string = cf.string;
const CFString = cf_string.CFString;
const StringError = cf_string.StringError;
const toCFString = cf_string.toCFString;
const CFDictionary = cf.dictionary.CFDictionary;
const CFArray = cf.array.CFArray;
const CFNumber = cf.number.CFNumber;
const CFSet = cf.set.CFSet;
const SymbolicTraits = types.SymbolicTraits;

pub const CTFontDescriptorRef = std.meta.Child(c.CTFontDescriptorRef);

ref: CTFontDescriptorRef,

pub fn fromRef(reference: c.CTFontDescriptorRef) CTFontDescriptor {
    return .{
        .ref = reference orelse @panic("Attempt to create a null object."),
    };
}

pub fn retain(descriptor: CTFontDescriptor) CTFontDescriptor {
    _ = cf.retain(descriptor.ref);
    return descriptor;
}

pub fn release(descriptor: CTFontDescriptor) void {
    cf.release(descriptor.ref);
}

pub fn initWithNameAndSize(name: []const u8, size: f64) StringError!CTFontDescriptor {
    const string = try toCFString(name);
    defer cf.release(string);

    return fromRef(c.CTFontDescriptorCreateWithNameAndSize(string, size));
}

pub fn initWithAttributes(attributes: CFDictionary) CTFontDescriptor {
    return fromRef(c.CTFontDescriptorCreateWithAttributes(attributes));
}

pub fn initCopyWithAttributes(original: CTFontDescriptor, attributes: CFDictionary) CTFontDescriptor {
    return fromRef(c.CTFontDescriptorCreateCopyWithAttributes(original.ref, attributes));
}

pub fn initCopyWithVariation(original: CTFontDescriptor, variation_identifier: CFNumber, variation_value: f64) CTFontDescriptor {
    return fromRef(c.CTFontDescriptorCreateCopyWithVariation(
        original.ref,
        variation_identifier,
        variation_value,
    ));
}
pub fn initCopyWithFeature(original: CTFontDescriptor, feature_type_identifier: CFNumber, feature_selector_identifier: CFNumber) CTFontDescriptor {
    return fromRef(c.CTFontDescriptorCreateCopyWithFeature(
        original.ref,
        feature_type_identifier,
        feature_selector_identifier,
    ));
}

pub fn initCopyWithFamily(original: CTFontDescriptor, family: []const u8) StringError!?CTFontDescriptor {
    const string = try toCFString(family);
    defer cf.release(string);

    return fromRef(c.CTFontDescriptorCreateCopyWithFamily(original.ref, string) orelse return null);
}

pub fn initCopyWithSymbolicTraits(original: CTFontDescriptor, sym_trait_value: SymbolicTraits, sym_trait_mask: SymbolicTraits) ?CTFontDescriptor {
    return fromRef(c.CTFontDescriptorCreateCopyWithSymbolicTraits(
        original.ref,
        @backingInt(sym_trait_value),
        @backingInt(sym_trait_mask),
    ) orelse return null);
}

pub fn createMatchingFontDescriptors(descriptor: CTFontDescriptor, mandatory_attributes: CFSet) CFArray {
    return c.CTFontDescriptorCreateMatchingFontDescriptors(descriptor.ref, mandatory_attributes);
}

pub fn createMatchingFontDescriptor(descriptor: CTFontDescriptor, mandatory_attributes: CFSet) ?CTFontDescriptor {
    return fromRef(c.CTFontDescriptorCreateMatchingFontDescriptor(descriptor.ref, mandatory_attributes) orelse return null);
}

pub fn copyAttributes(descriptor: CTFontDescriptor) CFDictionary {
    return c.CTFontDescriptorCopyAttributes(descriptor.ref);
}

pub fn copyAttribute(descriptor: CTFontDescriptor, attribute: []const u8) StringError!cf.CFType {
    const string = try toCFString(attribute);
    defer cf.release(string);

    return c.CTFontDescriptorCopyAttribute(descriptor.ref, string);
}

pub fn copyLocalizedAttribute(descriptor: CTFontDescriptor, attribute: []const u8, language: ?*CFString) StringError!cf.CFType {
    const string = try toCFString(attribute);
    defer cf.release(string);

    return c.CTFontDescriptorCopyLocalizedAttribute(descriptor.ref, string, language);
}

pub fn getTypeID() usize {
    return c.CTFontDescriptorGetTypeID();
}
