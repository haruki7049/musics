const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

fn Options(comptime Scale: type, comptime Synths: type, comptime Generators: type) type {
    return struct {
        scale: Scale,
        synths: Synths,
        generators: Generators,

        bpm: usize,
        amplitude: f32,

        sample_rate: usize,
        channels: usize,
        bits: usize,
    };
}

pub fn generate(allocator: std.mem.Allocator, comptime options: Options(type, type, type)) Wave {
    const samples_per_beat: usize = @intFromFloat(@as(f32, @floatFromInt(60)) / @as(f32, @floatFromInt(options.bpm)) * @as(f32, @floatFromInt(options.sample_rate)));

    const melodies: []const WaveInfo = &[_]WaveInfo{
        .{
            .wave = options.generators.Equidistant.generate(allocator, options.scale, options.synths.Sine, .{
                .scales = &[_]options.scale{
                    // C4 for 16 times
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .c, .octave = 4 },
                },
                .length = samples_per_beat / 2,
                .duration = samples_per_beat / 2,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
                .per_sound_filters = &.{
                    &decay,
                },
            }),
            .start_point = samples_per_beat * 0,
        },
    };

    const composer: Composer = Composer.init_with(melodies, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });
    defer composer.deinit();

    return composer.finalize();
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

fn staccato(original_wave: Wave) !Wave {
    const allocator = original_wave.allocator;
    var result: std.array_list.Aligned(f32, null) = .empty;

    const length: usize = 8000;
    for (0..length) |i| {
        const v = original_wave.data[i];
        try result.append(allocator, v);
    }

    return Wave{
        .data = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
        .bits = original_wave.bits,
    };
}
