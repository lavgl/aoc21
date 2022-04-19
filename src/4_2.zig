const std = @import("std");

const mem = std.mem;
const fmt = std.fmt;
const print = std.debug.print;
const testing = std.testing;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

const input_content = @embedFile("../resources/4_input.txt");

const Board = struct { cells: [25]u8, marked: u25 = 0, hasWon: bool = undefined };

pub fn main() !void {
    var it = mem.split(u8, input_content, "\n\n");

    var input_sequence = std.ArrayList(u8).init(allocator);

    const seq_line = it.next().?;
    var seq_line_it = mem.tokenize(u8, seq_line, ",");
    while (seq_line_it.next()) |v| {
        try input_sequence.append(try fmt.parseInt(u8, v, 10));
    }

    var boards = std.ArrayList(Board).init(allocator);

    while (it.next()) |board_input| {
        var it_line = mem.tokenize(u8, board_input, " \n");

        var tmp: [25]u8 = mem.zeroes([25]u8);
        var i: usize = 0;

        while (it_line.next()) |v| {
            tmp[i] = try fmt.parseInt(u8, v, 10);
            i += 1;
        }

        try boards.append(.{ .cells = tmp });
    }

    var res: u32 = 0;

    for (input_sequence.items) |drawn| {
        for (boards.items) |*b, bi| {
            if (b.*.hasWon) {
                continue;
            }
            for (b.*.cells) |cell, i| {
                if (cell == drawn) {
                    const bit = @as(u25, 1) << @intCast(u5, i);
                    b.*.marked |= bit;
                }
            }

            if (hasWon(b.*)) {
                b.*.hasWon = true;
                print("board {} won\n", .{bi});
                res = calculateScore(b.*) * drawn;
            }
        }
    }

    print("res: {}\n", .{res});
}

fn hasWon(board: Board) bool {
    // zig fmt: off
    const win_patterns: [10]u25 = .{
        0b1111100000000000000000000,
        0b0000011111000000000000000,
        0b0000000000111110000000000,
        0b0000000000000001111100000,
        0b0000000000000000000011111,
        0b1000010000100001000010000,
        0b0100001000010000100001000,
        0b0010000100001000010000100,
        0b0001000010000100001000010,
        0b0000100001000010000100001
      };
    // zig fmt: on

    for (win_patterns) |p| {
        if (p & board.marked == p) {
            return true;
        }
    }

    return false;
}

test "hasWon" {
    const board: Board = .{ .cells = mem.zeroes([25]u8), .marked = 0b1111100000000000000000000 };
    try testing.expect(hasWon(board));

    const board2: Board = .{ .cells = mem.zeroes([25]u8), .marked = 0b1000010000100001000010000 };
    try testing.expect(hasWon(board2));

    const board3: Board = .{ .cells = mem.zeroes([25]u8), .marked = 0 };
    try testing.expect(!hasWon(board3));

    const board4: Board = .{ .cells = mem.zeroes([25]u8), .marked = 0b1001110010001000100011111 };
    try testing.expect(hasWon(board4));
}

fn calculateScore(board: Board) u32 {
    var sum: u32 = 0;

    for (board.cells) |v, i| {
        const bit = @as(u25, 1) << @intCast(u5, i);
        if (board.marked & bit == 0) {
            sum += v;
        }
    }

    return sum;
}
