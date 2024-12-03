const std = @import("std");
const util = @import("../util.zig");
const input = @embedFile("input.txt");
const print = std.debug.print;

fn readToArrayList(
    comptime T: type,
    alloc: std.mem.Allocator,
    data: []const u8,
) !struct {
    leftAL: std.ArrayList(T),
    rightAL: std.ArrayList(T),
} {
    const lines = try util.splitByte(alloc, data, '\n');
    var leftAL = std.ArrayList(T).init(alloc);
    var rightAL = std.ArrayList(T).init(alloc);
    for (lines) |line| {
        const items = try util.splitByte(alloc, line, ' ');
        try leftAL.append(try std.fmt.parseInt(T, items[0], 10));
        try rightAL.append(try std.fmt.parseInt(T, items[1], 10));
    }
    return .{
        .leftAL = leftAL,
        .rightAL = rightAL,
    };
}

pub const Day = struct {
    pub fn partOne() !u64 {
        var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer aa.deinit();
        const alloc = aa.allocator();

        const inputAL = try readToArrayList(i64, alloc, input);
        std.mem.sort(i64, inputAL.leftAL.items, {}, comptime std.sort.asc(i64));
        std.mem.sort(i64, inputAL.rightAL.items, {}, comptime std.sort.asc(i64));

        var sum: u64 = 0;
        for (inputAL.leftAL.items, inputAL.rightAL.items) |left, right| {
            sum += @abs(left - right);
        }

        return sum;
    }

    pub fn partTwo() !u64 {
        var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer aa.deinit();
        const alloc = aa.allocator();

        const inputAL = try readToArrayList(u64, alloc, input);

        var sum: u64 = 0;
        for (inputAL.leftAL.items) |left| {
            for (inputAL.rightAL.items) |right| {
                if (left == right) {
                    sum += left;
                }
            }
        }
        return sum;
    }
};
