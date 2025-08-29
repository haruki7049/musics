const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

const Triangle = @import("../triangle.zig");
const Scale = @import("../../scale.zig");

pub const Seventh = struct {
    pub fn minor(allocator: std.mem.Allocator, options: Options) Wave {
        const base_frequency: f32 = Scale.generate_freq(.{ .code = .d, .octave = options.octave, });

        const base: Wave = Triangle.generate(allocator, .{
            .frequency = base_frequency,
            .length = options.length,
            .amplitude = options.amplitude / 4,
            .sample_rate = options.sample_rate,
            .channels = options.channels,
            .bits = options.bits,
        });
        defer base.deinit();

        const plus_four: Wave = Triangle.generate(allocator, .{
            .frequency = add_half_tones(base_frequency, 3.0),
            .length = options.length,
            .amplitude = options.amplitude / 4,

            .sample_rate = options.sample_rate,
            .channels = options.channels,
            .bits = options.bits,
        });
        defer plus_four.deinit();

        const plus_seven: Wave = Triangle.generate(allocator, .{
            .frequency = add_half_tones(base_frequency, 7.0),
            .length = options.length,
            .amplitude = options.amplitude / 4,

            .sample_rate = options.sample_rate,
            .channels = options.channels,
            .bits = options.bits,
        });
        defer plus_seven.deinit();

        const plus_eleven: Wave = Triangle.generate(allocator, .{
            .frequency = add_half_tones(base_frequency, 10.0),
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

    pub fn major(allocator: std.mem.Allocator, options: Options) Wave {
        const base_frequency: f32 = Scale.generate_freq(.{ .code = .c, .octave = options.octave, });

        const base: Wave = Triangle.generate(allocator, .{
            .frequency = base_frequency,
            .length = options.length,
            .amplitude = options.amplitude / 4,
            .sample_rate = options.sample_rate,
            .channels = options.channels,
            .bits = options.bits,
        });
        defer base.deinit();

        const plus_four: Wave = Triangle.generate(allocator, .{
            .frequency = add_half_tones(base_frequency, 4.0),
            .length = options.length,
            .amplitude = options.amplitude / 4,

            .sample_rate = options.sample_rate,
            .channels = options.channels,
            .bits = options.bits,
        });
        defer plus_four.deinit();

        const plus_seven: Wave = Triangle.generate(allocator, .{
            .frequency = add_half_tones(base_frequency, 7.0),
            .length = options.length,
            .amplitude = options.amplitude / 4,

            .sample_rate = options.sample_rate,
            .channels = options.channels,
            .bits = options.bits,
        });
        defer plus_seven.deinit();

        const plus_eleven: Wave = Triangle.generate(allocator, .{
            .frequency = add_half_tones(base_frequency, 11.0),
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
};
fn add_half_tones(base_frequency: f32, intervals: usize) f32 {
    return base_frequency * std.math.pow(f32, 2.0, @as(f32, @floatFromInt(intervals)) / 12.0);
}

const Options = struct {
    octave: usize,
    length: usize,
    amplitude: f32,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};
