const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

const Scale = @import("./introduction/scale.zig");
const Synths = @import("./introduction/synths.zig");

const Options = struct {
    bpm: usize,
    amplitude: f32,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};

pub fn generate(allocator: std.mem.Allocator, options: Options) Wave {
    const samples_per_beat: usize = @intFromFloat(@as(f32, @floatFromInt(60)) / @as(f32, @floatFromInt(options.bpm)) * @as(f32, @floatFromInt(options.sample_rate)));

    const melodies: []const WaveInfo = &[_]WaveInfo{
        .{
            .wave = Synths.Triangle.Equidistant.generate(allocator, .{
                .scales = &[_]Scale{
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .e, .octave = 4 },
                    .{ .code = .g, .octave = 4 },
                    .{ .code = .b, .octave = 4 },
                },
                .length = samples_per_beat / 2,
                .duration = samples_per_beat / 2,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }),
            .start_point = samples_per_beat * 0,
        },
        .{
            .wave = Synths.Triangle.Equidistant.generate(allocator, .{
                .scales = &[_]Scale{
                    .{ .code = .d, .octave = 4 },
                    .{ .code = .f, .octave = 4 },
                    .{ .code = .a, .octave = 4 },
                    .{ .code = .c, .octave = 5 },
                },
                .length = samples_per_beat / 2,
                .duration = samples_per_beat / 2,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }),
            .start_point = samples_per_beat * 4,
        },
        .{
            .wave = Synths.Triangle.Equidistant.generate(allocator, .{
                .scales = &[_]Scale{
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .e, .octave = 4 },
                    .{ .code = .g, .octave = 4 },
                    .{ .code = .b, .octave = 4 },
                },
                .length = samples_per_beat / 2,
                .duration = samples_per_beat / 2,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }),
            .start_point = samples_per_beat * 8,
        },
        .{
            .wave = Synths.Triangle.Equidistant.generate(allocator, .{
                .scales = &[_]Scale{
                    .{ .code = .d, .octave = 4 },
                    .{ .code = .f, .octave = 4 },
                    .{ .code = .a, .octave = 4 },
                    .{ .code = .c, .octave = 5 },
                },
                .length = samples_per_beat / 2,
                .duration = samples_per_beat / 2,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }),
            .start_point = samples_per_beat * 12,
        },
    };

    const base_chords: []const WaveInfo = &[_]WaveInfo{
        .{
            .wave = Synths.Sine.Chords.generate(allocator, .{
                .scales = &[_]Scale{
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .e, .octave = 4 },
                    .{ .code = .g, .octave = 4 },
                    .{ .code = .b, .octave = 4 },
                },
                .length = samples_per_beat * 4,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }).filter(decay),
            .start_point = samples_per_beat * 0,
        },
        .{
            .wave = Synths.Sine.Chords.generate(allocator, .{
                .scales = &[_]Scale{
                    .{ .code = .d, .octave = 4 },
                    .{ .code = .f, .octave = 4 },
                    .{ .code = .a, .octave = 4 },
                    .{ .code = .c, .octave = 5 },
                },
                .length = samples_per_beat * 4,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }).filter(decay),
            .start_point = samples_per_beat * 4,
        },
        .{
            .wave = Synths.Sine.Chords.generate(allocator, .{
                .scales = &[_]Scale{
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .e, .octave = 4 },
                    .{ .code = .g, .octave = 4 },
                    .{ .code = .b, .octave = 4 },
                },
                .length = samples_per_beat * 4,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }).filter(decay),
            .start_point = samples_per_beat * 8,
        },
        .{
            .wave = Synths.Sine.Chords.generate(allocator, .{
                .scales = &[_]Scale{
                    .{ .code = .d, .octave = 4 },
                    .{ .code = .f, .octave = 4 },
                    .{ .code = .a, .octave = 4 },
                    .{ .code = .c, .octave = 5 },
                },
                .length = samples_per_beat * 4,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }).filter(decay),
            .start_point = samples_per_beat * 12,
        },
    };

    const data: []const WaveInfo = std.mem.concat(allocator, WaveInfo, &[_][]const WaveInfo{ melodies, base_chords }) catch @panic("Out of memory");
    defer allocator.free(data);

    const composer: Composer = Composer.init_with(data, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });
    defer composer.deinit();

    return composer.finalize();
}

fn decay(original_wave: Wave) !Wave {
    var result = std.ArrayList(f32).init(original_wave.allocator);

    for (original_wave.data, 0..) |data, n| {
        const i = original_wave.data.len - n;
        const volume: f32 = @as(f32, @floatFromInt(i)) * (1.0 / @as(f32, @floatFromInt(original_wave.data.len)));

        const new_data = data * volume;
        try result.append(new_data);
    }

    return Wave{
        .data = try result.toOwnedSlice(),
        .allocator = original_wave.allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
        .bits = original_wave.bits,
    };
}

fn staccato(original_wave: Wave) !Wave {
    var result = std.ArrayList(f32).init(original_wave.allocator);

    const length: usize = 8000;
    for (0..length) |i| {
        const v = original_wave.data[i];
        try result.append(v);
    }

    return Wave{
        .data = try result.toOwnedSlice(),
        .allocator = original_wave.allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
        .bits = original_wave.bits,
    };
}
