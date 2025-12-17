const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

const Triangle = @import("../triangle.zig");

pub fn generate(allocator: std.mem.Allocator, comptime Scale: type, options: Options(Scale)) Wave {
    var wave_list: std.array_list.Aligned(Wave, null) = .empty;
    defer wave_list.deinit(allocator);

    for (options.scales) |scale| {
        const wave: Wave = Triangle.generate(allocator, .{
            .frequency = scale.generate_freq(),
            .length = options.length,
            .amplitude = options.amplitude,

            .sample_rate = options.sample_rate,
            .channels = options.channels,
            .bits = options.bits,
        }).filter(decay);

        wave_list.append(allocator, wave) catch @panic("Out of memory");
    }

    var waveinfo_list: std.array_list.Aligned(WaveInfo, null) = .empty;
    defer waveinfo_list.deinit(allocator);

    var start_point: usize = 0;
    for (wave_list.items) |wave| {
        waveinfo_list.append(allocator, .{ .wave = wave, .start_point = start_point }) catch @panic("Out of memory");

        start_point = start_point + options.duration;
    }

    const composer: Composer = Composer.init_with(waveinfo_list.items, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });
    defer composer.deinit();

    return composer.finalize();
}

pub fn Options(comptime T: type) type {
    return struct {
        scales: []const T,
        length: usize,
        duration: usize,
        amplitude: f32,

        sample_rate: usize,
        channels: usize,
        bits: usize,
    };
}

fn decay(original_wave: Wave) !Wave {
    const allocator = original_wave.allocator;
    var result: std.array_list.Aligned(f32, null) = .empty;

    for (original_wave.data, 0..) |data, n| {
        const i = original_wave.data.len - n;
        const volume: f32 = @as(f32, @floatFromInt(i)) * (1.0 / @as(f32, @floatFromInt(original_wave.data.len)));

        const new_data = data * volume;
        try result.append(allocator, new_data);
    }

    return Wave{
        .data = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
        .bits = original_wave.bits,
    };
}
