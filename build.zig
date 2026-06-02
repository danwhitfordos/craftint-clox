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

const test_sources = [_][]const u8{
    "chunk.zig",
    "scanner.zig",
    "vm.zig",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("main.h"),
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run unit tests");

    for (test_sources) |zigfile| {
        const test_name = std.fs.path.basename(zigfile);

        const zig_test = b.addTest(.{
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

        zig_test.root_module.addCSourceFiles(.{
            .files = object_sources,
            .flags = &.{},
        });

        const run_test = b.addRunArtifact(zig_test);

        test_step.dependOn(&run_test.step);
    }

    const main_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("main.zig"),
        .imports = &.{
            .{
                .name = "c",
                .module = translate_c.createModule(),
            },
        },
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
