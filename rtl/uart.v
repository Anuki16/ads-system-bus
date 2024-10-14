module uart #(
	parameter CLOCKS_PER_PULSE = 5208,
              DATA_WIDTH = 8
)
(
	input [DATA_WIDTH - 1:0] data_input,
	input data_en,
	input clk,
	input rstn,
	output tx,
	output tx_busy,
	input ready_clr,
	input rx,
	output ready,
    output [DATA_WIDTH -1:0] data_output
);


	transmitter #(.CLOCKS_PER_PULSE(CLOCKS_PER_PULSE)) uart_tx (
		.data_in(data_input),
		.data_en(data_en),
		.clk(clk),
		.rstn(rstn),
		.tx(tx),
		.tx_busy(tx_busy)
	);
	
	receiver #(.CLOCKS_PER_PULSE(CLOCKS_PER_PULSE)) uart_rx (
		.clk(clk),
		.rstn(rstn),
		.ready_clr(ready_clr),
		.rx(rx),
		.ready(ready),
		.data_out(data_output)
	);	
	
	
endmodule