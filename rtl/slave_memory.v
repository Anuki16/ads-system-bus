module slave_memory #(parameter ADDR_WIDTH = 16, DATA_WIDTH = 32, MEM_SIZE = 4096)
(

	input clk, rstn, wen, ren,
	
	input [ADDR_WIDTH-1:0] addr, //input address of slave
	input [DATA_WIDTH-1:0] wdata, // data to be written in the slave

	output [DATA_WIDTH-1:0] rdata // data to be read from the slave
);


reg [DATA_WIDTH - 1:0] memory [(MEM_SIZE / (DATA_WIDTH / 8))-1:0];

//define memory

assign waddr = addr[ADDR_WIDTH-1:2];
 
always @(posedge clk) begin
	//if !rstn reset slave memory
	//else
	if (wen)
		memory[waddr] <= wdata;
end
 
assign rdata = (ren==1'b1) ? memory[waddr]: 32'd0; 

endmodule
