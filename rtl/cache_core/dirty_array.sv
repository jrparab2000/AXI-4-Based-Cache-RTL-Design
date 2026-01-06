module dirty_array #(
    parameter ASSOC = 8,
    parameter INDEX_SIZE = 7
) (
    input clk,
    input [INDEX_SIZE-1:0] index,
    input [$clog2(ASSOC)-1:0] assoc,    //this is from tag array
    input [1:0] replace, //from controller when write back is successful 
    output dirty //produced in same cycle
);

    localparam SETS = 2**INDEX_SIZE;
    reg mem [SETS-1:0][ASSOC-1:0];
    reg mem_next [SETS-1:0][ASSOC-1:0];

    assign dirty = mem[index][assoc];

    always_comb begin
        foreach(mem[i,j]) begin
            mem_next[i][j] = 1'b0;
        end
    end
    always_ff @( posedge clk ) begin
        if(replace == 2'b00) begin
            // foreach(mem[i,j]) begin
            //     mem[i][j] <= 1'b0;
            // end
            mem <= mem_next;
        end
        else if(replace == 2'b01) begin // hit and write
            mem[index][assoc] <= 1'b1;
        end
        else if (replace == 2'b10) begin //after load 
            mem[index][assoc] <= 1'b0;
        end
        // else if (replace == 3'b100) begin //after write back
        //     mem[index][assoc] <= 1'b0;
        // end
    end
    
endmodule
