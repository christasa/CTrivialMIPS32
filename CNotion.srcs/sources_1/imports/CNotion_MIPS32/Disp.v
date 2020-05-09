module Disp(clk, sseg_ca, sseg_an, number);
input clk; 
input [7:0] number; 

output reg[7:0] sseg_an; // 显示的晶体管
output wire  [7:0] sseg_ca; // 显示的数码管位置

reg [3:0] value = 4'b0000;
reg [7:0] dispdigit = 8'b01110001;
reg clk_sys;
reg [25:0] div_counter;

assign sseg_ca = dispdigit;


always @(posedge clk) begin    // 鏃堕挓涓婂崌娌?
    if(div_counter >= 25000) begin  //1ms
		clk_sys <= ~clk_sys;    
		div_counter <= 0;
	end
	else begin
		div_counter <= div_counter + 1;
	end
end

wire [7:0] sel;


parameter[2:0] SEG1 = 3'b000,
                    SEG2 = 3'b001,
                    SEG3 = 3'b010,
                    SEG4 = 3'b011,
                    SEG5 = 3'b100,
                    SEG6 = 3'b101,
                    SEG7 = 3'b110,
                    SEG8 = 3'b111;

assign sel = number[7:0]; //一到七为显示位置

reg [2:0] state = 3'b000;

always @(posedge clk_sys ) begin
        case(state)
                SEG1: begin
                    if(sel[7]) begin // 第一位晶体管
                        value <= 4'b0000;
                        sseg_an[7:0] <= 8'b11111111;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG2;
                end
                SEG2: begin
                    if(sel[6] ) begin // 第二位晶体管
                        value <= 4'b1100;
                        sseg_an[7:0] <= 8'b10111111;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG3;
                end
                SEG3: begin
                    if(sel[5] ) begin
                          value <= 4'b0000;
                        sseg_an[7:0] <= 8'b11011111;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG4;
                end
                SEG4: begin
                    if(sel[4] ) begin
                         value <= 4'b0011;
                        sseg_an[7:0] <= 8'b11101111;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG5;
                end
                SEG5: begin
                    if(sel[3] ) begin
                        value <= 4'b0011;
                        sseg_an[7:0] <= 8'b11110111;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG6;
                end
                SEG6: begin
                    if(sel[2] ) begin
                        value <= 4'b0101;
                        sseg_an[7:0] <= 8'b11111011;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG7;
                end
                SEG7: begin
                    if(sel[1]) begin
                        value <= 4'b0111;
                        sseg_an[7:0] <= 8'b11111101;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG8;
                end
                SEG8: begin
                    if(sel[0] ) begin
                        value <= 4'b1010;
                        sseg_an[7:0] <= 8'b11111110;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG1;
                end
                default: begin
                    state <= SEG1;
                end
        endcase
end


// 显示的晶体管位数
always @(*) begin
	case(value)
		4'h0 : dispdigit[7:0] <= 8'b10010001;  //H  //8'b00000011;  // 0    0x03 
		4'h1 : dispdigit[7:0] <= 8'b10011111;  // 1    0x9F
		4'h2 : dispdigit[7:0] <= 8'b00100101;  // 2    0x25
		4'h3 : dispdigit[7:0] <= 8'b00001101;  // 3    0x0D
		4'h4 : dispdigit[7:0] <= 8'b10011001;  // 4    0x99
		4'h5 : dispdigit[7:0] <= 8'b01001001;  // 5    0x49
		4'h6 : dispdigit[7:0] <= 8'b01000001;  // 6    0x41
		4'h7 : dispdigit[7:0] <= 8'b00011111;  // 7    0x1F
		4'h8 : dispdigit[7:0] <= 8'b00000001;  // 8    0x01
		4'h9 : dispdigit[7:0] <= 8'b00011001;  // 9    0x9
		4'hA : dispdigit[7:0] <= 8'b00010001;  // A   0x8
		4'hB : dispdigit[7:0] <= 8'b11000001;	 // B   0xC0
		4'hC : dispdigit[7:0] <= 8'b01100011;	 // C
		4'hD : dispdigit[7:0] <= 8'b10000101;	 // D
		4'hE : dispdigit[7:0] <= 8'b01100001;	 // E
		4'hF : dispdigit[7:0] <= 8'b01110001;	 // F
		default : dispdigit[7:0] <= 8'b11111110;
	endcase
end

endmodule