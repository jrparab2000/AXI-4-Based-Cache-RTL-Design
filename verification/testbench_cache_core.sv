module testbench_cache_core ();
    localparam ASSOC = 8;
    localparam ADDR_SIZE = 32;
    localparam DATA_SIZE = 32;
    localparam BLOCK_SIZE = 6;
    localparam INDEX_SIZE = 7; 
    localparam WR_M_DATA_SIZE = 4; 
    localparam TAG_SIZE = ADDR_SIZE - BLOCK_SIZE - INDEX_SIZE;
    localparam BLOCKS = 2**BLOCK_SIZE;

    logic clk;
    logic rst_n;

    // cpu interface
    logic valid_in_c;
    logic rw;
    logic [ADDR_SIZE-1:0] addr;
    logic [DATA_SIZE-1:0] data_in;
    logic [DATA_SIZE-1:0] data_out;
    logic cache_ready;
    logic valid_out_c;
    logic hit_miss;
    
    //memory interface
    logic addr_valid_out;
    logic [ADDR_SIZE-1:0] addr_out_m;
    logic rw_out;
    
    //Write back interface
    logic ready_wb;
    logic valid_wb;
    logic [WR_M_DATA_SIZE-1:0][DATA_SIZE-1:0] data_out_m;

    //load interface
    logic valid_ld;
    logic [WR_M_DATA_SIZE-1:0][DATA_SIZE-1:0] data_in_m;
    logic ready_ld;

    initial begin
        rst_n = 0;
        #20
        rst_n = 1;
    end

    initial begin
        clk = 0;
        forever begin
            #5
            clk = ~clk;
        end
    end

    cache_top #(
        .ASSOC(ASSOC),
        .ADDR_SIZE(ADDR_SIZE),
        .DATA_SIZE(DATA_SIZE),
        .BLOCK_SIZE(BLOCK_SIZE),
        .INDEX_SIZE(INDEX_SIZE),
        .WR_M_DATA_SIZE(WR_M_DATA_SIZE),
        .TAG_SIZE(TAG_SIZE)
    ) cache (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in_c(valid_in_c),
        .rw(rw),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out),
        .cache_ready(cache_ready),
        .valid_out_c(valid_out_c),
        .hit_miss(hit_miss),
        .addr_valid_out(addr_valid_out),
        .addr_out_m(addr_out_m),
        .rw_out(rw_out),
        .ready_wb(ready_wb),
        .valid_wb(valid_wb),
        .data_out_m(data_out_m),
        .valid_ld(valid_ld),
        .data_in_m(data_in_m),
        .ready_ld(ready_ld)
    );

    initial begin
        wait(rst_n);
        @(posedge clk)
        @(posedge clk)
        wait(cache_ready);
        @(posedge clk)

        rw <= 0;
        valid_in_c <=1;
        addr <= 32'h00001234;
        data_in <= 32'h00001234;
        ld(32'h1000);
        
        @(posedge clk);
        valid_in_c <=0;

        wait(cache_ready);
        @(posedge clk)
        rw <= 1;
        valid_in_c <=1;
        addr <= 32'h10001234;
        data_in <= 32'h00001234;
        ld(32'h2000);

        @(posedge clk);
        valid_in_c <=0;

        wait(cache_ready);
        @(posedge clk)
        rw <= 0;
        valid_in_c <=1;
        addr <= 32'h20001234;
        data_in <= 32'h00001234;
        ld(32'h3000);

        @(posedge clk);
        valid_in_c <=0;

        wait(cache_ready);
        @(posedge clk)
        rw <= 0;
        valid_in_c <=1;
        addr <= 32'h30001234;
        data_in <= 32'h00001234;
        ld(32'h4000);

        @(posedge clk);
        valid_in_c <=0;

        wait(cache_ready);
        @(posedge clk)
        rw <= 0;
        valid_in_c <=1;
        addr <= 32'h40001234;
        data_in <= 32'h00001234;
        ld(32'h5000);

        @(posedge clk);
        valid_in_c <=0;

        wait(cache_ready);
        @(posedge clk)
        rw <= 0;
        valid_in_c <=1;
        addr <= 32'h50001234;
        data_in <= 32'h00001234;
        ld(32'h6000);

        @(posedge clk);
        valid_in_c <=0;

        wait(cache_ready);
        @(posedge clk)
        rw <= 0;
        valid_in_c <=1;
        addr <= 32'h60001234;
        data_in <= 32'h00001234;
        ld(32'h7000);

        @(posedge clk);
        valid_in_c <=0;

        wait(cache_ready);
        @(posedge clk)
        rw <= 0;
        valid_in_c <=1;
        addr <= 32'h00001234;
        data_in <= 32'h00001234;
        ld(32'h8000);

        @(posedge clk);
        valid_in_c <=0;

        wait(cache_ready);
        @(posedge clk)
        rw <= 0;
        valid_in_c <=1;
        addr <= 32'h80001234;
        data_in <= 32'h00001234;
        ld(32'h9000);

        @(posedge clk);
        valid_in_c <=0;

        wait(cache_ready);
        @(posedge clk)
        rw <= 0;
        valid_in_c <=1;
        addr <= 32'h90001234;
        data_in <= 32'h00001234;
        ld(32'h1000);

        @(posedge clk);
        valid_in_c <=0;

        wait(cache_ready);
        @(posedge clk)
        rw <= 0;
        valid_in_c <=1;
        addr <= 32'h10001234;
        data_in <= 32'h00001234;
        ld(32'h2000);

        @(posedge clk);
        valid_in_c <=0;

        wait(cache_ready);
        @(posedge clk)
        rw <= 0;
        valid_in_c <=1;
        addr <= 32'h20001234;
        data_in <= 32'h00001234;
        ld(32'h3000);

        @(posedge clk);
        valid_in_c <=0;

        $finish();
    end

    initial begin
        #10000
        $display("Test Failed");
        $finish();
    end

    task automatic ld(input [31:0] data);
        while (1) begin
            if(hit_miss)
                break;
            if(addr_valid_out) begin
                if(!rw_out&&ready_ld) begin
                    // int count = 0;
                    for(int i = 0; i < BLOCKS;i = i + WR_M_DATA_SIZE) begin
                        @(posedge clk)
                        valid_ld <= 1;
                        data_in_m <= {WR_M_DATA_SIZE{i+data}};
                    end
                    @(posedge clk);
                    valid_ld <= 0;
                end
            end
            @(posedge clk);
        end
    endtask //automatic
endmodule