module Disp(clk, sseg_ca, sseg_an, number);
input clk; // 时钟显示
input [7:0] number; //显示的数字

output reg[7:0] sseg_an; // 低位数码管
output reg [7:0] sseg_ca; // 高位数码管;

reg [3:0] value = 4'b0000;

// 分频到1ms
reg clk_sys;
reg [25:0] div_counter;
always @(posedge clk) begin    // 时钟上升沿
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

assign sel = number[7:0]; //显示8个字符

reg [2:0] state = 3'b000;

always @(posedge clk_sys ) begin
        case(state)
                SEG1: begin
                    if(sel[7]) begin//第1个数码管选通
                        value <= 4'b0001;
                        sseg_an[7:0] <= 8'b01111111;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG2;
                end
                SEG2: begin
                    if(sel[6] ) begin//第2个数码管选通
                        value <= 4'b0001;
                        sseg_an[7:0] <= 8'b10111111;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG3;
                end
                SEG3: begin
                    if(sel[5] ) begin//第3个数码管选通
                        value <= 4'b0001;
                        sseg_an[7:0] <= 8'b11011111;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG4;
                end
                SEG4: begin
                    if(sel[4] ) begin//第4个数码管选通
                        value <= 4'b0001;
                        sseg_an[7:0] <= 8'b11101111;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG5;
                end
                SEG5: begin
                    if(sel[3] ) begin//第5个数码管选通
                        value <= 4'b0001;
                        sseg_an[7:0] <= 8'b11110111;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG6;
                end
                SEG6: begin
                    if(sel[2] ) begin//第6个数码管选通
                        value <= 4'b0001;
                        sseg_an[7:0] <= 8'b11111011;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG7;
                end
                SEG7: begin
                    if(sel[1]) begin//第7个数码管选通
                        value <= 4'b0001;
                        sseg_an[7:0] <= 8'b11111101;
                    end else begin
                        sseg_an[7:0] <= 8'b11111111;
                    end
                    state <= SEG8;
                end
                SEG8: begin
                    if(sel[0] ) begin//第8个数码管选通
                        value <= 4'b0001;
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


// 显示的数字集合
always @(*) begin
	case(value)
		4'h0 : sseg_ca[7:0] <= 8'b00000011;  // 0    0x03
		4'h1 : sseg_ca[7:0] <= 8'b10011111;  // 1    0x9F
		4'h2 : sseg_ca[7:0] <= 8'b00100101;  // 2    0x25
		4'h3 : sseg_ca[7:0] <= 8'b00001101;  // 3    0x0D
		4'h4 : sseg_ca[7:0] <= 8'b10011001;  // 4    0x99
		4'h5 : sseg_ca[7:0] <= 8'b01001001;  // 5    0x49
		4'h6 : sseg_ca[7:0] <= 8'b01000001;  // 6    0x41
		4'h7 : sseg_ca[7:0] <= 8'b00011111;  // 7    0x1F
		4'h8 : sseg_ca[7:0] <= 8'b00000001;  // 8    0x01
		4'h9 : sseg_ca[7:0] <= 8'b00001001;  // 9    0x9
		4'hA : sseg_ca[7:0] <= 8'b00010001;  // A   0x8
		4'hB : sseg_ca[7:0] <= 8'b11000001;	 // B   0xC0
		4'hC : sseg_ca[7:0] <= 8'b01100011;	 // C
		4'hD : sseg_ca[7:0] <= 8'b10000101;	 // D
		4'hE : sseg_ca[7:0] <= 8'b01100001;	 // E
		4'hF : sseg_ca[7:0] <= 8'b01110001;	 // F
		default : sseg_ca[7:0] <= 8'b11111110;
	endcase
end

endmodule