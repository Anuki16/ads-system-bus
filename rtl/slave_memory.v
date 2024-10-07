module slave_memory #(parameter ADDR_WIDTH = 12, DATA_WIDTH = 8, MEM_SIZE = 4096)
(

	input clk, rstn, wen, ren,
	
	input [ADDR_WIDTH-1:0] addr, //input address of slave
	input [DATA_WIDTH-1:0] wdata, // data to be written in the slave

	output [DATA_WIDTH-1:0] rdata // data to be read from the slave
);


reg [DATA_WIDTH - 1:0] memory [(MEM_SIZE / (DATA_WIDTH / 8))-1:0];

integer i;

//assign waddr = addr[ADDR_WIDTH-1:0];
 
always @(posedge clk) begin
	if (!rstn) begin
		// Reset memory when rstn is low
		for (i = 0; i < (MEM_SIZE / (DATA_WIDTH / 8)); i = i + 1) begin
			memory[i] <= {DATA_WIDTH{1'b0}};
		end
	end else begin
		if (wen) begin
			memory[addr] <= wdata;
		end
	end
end
 
assign rdata = (ren==1'b1) ? memory[addr]: 32'd0; 

endmodule
