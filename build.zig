const std = @import("std");
const Translator = @import("translate_c").Translator;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    if (target.result.os.tag != .macos) @panic("requires macOS as target");

    const core_text_t: Translator = .init(b.dependency("translate_c", .{}), .{
        .c_source_file = b.path("src/core_text/c.h"),
        .target = target,
        .optimize = optimize,
    });
    core_text_t.mod.linkFramework("CoreText", .{});

    const core_foundation_t: Translator = .init(b.dependency("translate_c", .{}), .{
        .c_source_file = b.path("src/core_foundation/c.h"),
        .target = target,
        .optimize = optimize,
    });

    core_foundation_t.mod.linkFramework("CoreText", .{});
}
