module slave_port #(parameter ADDR_WIDTH = 12, DATA_WIDTH = 8)
(
	input clk, rstn,

	// Signals connecting to slave memory
	input [DATA_WIDTH-1:0] smemrdata, // data read from the slave memory
	
	output reg smemwen, smemren,
	output [ADDR_WIDTH-1:0] smemaddr, //input address of slave
	output [DATA_WIDTH-1:0] smemwdata, // data written to the slave memory

	// Signals connecting to serial bus
	input swdata,	// write data and address from master
	output reg srdata,	// read data to the master
	input smode,	// 0 -  read, 1 - write, from master
	input mvalid,	// wdata valid - (recieving data and address from master)
	output reg svalid	// rdata valid - (sending data from slave)
);

	/* Internal signals */

	// registers to accept data from master and slave memory
	reg [DATA_WIDTH-1:0] wdata;  //write data from master
	reg [ADDR_WIDTH-1:0] addr;
	reg [DATA_WIDTH-1:0] rdata;	//read data from slave memory

	// counters
	reg [7:0] counter;

	// States
    localparam IDLE  = 3'b000,    
               ADDR  = 3'b001, 	// Receive address from slave
               RDATA = 3'b010,    // Send data to master
					WDATA = 3'b011;	// Receive data from master
	// State variables
	reg [2:0] state, next_state;

	// Next state logic
	always @(*) begin
		case (state)
			IDLE  : next_state = (mvalid) ? ADDR : IDLE;
			ADDR  : next_state = (counter == ADDR_WIDTH-1) ? ((smode) ? WDATA : RDATA) : ADDR;
			RDATA : next_state = (counter == DATA_WIDTH-1) ? IDLE : RDATA;
			WDATA : next_state = (counter == DATA_WIDTH-1) ? IDLE : WDATA;
			default: next_state = IDLE;
		endcase
	end

	// State transition logic
	always @(posedge clk) begin
		state <= (!rstn) ? IDLE : next_state;
	end

	// Combinational output assignments
	assign smemwdata = wdata;
	assign smemaddr = addr;

	// Sequential output logic
	always @(posedge clk) begin
		if (!rstn) begin
			wdata <= 'b0;
			rdata <= 'b0;
			addr <= 'b0;
			counter <= 'b0;
			svalid <= 0;
			smemren <= 0;
			smemwen <= 0;
		end
		else begin
			case (state)
			
				IDLE : begin
					counter <= 'b0;
					svalid <= 0;
				end
				
				ADDR : begin
					if (mvalid) begin
						addr[counter] <= swdata;

						if (counter == ADDR_WIDTH-1) begin
							counter <= 'b0;
						end else begin
							counter <= counter + 1;
						end
						
					end else begin
						addr <= addr;
						counter <= counter;
					end

				end
			
				RDATA : begin	// Send data to master
					smemren <= 1'b1;
					rdata	<=	smemrdata;
					
					srdata <= rdata[counter];
					svalid <= 1'b1;

					if (counter == DATA_WIDTH-1) begin
						counter <= 'b0;
						svalid <= 1'b0;
					end else begin
						counter <= counter + 1;
					end
					
				end			
			
				WDATA : begin	// Receive data from master
					smemwen <= 1'b1;
					if (mvalid) begin
						wdata[counter] <= swdata;
			
						if (counter == DATA_WIDTH-1) begin
							counter <= 'b0;
						end else begin
							counter <= counter + 1;
						end	
					end else begin
						wdata <= wdata;
						counter <= counter;
					end
				end
				
				default: begin
					wdata <= wdata;
					rdata <= rdata;
					addr <= addr;;
					counter <= counter;
					svalid <= mvalid;
					smemwen <= smemwen;
					smemren <= smemren;
				end
				
			endcase
		end
	end


endmodule
