const std = @import("std");

pub fn count(comptime T: type, in: []const T, e: T) usize {
    var c: usize = 0;
    for (in) |x| {
        if (x == e) {
            c += 1;
        }
    }
    return c;
}

pub fn splitByte(alloc: std.mem.Allocator, data: []const u8, b: u8) ![][]const u8 {
    var buf = try alloc.alloc([]const u8, count(u8, data, b) + 1);
    var it = std.mem.tokenizeScalar(u8, data, b);
    var idx: usize = 0;
    while (it.next()) |token| {
        buf[idx] = token;
        idx += 1;
    }
    return buf[0..idx];
}

pub fn OverlappingWindow(comptime T: type) type {
    return struct {
        data: []const T,
        window_size: usize,
        overlap: usize,
        current_start: usize = 0,

        const Self = @This();

        /// Initialize the overlapping window
        pub fn init(data: []const T, window_size: usize, overlap: usize) Self {
            // Validate inputs
            if (window_size == 0) {
                @panic("Window size must be greater than 0");
            }
            if (overlap >= window_size) {
                @panic("Overlap must be less than window size");
            }

            return Self{
                .data = data,
                .window_size = window_size,
                .overlap = overlap,
            };
        }

        /// Get the next window, wrapping around to the beginning when reaching the end
        pub fn next(self: *Self) ?[]const T {
            // If we've gone past the end of the data, restart from the beginning
            if (self.current_start >= self.data.len) {
                return null;
            }

            // If not enough data left for a full window, return null
            if (self.data.len < self.window_size) {
                return null;
            }

            // Calculate the end of the current window
            const end = @min(self.current_start + self.window_size, self.data.len);

            // Extract the current window
            const window = self.data[self.current_start..end];

            // Move the start position, accounting for overlap
            self.current_start += (self.window_size - self.overlap);

            return window;
        }

        /// Reset the window iterator to the beginning
        pub fn reset(self: *Self) void {
            self.current_start = 0;
        }
    };
}
