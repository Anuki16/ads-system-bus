`timescale 1ns/1ps

// This TB has both masters for convenience
// But only 1 will be tested

module demo_top (
    input clk, rstn
);

    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter SLAVE_MEM_ADDR_WIDTH = 12;

    // External signals
    reg [DATA_WIDTH-1:0] d1_wdata, d2_wdata;  // Write data to the DUT
    wire [DATA_WIDTH-1:0] d1_rdata, d2_rdata; // Read data from the DUT
    reg [ADDR_WIDTH-1:0] d1_addr, d2_addr;
    reg d1_valid, d2_valid; 				  // Ready valid interface
    wire d1_ready, d2_ready;
    reg d1_mode, d2_mode;					  // 0 - read, 1 - write
    wire s_ready;
    
    top #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),

        .d1_wdata(d1_wdata),
        .d1_rdata(d1_rdata),
        .d1_addr(d1_addr),
        .d1_valid(d1_valid),
        .d1_ready(d1_ready),
        .d1_mode(d1_mode),

        .d2_wdata(d2_wdata),
        .d2_rdata(d2_rdata),
        .d2_addr(d2_addr),
        .d2_valid(d2_valid),
        .d2_ready(d2_ready),
        .d2_mode(d2_mode),

        .s_ready(s_ready)
    );

    

endmodule