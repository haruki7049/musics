const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

pub fn generate(
    allocator: std.mem.Allocator,
    comptime Scale: type,
    comptime Synth: type,
    comptime options: Options(Scale),
) Wave {
    const samples_per_beat: usize = @intFromFloat(@as(f32, @floatFromInt(60)) / @as(f32, @floatFromInt(options.bpm)) * @as(f32, @floatFromInt(options.sample_rate)));

    var waveinfo_list: std.array_list.Aligned(WaveInfo, null) = .empty;
    defer waveinfo_list.deinit(allocator);

    {
        var wave_list: std.array_list.Aligned(Wave, null) = .empty;
        defer wave_list.deinit(allocator);

        for (0..7) |_| {
            var result: Wave = Synth.generate(allocator, .{
                .frequency = options.scale.generate_freq(),
                .length = samples_per_beat,
                .amplitude = options.amplitude,

                .sample_rate = options.sample_rate,
                .channels = options.channels,
            });

            // Filters
            const filters = &.{
                &cut_attack,
                &decay,
                &decay,
                &decay,
                &decay,
                &decay,
                &decay,
            };
            inline for (filters) |f| {
                result = result.filter(f.*);
            }

            wave_list.append(allocator, result) catch @panic("Out of memory");
        }

        var start_point: usize = 0;
        for (wave_list.items) |wave| {
            waveinfo_list.append(allocator, .{ .wave = wave, .start_point = start_point }) catch @panic("Out of memory");

            start_point = start_point + samples_per_beat;
        }
    }

    {
        var wave_list: std.array_list.Aligned(Wave, null) = .empty;
        defer wave_list.deinit(allocator);

        for (0..2) |_| {
            var result: Wave = Synth.generate(allocator, .{
                .frequency = options.scale.generate_freq(),
                .length = samples_per_beat,
                .amplitude = options.amplitude,

                .sample_rate = options.sample_rate,
                .channels = options.channels,
            });

            // Filters
            const filters = &.{
                &cut_attack,
                &decay,
                &decay,
                &decay,
                &decay,
                &decay,
                &decay,
            };
            inline for (filters) |f| {
                result = result.filter(f.*);
            }

            wave_list.append(allocator, result) catch @panic("Out of memory");
        }

        var start_point: usize = samples_per_beat * 7;
        for (wave_list.items) |wave| {
            waveinfo_list.append(allocator, .{ .wave = wave, .start_point = start_point }) catch @panic("Out of memory");

            start_point = start_point + (samples_per_beat / 2);
        }
    }

    const composer: Composer = Composer.init_with(waveinfo_list.items, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
    });
    defer composer.deinit();

    return composer.finalize();
}

pub fn Options(comptime ScaleType: type) type {
    return struct {
        scale: ScaleType,

        bpm: usize,
        amplitude: f32,

        sample_rate: usize,
        channels: usize,
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
    };
}

fn cut_attack(original_wave: Wave) !Wave {
    const allocator = original_wave.allocator;
    var result: std.array_list.Aligned(f32, null) = .empty;

    const length: usize = 100;
    for (original_wave.data, 1..) |data, n| {
        if (n < length) {
            const percent: f32 = @floatFromInt(n / length);
            try result.append(allocator, percent * data);

            continue;
        }

        try result.append(allocator, data);
    }

    return Wave{
        .data = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
    };
}
