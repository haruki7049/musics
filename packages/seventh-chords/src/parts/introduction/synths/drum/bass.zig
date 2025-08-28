const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;

const Scale = @import("../../scale.zig");

pub fn generate(allocator: std.mem.Allocator, options: Options) Wave {
    const frequency: f32 = Scale.generate_freq(.{
        .code = .c,
        .octave = 2,
    });
    const length: usize = 44100;

    const sample_rate: f32 = @floatFromInt(options.sample_rate);
    const bass_drum_data: []const f32 = generate_bass_drum_data(frequency, options.amplitude * 3.0, length, sample_rate, allocator);
    defer allocator.free(bass_drum_data);

    const result: Wave = Wave.init(bass_drum_data, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    }).filter(decay).filter(staccato).filter(decay);
    return result;
}

fn generate_bass_drum_data(frequency: f32, amplitude: f32, length: usize, sample_rate: f32, allocator: std.mem.Allocator) []const f32 {
    const radians_per_sec: f32 = frequency * 2.0 * std.math.pi;

    var result = std.ArrayList(f32).init(allocator);
    defer result.deinit();

    for (0..length) |i| {
        const v: f32 = std.math.sin(@as(f32, @floatFromInt(i)) * radians_per_sec / sample_rate) * amplitude;
        result.append(v) catch @panic("Out of memory");
    }

    return result.toOwnedSlice() catch @panic("Out of memory");
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

    const length: usize = original_wave.data.len / 4;
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

const Options = struct {
    amplitude: f32,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};
