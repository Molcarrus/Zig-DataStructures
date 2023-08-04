const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const assert = std.assert;

pub fn CircularLinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            next: *Node = undefined,
            data: T,
        };

        head: ?*Node = null,

        pub fn insertAtBeginning(self: *Self, new_node: *Node) void {
            if (self.head == null) {
                new_node.next = new_node;
                self.head = new_node;
                return;
            }
            new_node.next = self.head.?;
            var last: *Node = self.head orelse return;
            while (last.next != self.head) {
                last = last.next;
            }
            last.next = new_node;
            self.head = new_node;
        }

        pub fn insertAtEnd(self: *Self, new_node: *Node) void {
            if (self.head == null) {
                new_node.next = new_node;
                self.head = new_node;
                return;
            }
            var last: *Node = self.head orelse return;
            while (last.next != self.head) {
                last = last.next;
            }
            new_node.next = last.next;
            last.next = new_node;
        }

        pub fn removeAtBeginning(self: *Self) ?*Node {
            const first = self.head orelse return null;
            var it = self.head.?;
            while (it.next != self.head) {
                it = it.next;
            }
            it.next = first.next;
            self.head = first.next;
            return first;
        }

        pub fn removeAtEnd(self: *Self) ?*Node {
            var last = self.head.?;
            var it: *Node = undefined;
            while (last.next != self.head) {
                it = last;
                last = last.next;
            }
            it.next = last.next;
            return last;
        }

        pub fn getHead(self: *Self) ?*Node {
            return self.head orelse return null;
        }

        pub fn length(self: Self) usize {
            var count: usize = 0;
            var it = self.head orelse return 0;
            var has_reached_end = false;
            while (has_reached_end == false) :  (it = it.next) {
                if (it.next == self.head) {
                    has_reached_end = true;
                }
                count += 1;
            }
            return count;
        }

        pub fn print(self: *Self) void {
            var it = self.head;
            while (it) |n| : (it = n.next) {
                if (it == self.head) {
                    break;
                }
                std.debug.print("{} ", .{n.data});
            }
            std.debug.print("\n", .{});
        }
    };
}

test "CLL" {
    const CLL = CircularLinkedList(u32);
    var cll = CLL{};

    try testing.expect(cll.length() == 0);

    var one = CLL.Node{ .data = 1 };
    var two = CLL.Node{ .data = 2 };
    var three = CLL.Node{ .data = 3 };
    var four = CLL.Node{ .data = 4 };
    var five = CLL.Node{ .data = 5 };

    cll.insertAtBeginning(&two);            // 2
    cll.insertAtBeginning(&one);            // 1 -> 2
    cll.insertAtEnd(&three);                // 1 -> 2 -> 3
    cll.insertAtEnd(&four);                 // 1 -> 2 -> 3 -> 4
    cll.insertAtEnd(&five);                 // 1 -> 2 -> 3 -> 4 -> 5

    try testing.expect(cll.length() == 5);

    try testing.expect(cll.getHead().?.data == 1);
    try testing.expect(cll.removeAtEnd().?.data == 5);          // 1 -> 2 -> 3 -> 4
    try testing.expect(cll.removeAtBeginning().?.data == 1);    // 2 -> 3 -> 4

    try testing.expect(cll.length() == 3);
}