module address_decode #(
    parameter ADDR_SIZE = 32,
    parameter BLOCK_SIZE = 6,
    parameter INDEX_SIZE = 7, 
    parameter TAG_SIZE = ADDR_SIZE - BLOCK_SIZE - INDEX_SIZE
) (
    input [ADDR_SIZE-1:0] addr,
    output [INDEX_SIZE-1:0] index,
    output [TAG_SIZE-1:0] tag,
    output [BLOCK_SIZE-1:0] block
);

    assign block = addr[BLOCK_SIZE-1:0];
    assign index = addr[INDEX_SIZE+BLOCK_SIZE-1:BLOCK_SIZE];
    assign tag = addr[ADDR_SIZE-1:INDEX_SIZE+BLOCK_SIZE];
    
endmodule
