
module addr_convert #(
    BB_ADDR_WIDTH = 12,
    BUS_ADDR_WIDTH = 16,
    BUS_MEM_ADDR_WIDTH = 12
) (
    input [BB_ADDR_WIDTH-1:0] bb_addr,
    output [BUS_ADDR_WIDTH-1:0] bus_addr
);

    assign bus_addr[0+:BUS_MEM_ADDR_WIDTH] = {(BUS_MEM_ADDR_WIDTH-BB_ADDR_WIDTH+1){1'b0}, bb_addr[0+:(BB_ADDR_WIDTH-1)]};
    assign bus_addr[BUS_MEM_ADDR_WIDTH+:1] = bb_addr[BB_ADDR_WIDTH-1+:1];
    assign bus_addr[BUS_ADDR_WIDTH-1:BUS_MEM_ADDR_WIDTH+1] = 'b0;

endmodule