module lru_array #(
    parameter ASSOC = 8,
    parameter INDEX_SIZE = 7
) (
    input clk,
    input [1:0] replace,
    input [INDEX_SIZE-1:0] index,
    input [$clog2(ASSOC)-1:0] assoc,
    output [$clog2(ASSOC)-1:0] lru
);
    localparam SIZE = $clog2(ASSOC);
    localparam SETS = (2**INDEX_SIZE);
    reg [SIZE-1:0] lrus [SETS-1:0][ASSOC-1:0];
    
    always_comb begin
        lru = 0;
        foreach(lrus[index][i]) begin
            if(lrus[index][i] == (ASSOC-1)) begin
                lru = lrus[index][i];
            end
        end    
    end

    always_ff @(posedge clk) begin
        if(replace == 2'b00) begin
            foreach(lrus[i]) begin
                foreach(lrus[i][j]) begin
                    lrus[i][j] <= j;
                end
            end
        end
        else if(replace == 2'b01) begin
            foreach(lrus[index][i]) begin
                if(lrus[index][i] < lrus[index][assoc]) begin
                    lrus[index][i] <= lrus[index][i] + 1;
                end
            end
            lrus[index][assoc] <= 'b0;
        end
        else if(replace == 2'b10) begin
            foreach(lrus[index][i]) begin
                if(lrus[index][i] != (ASSOC-1)) begin
                    lrus[index][i] <= lrus[index][i] + 1;
                end
                else begin
                    lrus[index][i] <= 'b0;
                end
            end
        end
    end
endmodule