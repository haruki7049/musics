const std = @import("std");
const lightmix = @import("lightmix");

const bit_type = .i16;

pub fn build(b: *std.Build) !void {
    // `zig build` & `zig build play` code block
    {
        const Root = @import("src/root.zig");
        const Utils = @import("src/utils.zig");
        const wave: lightmix.Wave = Root.generate(b.allocator, .{
            .utils = Utils,

            .bpm = 170,
            .amplitude = 1.0,

            .sample_rate = 44100,
            .channels = 1,
        }).filter(normalize);

        const wave_install_file: *std.Build.Step.InstallFile = try lightmix.addWaveInstallFile(b, wave, .{
            .wave = .{ .name = "result.wav", .bit_type = bit_type },
            .path = .{ .custom = "share" },
        });

        const play_step = try lightmix.addDebugPlayStep(b, wave, .{
            .step = .{ .name = "play" },
            .wave = .{ .name = "result.wav", .bit_type = bit_type },
            .command = &[_][]const u8{"play"}, // pkgs.sox
        });

        play_step.dependOn(&wave_install_file.step);
        b.getInstallStep().dependOn(&wave_install_file.step);
    }

    // `zig build test` code block
    {
        const target = b.standardTargetOptions(.{});
        const optimize = b.standardOptimizeOption(.{});

        // Dependencies
        const lightmix_dep = b.dependency("lightmix", .{ .with_debug_features = true });

        // Modules
        const lib_mod = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        });
        lib_mod.addImport("lightmix", lightmix_dep.module("lightmix"));

        // Unit tests
        const lib_unit_tests = b.addTest(.{ .root_module = lib_mod });
        const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

        // Test step
        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_lib_unit_tests.step);
    }
}

fn normalize(original_wave: lightmix.Wave) !lightmix.Wave {
    const allocator = original_wave.allocator;
    var result: std.array_list.Aligned(f32, null) = .empty;

    var max_volume: f32 = 0.0;
    for (original_wave.data) |sample| {
        if (@abs(sample) > max_volume)
            max_volume = @abs(sample);
    }

    for (original_wave.data) |sample| {
        const volume: f32 = 1.0 / max_volume;

        const new_sample: f32 = sample * volume;
        try result.append(allocator, new_sample);
    }

    return lightmix.Wave{
        .data = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
    };
}
