const std = @import("std");
const print = std.debug.print;

pub fn printBox(comptime name: []const u8, comptime T: type) !void {
    if (std.mem.eql(u8, name, "DAY 25")) {
        print("┏━━━━ {s: <6} ━━━━━━┓\n┃{d:<18}┃\n┃{d:<18}┃\n", .{
            name,
            try T.Day.partOne(),
            try T.Day.partTwo(),
        });
        print("┗━━━━━━━━━━━━━━━━━━┛\n", .{});
    } else {
        print("┏━━━━ {s: <6} ━━━━━━┓\n┃{d:<18}┃\n┃{d:<18}┃\n", .{
            name,
            try T.Day.partOne(),
            try T.Day.partTwo(),
        });
        print("┗━━━━━━━━━━━━━━━━━━┛\n\n", .{});
    }
}

pub fn main() !void {
    try printBox("DAY 1", @import("day1/root.zig"));
    try printBox("DAY 2", @import("day2/root.zig"));
    try printBox("DAY 3", @import("day3/root.zig"));
}
