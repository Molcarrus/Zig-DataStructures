const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const assert = std.assert;

pub fn DoublyCircularLinkedList (comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            next: *Node = undefined,
            prev: *Node = undefined,
            data: T,
        };

        head: ?*Node = null,

        pub fn insertAtBeginning(self: *Self, new_node: *Node) void {
            if (self.head == null) {
                new_node.next = new_node;
                new_node.prev = new_node;
                self.head = new_node;
                return;
            }
            new_node.next = self.head.?;
            new_node.prev = self.head.?.prev;
            self.head.?.prev.next = new_node;
            self.head.?.prev = new_node;
            self.head = new_node;
        }

        pub fn insertAtEnd(self: *Self, new_node: *Node) void {
            if (self.head == null) {
                new_node.next = new_node;
                new_node.prev = new_node;
                self.head = new_node;
                return;
            }
            new_node.prev = self.head.?.prev;
            new_node.next = self.head.?;
            self.head.?.prev.next = new_node;
            self.head.?.prev = new_node;
        }

        pub fn removeAtBeginning(self: *Self) ?*Node {
            const first: *Node = self.head orelse return null;
            self.head.?.prev.next = self.head.?.next;
            self.head.?.next.prev = self.head.?.prev;
            self.head = first.next;
            return first;
        }

        pub fn removeAtEnd(self: *Self) ?*Node {
            if (self.head == null) return null;
            const last: *Node = self.head.?.prev;
            self.head.?.prev.prev.next = self.head.?;
            self.head.?.prev = last.prev;
            return last;
        }

        pub fn getHead(self: *Self) ?*Node {
            return self.head;
        }

        pub fn getLast(self: *Self) ?*Node {
            if (self.head == null) return null;
            return self.head.?.prev;
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
                if (it == self.head) break;
                std.debug.print("{d} ", .{n.data});
            }
            std.debug.print("\n", .{});
        }
    };
}

test "DCLL" {
    const D = DoublyCircularLinkedList(u32);
    var list = D{};

    try testing.expect(list.length() == 0);

    var one = D.Node{ .data = 1 };
    var two = D.Node{ .data = 2 };
    var three = D.Node{ .data = 3 };
    var four = D.Node{ .data = 4 };
    var five = D.Node{ .data = 5 };

    list.insertAtBeginning(&one);           // 1
    list.insertAtEnd(&two);                 // 1 -> 2
    list.insertAtEnd(&three);               // 1 -> 2 -> 3
    list.insertAtEnd(&four);                // 1 -> 2 -> 3 -> 4
    list.insertAtEnd(&five);                // 1 -> 2 -> 3 -> 4 -> 5

    try testing.expect(list.length() == 5);

    try testing.expect(list.head.?.data == 1);
    try testing.expect(list.head.?.next.data == 2);
    
    try testing.expect(list.getHead().?.data == 1);
    try testing.expect(list.getLast().?.data == 5);

    try testing.expect(list.removeAtEnd().?.data == 5);             // 1 -> 2 -> 3 -> 4
    try testing.expect(list.removeAtBeginning().?.data == 1);       // 2 -> 3 -> 4

    try testing.expect(list.length() == 3);
}