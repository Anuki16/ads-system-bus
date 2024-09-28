module arbiter
(

	input clk,
	input breq1, breq2,  //bus requests from 2 masters
	
	output reg [1:0] bgrant  //bus grant or master select
);


//priority based:high priority for master 1 - breq1

always @(posedge clk) begin
	if (breq1 && breq2)       // If both masters request 
		bgrant <= 2'b11;       // Master 1
	else if (breq1)           //
		bgrant <= 2'b11;       // Master 1 
	else if (breq2)           // 
		bgrant <= 2'b10;       // Master 2 
	else                   
		bgrant <= 2'b00;       // Bus Idle
end
 

endmodule
