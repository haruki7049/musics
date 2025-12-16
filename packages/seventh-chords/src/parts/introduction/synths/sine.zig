const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;

pub const Chords = @import("./sine/chords.zig");

pub fn generate(allocator: std.mem.Allocator, options: Options) Wave {
    const sample_rate: f32 = @floatFromInt(options.sample_rate);
    const base_data: []const f32 = generate_sine_data(options.frequency, options.amplitude, options.length, sample_rate, allocator);
    defer allocator.free(base_data);

    const result: Wave = Wave.init(base_data, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });

    return result;
}

fn generate_sine_data(frequency: f32, amplitude: f32, length: usize, sample_rate: f32, allocator: std.mem.Allocator) []const f32 {
    const radians_per_sec: f32 = frequency * 2.0 * std.math.pi;

    var result: std.array_list.Aligned(f32, null) = .empty;
    defer result.deinit(allocator);

    for (0..length) |i| {
        const v: f32 = std.math.sin(@as(f32, @floatFromInt(i)) * radians_per_sec / sample_rate) * amplitude;
        result.append(allocator, v) catch @panic("Out of memory");
    }

    return result.toOwnedSlice(allocator) catch @panic("Out of memory");
}

const Options = struct {
    length: usize,
    frequency: f32,
    amplitude: f32,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};
