module demo_master #(
	parameter ADDR_WIDTH = 16, 
	parameter DATA_WIDTH = 8,
	parameter SLAVE_MEM_ADDR_WIDTH = 12,
    parameter SLAVE_COUNT = 3
)(
	input clk, rstn,
	
	// Signals connecting to serial bus
	input mrdata,	// read data
	output mwdata,	// write data and address
	output mmode,	// 0 -  read, 1 - write
	output mvalid,	// wdata valid
	input svalid,	// rdata valid

	// Signals to arbiter
	output mbreq,
	input mbgrant,

	// Acknowledgement from address decoder 
	input ack,

    // Control signals
    input start,
    input mode,
    output ready
);

    localparam DEVICE_ADDR_WIDTH = ADDR_WIDTH - SLAVE_MEM_ADDR_WIDTH;

    // Signals connecting to master device
	wire [DATA_WIDTH-1:0] dwdata; // write data
	wire [DATA_WIDTH-1:0] drdata;	// read data
	wire [ADDR_WIDTH-1:0] daddr;
	reg dvalid; 			 		// ready valid interface
	wire dready;
	reg dmode;					// 0 - read, 1 - write

    reg [4:0] memaddr;
    reg memwen;
    reg [DEVICE_ADDR_WIDTH-1:0] slave_id;
    reg [SLAVE_MEM_ADDR_WIDTH-1:0] slave_mem_addr;

    master_port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE_MEM_ADDR_WIDTH(SLAVE_MEM_ADDR_WIDTH)
    ) dut (
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
        .ack(ack)
    );

    master_bram memory (
        .address(memaddr),
        .clock(clk),
        .data(drdata),
        .wren(memwen),
        .q(dwdata)
    );

    localparam IDLE = 2'b00,
               READ = 2'b01,
               SEND = 2'b10,
               DONE = 2'b11;

    // State variables
	reg [1:0] state, next_state;
    reg [1:0] counter;

    // Next state logic
	always @(*) begin
		case (state)
			IDLE    : next_state = (start) ? ((!mode) ? SEND : READ) : IDLE;
			READ    : next_state = (counter == 1) ? SEND : READ;
			SEND    : next_state = (counter == 1) ? DONE : SEND; 
            DONE    : next_state = (dready) ? IDLE : DONE;
			default: next_state = IDLE;
		endcase
	end

    // State transition logic
	always @(posedge clk) begin
		state <= (!rstn) ? IDLE : next_state;
	end

    assign ready = (state == IDLE);
    assign daddr = {slave_id, slave_mem_addr};

    always @(posedge clk) begin
        if (!rstn) begin
            memaddr <= 'b0;
            memwen <= 0;
            slave_id <= 'b0;
            slave_mem_addr <= 'b0;
            dvalid <= 0;
            dmode <= 0;
        end 
        else begin
            case (state)
                IDLE : begin
                    dvalid <= 0;
                    memwen <= 0;
                    counter <= 'b0;

                    if (start) begin
                        dmode <= mode;

                        if (mode) begin     // write to new location, otherwise read from same location
                            memaddr <= memaddr + 1;
                            slave_id <= (slave_id == SLAVE_COUNT-1) ? 'b0 : (slave_id + 1);
                            slave_mem_addr <= slave_mem_addr + 1;
                        end else begin
                            memaddr <= memaddr;
                            slave_id <= slave_id;
                            slave_mem_addr <= slave_mem_addr;
                        end
                        
                    end else begin
                        dmode <= dmode;
                        memaddr <= memaddr;
                        slave_id <= slave_id;
                        slave_mem_addr <= slave_mem_addr;
                    end
                end

                READ : begin
                    dvalid <= 0;
                    counter <= counter ^ 1;
                end

                SEND : begin
                    dvalid <= 1;
                    counter <= counter ^ 1;
                end

                DONE : begin
                    dvalid <= 0;
                    if (dready) begin
                        memwen <= (!dmode);
                    end 
                    else begin
                        memwen <= 0;
                    end
                end

                default: begin
                    memaddr <= memaddr;
                    memwen <= memwen;
                    slave_id <= slave_id;
                    slave_mem_addr <= slave_mem_addr;
                    dvalid <= dvalid;
                    dmode <= dmode;
                end

            endcase
        end
    end

endmodule