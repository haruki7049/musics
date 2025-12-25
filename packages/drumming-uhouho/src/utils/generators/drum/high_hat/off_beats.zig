const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;
const WaveInfo = Composer.WaveInfo;

pub fn generate(
    allocator: std.mem.Allocator,
    comptime Synths: type,
    options: Options,
) Wave {
    const samples_per_beat: usize = @intFromFloat(@as(f32, @floatFromInt(60)) / @as(f32, @floatFromInt(options.bpm)) * @as(f32, @floatFromInt(options.sample_rate)));

    var waveinfo_list: std.array_list.Aligned(WaveInfo, null) = .empty;
    defer waveinfo_list.deinit(allocator);

    {
        var wave_list: std.array_list.Aligned(Wave, null) = .empty;
        defer wave_list.deinit(allocator);

        for (0..8) |_| {
            var result: Wave = undefined;

            switch (options.state) {
                .closed => {
                    result = Synths.HighHat.Closed.generate(allocator, .{
                        .amplitude = options.amplitude,

                        .sample_rate = options.sample_rate,
                        .channels = options.channels,
                    });
                },
                .opened => {
                    result = Synths.HighHat.Opened.generate(allocator, .{
                        .amplitude = options.amplitude,

                        .sample_rate = options.sample_rate,
                        .channels = options.channels,
                    });
                },
            }

            wave_list.append(allocator, result) catch @panic("Out of memory");
        }

        var start_point: usize = samples_per_beat / 2;
        for (wave_list.items) |wave| {
            waveinfo_list.append(allocator, .{ .wave = wave, .start_point = start_point }) catch @panic("Out of memory");

            start_point = start_point + samples_per_beat;
        }
    }

    const composer: Composer = Composer.init_with(waveinfo_list.items, allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
    });
    defer composer.deinit();

    return composer.finalize(.{});
}

pub const Options = struct {
    bpm: usize,
    amplitude: f32,
    state: HighHatState,

    sample_rate: usize,
    channels: usize,
};

const HighHatState = enum {
    closed,
    opened,
};
