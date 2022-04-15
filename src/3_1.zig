const std = @import("std");

const mem = std.mem;
const fmt = std.fmt;
const print = std.debug.print;

const input = @embedFile("../resources/3_input.txt");
const input_line_length = 12;

pub fn main() !void {
    var it = mem.tokenize(u8, input, "\n");

    var ones: [input_line_length]u32 = .{0} ** input_line_length;
    var total: u32 = 0;

    while(it.next()) |line| {
        for (line) |bit, i| {
            if (bit == '1') {
                ones[i] += 1;
            }
        }

        total += 1;
    }

    var gamma_bit: [input_line_length]u8 = .{0} ** input_line_length;
    var epsilon_bit: [input_line_length]u8 = .{0} ** input_line_length;

    for (ones) |bit, i| {
        gamma_bit[i] = if (bit > (total / 2)) '1' else '0';
        epsilon_bit[i] = if (bit > (total / 2)) '0' else '1';
    }

    var gamma = try fmt.parseInt(u32, gamma_bit[0..], 2);
    var epsilon = try fmt.parseInt(u32, epsilon_bit[0..], 2);

    print("{}\n", .{gamma * epsilon});
}
