const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

pub fn generate(
    allocator: std.mem.Allocator,
    comptime Scale: type,
    comptime Synth: type,
    options: Options(Scale),
) Wave {
    var wave_list: std.array_list.Aligned(Wave, null) = .empty;
    defer wave_list.deinit(allocator);

    for (options.scales) |scale| {
        const wave: Wave = Synth.generate(allocator, .{
            .frequency = scale.generate_freq(),
            .length = options.length,
            .amplitude = options.amplitude / @as(f32, @floatFromInt(options.scales.len)),

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

pub fn Options(comptime ScaleType: type) type {
    return struct {
        scales: []const ScaleType,
        length: usize,
        amplitude: f32,

        sample_rate: usize,
        channels: usize,
        bits: usize,
    };
}
