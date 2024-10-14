module master_port #(
	parameter ADDR_WIDTH = 16, 
	parameter DATA_WIDTH = 8,
	parameter SLAVE_MEM_ADDR_WIDTH = 12
)(
	input clk, rstn,
	
	// Signals connecting to serial bus
	input mrdata,	// read data
	output reg mwdata,	// write data and address
	output mmode,	// 0 -  read, 1 - write
	output reg mvalid,	// wdata valid
	input svalid,	// rdata valid

	// Signals to arbiter
	output mbreq,
	input mbgrant,
	input msplit,

	// Acknowledgement from address decoder 
	input ack
);
    
	// Signals connecting to master port
	reg [DATA_WIDTH-1:0] dwdata; // write data
	wire [DATA_WIDTH-1:0] drdata;	// read data
	reg [ADDR_WIDTH-1:0] daddr;
	reg dvalid; 			 		// ready valid interface
	wire dready;
	reg dmode;					// 0 - read, 1 - write

    // Instantiate modules
    master_port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    ) master_dev (
        .clk(clk),
        .rstn(rstn),
        .dwdata(dwdata),
        .drdata(drdata),
        .daddr(daddr),
        .dvalid(dvalid),
        .dready(dready),
        .dmode(dmode),
        .mrdata(mrdata),
        .mwdata(mwdata),
        .mmode(mmode),
        .mvalid(mvalid),
        .svalid(svalid),
        .mbreq(mbreq),
        .mbgrant(mbgrant),
        .msplit(msplit),
        .ack(ack)
    );

endmodule