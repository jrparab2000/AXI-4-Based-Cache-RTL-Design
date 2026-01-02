module cache_top #(
    parameter ASSOC = 8,
    parameter ADDR_SIZE = 32,
    parameter DATA_SIZE = 32,
    parameter BLOCK_SIZE = 6,
    parameter INDEX_SIZE = 7, 
    parameter TAG_SIZE = ADDR_SIZE - BLOCK_SIZE - INDEX_SIZE
) (
    input clk,
    input rst_n,

    // cpu interface
    input valid_in_c,
    input rw,
    input [ADDR_SIZE-1:0] addr,
    input [DATA_SIZE-1:0] data_in,
    output [DATA_SIZE-1:0] data_out,
    output valid_out_c,
    output hit_miss,
    
    //memory interface
    output addr_valid_out,
    output [ADDR_SIZE-1:0] addr_out_m,
    output rw_out,
    
    //Write back interface
    input ready_wb,
    output valid_wb,
    output [BLOCKS-1:0][DATA_SIZE-1:0] data_out_m,

    //load interface
    input valid_ld,
    input [BLOCKS-1:0][DATA_SIZE-1:0] data_in_m,
    output ready_ld
);
    wire dirty;
    wire match;
    wire valid_tag;
    wire [2:0] tag_replace;
    wire [2:0] dirty_replace;
    wire [2:0] data_replace;
    wire [1:0] lru_replace;
    wire [INDEX_SIZE-1:0] index;
    wire [$clog2(ASSOC)-1:0] assoc, lru;
    wire [TAG_SIZE-1:0] tag;
    // wire [ADDR_SIZE-1:0] addr_out;
    wire [BLOCK_SIZE-1:0] block;

    lru_array  #(.ASSOC(ASSOC), .INDEX_SIZE(INDEX_SIZE)) lru_mem (
        .clk(clk),
        .replace(lru_replace),
        .index(index),
        .assoc(assoc),
        .lru(lru)
        );
    tag_array  #(.ASSOC(ASSOC), .ADDR_SIZE(ADDR_SIZE), .BLOCK_SIZE(BLOCK_SIZE), .INDEX_SIZE(INDEX_SIZE), .TAG_SIZE(TAG_SIZE)) tag_mem (
        .clk(clk),
        .tag(tag),
        .index(index),
        .lru(lru),
        .dirty(dirty),
        .replace(tag_replace),
        .match(match),
        .valid(valid_tag),
        .assoc(assoc),
        .addr(addr_out_m)
    );
    data_array  #(.ASSOC(ASSOC), .DATA_SIZE(DATA_SIZE), .BLOCK_SIZE(BLOCK_SIZE), .INDEX_SIZE(INDEX_SIZE)) data_mem (
        .clk(clk),
        .index(index),
        .assoc(assoc),
        .block(block),
        .replace(data_replace),
        .data_in_c(data_in),
        .data_in_m(data_in_m),
        .data_out(data_out),
        .data_out_m(data_out_m)
    );
    dirty_array  #(.ASSOC(ASSOC), .BLOCK_SIZE(BLOCK_SIZE), .INDEX_SIZE(INDEX_SIZE)) dirty_mem (
        .clk(clk),
        .index(index),
        .assoc(assoc),
        .replace(dirty_replace),
        .dirty(dirty)
    );
    controller ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .rw(rw),
        .valid_in_c(valid_in_c),
        .hit_miss(hit_miss),
        .out_valid(valid_out_c),
        .dirty(dirty),
        .match(match),
        .valid_tag(valid_tag),
        .tag_replace(tag_replace),
        .dirty_replace(dirty_replace),
        .data_replace(data_replace),
        .lru_replace(lru_replace),
        .ready_wb(ready_wb),
        .valid_wb(valid_wb),
        .valid_ld(valid_ld),
        .ready_ld(ready_ld),
        .out_rw(rw_out),
        .addr_valid_out(addr_valid_out)
    );
    address_decode #(.ADDR_SIZE(ADDR_SIZE), .BLOCK_SIZE(BLOCK_SIZE), .INDEX_SIZE(INDEX_SIZE), .TAG_SIZE(TAG_SIZE)) addr_dec (
        .addr(addr),
        .index(index),
        .tag(tag),
        .block(block)
    )
endmodule