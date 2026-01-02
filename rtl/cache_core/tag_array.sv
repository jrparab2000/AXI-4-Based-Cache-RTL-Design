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
    input dirty, //from dirty_array block
    input [2:0] replace,  //from controller when ever it is safe to overrite the tag
    output match, //produce in same clock
    output valid,
    output [$clog2(ASSOC)-1:0] assoc, //produced in same clock
    output [ADDR_SIZE-1:0] addr    //produced in next clock cycle
);
    localparam SETS = 2**INDEX_SIZE;
    reg [TAG_SIZE-1:0] tags [SETS-1:0][ASSOC-1:0];
    reg valids [SETS-1:0][ASSOC-1:0];
    reg [$clog2(ASSOC)-1:0] temp_assoc;
    // int i;

    always_comb begin : match_logic
        match = 1'b0;
        temp_assoc = 'b0;
        foreach(tags[index][i]) begin
            if(tags[index][i] == tag && valids[index][i]) begin
                match = 1'b1
                temp_assoc = i;
            end
        end
    end

    always_ff @(posedge clk) begin : replacing_logic
        if (replace == 3'b000) begin //reset
            foreach(tags[i]) begin
                foreach(tags[i][j]) begin
                    tags[i][j] <= 'b0;
                    valids[i][j] <= 1'b0;
                end
            end
            addr <= 0;
        end
        else if (replace == 3'b001) begin //miss 
            addr <= 0;
            tags[index][lru] <= tag;
            valids[index][lru] <= 1'b1;
        end
        else if(replace == 2'b010) begin //miss and write back
            addr <= {tags[index][lru],index,BLOCK_SIZE'b0};
        end
        else if(replace == 2'b011) begin //miss and load back
            addr <= {tag,index,BLOCK_SIZE'b0};
        end
    end

    // assign write_back = match ? 0 : dirty;
    // assign addr =  write_back ? 0 : {tags[index][lru],index,BLOCK_SIZE'b0};
    assign assoc = match ? temp_assoc:lru;
    assign valid = match ? valids[index][temp_assoc]:valids[index][lru];
endmodule