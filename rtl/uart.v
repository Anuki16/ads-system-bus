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
	input rx,
	output ready,
    output [DATA_WIDTH -1:0] data_output
);


	uart_tx #(.CLOCKS_PER_PULSE(CLOCKS_PER_PULSE)) transmitter (
		.data_in(data_input),
		.data_en(data_en),
		.clk(clk),
		.rstn(rstn),
		.tx(tx),
		.tx_busy(tx_busy)
	);
	
	uart_rx #(.CLOCKS_PER_PULSE(CLOCKS_PER_PULSE)) receiver (
		.clk(clk),
		.rstn(rstn),
		.rx(rx),
		.ready(ready),
		.data_out(data_output)
	);	
	
	
endmodule