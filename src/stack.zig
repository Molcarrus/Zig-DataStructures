const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const assert = std.assert;

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            next: ?*Node = null,
            data: T,

            pub fn countChildren(node: *const Node) usize {
                var count: usize = 0;
                var it: ?*const Node = node.next;
                while (it) |n| : (it = n.next) {
                    count += 1;
                }
                return count;
            }
        };

        top: ?*Node = null,

        pub fn push(self: *Self, new_node: *Node) void {
            new_node.next = self.top;
            self.top = new_node;
        }

        pub fn pop(self: *Self) ?*Node {
            const first = self.top orelse return null;
            self.top = first.next;
            return first;
        }

        pub fn getTop(self: *Self) ?*Node {
            return self.top orelse return null;
        }

        pub fn length(self: Self) usize {
            if (self.top) |n| {
                return 1 + n.countChildren();
            } else {
                return 0;
            }
        }

        pub fn print(self: *Self) void {
            var it = self.top;
            while (it) |n| : (it = n.next) {
                std.debug.print("{d} ", .{n.data});
            }
            std.debug.print("\n", .{});
        }
    };
}

test "Stack" {
    const S = Stack(u32);
    var stack = S{};

    try testing.expect(stack.length() == 0);

    var one = S.Node{ .data = 1 };
    var two = S.Node{ .data = 2 };
    var three = S.Node{ .data = 3 };
    var four = S.Node{ .data = 4 };
    var five = S.Node{ .data = 5 };

    stack.push(&one);               // 1
    stack.push(&two);               // 2 1
    stack.push(&three);             // 3 2 1
    stack.push(&four);              // 4 3 2 1
    stack.push(&five);              // 5 4 3 2 1

    try testing.expect(stack.length() == 5);

    try testing.expectEqual(@as(u32, 5), stack.getTop().?.data);
    try testing.expectEqual(@as(u32, 5), stack.pop().?.data);           // 4 3 2 1
    try testing.expectEqual(@as(u32, 4), stack.getTop().?.data);
    try testing.expectEqual(@as(u32, 4), stack.pop().?.data);           // 3 2 1

    try testing.expect(stack.length() == 3);
}
 