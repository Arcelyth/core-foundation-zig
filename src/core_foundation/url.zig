const std = @import("std");
const c = @import("c");
const CFAllocator = std.meta.Child(c.CFAllocatorRef);
const CFIndex = @import("index.zig").CFIndex;
const toCFIndex = @import("index.zig").toCFIndex;
const CFRange = @import("range.zig").CFRange;
const CFData = @import("data.zig").CFData;
const string = @import("string.zig");
const CFString = string.CFString;
const CFStringEncoding = string.CFStringEncoding;
const StringError = string.StringError;

pub const CFURL = std.meta.Child(c.CFURLRef);
pub const PathStyle = c.CFURLPathStyle;
pub const ComponentType = c.CFURLComponentType;

pub fn getTypeID() usize {
    return c.CFURLGetTypeID();
}

pub fn createWithBytes(
    allocator: ?CFAllocator,
    bytes: []const u8,
    encoding: CFStringEncoding,
    base: ?CFURL,
) error{InputTooLong}!?CFURL {
    return c.CFURLCreateWithBytes(
        allocator,
        bytes.ptr,
        try toCFIndex(bytes.len),
        encoding,
        base,
    );
}

pub fn createWithString(allocator: ?CFAllocator, text: []const u8, base: ?CFURL) StringError!?CFURL {
    const value = try string.toCFString(text);
    defer c.CFRelease(value);
    return c.CFURLCreateWithString(allocator, value, base);
}

pub fn createAbsoluteURLWithBytes(
    allocator: ?CFAllocator,
    bytes: []const u8,
    encoding: CFStringEncoding,
    base: ?CFURL,
    use_compatibility_mode: bool,
) error{InputTooLong}!?CFURL {
    return c.CFURLCreateAbsoluteURLWithBytes(
        allocator,
        bytes.ptr,
        try toCFIndex(bytes.len),
        encoding,
        base,
        @intFromBool(use_compatibility_mode),
    );
}

/// Creates encoded URL data, not the contents of the resource.
pub fn createData(
    allocator: ?CFAllocator,
    url: CFURL,
    encoding: CFStringEncoding,
    escape_whitespace: bool,
) ?CFData {
    return c.CFURLCreateData(
        allocator,
        url,
        encoding,
        @intFromBool(escape_whitespace),
    );
}

pub fn createWithFileSystemPath(
    allocator: ?CFAllocator,
    path: []const u8,
    style: PathStyle,
    is_directory: bool,
) StringError!?CFURL {
    const value = try string.toCFString(path);
    defer c.CFRelease(value);
    return c.CFURLCreateWithFileSystemPath(
        allocator,
        value,
        style,
        @intFromBool(is_directory),
    );
}

/// Accepts native file-system bytes without UTF-8 conversion.
pub fn createFromFileSystemRepresentation(allocator: ?CFAllocator, path: []const u8, is_directory: bool) error{InputTooLong}!?CFURL {
    return c.CFURLCreateFromFileSystemRepresentation(
        allocator,
        path.ptr,
        try toCFIndex(path.len),
        @intFromBool(is_directory),
    );
}

pub fn createWithFileSystemPathRelativeToBase(
    allocator: ?CFAllocator,
    path: []const u8,
    style: PathStyle,
    is_directory: bool,
    base: ?CFURL,
) StringError!?CFURL {
    const value = try string.toCFString(path);
    defer c.CFRelease(value);
    return c.CFURLCreateWithFileSystemPathRelativeToBase(
        allocator,
        value,
        style,
        @intFromBool(is_directory),
        base,
    );
}

pub fn createFromFileSystemRepresentationRelativeToBase(
    allocator: ?CFAllocator,
    path: []const u8,
    is_directory: bool,
    base: ?CFURL,
) error{InputTooLong}!?CFURL {
    return c.CFURLCreateFromFileSystemRepresentationRelativeToBase(
        allocator,
        path.ptr,
        try toCFIndex(path.len),
        @intFromBool(is_directory),
        base,
    );
}

pub fn getFileSystemRepresentation(url: CFURL, resolve_against_base: bool, buffer: []u8) error{InputTooLong}!bool {
    return c.CFURLGetFileSystemRepresentation(
        url,
        @intFromBool(resolve_against_base),
        buffer.ptr,
        try toCFIndex(buffer.len),
    ) != 0;
}

pub fn copyAbsoluteURL(url: CFURL) ?CFURL {
    return c.CFURLCopyAbsoluteURL(url);
}

pub fn getString(url: CFURL) CFString {
    return c.CFURLGetString(url).?;
}

pub fn getBaseURL(url: CFURL) ?CFURL {
    return c.CFURLGetBaseURL(url);
}

pub fn canBeDecomposed(url: CFURL) bool {
    return c.CFURLCanBeDecomposed(url) != 0;
}

pub fn copyScheme(url: CFURL) ?CFString {
    return c.CFURLCopyScheme(url);
}

pub fn copyNetLocation(url: CFURL) ?CFString {
    return c.CFURLCopyNetLocation(url);
}

pub fn copyPath(url: CFURL) ?CFString {
    return c.CFURLCopyPath(url);
}

/// Returns the path without its leading slash and reports whether it was absolute.
pub fn copyStrictPath(url: CFURL, is_absolute: ?*bool) ?CFString {
    var native_absolute: c.Boolean = 0;
    const path = c.CFURLCopyStrictPath(
        url,
        if (is_absolute != null) &native_absolute else null,
    );
    if (is_absolute) |value| value.* = native_absolute != 0;
    return path;
}

pub fn copyFileSystemPath(url: CFURL, style: PathStyle) ?CFString {
    return c.CFURLCopyFileSystemPath(url, style);
}

pub fn hasDirectoryPath(url: CFURL) bool {
    return c.CFURLHasDirectoryPath(url) != 0;
}

pub fn copyResourceSpecifier(url: CFURL) ?CFString {
    return c.CFURLCopyResourceSpecifier(url);
}

pub fn copyHostName(url: CFURL) ?CFString {
    return c.CFURLCopyHostName(url);
}

pub fn getPortNumber(url: CFURL) ?i32 {
    const port = c.CFURLGetPortNumber(url);
    return if (port == -1) null else port;
}

pub fn copyUserName(url: CFURL) ?CFString {
    return c.CFURLCopyUserName(url);
}

pub fn copyPassword(url: CFURL) ?CFString {
    return c.CFURLCopyPassword(url);
}

pub fn copyQueryString(url: CFURL, characters_to_leave_escaped: ?[]const u8) StringError!?CFString {
    const characters = if (characters_to_leave_escaped) |text|
        try string.toCFString(text)
    else
        null;
    defer if (characters) |value| c.CFRelease(value);
    return c.CFURLCopyQueryString(url, characters);
}

pub fn copyFragment(url: CFURL, characters_to_leave_escaped: ?[]const u8) StringError!?CFString {
    const characters = if (characters_to_leave_escaped) |text|
        try string.toCFString(text)
    else
        null;
    defer if (characters) |value| c.CFRelease(value);
    return c.CFURLCopyFragment(url, characters);
}

pub fn copyLastPathComponent(url: CFURL) ?CFString {
    return c.CFURLCopyLastPathComponent(url);
}

pub fn copyPathExtension(url: CFURL) ?CFString {
    return c.CFURLCopyPathExtension(url);
}

pub fn createCopyAppendingPathComponent(
    allocator: ?CFAllocator,
    url: CFURL,
    component: []const u8,
    is_directory: bool,
) StringError!?CFURL {
    const value = try string.toCFString(component);
    defer c.CFRelease(value);

    return c.CFURLCreateCopyAppendingPathComponent(
        allocator,
        url,
        value,
        @intFromBool(is_directory),
    );
}

pub fn createCopyDeletingLastPathComponent(allocator: ?CFAllocator, url: CFURL) ?CFURL {
    return c.CFURLCreateCopyDeletingLastPathComponent(allocator, url);
}

pub fn createCopyAppendingPathExtension(allocator: ?CFAllocator, url: CFURL, extension: []const u8) StringError!?CFURL {
    const value = try string.toCFString(extension);
    defer c.CFRelease(value);
    return c.CFURLCreateCopyAppendingPathExtension(allocator, url, value);
}

pub fn createCopyDeletingPathExtension(allocator: ?CFAllocator, url: CFURL) ?CFURL {
    return c.CFURLCreateCopyDeletingPathExtension(allocator, url);
}

pub fn getBytes(url: CFURL, buffer: ?[]u8) error{
    InputTooLong,
    BufferTooSmall,
    EncodingFailed,
}!CFIndex {
    const length = c.CFURLGetBytes(
        url,
        if (buffer) |bytes| bytes.ptr else null,
        if (buffer) |bytes| try toCFIndex(bytes.len) else 0,
    );
    if (length >= 0) return length;
    if (buffer != null and c.CFURLGetBytes(url, null, 0) >= 0)
        return error.BufferTooSmall;
    return error.EncodingFailed;
}

pub fn getByteRangeForComponent(url: CFURL, component: ComponentType, including_separators: ?*CFRange) CFRange {
    return c.CFURLGetByteRangeForComponent(url, component, including_separators);
}

pub fn isFileReferenceURL(url: CFURL) bool {
    return c.CFURLIsFileReferenceURL(url) != 0;
}
