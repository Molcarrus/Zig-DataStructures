const std = @import("std");
const debug = std.debug;
const testing = std.testing;
const assert = debug.assert;

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            next: ?*Node = null,
            data: T,

            pub const Data = T;

            pub fn insertAfter(node: *Node, new_node: *Node) void {
                new_node.next = node.next;
                node.next = new_node;
            }

            pub fn removeNext(node: *Node) ?*Node {
                const next_node = node.next orelse return null;
                node.next = next_node.next;
                return next_node;
            }

            pub fn reverse(indirect: *?*Node) void {
                if (indirect.* == null) {
                    return;
                }

                var current: *Node = indirect.*.?;
                while (current.next) |next| {
                    current.next = next.next;
                    next.next = indirect.*;
                    indirect.* = next;
                }
            }

            pub fn countChildren(node: *const Node) usize {
                var count: usize = 0;
                var it: ?*const Node = node.next;
                while (it) |n| : (it = n.next) {
                    count += 1;
                }
                return count;
            }
        };

        first: ?*Node = null,

        pub fn insertAtBeginning(list: *Self, new_node: *Node) void {
            new_node.next = list.first;
            list.first = new_node;
        }

        pub fn insertAtEnd(list: *Self, new_node: *Node) void {
            var current = list.first;
            while (current != null) {
                current = current.next;
            }
            new_node.next = current.next;
            current.next = new_node;
        }

        pub fn insertAtPosition(list: *Self, new_node: *Node, position: usize) void {
            var current = list.first;
            while (current != null and position > 0) {
                current = current.next orelse return;
                position -= 1;
            }
            current.insertAfter(new_node);
        }

        pub fn removeAtBeginning(list: *Self) ?*Node {
            const first = list.first orelse return null;
            list.first = first.next;
            return first;
        }

        pub fn removeNode(list: *Self, node: *Node) void {
            if (list.first == node) {
                list.first = node.next;
            } else {
                var current = list.first.?;
                while (current.next != node) {
                    current = current.next.?;
                }
                current.next = node.next;
            }
        }

        pub fn len(list: Self) usize {
            if (list.first) |n| {
                return 1 + n.countChildren();
            } else {
                return 0;
            }
        }
    };
}

test "SLL" {
    const L = LinkedList(u32);
    var list = L{};

    try testing.expect(list.len() == 0);
    
    var one = L.Node{ .data = 1 };
    var two = L.Node{ .data = 2 };
    var three = L.Node{ .data = 3 };
    var four = L.Node{ .data = 4 };
    var five = L.Node{ .data = 5 };

    list.insertAtBeginning(&two);           // 2
    two.insertAfter(&five);                 // 2 -> 5
    list.insertAtBeginning(&one);           // 1 -> 2 -> 5
    two.insertAfter(&three);                // 1 -> 2 -> 3 -> 5
    three.insertAfter(&four);               // 1 -> 2 -> 3 -> 4 -> 5

    try testing.expect(list.len() == 5);

    {
        var it = list.first;
        var index: u32 = 1;
        while (it) |n| : (it = n.next) {
            try testing.expect(n.data == index);
            index += 1;
        }
    }

    _= list.removeAtBeginning();        // 2 -> 3 -> 4 -> 5
    _= list.removeNode(&five);          // 2 -> 3 -> 4
    _= two.removeNext();                // 2 -> 4

    try testing.expect(list.first.?.data == 2);
    try testing.expect(list.first.?.next.?.data == 4);
    try testing.expect(list.first.?.next.?.next == null);

    L.Node.reverse(&list.first);   // 4 -> 2

    try testing.expect(list.first.?.data == 4);
    try testing.expect(list.first.?.next.?.data == 2);
    try testing.expect(list.first.?.next.?.next == null);   
}