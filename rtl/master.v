module master #(parameter ADDR_WIDTH = 16, DATA_WIDTH = 32)
(

	input clk,
	input [DATA_WIDTH-1:0] rdata, //read deata from slave
	
	output [ADDR_WIDTH-1:0] addr, //adress of slave memory
	output [DATA_WIDTH-1:0] wdata, //data to be written in slave
	output breq,  //bus grant signal
	output wen, ren  //for slave
);


//if need to access bus 
assign breq = 1; 


endmodule
