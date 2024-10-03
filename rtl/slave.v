module slave #(parameter ADDR_WIDTH = 12, DATA_WIDTH = 8)
(
    input clk, rstn,
    // Signals connecting to serial bus
	input swdata,	// write data and address from master
	output srdata,	// read data to the master
	input smode,	// 0 -  read, 1 - write, from master
	input mvalid,	// wdata valid - (recieving data and address from master)
	output svalid,	// rdata valid - (sending data from slave)
    output sready //slave is ready for transaction
);

	wire [DATA_WIDTH-1:0] smemrdata;
	wire smemwen;
    wire smemren; 
	wire [ADDR_WIDTH-1:0] smemaddr; 
	wire [DATA_WIDTH-1:0] smemwdata;


    slave_port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    )sp(
        .clk(clk), 
        .rstn(rstn),
        .smemrdata(smemrdata),
        .smemwen(smemwen), 
        .smemren(smemren),
        .smemaddr(smemaddr), 
        .smemwdata(smemwdata),
        .swdata(swdata),
        .srdata(srdata),
        .smode(smode),
        .mvalid(mvalid),	
        .svalid(svalid),	
        .sready(sready)
    );


    slave_memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    )sm(
        .clk(clk), 
        .rstn(rstn), 
        .wen(smemwen),
        .ren(smemren),
        .addr(smemaddr), 
        .wdata(smemwdata), 
        .rdata(smemrdata) 
    );

endmodule