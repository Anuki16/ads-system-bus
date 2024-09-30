module arbiter
(
	input clk, rstn,
	input breq1, breq2,  //bus requests from 2 masters
	
	output reg bgrant1, bgrant2,  //bus grant signals for 2 masters
	output reg msel //master select; 0 - master 1, 1 - master 2
);

	//priority based: high priority for master 1 - breq1

	always @(posedge clk) begin
		if (!rstn) begin
			msel <= 1'b0;
			bgrant1 <= 1'b0;
			bgrant2 <= 1'b0;
		end
		else if (breq1 && breq2) begin      // If both masters request 
			msel <= 1'b0;       // Master 1 
			bgrant1 <= 1'b1;
			bgrant2 <= 1'b0;
		end
		else if (breq1) begin          
			msel <= 1'b0;       // Master 1 
			bgrant1 <= 1'b1;
			bgrant2 <= 1'b0;
		end
		else if (breq2) begin           
			msel <= 1'b1;       // Master 2 
			bgrant1 <= 1'b0;
			bgrant2 <= 1'b1;
		end
		else begin                  
			msel <= msel;       // Bus Idle - previous value remains
			bgrant1 <= bgrant1;
			bgrant2 <= bgrant2;
		end
	end

endmodule
