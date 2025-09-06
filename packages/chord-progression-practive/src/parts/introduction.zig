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

    // Using Diatonic chords
    // Key = F
    const base_chords: []const WaveInfo = &[_]WaveInfo{
        .{ // F major
            .wave = Synths.Sine.Patterns.Sustain.generate(allocator, .{
                .scales = &[_][]const Scale{
                    &[_]Scale{ // F major
                        .{ .code = .f, .octave = 3 },
                        .{ .code = .a, .octave = 3 },
                        .{ .code = .c, .octave = 4 },
                    },
                    &[_]Scale{ // F major
                        .{ .code = .f, .octave = 3 },
                        .{ .code = .a, .octave = 3 },
                        .{ .code = .c, .octave = 4 },
                    },
                },
                .length = samples_per_beat,
                .duration = samples_per_beat / 2,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }),
            .start_point = 0,
        },
        .{ // C major
            .wave = Synths.Sine.Patterns.Sustain.generate(allocator, .{
                .scales = &[_][]const Scale{
                    &[_]Scale{ // C major
                        .{ .code = .c, .octave = 3 },
                        .{ .code = .e, .octave = 3 },
                        .{ .code = .g, .octave = 3 },
                    },
                    &[_]Scale{ // C major
                        .{ .code = .c, .octave = 3 },
                        .{ .code = .e, .octave = 3 },
                        .{ .code = .g, .octave = 3 },
                    },
                },
                .length = samples_per_beat,
                .duration = samples_per_beat / 2,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }),
            .start_point = samples_per_beat * 1,
        },
        .{ // D minor
            .wave = Synths.Sine.Patterns.Sustain.generate(allocator, .{
                .scales = &[_][]const Scale{
                    &[_]Scale{ // D minor
                        .{ .code = .d, .octave = 3 },
                        .{ .code = .f, .octave = 3 },
                        .{ .code = .a, .octave = 3 },
                    },
                    &[_]Scale{ // D minor
                        .{ .code = .d, .octave = 3 },
                        .{ .code = .f, .octave = 3 },
                        .{ .code = .a, .octave = 3 },
                    },
                },
                .length = samples_per_beat,
                .duration = samples_per_beat / 2,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }),
            .start_point = samples_per_beat * 2,
        },
        .{ // D minor seventh major
            .wave = Synths.Sine.Patterns.Sustain.generate(allocator, .{
                .scales = &[_][]const Scale{
                    &[_]Scale{ // D minor seventh
                        .{ .code = .d, .octave = 3 },
                        .{ .code = .f, .octave = 3 },
                        .{ .code = .a, .octave = 3 },
                        .{ .code = .c, .octave = 4 },
                    },
                    &[_]Scale{ // D minor seventh
                        .{ .code = .d, .octave = 3 },
                        .{ .code = .f, .octave = 3 },
                        .{ .code = .a, .octave = 3 },
                        .{ .code = .c, .octave = 4 },
                    },
                },
                .length = samples_per_beat,
                .duration = samples_per_beat / 2,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }),
            .start_point = samples_per_beat * 3,
        },
    };

    const composer: Composer = Composer.init_with(base_chords, allocator, .{
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
