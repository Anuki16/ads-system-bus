`timescale 1ns/1ps

module demo_top_bb_tb;
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_MEM_ADDR_WIDTH = 14;
    parameter BB_ADDR_WIDTH = 16;
    parameter DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;

    // DUT Signals
    reg clk, rstn;
    reg start;

    wire ready;
	reg mode;

    wire m_u_tx, s_u_tx;
    reg m_u_rx, s_u_rx;

    demo_top_bb dut (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .ready(ready),
        .mode(mode),
        .m_u_tx(m_u_tx),
        .m_u_rx(m_u_rx),
        .s_u_tx(s_u_tx),
        .s_u_rx(s_u_rx)
    );

    // Generate Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period is 10 units
    end

    integer i;

    // Test Stimulus
    initial begin

        // Reset the DUT
        rstn = 0;
        start = 0;
        mode = 0;
        m_u_rx = 1;
        s_u_rx = 1;
        #15 rstn = 1; // Release reset after 15 time units

        // Repeat the write and read tests 10 times
        for (i = 0; i < 1; i = i + 1) begin

            // Write Operation: Sending data to the bus
            wait (ready == 1);
            @(posedge clk);
            mode = 1;
            start = 1;

            #20;
            start = 0;
            wait (ready == 1);

            #20;

            // Read operation
            @(posedge clk);
            mode = 0;                         // Set mode to read
            start = 1;                        // Assert valid signal

            #20;
            start = 0;
            wait (ready == 1);

            // Small delay before next iteration
            #10;
        end

        #10 $finish;
    end


endmodule