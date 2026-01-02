module controller (
    input clk,
    input rst_n,

    //cpu control interface
    input rw,
    input valid_in_c,
    output hit_miss,
    output out_valid,

    //internal control signals 
    input dirty,
    input match,
    input valid_tag,
    output [2:0] tag_replace,
    output [2:0] dirty_replace,
    output [2:0] data_replace,
    output [1:0] lru_replace,

    //write back control signals
    input ready_wb,
    output valid_wb,

    //load control signals
    input valid_ld,
    output ready_ld,

    //mem control signals 
    output out_rw,
    output addr_valid_out
);
    
    typedef enum [1:0] { IDLE, HIT, WB, LD} states;
    states cs, ns;

    always_ff @(posedge clk) begin
        if(!rst_n) begin
            cs <= IDLE;
            ns <= IDLE;
        end
        else begin
            cs <= ns;
        end
    end

    always_comb begin
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
        endcase
    end
endmodule