
module rom(
    input wire clk,
    input wire ce,
    input  wire [7:0] inst_count,
    output reg [7:0]  instruction,
    output reg [23:0] addr,
    output reg addr_req,
    output reg [15:0] rd_cnt
    );
 
 always @(posedge clk) begin
    case(inst_count)
	8'd0 : begin 
    instruction <= 8'h90;  addr_req <= 1'b1; 
    addr <= 24'h000000; rd_cnt <= 16'd2; end  // READ_ID
    8'd1 : begin 
    instruction <= 8'h9F;  addr_req <= 1'b0; 
    addr <= 24'h000000; rd_cnt <= 16'd81; end  // RDID
	8'd2 : begin 
    instruction <= 8'h05;  addr_req <= 1'b0; 
    addr <= 24'h000000;  rd_cnt <= 16'd2; end  // RDSR1
    8'd3 : begin 
    instruction <= 8'h35;addr_req <= 1'b0; 
    addr <= 24'h000000;  rd_cnt <= 16'd2; end  // RDCR
	8'd4 : begin 
    instruction <= 8'h03; addr_req <= 1'b1; 
    addr <= 24'h800000; rd_cnt <= 16'd32; end  // READ
    8'd5 : begin 
    instruction <= 8'h06; addr_req <= 1'b0; 
    addr <= 24'h000000;  rd_cnt <= 16'd0; end  // WREN
    8'd6 : begin 
    instruction <= 8'h05;  addr_req <= 1'b0; 
    addr <= 24'h000000;  rd_cnt <= 16'd2; end  // RDSR1
	8'd7 : begin 
    instruction <= 8'hd8;  addr_req <= 1'b1; 
    addr <= 24'h800000; rd_cnt <= 16'd64; end  // SE
    8'd8 : begin 
    instruction <= 8'h05;  addr_req <= 1'b0; 
    addr <= 24'h000000;  rd_cnt <= 16'd2; end  // RDSR1
    8'd9 : begin 
    instruction <= 8'h03; addr_req <= 1'b1; 
    addr <= 24'h800000;  rd_cnt <= 16'd32; end  // READ
    8'd10: begin 
    instruction <= 8'h06;  addr_req <= 1'b0; 
    addr <= 24'h000000; rd_cnt <= 16'd0; end  // WREN
	8'd11: begin 
    instruction <= 8'h02; addr_req <= 1'b1; 
    addr <= 24'h800000; rd_cnt <= 16'd0; end  // PP
    8'd12: begin 
    instruction <= 8'h05;  addr_req <= 1'b0; 
    addr <= 24'h000000;  rd_cnt <= 16'd2; end  // RDSR1
	8'd13: begin 
    instruction <= 8'h03;  addr_req <= 1'b1; 
    addr <= 24'h800000; rd_cnt <= 16'd32; end  // READ
	default : begin 
    instruction <= 8'h05;  addr_req <= 1'b0; 
    addr <= 24'h000000;  rd_cnt <= 16'd2; end  // RDSR1
	endcase
end
    
endmodule
