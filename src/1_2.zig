const std = @import("std");

const fs = std.fs;
const fmt = std.fmt;
const mem = std.mem;
const print = std.debug.print;

const input_items_count = 2000;
var allocator_memory: [2 * input_items_count * @sizeOf(u32)]u8 = undefined;

pub fn main() !void {
    const dir = fs.cwd();

    const f = try dir.openFile("../resources/1_input.txt", .{});
    defer f.close();
    
    var allocator = std.heap.FixedBufferAllocator.init(allocator_memory[0..]).allocator();
    var data = std.ArrayList(u32).init(allocator);
    defer data.deinit();

    var buf: [5]u8 = undefined;

    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try data.append(try fmt.parseInt(u32, line, 10));
    }

    var count: u32 = 0;
    for (data.items) |depth, i| {
        if ((i < 2) or (i == data.items.len - 1)) continue;
        const sum_a: u32 = data.items[i - 2] + data.items[i - 1] + depth;
        const sum_b: u32 = data.items[i + 1] + depth + data.items[i - 1];

        if (sum_b > sum_a) {
            count += 1;
        }
    }

    print("{}\n", .{count});
}