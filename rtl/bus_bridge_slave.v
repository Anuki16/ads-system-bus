module bus_bridge_slave #(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 12,
    parameter UART_CLOCKS_PER_PULSE = 5208
)(
    input clk, rstn,
    // Signals connecting to serial bus
	input swdata,	// write data and address from master
	output srdata,	// read data to the master
	input smode,	// 0 -  read, 1 - write, from master
	input mvalid,	// wdata valid - (recieving data and address from master)
    input split_grant, // grant bus access in split
	output svalid,	// rdata valid - (sending data from slave)
    output sready, //slave is ready for transaction
    output ssplit,

    // Bus bridge UART signals
    output u_tx,
    input u_rx
);
    localparam UART_TX_DATA_WIDTH = DATA_WIDTH + ADDR_WIDTH + 1;    // Transmit all 3 info
    localparam UART_RX_DATA_WIDTH = DATA_WIDTH;     // Receive only read data
    localparam SPLIT_EN = 1'b0;
    
	// Signals connecting to slave port
	wire [DATA_WIDTH-1:0] smemrdata;
	wire smemwen;
    wire smemren; 
	wire [ADDR_WIDTH-1:0] smemaddr; 
	wire [DATA_WIDTH-1:0] smemwdata;
    wire rvalid;

    // Signals connecting to UART
    reg [UART_TX_DATA_WIDTH-1:0] u_din;
    reg u_en;
    wire u_tx_busy;
    wire u_rx_ready;
    wire [UART_RX_DATA_WIDTH-1:0] u_dout;


    // Instantiate modules

    // Slave port
    slave_port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SPLIT_EN(SPLIT_EN)
    )slave(
        .clk(clk), 
        .rstn(rstn),
        .smemrdata(smemrdata),
        .rvalid(rvalid),
        .smemwen(smemwen), 
        .smemren(smemren),
        .smemaddr(smemaddr), 
        .smemwdata(smemwdata),
        .swdata(swdata),
        .srdata(srdata),
        .smode(smode),
        .mvalid(mvalid),	
        .split_grant(split_grant),
        .svalid(svalid),	
        .sready(sready),
        .ssplit(ssplit)
    );


    // UART module
    uart #(
        .CLOCKS_PER_PULSE(UART_CLOCKS_PER_PULSE),
        .TX_DATA_WIDTH(UART_TX_DATA_WIDTH),
        .RX_DATA_WIDTH(UART_RX_DATA_WIDTH)
    ) uart_module (
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


    // Send write data from slave port to UART TX 
    always @(posedge clk) begin
        if (!rstn) begin
            u_din <= 'b0;
            u_en <= 1'b0;
        end
        else begin
            if (smemwen & !u_tx_busy) begin
                    // Send address , data, mode
                    u_din <= {smemaddr, smemwdata, smemwen}; //[0:11] ADDR  [12:19] WDATA [20] mode
                    u_en  <= 1'b1;
                end
            else begin
                // No transmission when not writing
                u_din <= u_din;
                u_en <= 1'b0;
            end
        end
    end

    assign rvalid = u_rx_ready;
    assign smemrdata = (smemren) ? u_dout : 8'd0;

endmodule