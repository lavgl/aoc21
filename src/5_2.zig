const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const math = std.math;
const testing = std.testing;

const print = std.debug.print;
const assert = std.debug.assert;

const input_file = @embedFile("../resources/5_input.txt");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Point = struct {
    x: i32,
    y: i32,
};

const Vent = struct { start: Point, end: Point };

const VentMap = struct {
    map: std.AutoHashMap(Point, i32) = std.AutoHashMap(Point, i32).init(allocator),
    overlaps: u32 = 0,

    pub fn mark(self: *VentMap, x: i32, y: i32) void {
        const pt = Point{ .x = x, .y = y };
        var v = self.map.getOrPut(pt) catch unreachable;
        if (v.found_existing) {
            if (v.value_ptr.* == 1) {
                self.overlaps += 1;
            }
            v.value_ptr.* += 1;
        } else {
            v.value_ptr.* = 1;
        }
    }
};

pub fn main() !void {
    var lines = std.mem.tokenize(u8, input_file, "\n");
    var vents = std.ArrayList(Vent).init(allocator);
    defer vents.deinit();

    while (lines.next()) |line| {
        var ps = mem.split(u8, line, " -> ");
        const p1 = try parsePoint(ps.next().?);
        const p2 = try parsePoint(ps.next().?);

        try vents.append(Vent{ .start = p1, .end = p2 });
    }

    var map = VentMap{};

    for (vents.items) |vent| {
        if (vent.start.x == vent.end.x) {
            var curr_y = math.min(vent.start.y, vent.end.y);
            const max_y = math.max(vent.start.y, vent.end.y);
            while (curr_y <= max_y) : (curr_y += 1) {
                map.mark(vent.start.x, curr_y);
            }
        }

        if (vent.start.y == vent.end.y) {
            var curr_x = math.min(vent.start.x, vent.end.x);
            const max_x = math.max(vent.start.x, vent.end.x);
            while (curr_x <= max_x) : (curr_x += 1) {
                map.mark(curr_x, vent.start.y);
            }
        }

        if (vent.start.x != vent.end.x and vent.start.y != vent.end.y) {
            var curr_x = vent.start.x;
            var max_x = vent.end.x;
            const dx: i32 = if (curr_x < max_x) 1 else -1;
            var curr_y = vent.start.y;
            var max_y = vent.end.y;
            const dy: i32 = if (curr_y < max_y) 1 else -1;

            while (curr_y - dy != max_y) : ({
                curr_x += dx;
                curr_y += dy;
            }) {
                map.mark(curr_x, curr_y);
            }
        }
    }

    print("{}\n", .{map.overlaps});
}

fn parsePoint(str: []const u8) !Point {
    var it = mem.split(u8, str, ",");
    const x = try fmt.parseInt(i32, it.next().?, 10);
    const y = try fmt.parseInt(i32, it.next().?, 10);

    return Point{ .x = x, .y = y };
}
