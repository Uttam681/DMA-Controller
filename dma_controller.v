//DMA Controller
module dma_controller (
    input clk,
    input reset,
    input start,
    input [7:0] src_addr_in,
    input [7:0] dst_addr_in,
    input [7:0] length_in,
    
    output reg done,
    output reg mem_we,             // write enable for memory
    output reg [7:0] mem_addr,     // address we are asking memory for
    output reg [7:0] mem_data_out, // data we are writing to memory
    input [7:0] mem_data_in        // data we are reading from memory
);

    // 3 states of fsm
localparam IDLE  = 2'b00;
    localparam READ  = 2'b01;
    localparam WRITE = 2'b10;
    localparam DONE  = 2'b11; //*

    reg [1:0] state;
    reg [7:0] src_reg, dst_reg, length_reg;
    reg [7:0] data_buffer; // temporarily holds moving data

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done <= 0;
            mem_we <= 0;

        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    mem_we <= 0;
                    if (start) begin
                        src_reg <= src_addr_in;
                        dst_reg <= dst_addr_in;
                        length_reg <= length_in;
                        state <= READ;
                    end
                end

                READ: begin
                    mem_we <= 0;
                    mem_addr <= src_reg; // ask memory for source data
                    state <= WRITE;
                end

                WRITE: begin
                    mem_we <= 1; // tell memory we are writing
                    mem_addr <= dst_reg;
                    mem_data_out <= mem_data_in; // pass the read data to the output
                    
                    // update our counters for the next loop
                    src_reg <= src_reg + 1;
                    dst_reg <= dst_reg + 1;
                    length_reg <= length_reg - 1;

                    if (length_reg == 1) begin
                        state <= DONE; // * previously we moved the last byte and moved to IDLE now we move to DONE
                    end else begin
                        state <= READ; // keep looping onto next loop
                    end
                end
                DONE: begin
                    mem_we <= 0; // turn off write signal to prevent overwrite
                    done <= 1;   // tell the CPU we are properly! finished
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule