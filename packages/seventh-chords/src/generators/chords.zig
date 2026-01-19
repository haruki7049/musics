const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;

pub fn generate(
    allocator: std.mem.Allocator,
    comptime options: anytype,
) Wave(f128) {
    var wave_list: std.array_list.Aligned(Wave(f128), null) = .empty;
    defer wave_list.deinit(allocator);

    for (options.scales) |scale| {
        var result: Wave(f128) = options.synth.generate(allocator, .{
            .frequency = scale.generate_freq(),
            .length = options.length,
            .amplitude = options.amplitude / @as(f32, @floatFromInt(options.scales.len)),

            .sample_rate = options.sample_rate,
            .channels = options.channels,
        });

        inline for (options.per_sounds) |filter_set| {
            result = result.filter_with(filter_set.args_t, filter_set.filter_fn, .{});
        }

        wave_list.append(allocator, result) catch @panic("Out of memory");
    }

    var waveinfo_list: std.array_list.Aligned(Composer(f128).WaveInfo, null) = .empty;
    defer waveinfo_list.deinit(allocator);

    for (wave_list.items) |wave| {
        waveinfo_list.append(allocator, .{ .wave = wave, .start_point = 0 }) catch @panic("Out of memory");
    }

    const composer: Composer(f128) = Composer(f128).init_with(waveinfo_list.items, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
    });
    defer composer.deinit();

    return composer.finalize(.{});
}
