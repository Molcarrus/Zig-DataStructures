const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const assert = std.assert;

pub fn DoublyLinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            next: ?*Node = null,
            prev: ?*Node = null,
            data: T,

            pub const Data = T;

            pub fn insertAfter(node: *Node, new_node: *Node) void {
                new_node.next = node.next;
                node.next.?.prev = new_node;
                node.next = new_node;
                new_node.prev = node;
            }

            pub fn insertBefore(node: *Node, new_node: *Node) void {
                new_node.prev = node.prev;
                node.prev.?.next = new_node;
                node.prev = new_node;
                new_node.next = node;
            }

            pub fn removeAfter(node: *Node) ?*Node {
                const next_node = node.next orelse return null;
                node.next = next_node.next;
                if (node.next == null) return next_node;
                node.next.?.prev = node;
                return next_node;
            }

            pub fn removeBefore(node: *Node) ?*Node {
                const prev_node = node.prev orelse return null;
                node.prev = prev_node.prev;
                if (node.prev == null) return prev_node;
                node.prev.?.next = node;
                return prev_node;
            }

            pub fn removeThis(node: *Node) ?*Node {
                if (node.prev == null) {
                    if (node.next == null) {
                        return node;
                    } else {
                        node.next.?.prev = null;
                    }
                } else {
                    node.prev.?.next = node.next;
                    if (node.next == null) {
                        return node;
                    } else {
                        node.next.?.prev = node.prev;
                    }
                }
                return node;
            }

            pub fn countChildren(node: *const Node) usize {
                var count: usize = 0;
                var it: ?*const Node = node.next;
                while (it) |n| : (it = n.next) {
                    count += 1;
                }
                return count;
            }

            pub fn findLast(node: *Node) *Node {
                var current = node;
                while (true) {
                    current = current.next orelse return current;
                }
            }
        };

        head: ?*Node = null,

        pub fn insertAtBeginning(list: *Self, new_node: *Node) void {
            if (list.head == null) {
                list.head = new_node;
                return;
            }
            new_node.next = list.head;
            new_node.prev = list.head.?.prev;
            list.head.?.prev = new_node;
            list.head = new_node;
        }

        pub fn insertAtEnd(list: *Self, new_node: *Node) void {
            if (list.head == null) {
                list.head = new_node;
                return;
            }
            var current = list.head.?;
            while (current.next != null) {
                current = current.next.?;
            }
            new_node.prev = current;
            new_node.next = current.next;
            current.next = new_node;
        }

        pub fn insertAtPosition(list: *Self, new_node: *Node, position: usize) void {
            var current = list.head;
            while (current.next != null and position > 0) {
                current = current.next.?;
                position -= 1;
            }
            current.insertAfter(new_node);
        }

        pub fn removeAtBeginning(list: *Self) ?*Node {
            const first = list.head orelse return null;
            var next = first.next.?;
            next.prev = first.prev;
            list.head = next;
            return first;
        }

        pub fn removeAtEnd(list: *Self) ?*Node {
            var current: *Node = list.head.?;
            current = current.findLast();
            return current.removeThis();
        }

        pub fn removeNode(list: *Self, node: *Node) ?*Node {
            if (list.head == node) {
                return list.removeAtBeginning();
            } else {
                var current = list.head.?;
                while (current.next != node) {
                    current = current.next.?;
                }
                if (current.next.?.next == null) {
                    return list.removeAtEnd();
                }  else {
                    return current.removeAfter();
                }
            }
            return null;
        }

        pub fn length(list: *Self) usize {
            if (list.head) |n| {
                return 1 + n.countChildren();
            } else {
                return 0;
            }
        }
    };
}

test "DLL" {
    const L = DoublyLinkedList(u32);
    var list = L{};

    try testing.expect(list.length() == 0);

    var one = L.Node{ .data = 1 };
    var two = L.Node{ .data = 2 };
    var three = L.Node{ .data = 3 };
    var four = L.Node{ .data = 4 };
    var five = L.Node{ .data = 5 };

    list.insertAtBeginning(&two);           // 2
    list.insertAtEnd(&three);               // 2 -> 3
    list.insertAtBeginning(&one);           // 1 -> 2 -> 3
    list.insertAtEnd(&four);                // 1 -> 2 -> 3 -> 4
    list.insertAtEnd(&five);                // 1 -> 2 -> 3 -> 4 -> 5

    try testing.expect(list.length() == 5);
    
    _= list.removeAtBeginning();        // 2 -> 3 -> 4 -> 5
    _= list.removeNode(&five);          // 2 -> 3 -> 4
    _= two.removeAfter();               // 2 -> 4

    try testing.expect(list.length() == 2);

}
