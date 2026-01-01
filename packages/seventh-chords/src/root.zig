const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

const Parts = @import("./parts.zig");

pub fn generate(allocator: std.mem.Allocator, comptime options: Options(type, type, type)) Wave {
    const introduction: Wave = Parts.Introduction.generate(allocator, .{
        .scale = options.scale,
        .synths = options.synths,
        .generators = options.generators,

        .bpm = options.bpm,
        .amplitude = options.amplitude,

        .sample_rate = options.sample_rate,
        .channels = options.channels,
    });

    return introduction;
}

pub fn Options(comptime Scale: type, comptime Synthesizers: type, comptime Generators: type) type {
    return struct {
        scale: Scale,
        synths: Synthesizers,
        generators: Generators,

        bpm: usize,
        amplitude: f32,

        sample_rate: usize,
        channels: usize,
    };
}
