const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;

const Self = @This();

pub fn generate(allocator: std.mem.Allocator, options: Options) Wave(f128) {
    const sample_rate: f128 = @floatFromInt(options.sample_rate);
    const data: []const f128 = generate_data(options.frequency, options.amplitude, options.length, sample_rate, allocator);
    defer allocator.free(data);

    const result: Wave(f128) = Wave(f128).init(data, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
    });

    return result;
}

fn generate_data(frequency: f128, amplitude: f128, length: usize, sample_rate: f128, allocator: std.mem.Allocator) []const f128 {
    const period: f128 = sample_rate / frequency;

    var result: std.array_list.Aligned(f128, null) = .empty;
    for (0..length) |i| {
        const phase = @as(f128, @floatFromInt(i % @as(usize, @intFromFloat(period)))) / period;
        const triangle_value: f128 = if (phase < 0.5)
            (phase * 4.0) - 1.0 // First half
        else
            3.0 - (phase * 4.0); // Second half
        const v: f128 = triangle_value * amplitude;

        result.append(allocator, v) catch @panic("Out of memory");
    }

    return result.toOwnedSlice(allocator) catch @panic("Out of memory");
}

pub const Options = struct {
    length: usize,
    frequency: f128,
    amplitude: f128,

    sample_rate: u32,
    channels: u16,
};
