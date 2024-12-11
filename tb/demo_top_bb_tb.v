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

    wire m_u_tx, s_u_tx, s_u_rx, sig_tx;
    reg m_u_rx;

    wire [DATA_WIDTH + SLAVE_MEM_ADDR_WIDTH:0] data_out;
    reg [DATA_WIDTH-1:0] data_in;
    wire u_rx_ready, u_tx_nbusy;
    reg u_tx_en;

    demo_top_bb #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH),
        .BB_ADDR_WIDTH(BB_ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .ready(ready),
        .mode(mode),
        .m_u_tx(m_u_tx),
        .m_u_rx(m_u_rx),
        .s_u_tx(s_u_tx),
        .s_u_rx(sig_tx)
    );

    uart_rx_other #(
        .DATA_WIDTH(DATA_WIDTH + SLAVE_MEM_ADDR_WIDTH + 1), 
        .BAUD_RATE(9600), 
        .CLK_FREQ(50_000_000))
    s_uart_rx (
        .sig_rx(s_u_tx),
        .data_rx(data_out),
        .valid_rx(u_rx_ready),
        .ready_rx(0),
        .clk(clk),
        .rstn(rstn)
    );

    uart_tx_other #(
        .DATA_WIDTH(DATA_WIDTH), 
        .BAUD_RATE(9600), 
        .CLK_FREQ(50_000_000))
    s_uart_tx (
        .sig_tx(sig_tx),
        .data_tx(data_in),
        .valid_tx(u_tx_en),
        .ready_tx(u_tx_nbusy),
        .clk(clk),
        .rstn(rstn)
    );

    assign m_u_rx = 1;
    assign s_u_rx = 1;

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
        start = 1;
        mode = 0;
        //m_u_rx = 1;
        //s_u_rx = 1;
        #15 rstn = 1; // Release reset after 15 time units

        // Repeat the write and read tests 10 times
        for (i = 0; i < 1; i = i + 1) begin

            // Write Operation: Sending data to the bus
            wait (ready == 1);
            @(posedge clk);
            mode = 1;
            start = 0;

            #20;
            start = 1;
            wait (u_rx_ready == 1);

            #20;

            // Read operation
            @(posedge clk);
            mode = 0;                         // Set mode to read
            start = 0;                        // Assert valid signal

            #20;
            start = 1;
            wait (u_rx_ready == 1);

            #100
            data_in = 8'h34;
            u_tx_en = 1;

            #20;
            u_tx_en = 0;

            wait (ready == 1);

            // Small delay before next iteration
            #10;
        end

        #10 $finish;
    end


endmodule