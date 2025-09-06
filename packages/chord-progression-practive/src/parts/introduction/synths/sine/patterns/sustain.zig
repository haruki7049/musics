const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

const Sine = @import("../../sine.zig");
const Scale = @import("../../../scale.zig");

pub fn generate(allocator: std.mem.Allocator, options: Options) Wave {
    var wave_list = std.ArrayList(Wave).init(allocator);
    defer wave_list.deinit();

    var length: usize = 0;
    for (options.scales, 1..) |scale_list, i| {
        length = options.length / i;

        const wave: Wave = Sine.Patterns.Chords.generate(allocator, .{
            .scales = scale_list,
            .length = length,
            .amplitude = options.amplitude / @as(f32, @floatFromInt(options.scales.len)), // Reduce volume when scales are incremented

            .sample_rate = options.sample_rate,
            .channels = options.channels,
            .bits = options.bits,
        });

        wave_list.append(wave) catch @panic("Out of memory");
    }

    var waveinfo_list = std.ArrayList(WaveInfo).init(allocator);
    defer waveinfo_list.deinit();

    var start_point: usize = 0;
    for (wave_list.items, 0..) |wave, i| {
        start_point = options.duration * i;
        waveinfo_list.append(.{ .wave = wave, .start_point = start_point }) catch @panic("Out of memory");
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
    scales: []const []const Scale,
    length: usize,
    duration: usize,
    amplitude: f32,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};
