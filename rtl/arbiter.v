module arbiter
(
	input clk, rstn,
	input breq1, breq2,  //bus requests from 2 masters
	input sready1, sready2, sready3,   //slave ready
	
	output bgrant1, bgrant2,  //bus grant signals for 2 masters
	output msel //master select; 0 - master 1, 1 - master 2
);
	
	//priority based: high priority for master 1 - breq1

	wire sready;

	assign sready = sready1 & sready2 & sready3;

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

endmodule
