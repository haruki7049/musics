const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;

pub fn generate(
    allocator: std.mem.Allocator,
    comptime Scale: type,
    comptime Synth: type,
    comptime options: Options(Scale),
) Wave(f128) {
    var wave_list: std.array_list.Aligned(Wave(f128), null) = .empty;
    defer wave_list.deinit(allocator);

    for (options.scales) |scale| {
        var result: Wave(f128) = Synth.generate(allocator, .{
            .frequency = scale.generate_freq(),
            .length = options.length,
            .amplitude = options.amplitude,

            .sample_rate = options.sample_rate,
            .channels = options.channels,
        });

        inline for (options.per_sound_filters) |f| {
            result = result.filter(f.*);
        }

        wave_list.append(allocator, result) catch @panic("Out of memory");
    }

    var waveinfo_list: std.array_list.Aligned(Composer(f128).WaveInfo, null) = .empty;
    defer waveinfo_list.deinit(allocator);

    var start_point: usize = 0;
    for (wave_list.items) |wave| {
        waveinfo_list.append(allocator, .{ .wave = wave, .start_point = start_point }) catch @panic("Out of memory");

        start_point = start_point + options.duration;
    }

    const composer: Composer(f128) = Composer(f128).init_with(waveinfo_list.items, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
    });
    defer composer.deinit();

    return composer.finalize(.{});
}

pub fn Options(comptime ScaleType: type) type {
    return struct {
        scales: []const ScaleType,
        length: usize,
        duration: usize,
        amplitude: f32,

        sample_rate: usize,
        channels: usize,
        per_sound_filters: []const *const fn (Wave(f128)) anyerror!Wave(f128),
    };
}
