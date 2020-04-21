`default_nettype none
`include "defines.v"

module nexys_ddr_top(
	input wire clk_50M,   // 50MHZ 时钟输入

    input wire CPU_RESETN,         // BTN6手动复位按钮开关，带消抖电路，按下时为1

    input wire[4:0] BTN,      // BTN1~BTN5，按钮开关，按下时为1
    input wire[15:0] SW,     // 16位拨码开关，拨到“ON”时为1
    output wire[16:0] LED,   // 16位LED,输出1时点亮

    output wire[7:0] SSEG_CA, // 数码管低位信号,输出1点亮
    output wire [7:0] SSEG_AN, // 数码管高位信号,输出0点亮

    output wire RGB1_Blue,   // 灯泡1蓝色RGB
    output wire RGB1_Green, // 灯泡1绿色RGB
    output wire RGB1_Red,   // 灯泡1红色RGB
    output wire RGB2_Blue,  // 灯泡2蓝色RGB
    output wire RGB2_Green, // 灯泡2绿色RGB
    output wire RGB2_Red,   // 灯泡2红色RGB

    // CPLD串口控制信号
    // ???

    //RAM信号
	inout [15:0]			ddr2_dq,
	inout [1:0]				ddr2_dqs_n,
	inout [1:0]				ddr2_dqs_p,
	output [12:0]			ddr2_addr,
	output [2:0]			ddr2_ba,
	output					ddr2_ras_n,
	output					ddr2_cas_n,
	output					ddr2_we_n,
	output [0:0]			ddr2_ck_p,
	output [0:0]			ddr2_ck_n,
	output [0:0]			ddr2_cke,
	output [0:0]			ddr2_cs_n,
	output [1:0]			ddr2_dm,
	output [0:0]			ddr2_odt

    // 直连串口信号
    output wire UART_TXD_IN,   // 直连串口写入数据
    input wire UART_TXD, // 直连串口接收数据
    output reg UART_CTS, // 串口发送数据信号，0是有效，1是无效
    input wire UART_RTS, // 串口接受数据信号



    // SPI Flash存储信号
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
Disp disp(.clk(clk_50M), .sseg_ca(SSEG_CA), .sseg_an(SSEG_AN), .number(number)); // 显示数码管




reg app_en; // 指令使能，当app_addr和app_cmd都准备好后，将其拉高来送出指令
reg app_wdf_wren; // 写使能，当数据准备好时，将此信号拉高
reg app_wdf_end; // 写数据末端信号，当输入的数据是最后一个时，将此信号拉高，表示数据已送完
reg [2:0] app_cmd; // 用户指令，3’b001为读，3’b000为写
reg [26:0] app_addr;  // 数据地址，从高位到低位分别是 bank 4位，行地址13位和列地址10位
reg [127:0] app_wdf_data; // 写数据，他会先经过app_wdf_mask，将指定部分覆盖为全1后送出
wire [127:0] app_rd_data;  // 读数据
wire [15:0] app_wdf_mask;  // 写数据mask，16位的mask，每一位对应数据中的8位，当mask的[0]为高时，app_wdf_data[7:0]送入DDR时会变成全1；当mask的[15]为高时，app_wdf_data[127:120]送入DDR时会变成全1
wire app_rdy; // 指令接收信号，此信号升高表示送入的指令已经被接受。如果迟迟不升高，有可能DDR在初始化，或者FIFO已满无法在读写，或者正在处理其他的读操作
wire app_rd_data_end; // 读数据末端信号，最后一个读出的信号
wire app_rd_data_valid; // 读数据准备，此信号升高表示读数据准备，可以接受数据
wire app_wdf_rdy; // 写数据准备，此信号升高表示FIFO已经准备好接收新数据
wire app_sr_active; // 保留输出引脚，无视
wire app_ref_ack; // 该信号升高表示refresh刷新指令被确认
wire app_zq_ack; // 该信号升高表示ZQ校准指令被确认



// 初始化LED灯的显示
reg[15:0] led_bits = 16'b0000_0000_0000_0000;
assign LED = led_bits;

always @(posedge CPU_RESETN or ) begin
	if (CPU_RESETN) begin  // 重置LED和显示管
		number <= 0;
		led_bits <= 16'h1; // 重置LED
		
	end
end

sdram_ddr u_ddr (

		// 内存接口端
		.ddr2_cs_n					(ddr2_cs_n),
		.ddr2_addr					(ddr2_addr),
		.ddr2_ba					(ddr2_ba),
		.ddr2_we_n					(ddr2_we_n),
		.ddr2_ras_n					(ddr2_ras_n),
		.ddr2_cas_n					(ddr2_cas_n),
		.ddr2_ck_n					(ddr2_ck_n),
		.ddr2_ck_p					(ddr2_ck_p),
		.ddr2_cke					(ddr2_cke),
		.ddr2_dq					(ddr2_dq),
		.ddr2_dqs_n					(ddr2_dqs_n),
		.ddr2_dqs_p					(ddr2_dqs_p),
		.ddr2_dm					(ddr2_dm),
		.ddr2_odt					(ddr2_odt),

		// 数据接口端
		.app_addr					(app_addr),
		.app_cmd					(app_cmd),
		.app_en						(app_en),
		.app_wdf_rdy				(app_wdf_rdy),
		.app_wdf_data				(app_wdf_data),
		.app_wdf_end				(app_wdf_end),
		.app_wdf_wren				(app_wdf_wren),
		.app_rd_data				(app_rd_data),
		.app_rd_data_end			(app_rd_data_end),
		.app_rd_data_valid			(app_rd_data_valid),
		.app_rdy					(app_rdy),
		.app_sr_req					(1'b0),
		.app_ref_req				(1'b0),
		.app_zq_req					(1'b0),
		.app_sr_active				(app_sr_active),
		.app_ref_ack				(app_ref_ack),
		.app_zq_ack					(app_zq_ack),
		.app_wdf_mask				(16'h0000),
		.init_calib_complete		(init_calib_complete),

		// 系统时钟
		.sys_clk_i					(clk_50M),

		// Reference Clock Ports
		.clk_ref_i					(clk_50M),
		.sys_rst					(CPU_RESETN)
	);



reg [`RegBus] digit_data;
reg [`RegBus] write_data = app_wdf_data[`RegBus];

always@ (posedge clk_50M) begin
		if (SW[3]) begin
			digit_data <= app_addr;
		end
		case (SW[1:0])
			2'b00 : digit_data <= app_rd_data[31:0];
			2'b01 : digit_data <= app_rd_data[63:32];
			2'b10 : digit_data <= app_rd_data[95:64];
			2'b11 : digit_data <= app_rd_data[127:96];
		endcase
end


//直连串口接收发送演示，从直连串口收到的数据再发送出去
wire [7:0] ext_uart_rx;
reg [7:0] ext_uart_rx_reg;
reg [7:0] ext_uart_tx_reg, ext_uart_tx;
wire ext_uart_ready, ext_uart_busy;
reg ext_uart_start_reg, ext_uart_start, ext_uart_avai;
reg [1:0] counter;

assign  UART_CTS = ext_uart_start_reg;

always @(posedge clk_50M) begin
    if (CPU_RESETN) begin
        ext_uart_tx_reg <= 8'b0;
        ext_uart_start_reg <= 1'b0;
        counter <= 2'b0;
    end else begin
        if (ext_uart_start) begin
            ext_uart_tx_reg <= ext_uart_tx;
            ext_uart_start_reg <= 1'b1;
            counter <= 2'b0;
        end else begin
            counter <= counter + 1;
            if (&counter) begin
                ext_uart_tx_reg <= 8'b0;
                ext_uart_start_reg <= 1'b0;
            end
        end
    end
end
async_receiver #(.ClkFrequency(50000000),.Baud(115200)) //接收模块，115200无检验位
    ext_uart_r(
        .clk(clk_50M),                       //外部时钟信号
        .RxD(UART_TXD_IN),                   //外部串行信号输入
        .RxD_data_ready(ext_uart_ready), 	 //数据接收到标志
        .RxD_clear(ext_uart_ready),       	 //清除接收标志
        .RxD_data(ext_uart_rx)             	 //接收到的一字节数据
    );
    
async_transmitter #(.ClkFrequency(50000000),.Baud(115200)) //发送模块，115200无检验位
    ext_uart_t(
        .clk(clk_50M),                       //外部时钟信号
        .TxD(UART_TXD),                      //串行信号输出
        .TxD_busy(ext_uart_busy),            //发送器忙状态指示
        .TxD_start(ext_uart_start_reg),      //开始发送信号
        .TxD_data(ext_uart_tx_reg)           //待发送的数据
    );


wire[5:0] int_i;
wire timer_int;
assign int_i = {timer_int, 2'b00, serial_read_status^already_read_status, 2'b00}; //{3'b000, serial_read_status^already_read_status, 1'b0, timer_int};
reg serial_read_status = 1'b0;
reg already_read_status = 1'b0;
reg[7:0] serial_read_data;
always @(posedge ext_uart_ready) begin   
    if (reset_btn) begin 
        serial_read_status <= 1'b0;
    end else begin
        serial_read_status <= ~serial_read_status;
        serial_read_data <= ext_uart_rx;
    end
end


//连接指令存储器

  wire[`InstAddrBus] inst_addr;
  wire[`InstBus] inst;
  wire rom_ce;
  wire mem_we_i;
  wire[`RegBus] mem_addr_i;
  wire[3:0] mem_sel_i; 
  wire mem_ce_i;   

 openmips openmips0(
		.clk(clk_50M),
		.rst(CPU_RESETN),
	
		.rom_addr_o(inst_addr),
		.rom_data_i(inst),
		.rom_ce_o(rom_ce),

    	.int_i(int_i),

		.ram_we_o(app_wdf_wren),
		.ram_addr_o(mem_addr_i),
		.ram_sel_o(mem_sel_i),
		.ram_data_o(digit_data),
		.ram_data_i(write_data),
		.ram_ce_o(mem_ce_i),
		
		.timer_int_o(timer_int)			
	
	);
	
	inst_rom inst_rom0(
		.ce(rom_ce),
		.addr(inst_addr),
		.inst(inst)	
	);

	data_ram data_ram0(
		.clk(clk_50M),
		.ce(mem_ce_i),
		.we(app_wdf_wren),
		.addr(mem_addr_i),
		.sel(mem_sel_i),
		.data_i(digit_data),
		.data_o(write_data)	
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