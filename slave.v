module slave #(parameter ADDR_WIDTH = 16, DATA_WIDTH = 32, MEM_SIZE = 4096)
(

	input clk, wen, ren,
	
	input [ADDR_WIDTH-1:0] addr,
	input [DATA_WIDTH-1:0] wdata,

	output [DATA_WIDTH-1:0] rdata
);


reg [DATA_WIDTH - 1:0] memory [MEM_SIZE / DATA_WIDTH:0];

//define memory

 
always @(posedge clk) begin
	if (wen)
		memory[addr] <= wdata;
end
 
 assign rdata = (ren==1'b1) ? memory[addr]: 32'd0; 

endmodule
