module dirty_array #(
    parameter ASSOC = 8,
    parameter BLOCK_SIZE = 6,
    parameter INDEX_SIZE = 7
) (
    input clk,
    input [INDEX_SIZE-1:0] index,
    input [$clog2(ASSOC)-1:0] assoc,    //this is from tag array
    input [2:0] replace, //from controller when write back is successful 
    output dirty //produced in same cycle
);

    localparam SETS = 2**INDEX_SIZE;
    reg mem [SETS-1:0][ASSOC-1:0];

    assign dirty = mem[index][assoc];

    always_ff @( posedge clk ) begin
        if(replace == 3'b000) begin
            foreach(mem[i,j]) begin
                mem[i][j] <= 1'b0;
            end
        end
        else if(replace == 3'b001) begin // hit and write
            mem[index][assoc] <= 1'b1;
        end
        else if (replace == 3'b010) begin //after load 
            mem[index][assoc] <= 1'b1;
        end
        else if (replace == 3'b100) begin //after write back
            mem[index][assoc] <= 1'b0;
        end
    end
    
endmodule