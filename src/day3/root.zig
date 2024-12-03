const std = @import("std");
const input = @embedFile("input.txt");
const util = @import("../util.zig");
const ArrayList = std.ArrayList;

fn mul(alloc: std.mem.Allocator, data: []const u8) !u64 {
    var ow = std.mem.window(u8, data, 4, 1);
    var sum: u64 = 0;
    while (ow.next()) |p| {
        if (std.mem.eql(u8, p, "mul(")) {
            const start = ow.index.? + 3;
            var cursor = ow.index.?;
            while (ow.buffer[cursor] != ')') {
                cursor += 1;
            }
            if (@abs(cursor - start) > 7) {
                continue;
            }
            if (cursor > ow.buffer.len) {
                cursor = ow.buffer.len;
            }
            const spl = try util.splitByte(alloc, ow.buffer[start..cursor], ',');
            if (spl.len != 2) {
                continue;
            }
            const nums = try alloc.alloc(u64, 2);
            for (spl, 0..) |s, idx| {
                nums[idx] = try std.fmt.parseInt(u64, s, 10);
            }
            // std.debug.print("{any}\n", .{nums});
            sum += nums[0] * nums[1];
        }
    }
    return sum;
}

pub const Day = struct {
    pub fn partOne() !u64 {
        var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer aa.deinit();
        const alloc = aa.allocator();

        return mul(alloc, input);
    }

    pub fn partTwo() !u64 {
        var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer aa.deinit();
        const alloc = aa.allocator();

        var total: u64 = 0;
        var start: usize = 0;
        while (start < input.len) {
            var trimmed = ArrayList(u8).init(alloc);
            defer trimmed.deinit();
            const end = @min(
                start + (std.mem.indexOf(
                    u8,
                    input[start..],
                    "don't()",
                ) orelse input.len),
                input.len,
            );
            // std.debug.print("start={d:<7}end={d:<7}\n", .{ start, end });
            // std.debug.print("{s}\n\n\n", .{input[start..end]});
            try trimmed.appendSlice(input[start..end]);
            start = @min(
                end + 4 + (std.mem.indexOf(
                    u8,
                    input[end..],
                    "do()",
                ) orelse input.len),
                input.len,
            );
            total += try mul(alloc, trimmed.items);
        }
        return total;
    }
};
