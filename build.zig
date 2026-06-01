const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("./scanner.h"),
        .target = target,
        .optimize = optimize,
    });

    const app_tests = b.addTest(.{
        .name = "scanner test",
        .root_module = b.createModule(.{
            .root_source_file = b.path("scanner.zig"),
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

    app_tests.root_module.addCSourceFile(.{
        .file = b.path("scanner.c"),
        .flags = &.{},
    });

    const run_app_tests = b.addRunArtifact(app_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_app_tests.step);

    

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
    const sources = &.{
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
    exe.root_module.addCSourceFiles(.{
        .files = sources,
        .flags = &.{
            "-Wall",
            "-Wextra",
            "-Wpedantic",
            "-Werror",
            "-g",
            "-std=c23",
        },
    });
    exe.root_module.addIncludePath(.{ .cwd_relative = "." });

    b.installArtifact(exe);
}