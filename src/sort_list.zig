const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const assert = std.assert;

pub fn SortList(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            next: ?*Node = null,
            data: T,
        };

        head: ?*Node = null,

        pub fn insert(self: *Self, new_node: *Node) void {
            if (self.head == null or new_node.data <= self.head.?.data) {
                new_node.next = self.head;
                self.head = new_node;
            } else {
                var curr = self.head.?;
                while (curr.next != null and curr.next.?.data < new_node.data) {
                    curr = curr.next.?;
                }
                new_node.next = curr.next;
                curr.next = new_node;
            }
        }

        pub fn getHead(self: *Self) ?*Node {
            return self.head;
        }

        pub fn delete(self: *Self, node: *Node) ?*Node {
            if (self.head == null) {
                return null;
            }
            if (self.head.? == node) {
                self.head = node.next.?;
                return node;
            }
            var curr = self.head.?;
            while (curr.next != null) {
                if (curr.next == node) {
                    curr.next = node.next;
                    return node;
                }
                curr = curr.next.?;
            }
            return null;
        }

        pub fn length(self: *Self) usize {
            var count: usize = 0;
            var it = self.head;
            while (it) |n| : (it = n.next) {
                count += 1;
            }
            return count;
        }
    };
}

test "SL" {
    const S = SortList(u32);
    var list = S{};

    try testing.expect(list.length() == 0);

    var one = S.Node{ .data = 1 };
    var two = S.Node{ .data = 2 };
    var three = S.Node{ .data = 3 };
    var four = S.Node{ .data = 4 };
    var five = S.Node{ .data = 5 };

    list.insert(&one);          // 1
    list.insert(&two);          // 1 -> 2
    list.insert(&three);        // 1 -> 2 -> 3 
    list.insert(&four);         // 1 -> 2 -> 3 -> 4
    list.insert(&five);         // 1 -> 2 -> 3 -> 4 -> 5

    try testing.expect(list.length() == 5);

    try testing.expect(list.getHead().?.data == 1);

    _ = list.delete(&three);            // 1 -> 2 -> 4 -> 5
    _ = list.delete(&one);              // 2 -> 4 -> 5

    try testing.expect(list.head.?.data == 2);
}