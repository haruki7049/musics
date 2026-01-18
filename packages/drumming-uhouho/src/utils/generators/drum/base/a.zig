const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;

pub fn generate(allocator: std.mem.Allocator, comptime options: Options(type)) Wave(f128) {
    const samples_per_beat: usize = @intFromFloat(@as(f32, @floatFromInt(60)) / @as(f32, @floatFromInt(options.bpm)) * @as(f32, @floatFromInt(options.sample_rate)));

    var waveinfo_list: std.array_list.Aligned(Composer(f128).WaveInfo, null) = .empty;
    defer waveinfo_list.deinit(allocator);

    {
        var wave_list: std.array_list.Aligned(Wave(f128), null) = .empty;
        defer wave_list.deinit(allocator);

        for (0..7) |_| {
            var result: Wave(f128) = options.utils.Synths.Sine.generate(allocator, .{
                .frequency = options.frequency,
                .length = samples_per_beat,
                .amplitude = options.amplitude,

                .sample_rate = options.sample_rate,
                .channels = options.channels,
            });

            // Filters
            const cutAttackOptions = options.utils.Filters.Volume.cutAttackOptions;
            const cut_attack = options.utils.Filters.Volume.cut_attack;

            for (0..1) |_| {
                result = result.filter_with(cutAttackOptions, cut_attack, .{});
            }

            const decayOptions = options.utils.Filters.Volume.decayOptions;
            const decay = options.utils.Filters.Volume.decay;

            for (0..6) |_| {
                result = result.filter_with(decayOptions, decay, .{});
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
        var wave_list: std.array_list.Aligned(Wave(f128), null) = .empty;
        defer wave_list.deinit(allocator);

        for (0..2) |_| {
            var result: Wave(f128) = options.utils.Synths.Sine.generate(allocator, .{
                .frequency = options.frequency,
                .length = samples_per_beat,
                .amplitude = options.amplitude,

                .sample_rate = options.sample_rate,
                .channels = options.channels,
            });

            // Filters
            const cutAttackOptions = options.utils.Filters.Volume.cutAttackOptions;
            const cut_attack = options.utils.Filters.Volume.cut_attack;

            for (0..1) |_| {
                result = result.filter_with(cutAttackOptions, cut_attack, .{});
            }

            const decayOptions = options.utils.Filters.Volume.decayOptions;
            const decay = options.utils.Filters.Volume.decay;

            for (0..6) |_| {
                result = result.filter_with(decayOptions, decay, .{});
            }

            wave_list.append(allocator, result) catch @panic("Out of memory");
        }

        var start_point: usize = samples_per_beat * 7;
        for (wave_list.items) |wave| {
            waveinfo_list.append(allocator, .{ .wave = wave, .start_point = start_point }) catch @panic("Out of memory");

            start_point = start_point + (samples_per_beat / 2);
        }
    }

    const composer = Composer(f128).init_with(waveinfo_list.items, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
    });
    defer composer.deinit();

    return composer.finalize(.{});
}

pub fn Options(comptime Utils: type) type {
    return struct {
        utils: Utils,

        bpm: usize,
        frequency: f32,
        amplitude: f32,
        sample_rate: usize,
        channels: usize,
    };
}
