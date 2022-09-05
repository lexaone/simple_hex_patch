const std = @import("std");
const process = std.process;
const temp_filename = ".tempfile123.tmp";
//we xored search string just to disable patch patcher itself
//                           \x32\xC7\x99\x55\x4A\x24\x83\xAB\x31\x1B\xAC\x3A\xF1\x29\x00\xDD\x55\xB7\x8C\xA5\x0B\xED\xFE\xD3\x24\x12\x0F\x42\xB5
const search_string_xored = "\x02\xf7\xa9\x65\x7a\x14\xb3\x9b\x01\x2b\x9c\x0a\xc1\x19\x30\xed\x65\x87\xbc\x95\x3b\xdd\xce\xe3\x14\x22\x3f\x72\x85";
const replace_string = "\x05\xF5\x1F\x74\xD5\x08\x1B\x8F\xA2\x91\x5D\xC9\x0A\x33\x00\x96\x9F\x71\xCD\x8F\xB3\x6D\x0F\x0C\x6F\xD0\xB5\x4D\x46";
const xor_val = '0';

pub fn main() !void {
    const stdout_stream = std.io.getStdOut().writer();
    try stdout_stream.print("---===@@@ Simple binary patcher (c)2022 by lexa @@@===---\n\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);
    if (args.len < 3) {
        try stdout_stream.print("Usage: {s} infile outfile\n", .{args[0]});
    } else {
        const file_in = try std.fs.cwd().openFile(args[1], .{});
        defer file_in.close();
        const stat = try file_in.stat();
        const file_mem = try allocator.alloc(u8, stat.size);
        defer allocator.free(file_mem);
        _ = try file_in.readAll(file_mem);

        const search_string = try allocator.alloc(u8, search_string_xored.len);
        defer allocator.free(search_string);
        var i: usize = 0;
        // while (i < search_string_xored.len) : (i += 1) {
        //     try stdout_stream.print("\\x{x}", .{search_string_xored[i]});
        // }
        // try stdout_stream.print("\n", .{});
        // i = 0;
        while (i < search_string_xored.len) : (i += 1) {
            search_string[i] = search_string_xored[i] ^ xor_val;
        }
        // i = 0;
        // while (i < search_string.len) : (i += 1) {
        //     try stdout_stream.print("\\x{x}", .{search_string[i]});
        // }
        // try stdout_stream.print("\n", .{});

        const offset = std.mem.indexOf(u8, file_mem, search_string) orelse 0;
        if (offset != 0) {
            try stdout_stream.print("## Sequence found in file {s},offset:{d}\n", .{ args[1], offset });
            try stdout_stream.print("## Patching...\n", .{});
            std.mem.copy(u8, file_mem[offset..], replace_string);
            try stdout_stream.print("## Writing back...\n", .{});
            const file_out = try std.fs.cwd().createFile(temp_filename, .{});
            defer file_out.close();
            _ = try file_out.writeAll(file_mem);
            try std.fs.rename(std.fs.cwd(), temp_filename, std.fs.cwd(), args[2]);
            try stdout_stream.print("## Done...\n", .{});
        } else {
            try stdout_stream.print("Sequence not found in file {s}, maybe this file already pathed?\nCan you try different one?\n", .{args[1]});
        }
    }
}
