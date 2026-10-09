const std = @import("std");
const Translator = @import("translate_c").Translator;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    if (target.result.os.tag != .macos) @panic("requires macOS as target");

    const t: Translator = .init(b.dependency("translate_c", .{}), .{
        .c_source_file = b.path("src/c.h"),
        .target = target,
        .optimize = optimize,
    });
    t.mod.linkFramework("CoreText", .{});
    t.mod.linkFramework("CoreFoundation", .{});
    t.mod.linkFramework("CoreGraphics", .{});

    _ = b.addModule("core_text", .{
        .root_source_file = b.path("src/core_text.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "c", .module = t.mod }},
    });

    _ = b.addModule("core_foundation", .{
        .root_source_file = b.path("src/core_foundation.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "c", .module = t.mod }},
    });

    const test_step = b.step("test", "Run all tests");

    const test_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "c", .module = t.mod }},
    });
    const unit_tests = b.addTest(.{ .name = "tests", .root_module = test_module });
    const run_unit_tests = b.addRunArtifact(unit_tests);
    test_step.dependOn(&run_unit_tests.step);
}
