module data_array #(
    parameter ASSOC = 8,
    parameter DATA_SIZE = 32,
    parameter BLOCK_SIZE = 6,
    parameter INDEX_SIZE = 7
) (
    input clk,
    input [INDEX_SIZE-1:0] index,
    input [$clog2(ASSOC)-1:0] assoc,    //this is from tag array
    input [BLOCK_SIZE-1:0] block,
    // input match,
    input [2:0] replace,  //from controller when ever data is available from memory
    // input rw,
    input [DATA_SIZE-1:0] data_in_c, //from processor
    input [BLOCKS-1:0][DATA_SIZE-1:0] data_in_m, //from memory
    output [DATA_SIZE-1:0] data_out, 
    output reg [BLOCKS-1:0][DATA_SIZE-1:0] data_out_m //to memory
);
    localparam BLOCKS = 2**BLOCK_SIZE;
    localparam SETS = 2**INDEX_SIZE;

    reg [BLOCKS-1:0][DATA_SIZE-1:0] mem [SETS-1:0][ASSOC-1:0];
    reg [BLOCKS-1:0][DATA_SIZE-1:0] mem_next [SETS-1:0][ASSOC-1:0];

    always_comb begin
        foreach(mem_next[i]) begin
            foreach(mem_next[i][j]) begin
                foreach(mem_next[i][j][k]) begin
                    mem_next[i][j][k] = 0;
                end
            end
        end
    end

    always_ff @( posedge clk ) begin : load_store
        if(replace == 3'b000) begin
            // foreach(mem[i]) begin
            //     foreach(mem[i][j]) begin
            //         foreach(mem[i][j][k]) begin
            //             mem[i][j][k] <= 0;
            //         end
            //     end
            // end
            mem <= mem_next;
            // data_out <= 0;
            data_out_m <= 0;
        end
        else if (replace == 3'b001) begin //Hit and write case
            // data_out <= 0;
            data_out_m <= 0;
            mem[index][assoc][block] <= data_in_c;
        end
        // else if (replace == 3'b001) begin //Hit and read case
        //     data_out_m <= 0;
        //     data_out <= mem[index][assoc][block];
        // end
        else if (replace == 3'b011) begin //Miss, write and no dirty case
            // data_out <= 0;
            data_out_m <= 0;
            mem[index][assoc] <= data_in_m;
            mem[index][assoc][block] <= data_in_c;
        end
        else if (replace == 3'b100) begin //Miss and no dirty case
            data_out_m <= 0;
            mem[index][assoc] <= data_in_m;
            // data_out <= data_in_m[block];
        end
        else if (replace == 3'b101) begin //dirty case
            // data_out <= 0;
            data_out_m <= mem[index][assoc];
        end 
    end

    assign data_out = (replace == 3'b010) ?  mem[index][assoc][block] : 0;
endmodule
