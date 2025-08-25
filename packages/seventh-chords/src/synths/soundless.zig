const std = @import("std");
const lightmix = @import("lightmix");
const e_minor = @import("e-minor");

const Wave = lightmix.Wave;

pub fn generate(allocator: std.mem.Allocator, options: Options) Wave {
    const base_data: []const f32 = generate_data(options.length, allocator);
    defer allocator.free(base_data);

    const result: Wave = Wave.init(base_data, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });

    return result;
}

fn generate_data(length: usize, allocator: std.mem.Allocator) []const f32 {
    var result = std.ArrayList(f32).init(allocator);
    defer result.deinit();

    for (0..length) |_| {
        const v: f32 = 0.0;
        result.append(v) catch @panic("Out of memory");
    }

    return result.toOwnedSlice() catch @panic("Out of memory");
}

const Options = struct {
    length: usize,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};
