const std = @import("std");

const object_sources = &.{
    "chunk.c",
    "memory.c",
    "debug.c",
    "value.c",
    "vm.c",
    "compiler.c",
    "scanner.c",
    "object.c",
    "table.c",
};

fn create_test(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, header: []const u8, test_name: []const u8, zigfile: []const u8) *std.Build.Step.Run {
    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path(header),
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.addTest(.{
        .name = test_name,
        .root_module = b.createModule(.{
            .root_source_file = b.path(zigfile),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{
                .{
                    .name = "c",
                    .module = translate_c.createModule(),
                },
            },
        }),
    });

    test_step.root_module.addCSourceFiles(.{
        .files = object_sources,
        .flags = &.{},
    });

    return b.addRunArtifact(test_step);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const run_chunk_tests = create_test(b, target, optimize, "./chunk.h", "chunk test", "chunk.zig");
    const run_scanner_tests = create_test(b, target, optimize, "./scanner.h", "scanner test", "scanner.zig");
    const run_vm_tests = create_test(b, target, optimize, "./vm.h", "vm test", "vm.zig");

    const test_step = b.step("test", "Run unit tests");

    test_step.dependOn(&run_scanner_tests.step);
    test_step.dependOn(&run_chunk_tests.step);
    test_step.dependOn(&run_vm_tests.step);

    const main_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    main_module.addCSourceFile(.{
        .file = b.path("main.c"),
        .flags = &[_][]const u8{"-std=c23"},
    });

    const exe = b.addExecutable(.{
        .name = "main",
        .root_module = main_module,
    });

    exe.root_module.addCSourceFiles(.{
        .files = object_sources,
        .flags = &.{
            "-Wall",
            "-Wextra",
            "-Wpedantic",
            "-Werror",
            "-std=c23",
        },
    });
    exe.root_module.addIncludePath(.{ .cwd_relative = "." });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
