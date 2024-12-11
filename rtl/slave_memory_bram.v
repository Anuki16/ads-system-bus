module slave_memory_bram #(parameter ADDR_WIDTH = 12, DATA_WIDTH = 8, MEM_SIZE = 4096)
(

	input clk, rstn, wen, ren,
	
	input [ADDR_WIDTH-1:0] addr, //input address of slave
	input [DATA_WIDTH-1:0] wdata, // data to be written in the slave

	output [DATA_WIDTH-1:0] rdata // data to be read from the slave
);

	localparam MEM_ADDR_WIDTH = $clog2(MEM_SIZE);
	
	generate
		if (MEM_SIZE == 4096) begin
			slave_bram memory (
				.address(addr[MEM_ADDR_WIDTH-1:0]),
				.clock(clk),
				.data(wdata),
				.rden(ren),
				.wren(wen),
				.q(rdata)
			); 
		end else begin
			slave_bram_2k memory (
				.address(addr[MEM_ADDR_WIDTH-1:0]),
				.clock(clk),
				.data(wdata),
				.rden(ren),
				.wren(wen),
				.q(rdata)
			); 
		end
	endgenerate

	endmodule
