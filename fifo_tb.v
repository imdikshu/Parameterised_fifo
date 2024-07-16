module fifo_mem_tb;
    reg clk, rst;
    reg wr_en_i, rd_en_i;
    reg [7:0] data_i;
    
    wire full_o, empty_o, almost_full_o, almost_empty_o;
    wire [7:0] data_o;
    wire overflow, underflow;
    
    fifo_mem #(8, 8) FIFO_MEM (
        .clk(clk),
        .rst(rst),
        .wr_en_i(wr_en_i),
        .rd_en_i(rd_en_i),
        .data_i(data_i),
        .data_o(data_o),
        .full_o(full_o),
        .almost_full_o(almost_full_o),
        .empty_o(empty_o),
        .almost_empty_o(almost_empty_o),
        .overflow(overflow),
        .underflow(underflow)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end
    
    // Test sequence
    integer i;
    initial begin
        // Initialize signals
        rst = 1;
        wr_en_i = 0;
        rd_en_i = 0;
        data_i = 8'b0;
        
        // Apply reset
        #10 rst = 0; // reset system
        #10 rst = 1; // finish reset 
        
        // Write data into FIFO
        wr_en_i = 1'b1;
        rd_en_i = 0;
        
        for (i = 0; i < 8; i = i + 1) begin
            data_i = i;
            #10;
        end
        
        wr_en_i = 0;
        
        // Read data from FIFO
        rd_en_i = 1'b1;
        
        for (i = 0; i < 8; i = i + 1) begin
            #10;
        end
        
        rd_en_i = 0;
        
        // Write data again into FIFO to test overflow
        wr_en_i = 1'b1;
        rd_en_i = 0;
        
        for (i = 0; i < 9; i = i + 1) begin
            data_i = i + 8;
            #10;
        end
        
        wr_en_i = 0;
        
        // Read data again from FIFO to test underflow
        rd_en_i = 1'b1;
        
        for (i = 0; i < 9; i = i + 1) begin
            #10;
        end
        
        rd_en_i = 0;
        
        // Finish simulation
        #100 $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t clk=%b rst=%b wr_en_i=%b rd_en_i=%b data_i=%h data_o=%h full_o=%b almost_full_o=%b empty_o=%b almost_empty_o=%b overflow=%b underflow=%b",
                 $time, clk, rst, wr_en_i, rd_en_i, data_i, data_o, full_o, almost_full_o, empty_o, almost_empty_o, overflow, underflow);
    end
    
endmodule
