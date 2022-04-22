const std = @import("std");

const print = std.debug.print;

const input_file = @embedFile("../resources/6_input.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Fishes = struct {
    ages: [9]u64 = .{0} ** 9,

    pub fn tick(self: *Fishes) void {
        _ = self;
        var next = Fishes{};
        next.ages[0] = self.ages[1];
        next.ages[1] = self.ages[2];
        next.ages[2] = self.ages[3];
        next.ages[3] = self.ages[4];
        next.ages[4] = self.ages[5];
        next.ages[5] = self.ages[6];
        next.ages[6] = self.ages[0] + self.ages[7];
        next.ages[7] = self.ages[8];
        next.ages[8] = self.ages[0];

        self.* = next;
    }

    pub fn total(self: *Fishes) u64 {
        var res: u64 = 0;

        for (self.*.ages) |count| {
            res += count;
        }

        return res;
    }
};

pub fn main() !void {
    var fishes = Fishes{};

    var it = std.mem.tokenize(u8, input_file, ",\n ");

    while (it.next()) |v| {
        const age: u8 = std.fmt.parseInt(u8, v, 10) catch unreachable;
        fishes.ages[age] += 1;
    }

    var day: u32 = 0;

    while (day < 256) : (day += 1) {
        fishes.tick();
    }

    print("After {} days: {} fishes\n", .{ day, fishes.total() });
}
