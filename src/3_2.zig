const std = @import("std");

const mem = std.mem;
const fmt = std.fmt;
const print = std.debug.print;
const testing = std.testing;

const input_file = @embedFile("../resources/3_input.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};


pub fn main() !void {
    var it = mem.tokenize(u8, input_file, "\n");
    var allocator = gpa.allocator();

    var ones = mem.zeroes([12]u32);
    var input = std.ArrayList(u12).init(allocator);
    defer input.deinit();

    while(it.next()) |line| {
        for (line) |bit, i| {
            if (bit == '1') {
                ones[i] += 1;
            }
        }
        const value = try fmt.parseInt(u12, line, 2);
        try input.append(value);
    }

    var oxygen_left = std.ArrayList(u12).init(allocator);
    var co2_left = std.ArrayList(u12).init(allocator);
    var next = std.ArrayList(u12).init(allocator);
    defer next.deinit();
    defer co2_left.deinit();
    defer oxygen_left.deinit();

    for (input.items) |item| {
        try oxygen_left.append(item);
        try co2_left.append(item);
    }

    var i: u12 = 1<<11;
    while (oxygen_left.items.len != 1) : (i = i >> 1) {
        const bit_target = bitTarget(oxygen_left.items, i) & i;
        for (oxygen_left.items) |item| {
            if (item & i == bit_target) {
                try next.append(item);
            }
        }

        var tmp = oxygen_left;
        oxygen_left = next;
        tmp.clearRetainingCapacity();
        next = tmp;
    }


    i = 1<<11;
    while(co2_left.items.len != 1) : (i = i >> 1) {
        const bit_target = (~bitTarget(co2_left.items, i)) & i;
        for (co2_left.items) |item|{
            if (item & i == bit_target) {
                try next.append(item);
            }
        }

        var tmp = co2_left;
        co2_left = next;
        tmp.clearRetainingCapacity();
        next = tmp;
    }

    var res: usize = @as(usize, co2_left.items[0]) * @as(usize, oxygen_left.items[0]);

    print("result: {}\n", .{res});

}

fn bitTarget(items: []const u12, bit: u12) u12 {
    var count: usize = 0;
    for (items) |item| {
        count += @boolToInt(item & bit != 0);
    }
    return std.math.boolMask(u12, count * 2 >= items.len);
}

test "bitTarget" {
    const input: [1]u12 = .{0b000_000_000_011};
    const bit1: u12 = 0b000_000_000_001;
    const bit2: u12 = 0b000_000_000_010;
    const bit4: u12 = 0b000_000_000_100;
    const bit16: u12 = 0b000_000_010_000;

    try testing.expect(bitTarget(input[0..], bit1) & bit1 == 1);
    try testing.expect(bitTarget(input[0..], bit2) & bit2 == 2);
    try testing.expect(bitTarget(input[0..], bit4) & bit4 == 0);
    try testing.expect(bitTarget(input[0..], bit16) & bit16 == 0);
}