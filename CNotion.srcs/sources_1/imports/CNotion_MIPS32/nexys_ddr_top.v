`include "defines.v"

module nexys_ddr_top(
	input wire clk_50M,   // 50MHZ 时钟输入

    input wire CPU_RESETN,         // BTN6手动复位按钮开关，带消抖电路，按下时为1

    input wire[4:0] BTN,      // BTN1~BTN5，按钮开关，按下时为1
    input wire[15:0] SW,     // 16位拨码开关，拨到"ON"时为1
    output wire[15:0] LED,   // 16位LED,输出1时点亮

    output wire[7:0] SSEG_CA, // 数码管低位信号,输出1点亮
    output wire [7:0] SSEG_AN, // 数码管高位信号,输出0点亮

    output wire RGB1_Blue,   // 灯泡1蓝色RGB
    output wire RGB1_Green, // 灯泡1绿色RGB
    output wire RGB1_Red,   // 灯泡1红色RGB
    output wire RGB2_Blue,  // 灯泡2蓝色RGB
    output wire RGB2_Green, // 灯泡2绿色RGB
    output wire RGB2_Red,   // 灯泡2红色RGB



    //RAM信号
	inout wire [15:0]	ddr2_dq,
	inout wire [1:0]		ddr2_dqs_n,
	inout wire [1:0]		ddr2_dqs_p,
	output wire [12:0]	ddr2_addr,
	output wire [2:0]	ddr2_ba,
	output wire 	ddr2_ras_n,
	output wire 	ddr2_cas_n,
	output wire 	ddr2_we_n,
	output wire [0:0]	ddr2_ck_p,
	output wire [0:0]	ddr2_ck_n,
	output wire [0:0]	ddr2_cke,
	output wire [0:0]	ddr2_cs_n,
	output wire [1:0]	ddr2_dm,
	output wire [0:0]	ddr2_odt,

    // 直连串口信号
    output  UART_TXD_IN,   // 直连串口写入数据
    input  UART_TXD, // 直连串口接收数据
    output wire UART_CTS, // 串口发送数据信号，1是有效，0是无效
    input   UART_RTS, // 串口接受数据信号



    // SPI Flash存储信号
    input  wire sdi,
    output reg  cs_n,
    output reg  sdo,
    output wire  wp_n,
    output wire  hld_n

);


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


//assign UART_RTS = 1'b0;  // 串口信号始终为有效
//assign  UART_CTS = 1'b0 ; // true


reg app_en; // 指令使能，当app_addr和app_cmd都准备好后，将其拉高来送出指令
reg app_wdf_end; // 写数据末端信号，当输入的数据是最后一个时，将此信号拉高，表示数据已送完
reg [2:0] app_cmd; // 用户指令，3'b001为读，3'b000为写
reg [26:0] app_addr;  // 数据地址，从高位到低位分别是 bank 4位，行地址13位和列地址10位
reg [127:0] app_wdf_data; // 写数据，他会先经过app_wdf_mask，将指定部分覆盖为全1后送出
reg app_wdf_wren; // 写使能，当数据准备好时，将此信号拉高
wire [127:0] app_rd_data;  // 读数据
wire [15:0] app_wdf_mask;  // 写数据mask，16位的mask，每一位对应数据中的8位，当mask的[0]为高时，app_wdf_data[7:0]送入DDR时会变成全1；当mask的[15]为高时，app_wdf_data[127:120]送入DDR时会变成全1
wire app_rdy; // 指令接收信号，此信号升高表示送入的指令已经被接受。如果迟迟不升高，有可能DDR在初始化，或者FIFO已满无法在读写，或者正在处理其他的读操作
wire app_rd_data_end; // 读数据末端信号，最后一个读出的信号
wire app_rd_data_valid; // 读数据准备，此信号升高表示读数据准备，可以接受数据
wire app_wdf_rdy; // 写数据准备，此信号升高表示FIFO已经准备好接收新数据
wire app_sr_active; // 保留输出引脚，无视
wire app_ref_ack; // 该信号升高表示refresh刷新指令被确认
wire app_zq_ack; // 该信号升高表示ZQ校准指令被确认
wire init_calib_complete;
wire app_wire_en; //写数据准备,app_wdf_rdy不让动



// 初始化LED灯的显示
reg[15:0] led_bits = 16'b0000_0000_0000_0000;
assign LED = led_bits;


reg [15:0] counter = 16'h0;
parameter cnt_init = 16'h1;	// minimum: 1
reg [26:0] addr0 = 27'h000_0008;
reg [26:0] addr1 = 27'h003_0100;
reg [127:0] data = 128'h1111_2222_3333_4444_5555_6666_7777_8888;
reg [1:0] stop_w = 2'b00;
(* mark_debug = "TRUE" *) reg [1:0] read_valid = 2'b0;
(* mark_debug = "TRUE" *) reg [127:0] read_data = 128'h0;
always@ (posedge app_rd_data_valid) begin
    read_data = app_rd_data;
    read_valid[0] = (app_rd_data == data);
    read_valid[1] = (app_rd_data == data);
end

// Flash 读数据
assign wp_n  = 1'b1;
assign hld_n = 1'b1;

// 定义flash读取信号
parameter IDLE       = 4'b0000;
parameter START      = 4'b0001;
parameter INST_OUT   = 4'b0010;
parameter ADDR1_OUT  = 4'b0011;
parameter ADDR2_OUT  = 4'b0100;
parameter ADDR3_OUT  = 4'b0101;
parameter READ_DATA  = 4'b0111;
parameter ENDING     = 4'b1000;	

reg         sck;
reg  [3:0]  state;
reg  [3:0]  next_state;
reg  [7:0]   instruction;
reg  [7:0]   datain_shift;
reg  [7:0]   datain;
wire [7:0] instouch;

assign instouch = instruction;


reg  [7:0]  dataout;
reg         sck_en;
reg  [2:0]  sck_en_d;
reg  [2:0]  cs_n_d;

(* dont_touch = "true" *)reg  [7:0]  inst_count;
reg         temp;
reg  [3:0]  sdo_count;
reg  [2:0]	data_count;
reg  [15:0] page_count;
reg  [7:0]  wait_count;
wire         addr_req;  // Address writing requested
wire  [15:0] rd_cnt;  // Number of bytes to be read
wire  [23:0] addr;




always@ (posedge clk_50M or negedge CPU_RESETN) begin
    if (CPU_RESETN == 1'b0) begin
        counter = 12'b0;
        stop_w = 2'b0;
        app_en = 1'b0;
        app_addr = 27'h0;
        app_cmd = 3'b1;
        app_wdf_data = 128'h0;
        app_wdf_end = 1'b0;
        app_wdf_wren = 1'b0;
        state <= IDLE;
    end else begin
        if (counter == cnt_init && ~stop_w[0])
            if (app_rdy & app_wdf_rdy) begin
                app_addr = addr0;
                app_cmd = 3'b0;
                app_wdf_wren = 1'b1;
                app_wdf_end = 1'b1;
                app_en = 1'b1;
            end else		// Hold specific signals until app_wdf_rdy is asserted.
                counter = counter - 16'h1;
        else if (counter == cnt_init + 1 && ~stop_w[0])
            if (app_rdy & app_wdf_rdy) begin
                app_wdf_end = 1'b0;
                app_wdf_wren = 1'b0;
                app_en = 1'b0;
                app_cmd = 3'b1;
                stop_w[0] = 1'b1;
            end else		// Hold specific signals until app_wdf_rdy is asserted.
                counter = counter - 16'h1;
        else if (counter == cnt_init + 8 && ~stop_w[1])
            if (app_rdy & app_wdf_rdy) begin
                app_addr = addr1;
                app_cmd = 3'b0;
                app_wdf_wren = 1'b1;
                app_wdf_end = 1'b1;
                app_en = 1'b1;
            end else		// Hold specific signals until app_wdf_rdy is asserted.
                counter = counter - 16'h1;
        else if (counter == cnt_init + 9 && ~stop_w[1])
            if (app_rdy & app_wdf_rdy) begin
                app_wdf_end = 1'b0;
                app_wdf_wren = 1'b0;
                app_en = 1'b0;
                app_cmd = 3'b1;
                stop_w[1] = 1'b1;
            end else		// Hold specific signals until app_wdf_rdy is asserted.
                counter = counter - 16'h1;
        else if (counter == cnt_init + 88) begin
            app_addr = addr0;
            app_en = 1'b1;
            if (~app_rdy) counter = counter - 16'h1;
        end else if (counter == cnt_init + 89)
            app_en = 1'b0;
        
        counter = counter + 16'h1;
        state <= next_state;
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
wire[`RegBus] digit_data_o;

assign digit_data_o = app_wdf_data[`RegBus];

//assign app_wdf_data[`RegBus] = write_data;

always@ (posedge clk_50M) begin
		if (SW[3]) begin
			digit_data <= app_addr;
			 led_bits[3] <=1'b1;
		end
		if (SW[4]) begin
		    led_bits[4] <= 1'b1;
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
reg [1:0] counters;

assign  UART_CTS = ext_uart_start_reg;



always @(posedge clk_50M) begin
    if (~CPU_RESETN) begin
        number <= 8'b1111_1111; 
        led_bits <= 16'h0; // 重置LED
        ext_uart_tx_reg <= 8'b0;
        ext_uart_start_reg <= 1'b0;
        counters <= 2'b0;
        next_state  <= IDLE;
		sck_en      <= 1'b0;
		cs_n_d[0]   <= 1'b1;
		dataout     <= 8'd0;
		dataout     <= 8'd0;
		data[31:0]  <=32'b0;
		sdo_count   <= 4'd0;
		data_count  <= 3'd0;
		sdo         <= 1'b0;
		datain      <= 8'd0;
        inst_count  <= 8'd0;
        temp        <= 1'b0;
        page_count  <= 16'd0;
        wait_count  <= 8'd0;
        
    end else begin
        led_bits[15:10] <= SW[15:10];
        if (ext_uart_start) begin
            ext_uart_tx_reg <= ext_uart_tx;
            ext_uart_start_reg <= 1'b1;
            counters <= 2'b0;
        end else begin
            counters <= counters + 1;
            if (&counters) begin
                ext_uart_tx_reg <= 8'b0;
                ext_uart_start_reg <= 1'b0;
            end
        end
        case(state)
		IDLE: 
		begin	// IDLE state
			next_state <= START;
            wait_count <= 8'd0;
		end
		START:
		begin	// enable SCK and CS
			sck_en <= 1'b1;
			cs_n_d[0]  <= 1'b0;
			next_state <= INST_OUT;
		end
		INST_OUT:
		begin	// send out instruction
			if(sdo_count == 4'd1) begin
				{sdo, dataout[6:0]} <= instruction;
			end
			else if(sdo_count[0]) begin
				{sdo, dataout[6:0]} <= {dataout[6:0],1'b0};
			end
			
			if(sdo_count != 4'd15) begin
				sdo_count <= sdo_count + 4'd1;
			end
			else begin
				sdo_count  <= 4'd0;
				next_state <= (addr_req) ?  ADDR1_OUT : ((rd_cnt==16'd0) ? ENDING : READ_DATA);
			end
		end
		ADDR1_OUT:
		begin	// send out address[23:16]
			if(sdo_count == 4'd1) begin
				{sdo, dataout[6:0]} <= addr[23:16];
			end
			else if(sdo_count[0]) begin
				{sdo, dataout[6:0]} <= {dataout[6:0],1'b0};
			end
			
			if(sdo_count != 4'd15) begin
				sdo_count <= sdo_count + 4'd1;
			end
			else begin
				sdo_count  <= 4'd0;
				next_state <= ADDR2_OUT;
			end
		end
		ADDR2_OUT:
		begin	// send out address[15:8]
			if(sdo_count == 4'd1) begin
				{sdo, dataout[6:0]} <= addr[15:8];
			end
			else if(sdo_count[0]) begin
				{sdo, dataout[6:0]} <= {dataout[6:0],1'b0};
			end
			
			if(sdo_count != 4'd15) begin
				sdo_count <= sdo_count + 4'd1;
			end
			else begin
				sdo_count  <= 4'd0;
				next_state <= ADDR3_OUT;
			end
		end
		ADDR3_OUT:
		begin	// send out address[7:0]
			if(sdo_count == 4'd1) begin
				{sdo, dataout[6:0]} <= addr[7:0];
			end
			else if(sdo_count[0]) begin
				{sdo, dataout[6:0]} <= {dataout[6:0],1'b0};
			end
			
			if(sdo_count != 4'd15) begin
				sdo_count <= sdo_count + 4'd1;
			end
			else begin
				sdo_count  <= 4'd0;
				next_state <= ((rd_cnt==16'd0) ? ENDING : READ_DATA);
                page_count <= 16'd0;
			end
		end
		READ_DATA:
		begin	// get the first data from flash
            if(~sdo_count[0]) begin
                datain_shift <= {datain_shift[6:0],sdi};
            end
            
            if(sdo_count == 4'd1) begin
                datain <= {datain_shift, sdi};
                ext_uart_tx_reg <= datain; // flash读取到的数据发送到串口
                case (data_count)
                3'd0:begin
                	data[32:0] <= {data[31:8], datain};
                	data_count <= data_count + 3'd1;
                end
                3'd1:begin
                	data[32:0] <={data[31:16], datain, data[7:0]};
                	data_count <= data_count + 3'd1;
                end
                3'd2:begin
                	data[32:0] <={data[31:24], datain, data[15:0]};
                	data_count <= data_count + 3'd1;
                end
                3'd3:begin
                	data[32:0] <={datain, data[23:0]};
                	data_count <= data_count + 3'd1;
                end
                default: begin
                	data[32:0] <= 32'b0;
                	data_count <= 3'b0;
                end

                endcase
            end
            
			if(sdo_count != 4'd15) begin
				sdo_count <= sdo_count + 4'd1;
			end
			else begin
                page_count <= page_count + 16'd1;
				sdo_count  <= 4'd0;
				next_state <= (page_count < (rd_cnt-16'd1)) ? READ_DATA : ENDING;
            end
		end
		ENDING:
		begin	//disable SCK and CS, wait for 32 clock cycles
            if(wait_count != 8'd64) begin
                wait_count <= wait_count + 8'd1;
                next_state <= ENDING;
            end
            else begin
                if(instruction == 8'h05 && datain[0]) begin // If in RDSR1, wait until the process ended
                    {inst_count,temp} <= {inst_count,temp};
                end
                else begin
                    {inst_count,temp} <= {inst_count,temp} + 9'd1;
                end
                next_state <= IDLE;
            end
			sck_en <= 1'b0;
			cs_n_d[0] <= 1'b1;
            sdo_count <= 4'd0;
            data_count <= 3'd0;
            page_count <= 16'd0;
		end
		endcase
		
    end
end

// SPI接口逻辑，识别最后一段数据

always @(posedge clk_50M) begin
    sck_en_d <= {sck_en_d[1:0],sck_en};
    if(~CPU_RESETN) begin
		sck <= 1'b0;
		{cs_n,cs_n_d[2:1]} <= 3'h7;
	end
	else if(sck_en_d[2] & sck_en) begin
		sck <= ~sck;
	end
    else begin
        sck <= 1'b0;
        {cs_n,cs_n_d[2:1]} <= cs_n_d;
    end
end


STARTUPE2
#(
.PROG_USR("FALSE"),
.SIM_CCLK_FREQ(10.0)
)
STARTUPE2_inst
(
  .CFGCLK     (),
  .CFGMCLK    (),
  .EOS        (),
  .PREQ       (),
  .CLK        (1'b0),
  .GSR        (1'b0),
  .GTS        (1'b0),
  .KEYCLEARB  (1'b0),
  .PACK       (1'b0),
  .USRCCLKO   (sck),      // First three cycles after config ignored, see AR# 52626
  .USRCCLKTS  (1'b0),     // 0 to enable CCLK output
  .USRDONEO   (1'b1),     // Shouldn't matter if tristate is high, but generates a warning if tied low.
  .USRDONETS  (1'b1)      // 1 to tristate DONE output
);


async_receiver #(.ClkFrequency(50000000),.Baud(115200)) //接收模块，115200无检验位
    ext_uart_r(
        .clk(clk_50M),                       //外部时钟信号
        .RxD(UART_TXD),                   //外部串行信号输入
        .RxD_data_ready(ext_uart_ready), 	 //数据接收到标志
        .RxD_clear(ext_uart_ready),       	 //清除接收标志
        .RxD_data(ext_uart_rx)             	 //接收到的一字节数据
    );
    
async_transmitter #(.ClkFrequency(50000000),.Baud(115200)) //发送模块，115200无检验位
    ext_uart_t(
        .clk(clk_50M),                       //外部时钟信号
        .TxD(UART_TXD_IN),                      //串行信号输出
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
    if (~CPU_RESETN) begin 
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
  
  rom roms(
    .clk(clk_50M),
    .ce(rom_ce),
    .inst_count(inst_count),
    .instruction(instouch),
    .addr(addr),
    .addr_req(addr_req),
    .rd_cnt(rd_cnt)
);

 openmips openmips0(
		.clk(clk_50M),
		.rst(CPU_RESETN),
	
		.rom_addr_o(inst_addr),
		.rom_data_i(inst),
		.rom_ce_o(rom_ce),

    	.int_i(int_i),

		.ram_we_o(app_wire_en),
		.ram_addr_o(mem_addr_i),
		.ram_sel_o(mem_sel_i),
		.ram_data_o(digit_data_o),    // 写ram数据
		.ram_data_i(digit_data),    // 读取数据ram的内容
		.ram_ce_o(mem_ce_i),
		
		.timer_int_o(timer_int)			
	
	);
	
	inst_rom inst_rom0(
		.ce(rom_ce),
		.addr(inst_addr),
		.inst(inst)	
	);

//	data_ram data_ram0(
//		.clk(clk_50M),
//		.ce(mem_ce_i),
//		.we(app_wdf_rdy),
//		.addr(mem_addr_i),
//		.sel(mem_sel_i),
//		.data_i(digit_data),
//		.data_o(mem_data_o)	
//	);


endmodule