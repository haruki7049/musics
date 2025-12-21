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
            .wave = options.generators.Drum.Base.A.generate(allocator, options.scale, options.synths.Sine, .{
                .scale = .{ .code = .c, .octave = 2 },
                .bpm = options.bpm,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }),
            .start_point = samples_per_beat * 0,
        },
        .{
            .wave = options.generators.Drum.Base.A.generate(allocator, options.scale, options.synths.Sine, .{
                .scale = .{ .code = .c, .octave = 2 },
                .bpm = options.bpm,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }),
            .start_point = samples_per_beat * 8,
        },
        .{
            .wave = options.generators.Drum.Base.A.generate(allocator, options.scale, options.synths.Sine, .{
                .scale = .{ .code = .c, .octave = 2 },
                .bpm = options.bpm,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }),
            .start_point = samples_per_beat * 16,
        },
        .{
            .wave = options.generators.Drum.Base.A.generate(allocator, options.scale, options.synths.Sine, .{
                .scale = .{ .code = .c, .octave = 2 },
                .bpm = options.bpm,
                .amplitude = options.amplitude,
                .sample_rate = options.sample_rate,
                .channels = options.channels,
                .bits = options.bits,
            }),
            .start_point = samples_per_beat * 24,
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
