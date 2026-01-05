module controller #(
    parameter BLOCK_SIZE = 6,
    parameter WR_M_DATA_SIZE = 4
    )
    (
    input clk,
    input rst_n,

    //cpu control interface
    input rw,
    input valid_in_c,
    output reg hit_miss,
    output reg out_valid,

    //internal control signals 
    input dirty,
    input match,
    input valid_tag,
    output reg [2:0] tag_replace,
    output reg [2:0] dirty_replace,
    output reg [2:0] data_replace,
    output reg [1:0] lru_replace,

    //write back control signals
    input ready_wb,
    output reg valid_wb,

    //load control signals
    input valid_ld,
    output reg ready_ld,

    //mem control signals 
    output reg out_rw,
    output reg addr_valid_out
);
    reg [BLOCK_SIZE-1:0]counter, counter_next;
    reg [1:0] count_ctrl;
    typedef enum logic [2:0] { IDLE, HIT, WB, LD, INCR} states;
    states cs, ns;

    always_ff @(posedge clk) begin
        if(!rst_n) begin
            cs <= IDLE;
            // ns <= IDLE;
        end
        else begin
            cs <= ns;
        end
    end

    always_comb begin
        ns = IDLE;
        case (cs)
            IDLE    :   begin
                tag_replace = 3'b000;
                data_replace = 3'b000;
                valid_wb = 0;
                ready_ld = 1'b0;
                dirty_replace = 3'b000;
                lru_replace = 2'b00;
                out_rw = 1'b0;
                out_valid = 1'b0;
                hit_miss = 1'b0;
                addr_valid_out = 1'b0;
                count_ctrl = 2'b00;
                ns = HIT;
            end 

            HIT     :   begin
                tag_replace = 3'b111;
                data_replace = 3'b111;
                valid_wb = 0;
                ready_ld = 1'b0;
                dirty_replace = 3'b111; //default case for dirty
                out_rw = 1'b0;
                out_valid = 1'b0;
                hit_miss = 1'b0;
                lru_replace = 2'b11;
                addr_valid_out = 1'b0;
                count_ctrl = 2'b00;

                if(valid_in_c) begin
                    if (match) begin
                        lru_replace = 2'b01;
                        hit_miss = 1'b1;
                        ns = HIT;
                        if(rw) begin
                            data_replace = 3'b001;
                            dirty_replace = 3'b001;  //hit and write case
                        end
                        else begin
                            data_replace = 3'b010;
                            out_valid = 1'b1;
                        end
                    end
                    else begin
                        lru_replace = 2'b10;
                        if (valid_tag) begin
                            if (dirty) begin
                                data_replace = 3'b101;
                                tag_replace = 3'b010;
                                ns = WB;
                            end
                            else begin
                                tag_replace = 3'b011;
                                ns = LD;
                            end
                        end
                        else begin
                            ns = LD;
                        end
                    end
                end
                else begin
                    ns = HIT;
                end
            end

            WB      :   begin
                tag_replace = 3'b111;
                data_replace = 3'b101;
                valid_wb = 1'b1;
                ready_ld = 1'b0;
                dirty_replace = 3'b111;
                out_rw = 1'b1;
                out_valid = 1'b0;
                hit_miss = 1'b0;
                lru_replace = 2'b11;
                addr_valid_out = 1'b1;
                count_ctrl = 2'b00;

                if (ready_wb) begin
                    dirty_replace = 3'b100;
                    ns = LD;
                end
                else begin
                    ns = WB;
                end
            end

            LD      :   begin
                tag_replace = 3'b111;
                data_replace = 3'b111;
                valid_wb = 1'b0;
                ready_ld = 1'b1;
                dirty_replace = 3'b111;
                out_rw = 1'b0;
                out_valid = 1'b0;
                hit_miss = 1'b0;
                lru_replace = 2'b11;
                addr_valid_out = 1'b1;
                count_ctrl = 2'b00;
                
                if(valid_ld) begin
                    tag_replace = 3'b001;
                    ns = HIT;
                    if(rw) begin
                        data_replace = 3'b011;
                        dirty_replace = 3'b010;
                    end
                    else begin
                        data_replace = 3'b100;
                        // out_valid = 1'b1;
                    end
                end
                else begin
                   ns = LD; 
                end
            end
            INCR    :   begin
                
            end
        endcase
    end

    always_comb begin
        counter_next = counter;
        if(count_ctrl == 2'b00) begin
            counter_next = {BLOCK_SIZE{1'b0}};
        end
        else if (count_ctrl == 2'b01) begin
            counter_next = counter + 1;
        end
    end
endmodule
