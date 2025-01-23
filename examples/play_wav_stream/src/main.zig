const std = @import("std");

const sl = @import("soloud:c");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.skip(); // skip arg 0
    const args1 = args.next() orelse {
        return error.MissingArgument1;
    };

    const soloud = sl.Soloud_create();
    defer sl.Soloud_destroy(soloud);

    const steam = sl.WavStream_create();
    defer sl.WavStream_destroy(steam);

    if (sl.WavStream_load(steam, args1) != 0) {
        return error.FailToLoadWavStream;
    }

    sl.WavStream_setLooping(steam, 1);

    const init_r = sl.Soloud_init(soloud);
    if (init_r != 0) {
        std.log.debug("Soloud_initEx: {}", .{init_r});
        return error.FailToInitSoloud;
    }
    defer sl.Soloud_deinit(soloud);

    sl.Soloud_setGlobalVolume(soloud, 1);

    std.log.debug("play: {s}", .{args1});
    _ = sl.Soloud_play(soloud, steam);

    std.log.debug("Press Ctrl+C to stop.", .{});
    while (true) {}
}
