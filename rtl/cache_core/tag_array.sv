module tag_array #(
    parameter ASSOC = 8,
    parameter ADDR_SIZE = 32,
    parameter BLOCK_SIZE = 6,
    parameter INDEX_SIZE = 7, 
    parameter TAG_SIZE = ADDR_SIZE - BLOCK_SIZE - INDEX_SIZE
) (
    input clk,
    input [TAG_SIZE-1:0] tag,
    input [INDEX_SIZE-1:0] index,
    input [$clog2(ASSOC)-1:0] lru,
    // input dirty, //from dirty_array block
    input [2:0] replace,  //from controller when ever it is safe to overrite the tag
    output reg match, //produce in same clock
    output valid,
    output [$clog2(ASSOC)-1:0] assoc, //produced in same clock
    output reg [ADDR_SIZE-1:0] addr    //produced in next clock cycle
);
    localparam SETS = 2**INDEX_SIZE;
    localparam SIZE = $clog2(ASSOC);
    reg [TAG_SIZE-1:0] tags [SETS-1:0][ASSOC-1:0];
    reg [TAG_SIZE-1:0] tags_next [SETS-1:0][ASSOC-1:0];
    reg valids [SETS-1:0][ASSOC-1:0];
    reg valids_next [SETS-1:0][ASSOC-1:0];
    reg [SIZE-1:0] temp_assoc;
    // int i;

    always_comb begin : match_logic
        match = 1'b0;
        temp_assoc = 'b0;
        for(int i =0; i<ASSOC; i++) begin
            if(tags[index][i] == tag && valids[index][i]) begin
                match = 1'b1;
                temp_assoc = SIZE'(i);
            end
        end
    end

    always_comb begin
       foreach(tags_next[i,j]) begin
            tags_next[i][j] = 'b0;
            valids_next[i][j] = 1'b0;
        end 
    end
    always_ff @(posedge clk) begin : replacing_logic
        if (replace == 3'b000) begin //reset
            tags <= tags_next;
            valids <= valids_next;
            // addr <= 0;
        end
        else if (replace == 3'b001) begin //miss 
            // addr <= 0;
            tags[index][lru] <= tag;
            valids[index][lru] <= 1'b1;
        end
        
    end

    always_comb begin
        addr = {ADDR_SIZE{1'b0}};
        if(replace == 3'b010) begin //miss and write back
            addr = {tags[index][lru],index,{BLOCK_SIZE{1'b0}}};
        end
        else if(replace == 3'b011) begin //miss and load back
            addr = {tag,index,{BLOCK_SIZE{1'b0}}};
        end
    end

    // assign write_back = match ? 0 : dirty;
    // assign addr =  write_back ? 0 : {tags[index][lru],index,BLOCK_SIZE'b0};
    assign assoc = match ? temp_assoc:lru;
    assign valid = match ? valids[index][temp_assoc]:valids[index][lru];
endmodule
