const std = @import("std");
const l = @import("lightmix");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lightmix = b.dependency("lightmix", .{});

    const mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "lightmix", .module = lightmix.module("lightmix") },
        },
    });

    const wave_step = try l.createWave(b, mod, .{
        .func_name = "gen",
        .wave = .{ .bits = 16, .format_code = .pcm },
    });
    b.getInstallStep().dependOn(wave_step);

    // Unit tests
    const unit_tests = b.addTest(.{ .root_module = mod });
    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Test step
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

fn normalize(original_wave: l.Wave(f128)) !l.Wave(f128) {
    const allocator = original_wave.allocator;
    var result: std.array_list.Aligned(f128, null) = .empty;

    var max_volume: f128 = 0.0;
    for (original_wave.data) |sample| {
        if (@abs(sample) > max_volume)
            max_volume = @abs(sample);
    }

    for (original_wave.data) |sample| {
        const volume: f128 = 1.0 / max_volume;

        const new_sample: f128 = sample * volume;
        try result.append(allocator, new_sample);
    }

    return l.Wave(f128){
        .data = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
    };
}
