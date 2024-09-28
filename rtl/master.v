module master #(parameter ADDR_WIDTH = 16, DATA_WIDTH = 32)
(

	input clk, rstn,
	input [DATA_WIDTH-1:0] rdata, //read deata from slave
	input bgrant,	//bus grant signal from arbiter
	
	output reg [ADDR_WIDTH-1:0] addr, //adress of slave memory
	output reg [DATA_WIDTH-1:0] wdata, //data to be written in slave
	output reg breq,  //bus grant signal
	output reg wen, ren  //for slave
);


always @ (posedge clk) begin
    if (!rstn) begin
        breq <= 1'b0;
        addr <= 0;
        wdata <= 0;
        wen <= 1'b0;
        ren <= 1'b0;
    end
	
	//master logic
	//if need to access bus
	//breq <= 1;
	
	//if bgrant = 1 can access the bus
	
end

endmodule

