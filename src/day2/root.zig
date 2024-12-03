const std = @import("std");
const input = @embedFile("input.txt");
const util = @import("../util.zig");

pub fn areAllSameSign(arr: []const i64) bool {
    if (arr.len == 0) return true;
    const is_positive = arr[0] > 0;
    for (arr) |num| {
        if (is_positive and num <= 0) return false;
        if (!is_positive and num > 0) return false;
    }
    return true;
}

fn safe(alloc: std.mem.Allocator, in: []i64) !bool {
    var nums = try std.mem.Allocator.dupe(alloc, i64, in);
    var lineSafe: bool = true;
    for (nums[1..], 0..) |num, idx| {
        const diff: i64 = @intCast(nums[idx] - num);
        if (@abs(diff) == 0 or @abs(diff) > 3) {
            lineSafe = false;
        }
        nums[idx] = diff;
    }
    const allSame = areAllSameSign(nums[0 .. nums.len - 1]);
    return lineSafe and allSame;
}

fn factorial(n: usize) usize {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

fn dampenerPermutations(alloc: std.mem.Allocator, in: []i64) ![][]i64 {
    var nums = try std.mem.Allocator.dupe(alloc, i64, in);
    const size = nums.len;
    var output = try alloc.alloc([]i64, factorial(size - 1) - 1);
    // output[0] = try std.mem.Allocator.dupe(alloc, i64, nums);
    const p = try alloc.alloc(i64, size);
    for (0..size) |i| {
        p[i] = @intCast(i);
    }
    var idx: usize = 0;
    var i: usize = 1;
    while (i < size - 1) {
        p[i] -= 1;
        var j: usize = 0;
        if (i % 2 == 1) {
            j = @intCast(p[i]);
        }
        const tmp = nums[j];
        nums[j] = nums[i];
        nums[i] = tmp;
        output[idx] = try std.mem.Allocator.dupe(alloc, i64, nums[1..]);
        idx += 1;
        i = 1;
        while (p[i] == 0) {
            p[i] = @intCast(i);
            i += 1;
        }
    }
    return output;
}

pub fn CircularWindow(comptime T: type) type {
    return struct {
        data: []const T,
        window_size: usize,
        current_start: usize = 0,

        const Self = @This();

        pub fn init(data: []const T, window_size: usize) Self {
            if (window_size > data.len) {
                @panic("Window size cannot be larger than array length");
            }

            return Self{
                .data = data,
                .window_size = window_size,
            };
        }

        pub fn next(self: *Self, alloc: std.mem.Allocator) ![]T {
            // Create a temporary array to hold the circular window
            var temp_window = try alloc.alloc(T, 20);
            var temp_index: usize = 0;

            // Fill the window, wrapping around the array
            for (0..self.window_size) |i| {
                // Calculate the index, wrapping around the array
                const index = (self.current_start + i) % self.data.len;
                temp_window[temp_index] = self.data[index];
                temp_index += 1;
            }

            // Advance the start index
            self.current_start = (self.current_start + 1) % self.data.len;

            // Create a slice from the temporary array
            return temp_window[0..self.window_size];
        }

        pub fn reset(self: *Self) void {
            self.current_start = 0;
        }
    };
}

fn dampenedLevels(alloc: std.mem.Allocator, in: []i64) ![][]i64 {
    var al = std.ArrayList(i64).init(alloc);
    defer al.deinit();

    const nums = try std.mem.Allocator.dupe(alloc, i64, in);
    for (nums) |n| {
        try al.append(n);
    }
    const size = nums.len;
    var output = try alloc.alloc([]i64, size);

    for (al.items, 0..) |_, idx| {
        const v = al.orderedRemove(idx);
        output[idx] = try std.mem.Allocator.dupe(alloc, i64, al.items);
        try al.insert(idx, v);
    }

    // var cw = CircularWindow(i64).init(nums, size - 1);
    // for (0..size) |idx| {
    //     const w = try cw.next(alloc);
    //     // std.debug.print("w={any}\n", .{w});
    //     output[idx] = try std.mem.Allocator.dupe(alloc, i64, w);
    //     // output[idx] = try alloc.alloc(i64, w.len);
    //     // std.debug.print("output[idx]={any}\n", .{output[idx]});
    // }
    // std.debug.print("output={any}\n", .{output});

    return output;
}

pub const Day = struct {
    pub fn partOne() !u64 {
        var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer aa.deinit();
        const alloc = aa.allocator();
        const lines = try util.splitByte(alloc, input, '\n');
        var numSafe: u64 = 0;
        for (lines) |line| {
            const items = try util.splitByte(alloc, line, ' ');
            const nums = try alloc.alloc(i64, items.len);
            for (items, 0..) |item, idx| {
                nums[idx] = try std.fmt.parseInt(i64, item, 10);
            }
            if (try safe(alloc, nums)) {
                numSafe += 1;
            }
        }
        return numSafe;
    }

    pub fn partTwo() !u64 {
        var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer aa.deinit();
        const alloc = aa.allocator();

        const lines = try util.splitByte(alloc, input, '\n');
        var numSafe: u64 = 0;
        for (lines) |line| {
            const items = try util.splitByte(alloc, line, ' ');
            const nums = try alloc.alloc(i64, items.len);
            for (items, 0..) |item, idx| {
                nums[idx] = try std.fmt.parseInt(i64, item, 10);
            }
            if (try safe(alloc, nums)) {
                numSafe += 1;
                continue;
            }
            const perms = try dampenedLevels(alloc, nums);
            for (perms) |perm| {
                if (try safe(alloc, perm)) {
                    numSafe += 1;
                    break;
                }
            }
        }
        return numSafe;
    }
};
