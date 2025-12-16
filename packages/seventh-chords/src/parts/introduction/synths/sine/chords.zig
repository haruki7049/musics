const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

const Sine = @import("../sine.zig");
const Scale = @import("../../scale.zig");

pub fn generate(allocator: std.mem.Allocator, options: Options) Wave {
    var wave_list: std.array_list.Aligned(Wave, null) = .empty;
    defer wave_list.deinit(allocator);

    for (options.scales) |scale| {
        const wave: Wave = Sine.generate(allocator, .{
            .frequency = scale.generate_freq(),
            .length = options.length,
            .amplitude = options.amplitude / @as(f32, @floatFromInt(options.scales.len)), // Reduce volume when scales are incremented

            .sample_rate = options.sample_rate,
            .channels = options.channels,
            .bits = options.bits,
        });

        wave_list.append(allocator, wave) catch @panic("Out of memory");
    }

    var waveinfo_list: std.array_list.Aligned(WaveInfo, null) = .empty;
    defer waveinfo_list.deinit(allocator);

    for (wave_list.items) |wave| {
        waveinfo_list.append(allocator, .{ .wave = wave, .start_point = 0 }) catch @panic("Out of memory");
    }

    const composer: Composer = Composer.init_with(waveinfo_list.items, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });
    defer composer.deinit();

    return composer.finalize();
}

const Options = struct {
    scales: []const Scale,
    length: usize,
    amplitude: f32,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};
