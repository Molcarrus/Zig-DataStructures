const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const assert = std.assert;

pub fn CircularQueue(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            next: *Node = undefined,
            data: T,

            pub fn removeThis(node: *Node, prev_node: *Node) ?*Node {
                prev_node.next = node.next;
                return node;
            }
        };

        front: ?*Node = null,
        
        pub fn enqueue(self: *Self, new_node: *Node) void {
            if (self.front == null) {
                new_node.next = new_node;
                self.front = new_node;
                return;
            }
            new_node.next = self.front.?;
            var last: *Node = self.front orelse return;
            while (last.next != self.front) {
                last = last.next;
            }
            last.next = new_node;
            self.front = new_node;
        }

        pub fn dequeue(self: *Self) ?*Node {
            var last = self.front.?;
            var it: *Node = undefined;
            while (last.next != self.front) {
                it = last;
                last = last.next;
            }
            it.next = last.next;
            return last;
        }

        pub fn getFront(self: *Self) ?*Node {
            return self.front;
        }

        pub fn getRear(self: *Self) ?*Node {
            if (self.front == null) return null;
            var it = self.front.?;
            while (it.next != self.front) {
                it = it.next;
            }
            return it;
        }

        pub fn length(self: *Self) usize {
            var count: usize = 0;
            if (self.front == null) return count;
            var it = self.front.?;
            var has_reached_end = false;
            while (has_reached_end == false) : (it = it.next) {
                if (it.next == self.front) {
                    has_reached_end = true;
                }
                count += 1;
            }
            return count;
        }
    };
}

test "CQ" {
    const C = CircularQueue(u32);
    var cq = C{};

    try testing.expect(cq.length() == 0);

    var one = C.Node{ .data = 1 };
    var two = C.Node{ .data = 2 };
    var three = C.Node{ .data = 3 };
    var four = C.Node{ .data = 4 };
    var five = C.Node{ .data = 5 };

    cq.enqueue(&one);           // 1
    cq.enqueue(&two);           // 2 1
    cq.enqueue(&three);         // 3 2 1
    cq.enqueue(&four);          // 4 3 2 1
    cq.enqueue(&five);          // 5 4 3 2 1

    try testing.expect(cq.length() == 5);

    try testing.expect(cq.getFront().?.data == 5);  
    try testing.expect(cq.getRear().?.data == 1);
    try testing.expect(cq.dequeue().?.data == 1);       // 5 4 3 2

    try testing.expect(cq.length() == 4);
}