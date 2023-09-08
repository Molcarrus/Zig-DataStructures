const std = @import("std");
const testing = std.testing;
const debug = std.debug;

const StackError = error {
    StackOverflow,
    StackUnderflow,
    NoElements,
};

pub fn FixedSizeStack(comptime T: type, comptime size: usize) type {
    return struct {
        const Self = @This();

        data: [size]T = undefined,
        len: usize = 0,

        pub fn push(self: *Self, value: T) StackError!void {
            if (self.len == size) {
                return StackError.StackOverflow;
            } else {
                self.len += 1;
                self.data[self.len - 1] = value;
            }
        }

        pub fn pop(self: *Self) StackError!T {
            if (self.len == 0) {
                return StackError.StackUnderflow;
            } else {
                self.len -= 1;
                return self.data[self.len];
            }
        }

        pub fn length(self: *Self) usize {
            return self.len;
        }

        pub fn top(self: *Self) StackError!T{
            if (self.len == 0) {
                return StackError.NoElements;
            } else {
                return self.data[self.len - 1];
            }
        }

        pub fn print(self: *Self) void {
            for (0..self.length()) |i| {
                debug.print("{} ", .{self.data[i]});
            }
        }     
    };
}

test "FSS" {
    const Stack = FixedSizeStack(i32, 5);
    var stack = Stack{};

    try testing.expect(stack.length() == 0);

    try stack.push(1);
    try stack.push(2);
    try stack.push(3);
    try stack.push(4);
    try stack.push(5);

    try testing.expect(stack.length() == 5);

    try testing.expectEqual(@as(i32, 5), try stack.top());
    try testing.expectEqual(@as(i32, 5), try stack.pop());
}
