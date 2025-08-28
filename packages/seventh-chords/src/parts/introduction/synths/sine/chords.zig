const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

const Sine = @import("../sine.zig");

pub fn major_seventh(allocator: std.mem.Allocator, options: Options) Wave {
    const base: Wave = Sine.generate(allocator, .{
        .frequency = options.base_frequency,
        .length = options.length,
        .amplitude = options.amplitude / 4,

        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });
    defer base.deinit();

    const plus_four: Wave = Sine.generate(allocator, .{
        .frequency = add_half_tones(options.base_frequency, 4.0),
        .length = options.length,
        .amplitude = options.amplitude / 4,

        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });
    defer plus_four.deinit();

    const plus_seven: Wave = Sine.generate(allocator, .{
        .frequency = add_half_tones(options.base_frequency, 7.0),
        .length = options.length,
        .amplitude = options.amplitude / 4,

        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });
    defer plus_seven.deinit();

    const plus_eleven: Wave = Sine.generate(allocator, .{
        .frequency = add_half_tones(options.base_frequency, 11.0),
        .length = options.length,
        .amplitude = options.amplitude / 4,

        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });
    defer plus_eleven.deinit();

    const composer: Composer = Composer.init_with(&[_]WaveInfo{
        .{ .wave = base, .start_point = 0 },
        .{ .wave = plus_four, .start_point = 0 },
        .{ .wave = plus_seven, .start_point = 0 },
        .{ .wave = plus_eleven, .start_point = 0 },
    }, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });
    defer composer.deinit();

    return composer.finalize();
}

fn add_half_tones(base_frequency: f32, intervals: usize) f32 {
    return base_frequency * std.math.pow(f32, 2.0, @as(f32, @floatFromInt(intervals)) / 12.0);
}

const Options = struct {
    base_frequency: f32,
    length: usize,
    amplitude: f32,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};
