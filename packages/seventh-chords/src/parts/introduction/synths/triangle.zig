const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;

pub const Chords = @import("./triangle/chords.zig");

pub fn generate(allocator: std.mem.Allocator, options: Options) Wave {
    const sample_rate: f32 = @floatFromInt(options.sample_rate);
    const data: []const f32 = generate_data(options.frequency, options.amplitude, options.length, sample_rate, allocator);
    defer allocator.free(data);

    const result: Wave = Wave.init(data, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });

    return result;
}

fn generate_data(frequency: f32, amplitude: f32, length: usize, sample_rate: f32, allocator: std.mem.Allocator) []const f32 {
    const period: f32 = sample_rate / frequency;

    var result = std.ArrayList(f32).init(allocator);
    for (0..length) |i| {
        const phase = @as(f32, @floatFromInt(i % @as(usize, @intFromFloat(period)))) / period;
        const triangle_value: f32 = if (phase < 0.5)
            (phase * 4.0) - 1.0 // First half
        else
            3.0 - (phase * 4.0); // Second half
        const v: f32 = triangle_value * amplitude;

        result.append(v) catch @panic("Out of memory");
    }

    return result.toOwnedSlice() catch @panic("Out of memory");
}

const Options = struct {
    length: usize,
    frequency: f32,
    amplitude: f32,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};
