const std = @import("std");
const testing = std.testing;

pub fn Pair(comptime T1: type, comptime T2: type) type {
    return struct {
        first: T1 = undefined,
        second: T2 = undefined,

        const Self = @This();

        pub fn make_pair(self: *Self, first: T1, second: T2) void {
            self.first = first;
            self.second = second;
        }

        // Similar to the swap function of a C++ pair
        // But instead of swapping the values of the pair
        // It returns a new pair with the values swapped
        pub fn get_inverse_pair(self: *Self) Pair(T2, T1) {
            const P = Pair(T2, T1);
            var q = P{};
            q.make_pair(self.second, self.first);
            return q;
        }
    };
}

test "Pair" {
    const P = Pair(i32, bool);
    var p = P{};
    p.make_pair(1, true);
    try testing.expect(p.first == 1);
    try testing.expect(p.second == true);
    const inv_p = p.get_inverse_pair();
    try testing.expect(inv_p.first == true);
    try testing.expect(inv_p.second == 1);
}