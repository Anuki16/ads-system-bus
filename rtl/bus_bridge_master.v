module master_port #(
	parameter ADDR_WIDTH = 16, 
	parameter DATA_WIDTH = 8,
	parameter SLAVE_MEM_ADDR_WIDTH = 12,
    parameter UART_CLOCKS_PER_PULSE = 5208
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
	input ack,

    // Bus bridge UART signals
    output u_tx,
    input u_rx
);
    //localparam UART_TX_DATA_WIDTH = 
    
	// Signals connecting to master port
	reg [DATA_WIDTH-1:0] dwdata; // write data
	wire [DATA_WIDTH-1:0] drdata;	// read data
	reg [ADDR_WIDTH-1:0] daddr;
	reg dvalid; 			 		// ready valid interface
	wire dready;
	reg dmode;					// 0 - read, 1 - write

    // Signals connecting to FIFO
    reg fifo_enq;
    reg fifo_deq;
    reg [DATA_WIDTH-1:0] fifo_din;
    wire [DATA_WIDTH-1:0] fifo_dout;
    wire fifo_empty;

    // Signals connecting to UART
    reg [DATA_WIDTH-1:0] u_din;
    reg u_en;
    wire u_tx_busy;
    wire u_rx_ready;
    wire [DATA_WIDTH-1:0] u_dout;

    // Instantiate modules

    // Master port
    master_port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    ) master (
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

    // FIFO module
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) fifo_queue (
        .clk(clk),
        .rstn(rstn),
        .enq(fifo_enq),
        .deq(fifo_deq),
        .data_in(fifo_din),
        .data_out(fifo_dout),
        .empty(fifo_empty)
    );

    // UART module
    uart #(
        .CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE),
        .DATA_WIDTH(DATA_WIDTH)
    ) uart1 (
        .data_input(u_din),
        .data_en(u_en),
        .clk(clk),
        .rstn(rstn),
        .tx(u_tx),  // Transmitter output (tx)
        .tx_busy(u_tx_busy),
        .rx(u_rx),  
        .ready(u_rx_ready),   
        .data_output(u_dout)
    );

    // Send UART received data to FIFO 
    always @(posedge clk) begin
        if (!rstn) begin
            fifo_din <= 'b0;
            fifo_enq <= 1'b0;
        end
        else begin
            if (u_rx_ready) begin
                fifo_din <= u_dout;
                fifo_enq <= 1'b1;
            end
            else begin
                fifo_din <= fifo_din;
                fifo_enq <= 1'b0;
            end
        end
    end

    // Send FIFO data to master port 
    always @(posedge clk) begin
        if (!rstn) begin
            fifo_din <= 'b0;
            fifo_enq <= 1'b0;
        end
        else begin
            if (dready & !fifo_empty) begin
                
            end
            else begin
                fifo_din <= fifo_din;
                fifo_enq <= 1'b0;
            end
        end
    end

endmodule