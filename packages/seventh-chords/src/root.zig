const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

const Parts = @import("./parts.zig");

pub fn generate(allocator: std.mem.Allocator, comptime Scale: type, options: Options) Wave {
    const introduction: Wave = Parts.Introduction.generate(allocator, Scale, .{
        .bpm = options.bpm,
        .amplitude = options.amplitude,

        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });

    return introduction;
}

const Options = struct {
    bpm: usize,
    amplitude: f32,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};
