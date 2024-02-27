const std = @import("std");

const tyon_version = std.SemanticVersion{ .major = 0, .minor = 5, .patch = 0 };
const spec_version = std.SemanticVersion{ .major = 1, .minor = 0, .patch = 0, .pre = "rc.1" };
const data_version = std.SemanticVersion{ .major = 1, .minor = 0, .patch = 0, .pre = "rc.1" };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len == 2 and std.ascii.eqlIgnoreCase(args[1], "help")) {
        printUsage();
    } else if (args.len == 2 and std.ascii.eqlIgnoreCase(args[1], "version")) {
        std.debug.print("tyon {}\nspec {}\ndata {}\n", .{ tyon_version, spec_version, data_version });
    } else {
        printUsage();
        return error.InvalidCommand;
    }
}

fn printUsage() void {
    std.debug.print(
        \\Usage: tyon [command]
        \\
        \\Commands:
        \\  format [files]      Format specified files
        \\  to-json [files]     Save files as JSON
        \\  validate [files]    Validate specified files
        \\
        \\  debug [files]       Debug specified files
        \\
        \\  help                Print this help and exit
        \\  version             Print version and exit
        \\
    , .{});
}
