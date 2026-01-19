const std = @import("std");
const lightmix = @import("lightmix");
const lightmix_filters = @import("lightmix_filters");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;

const decay = lightmix_filters.volume.decay;
const DecayArgs = lightmix_filters.volume.DecayArgs;

fn Options(comptime Scale: type, comptime Synths: type, comptime Generators: type) type {
    return struct {
        scale: Scale,
        synths: Synths,
        generators: Generators,

        bpm: usize,
        amplitude: f32,

        sample_rate: u32,
        channels: u16,
    };
}

pub fn generate(allocator: std.mem.Allocator, comptime options: Options(type, type, type)) Wave(f128) {
    const samples_per_beat: usize = @intFromFloat(@as(f32, @floatFromInt(60)) / @as(f32, @floatFromInt(options.bpm)) * @as(f32, @floatFromInt(options.sample_rate)));

    const melodies: []const Composer(f128).WaveInfo = &.{
        .{
            .wave = options.generators.Arpeggio.generate(allocator, .{
                .synth = options.synths.Triangle,
                .scales = &[_]options.scale{
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
                .per_sounds = &.{
                    .{ .filter_fn = &decay, .args_t = DecayArgs },
                },
            }),
            .start_point = samples_per_beat * 0,
        },
        .{
            .wave = options.generators.Arpeggio.generate(allocator, .{
                .synth = options.synths.Triangle,
                .scales = &[_]options.scale{
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
                .per_sounds = &.{
                    .{ .filter_fn = &decay, .args_t = DecayArgs },
                },
            }),
            .start_point = samples_per_beat * 4,
        },
        .{
            .wave = options.generators.Arpeggio.generate(allocator, .{
                .synth = options.synths.Triangle,
                .scales = &[_]options.scale{
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
                .per_sounds = &.{
                    .{ .filter_fn = &decay, .args_t = DecayArgs },
                },
            }),
            .start_point = samples_per_beat * 8,
        },
        .{
            .wave = options.generators.Arpeggio.generate(allocator, .{
                .synth = options.synths.Triangle,
                .scales = &[_]options.scale{
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
                .per_sounds = &.{
                    .{ .filter_fn = &decay, .args_t = DecayArgs },
                },
            }),
            .start_point = samples_per_beat * 12,
        },
    };

    const base_chords: []const Composer(f128).WaveInfo = &.{
        .{
            .wave = options.generators.Chords.generate(allocator, .{
                .synth = options.synths.Sine,
                .scales = &[_]options.scale{
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .e, .octave = 4 },
                    .{ .code = .g, .octave = 4 },
                    .{ .code = .b, .octave = 4 },
                },
                .length = samples_per_beat * 4,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .per_sounds = &.{
                    .{ .filter_fn = &decay, .args_t = DecayArgs },
                },
            }),
            .start_point = samples_per_beat * 0,
        },
        .{
            .wave = options.generators.Chords.generate(allocator, .{
                .synth = options.synths.Sine,
                .scales = &[_]options.scale{
                    .{ .code = .d, .octave = 4 },
                    .{ .code = .f, .octave = 4 },
                    .{ .code = .a, .octave = 4 },
                    .{ .code = .c, .octave = 5 },
                },
                .length = samples_per_beat * 4,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .per_sounds = &.{
                    .{ .filter_fn = &decay, .args_t = DecayArgs },
                },
            }),
            .start_point = samples_per_beat * 4,
        },
        .{
            .wave = options.generators.Chords.generate(allocator, .{
                .synth = options.synths.Sine,
                .scales = &[_]options.scale{
                    .{ .code = .c, .octave = 4 },
                    .{ .code = .e, .octave = 4 },
                    .{ .code = .g, .octave = 4 },
                    .{ .code = .b, .octave = 4 },
                },
                .length = samples_per_beat * 4,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .per_sounds = &.{
                    .{ .filter_fn = &decay, .args_t = DecayArgs },
                },
            }),
            .start_point = samples_per_beat * 8,
        },
        .{
            .wave = options.generators.Chords.generate(allocator, .{
                .synth = options.synths.Sine,
                .scales = &[_]options.scale{
                    .{ .code = .d, .octave = 4 },
                    .{ .code = .f, .octave = 4 },
                    .{ .code = .a, .octave = 4 },
                    .{ .code = .c, .octave = 5 },
                },
                .length = samples_per_beat * 4,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .per_sounds = &.{
                    .{ .filter_fn = &decay, .args_t = DecayArgs },
                },
            }),
            .start_point = samples_per_beat * 12,
        },
    };

    const samples: []const Composer(f128).WaveInfo = std.mem.concat(allocator, Composer(f128).WaveInfo, &[_][]const Composer(f128).WaveInfo{ melodies, base_chords }) catch @panic("Out of memory");
    defer allocator.free(samples);

    const composer: Composer(f128) = Composer(f128).init_with(samples, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
    });
    defer composer.deinit();

    return composer.finalize(.{});
}
