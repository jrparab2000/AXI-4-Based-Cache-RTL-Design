module data_array #(
    parameter ASSOC = 8,
    parameter DATA_SIZE = 32,
    parameter BLOCK_SIZE = 6,
    parameter INDEX_SIZE = 7,
    parameter WR_M_DATA_SIZE = 4,
    parameter BLOCKS = 1<<BLOCK_SIZE
) (
    input clk,
    input [INDEX_SIZE-1:0] index,
    input [$clog2(ASSOC)-1:0] assoc,    //this is from tag array
    input [BLOCK_SIZE-1:0] block,
    input [BLOCK_SIZE-1:0] counter,
    // input match,
    input [2:0] replace,  //from controller when ever data is available from memory
    // input rw,
    input [DATA_SIZE-1:0] data_in_c, //from processor
    input [WR_M_DATA_SIZE-1:0][DATA_SIZE-1:0] data_in_m, //from memory
    output [DATA_SIZE-1:0] data_out, 
    output reg [WR_M_DATA_SIZE-1:0][DATA_SIZE-1:0] data_out_m //to memory
);
    
    localparam SETS = 2**INDEX_SIZE;

    reg [BLOCKS-1:0][DATA_SIZE-1:0] mem [SETS-1:0][ASSOC-1:0];
    reg [BLOCKS-1:0][DATA_SIZE-1:0] mem_next [SETS-1:0][ASSOC-1:0];
    reg [WR_M_DATA_SIZE-1:0][DATA_SIZE-1:0] data_out_m_next, data_out_t;

    always_comb begin
        mem_next = mem;
        data_out_m_next = data_out_t;
        if(replace == 3'b000) begin
            data_out_m_next = {WR_M_DATA_SIZE{{DATA_SIZE{1'b0}}}};
            foreach(mem_next[i,j,k]) begin
                mem_next[i][j][k] = 0;
            end
        end
        else if (replace == 3'b001) begin
            data_out_m_next = {WR_M_DATA_SIZE{{DATA_SIZE{1'b0}}}};
            mem_next[index][assoc][block] = data_in_c;
        end
        else if(replace == 3'b011) begin
            data_out_m_next = {WR_M_DATA_SIZE{{DATA_SIZE{1'b0}}}};
            for (int i = 0; i < WR_M_DATA_SIZE; i++) begin
                mem_next[index][assoc][BLOCK_SIZE'(BLOCK_SIZE'(counter) + BLOCK_SIZE'(i))] = data_in_m[i];
            end
        end
        else if (replace == 3'b101) begin //dirty case
            // data_out_m_next = {WR_M_DATA_SIZE{DATA_SIZE{1'b0}}};
            for (int i = 0; i < WR_M_DATA_SIZE; i++) begin
                data_out_m_next[i] = mem[index][assoc][BLOCK_SIZE'(BLOCK_SIZE'(counter) + BLOCK_SIZE'(i))];
            end
        end 
    end


    always_ff @( posedge clk ) begin : load_store
        mem <= mem_next;
        data_out_t <= data_out_m_next;
    end

    assign data_out = (replace == 3'b010) ?  mem[index][assoc][block] : 0;
    assign data_out_m = data_out_t;
endmodule
