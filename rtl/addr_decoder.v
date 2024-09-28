
module addr_decoder #(
    parameter ADDR_WIDTH = 16,
    parameter DEVICE_BIT_WIDTH = 2
) (
    input [ADDR_WIDTH-1:0] addr,
    input wen, ren,     // input controls from master
    output wen1, wen2, wen3,    // output controls
    output ren1, ren2, ren3,
    output [1:0] read_mux_sel
);
    wire [DEVICE_BIT_WIDTH-1:0] device_id;

    // Part of the address to identify the slave device
    assign device_id = addr[ADDR_WIDTH-1:ADDR_WIDTH-DEVICE_BIT_WIDTH];

    // To the read mux selector
    assign read_mux_sel = device_id;

    // To give the correct wen signals
    dec3 wen_decoder (
        .sel(device_id),
        .en(wen),
        .out1(wen1),
        .out2(wen2),
        .out3(wen3)
    );

    // To give the correct ren signals
    dec3 ren_decoder (
        .sel(device_id),
        .en(ren),
        .out1(ren1),
        .out2(ren2),
        .out3(ren3)
    );

endmodule