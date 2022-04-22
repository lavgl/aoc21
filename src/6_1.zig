const std = @import("std");

const print = std.debug.print;

const input_file = @embedFile("../resources/6_input.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Fish = struct {
    timer: u8,
    pub fn born() Fish {
        return Fish{ .timer = 8 };
    }
    pub fn resetTimer(self: *Fish) void {
        self.*.timer = 6;
    }
    pub fn decTimer(self: *Fish) void {
        self.*.timer -= 1;
    }
};

pub fn main() !void {
    var fishes = std.ArrayList(Fish).init(allocator);
    defer fishes.deinit();
    var new_fishes = std.ArrayList(Fish).init(allocator);
    defer new_fishes.deinit();

    var it = std.mem.tokenize(u8, input_file, ",\n ");

    while (it.next()) |v| {
        try fishes.append(Fish{ .timer = try std.fmt.parseInt(u8, v, 10) });
    }

    var day: u8 = 0;

    while (day < 80) : (day += 1) {
        // print("fishes at the beginning of the {} day: {s}\n", .{ day + 1, fishes });
        for (fishes.items) |*fish| {
            if (fish.timer == 0) {
                try new_fishes.append(Fish.born());
                fish.*.resetTimer();
            } else {
                fish.*.decTimer();
            }
        }
        if (new_fishes.items.len > 0) {
            try fishes.appendSlice(new_fishes.toOwnedSlice());
            new_fishes.clearRetainingCapacity();
        }
        // print("After {} days: {} fishes\n", .{ day + 1, fishes.items.len });
    }

    print("After {} days: {} fishes\n", .{ day, fishes.items.len });
}
