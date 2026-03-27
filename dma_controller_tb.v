// DMA Controller - testbench
module testbench;
    reg clk, reset, start;
    reg [7:0] src, dst, len;
    wire done, mem_we;
    wire [7:0] mem_addr, mem_data_out;
    wire [7:0] mem_data_in;

    //  a fake SRAM memory-(256 bytes)
    reg [7:0] sram [0:255]; 

    // create DMA Controller
    dma_controller dma (
        .clk(clk), .reset(reset), .start(start),
        .src_addr_in(src), .dst_addr_in(dst), .length_in(len),
        .done(done), .mem_we(mem_we), .mem_addr(mem_addr),
        .mem_data_out(mem_data_out), .mem_data_in(mem_data_in)
    );

    
    always #5 clk = ~clk;// clock signal - 5 nanoseconds

    //////// fake memory logic ////////////
    always @(posedge clk) begin
        if (mem_we) sram[mem_addr] <= mem_data_out; // write
    end
    assign mem_data_in = sram[mem_addr];            // asynchronous Read

    // main execution
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
        
        clk = 0; reset = 1; start = 0;
        // doad fake data into memory
        sram[10] = 8'hAA; // Hex value AA at address 10
        sram[11] = 8'hBB; // Hex value BB at address 11
        sram[12] = 8'hCC; // Hex value CC at address 12
        
        #10 reset = 0; // turn off reset

        //CPU commands DMA to move 3 bytes from Addr 10 to Addr 50
        $display("--- STARTING DMA TRANSFER ---");
        src = 10; dst = 50; len = 3;
        start = 1; #10 start = 0; // start button

        // wait for DMA to finish
        wait(done == 1);
        #10;
        
        //final reults displayed
        $display("--- TRANSFER COMPLETE ---");
        $display("Memory Addr 50: %h (Expected AA)", sram[50]);
        $display("Memory Addr 51: %h (Expected BB)", sram[51]);
        $display("Memory Addr 52: %h (Expected CC)", sram[52]);
        
        $finish;
    end
endmodule