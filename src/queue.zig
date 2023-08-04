const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const assert = std.assert;

pub fn Queue(comptime T: type) type {
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

        front: ?*Node = null,
        rear: ?*Node = null,

        pub fn enqueue(self: *Self, new_node: *Node) void {
            new_node.next = self.front;
            self.front = new_node;
            if (self.rear == null) {
                self.rear = new_node;
            }
        }

        pub fn dequeue(self: *Self) ?*Node {
            var it = self.front.?;
            var it1: *Node = undefined;

            while (it.next != null) {
                it1 = it;
                it = it.next.?;
            }
            it1.next = it.next;
            self.rear = it1;
            return it;
        }

        pub fn getFront(self: *Self) ?*Node {
            return self.front orelse return null;
        }

        pub fn getRear(self: *Self) ?*Node {
            return self.rear orelse return null;
        }

        pub fn length(self: Self) usize {
            var count: usize = 0;
            var it = self.front;
            while (it) |n| : (it = n.next) {
                count += 1;
            }
            return count;
        }

        pub fn print(self: *Self) void {
            var it = self.front;
            while (it) |n| : (it = n.next) {
                std.debug.print("{d} ", .{n.data});
            }
            std.debug.print("\n", .{});
        }
    };
}

test "Queue" {
    const Q = Queue(u32);
    var queue = Q{};

    try testing.expect(queue.length() == 0);

    var one = Q.Node{ .data = 1 };
    var two = Q.Node{ .data = 2 };
    var three = Q.Node{ .data = 3 };
    var four = Q.Node{ .data = 4 };
    var five = Q.Node{ .data = 5 };

    queue.enqueue(&one);                // 1
    queue.enqueue(&two);                // 2 1
    queue.enqueue(&three);              // 3 2 1
    queue.enqueue(&four);               // 4 3 2 1
    queue.enqueue(&five);               // 5 4 3 2 1

    try testing.expect(queue.length() == 5);

    try testing.expect(queue.getFront().?.data == 5);
    try testing.expect(queue.getRear().?.data == 1);
    try testing.expect(queue.dequeue().?.data == 1);    // 5 4 3 2

    try testing.expect(queue.length() == 4);
}