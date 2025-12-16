const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;

const Scale = @import("../../scale.zig");

pub fn generate(allocator: std.mem.Allocator, options: Options) Wave {
    const base_frequency: f32 = 100.0;
    const attack_frequency: f32 = 200.0;
    const length: usize = 8000;

    const sample_rate: f32 = @floatFromInt(options.sample_rate);
    const base_data: []const f32 = generate_sine_data(base_frequency, options.amplitude, length, sample_rate, allocator);
    defer allocator.free(base_data);

    const attack_data: []const f32 = blk: {
        const attack_data_without_zero: []const f32 = generate_sine_data(attack_frequency, options.amplitude / 2, length / 2, sample_rate, allocator);
        defer allocator.free(attack_data_without_zero);

        var zero_data = std.ArrayList(f32).init(allocator);
        defer zero_data.deinit();

        for (0..length / 2) |_|
            zero_data.append(0.0) catch @panic("Out of memory");

        const result: []const f32 = std.mem.concat(allocator, f32, &[_][]const f32{ attack_data_without_zero, zero_data.items }) catch @panic("Out of memory");
        std.debug.assert(result.len == length);

        break :blk result;
    };
    defer allocator.free(attack_data);

    var data: std.array_list.Aligned(f32, null) = .empty;
    defer data.deinit(allocator);

    for (0..base_data.len) |i| {
        const value: f32 = base_data[i] + attack_data[i];
        data.append(allocator, value) catch @panic("Out of memory");
    }

    const result: Wave = Wave.init(data.items, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    }).filter(staccato).filter(decay);
    return result;
}

fn generate_sine_data(frequency: f32, amplitude: f32, length: usize, sample_rate: f32, allocator: std.mem.Allocator) []const f32 {
    const radians_per_sec: f32 = frequency * 2.0 * std.math.pi;

    var result: std.array_list.Aligned(f32, null) = .empty;
    defer result.deinit();

    for (0..length) |i| {
        const v: f32 = std.math.sin(@as(f32, @floatFromInt(i)) * radians_per_sec / sample_rate) * amplitude;
        result.append(allocator, v) catch @panic("Out of memory");
    }

    return result.toOwnedSlice() catch @panic("Out of memory");
}

fn decay(original_wave: Wave) !Wave {
    const allocator = original_wave.allocator;
    var result: std.array_list.Aligned(f32, null) = .empty;

    for (original_wave.data, 0..) |data, n| {
        const i = original_wave.data.len - n;
        const volume: f32 = @as(f32, @floatFromInt(i)) * (1.0 / @as(f32, @floatFromInt(original_wave.data.len)));

        const new_data = data * volume;
        try result.append(allocator, new_data);
    }

    return Wave{
        .data = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
        .bits = original_wave.bits,
    };
}

fn staccato(original_wave: Wave) !Wave {
    const allocator = original_wave.allocator;
    var result: std.array_list.Aligned(f32, null) = .empty;

    const length: usize = original_wave.data.len / 8;
    for (0..length) |i| {
        const v = original_wave.data[i];
        try result.append(allocator, v);
    }

    return Wave{
        .data = try result.toOwnedSlice(allocator),
        .allocator = allocator,

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
