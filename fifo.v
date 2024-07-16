module fifo_mem #(parameter WIDTH = 8, DEPTH = 8) (
    input clk,
    input rst,
    
    input wr_en_i,
    input [WIDTH-1:0] data_i,
    output full_o,
    output almost_full_o,
    
    input rd_en_i,
    output reg [WIDTH-1:0] data_o,
    output empty_o,
    output almost_empty_o,
    
    output reg overflow,
    output reg underflow
);

    // Calculate the width of the address pointers based on DEPTH
    localparam ADDR_WIDTH = $clog2(DEPTH);

    // Memory array to store FIFO data
    reg [WIDTH-1:0] mem [DEPTH-1:0];

    // Write and read pointers
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;
    
    // Counter to keep track of the number of elements in the FIFO
    reg [ADDR_WIDTH:0] count;

    // Full and empty flags based on count value
    assign full_o = (count == DEPTH);
    assign almost_full_o = (count >= DEPTH-1);
    assign empty_o = (count == 0);
    assign almost_empty_o = (count <= 1);

    // Write operation
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            overflow <= 0;
        end else begin
            if (wr_en_i && !full_o) begin
                mem[wr_ptr] <= data_i;      // Write data to memory
                wr_ptr <= (wr_ptr + 1) % DEPTH; // Increment and wrap around write pointer
                overflow <= 0;
            end else if (wr_en_i && full_o) begin
                overflow <= 1; // FIFO overflow error
            end
        end
    end

    // Read operation
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            data_o <= {WIDTH{1'b0}}; // Initialize output data
            underflow <= 0;
        end else begin
            if (rd_en_i && !empty_o) begin
                data_o <= mem[rd_ptr];     // Read data from memory
                rd_ptr <= (rd_ptr + 1) % DEPTH; // Increment and wrap around read pointer
                underflow <= 0;
            end else if (rd_en_i && empty_o) begin
                underflow <= 1; // FIFO underflow error
            end
        end
    end

    // Counter to track the number of elements in the FIFO
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end else begin
            case ({wr_en_i, rd_en_i})
                2'b10 : if (!full_o) count <= count + 1; // Increment count on write
                2'b01 : if (!empty_o) count <= count - 1; // Decrement count on read
                2'b11 : count <= count; // No change on simultaneous read and write
                2'b00 : count <= count; // No change on idle
                default : count <= count;
            endcase
        end
    end

endmodule
