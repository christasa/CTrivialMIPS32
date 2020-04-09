`default_nettype none
`include "defines.v"

module nexys_ddr_top(
	input wire clk_50M,   //50MHZ 时钟输入

	input wire clock_btn,          //BTN5手动时钟按钮开关，带消抖电路，按下时为1 ,暂时找不到
    input wire CPU_RESETN,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input wire[4:0] BTN,      //BTN1~BTN5，按钮开关，按下时为1
    input wire[15:0] SW,     //16位拨码开关，拨到“ON”时为1
    output wire[16:0] LED,   //16位LED,输出1时点亮
    output wire[7:0] SSEG_CA, //数码管低位信号,输出1点亮
    output wire [7:0] SSEG_AN, //数码管高位信号,输出1点亮
    output wire RGB1_Blue,   //灯泡1蓝色RGB
    output wire RGB1_Green, //灯泡1绿色RGB
    output wire RGB1_Red,   //灯泡1红色RGB
    output wire RGB2_Blue,  //灯泡2蓝色RGB
    output wire RGB2_Green, //灯泡2绿色RGB
    output wire RGB2_Red,   //灯泡2红色RGB

    //CPLD串口控制信号
    // ???

    //直连串口信号
    output wire UART_TXD_IN,   //直连串口发送端
    input wire UART_TXD, //直连串口接收端

    //Flash存储信号
    output reg  cs_n,
    input       sdi,
    output reg  sdo,
    output      wp_n,
    output      hld_n,

);

assign wp_n  = 1'b1;
assign hld_n = 1'b1;

// 数码管连接关系示意图，dpy1同理
// p=SSEG_CA[0] // ---a---
// c=SSEG_CA[1] // |     |
// d=SSEG_CA[2] // f     b
// e=SSEG_CA[3] // |     |
// b=SSEG_CA[4] // ---g---
// a=SSEG_CA[5] // |     |
// f=SSEG_CA[6] // e     c
// g=SSEG_CA[7] // |     |
//              // ---d---  p

reg[7:0] number;
SEG7_LUT segL(.oSEG1(SSEG_CA), .iDIG(number[3:0])); //SSEG_CA是低位数码管
SEG7_LUT segH(.oSEG1(SSEG_AN), .iDIG(number[7:4])); //SSEG_AN是高位数码管


//初始化LED灯的显示
reg[15:0] led_bits;
assign LED = led_bits;

always @(posedge CPU_RESETN or ) begin
	if (CPU_RESETN) begin // 重置LED和显示管
		number <= 0;
		led_bits <= 16'h1; //重置LED
		
	end
end


cnotionmips cnotionmips0(
	.clk(clk_50M), //100MHz
	.rst(CPU_RESETN),


);

always @(posedge clk_50M) begin
	number <= 0;
	led_bits <= 16'b1111111111111111;
	if (CPU_RESETN) begin
		number <= 8'b0; 
		// reset	
	end
end

endmodule