module arbiter
(
	input clk, rstn,
	input breq1, breq2,  //bus requests from 2 masters
	input sready1, sready2, sready3,   //slave ready
	input ssplit,			// slave split
	
	output bgrant1, bgrant2,  //bus grant signals for 2 masters
	output msel, //master select; 0 - master 1, 1 - master 2
	output reg msplit1, msplit2,		// Split signals given to master
	output split_grant			// grant access to continue split transaction (send back to slave)
);
	
	//priority based: high priority for master 1 - breq1

	wire sready;
	reg [1:0] split_owner;

	assign sready = sready1 & sready2 & sready3;

	// Split owner encoding
	localparam NONE = 2'b00,
			   SM1 = 2'b01,
			   SM2 = 2'b10;

	// States
    localparam IDLE  = 3'b000,    //0
               M1  = 3'b001, 	// M1 uses bus//1
			   M2 = 3'b010;	// M2 uses bu3 //3

	// State variables
	reg [2:0] state, next_state;

	// Next state logic
	always @(*) begin
		case (state)
			IDLE  : next_state = (breq1 & sready) ? M1 : ((breq2 & sready) ? M2 : IDLE);
			M1  : next_state = (breq1) ? M1 : IDLE;
			M2 : next_state = (breq2) ? M2 : IDLE;
			default: next_state = IDLE;
		endcase
	end

	// State transition logic
	always @(posedge clk) begin
		state <= (!rstn) ? IDLE : next_state;
	end

	// Combinational output assignments
	assign bgrant1 = (state == M1);
	assign bgrant2 = (state == M2);
	assign msel = (state == M2);

	// Sequential output assignments (for split)
	always @(posedge clk) begin
		if (!rstn) begin
			msplit1 <= 1'b0;
			msplit2 <= 1'b0;
			split_owner <= NONE;
		end
		else begin
			case (state)
				// IDLE : begin
				// 	if (split_owner != NONE && !ssplit) begin
				// 		split_grant <= 1'b1;
				// 	end else begin
				// 		split_grant <= split_grant;
				// 	end
				// end

				M1 : begin
					if (ssplit) begin
						msplit1 <= 1'b1;
						split_owner <= SM1;
					end else begin
						msplit1 <= 1'b0;
						split_owner <= NONE;
					end
				end

				M2 : begin
					if (ssplit) begin
						msplit2 <= 1'b1;
						split_owner <= SM2;
					end else begin
						msplit2 <= 1'b0;
						split_owner <= NONE;
					end
				end

				default : begin
					msplit1 <= msplit1;
					msplit2 <= msplit2;
					split_owner <= split_owner;
				end
			endcase
		end
	end

endmodule
