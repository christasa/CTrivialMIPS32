`default_nettype none
`include "defines.v"

module nexys_ddr_top(
	input wire clk_50M,   // 50MHZ ʱ������

    input wire CPU_RESETN,         // BTN6�ֶ���λ��ť���أ���������·������ʱΪ1

    input wire[4:0] BTN,      // BTN1~BTN5����ť���أ�����ʱΪ1
    input wire[15:0] SW,     // 16λ���뿪�أ�����"ON"ʱΪ1
    output wire[15:0] LED,   // 16λLED,���1ʱ����

    output wire[7:0] SSEG_CA, // ����ܵ�λ�ź�,���1����
    output wire [7:0] SSEG_AN, // ����ܸ�λ�ź�,���0����

    output wire RGB1_Blue,   // ����1��ɫRGB
    output wire RGB1_Green, // ����1��ɫRGB
    output wire RGB1_Red,   // ����1��ɫRGB
    output wire RGB2_Blue,  // ����2��ɫRGB
    output wire RGB2_Green, // ����2��ɫRGB
    output wire RGB2_Red,   // ����2��ɫRGB



    //RAM�ź�
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

    // ֱ�������ź�
    output wire UART_TXD_IN,   // ֱ������д������
    input wire UART_TXD, // ֱ�����ڽ�������
    output wire UART_CTS, // ���ڷ��������źţ�0����Ч��1����Ч
    input wire UART_RTS, // ���ڽ��������ź�



    // SPI Flash�洢�ź�
    input  wire    sdi,
    output reg  cs_n,
    output reg  sdo,
    output reg  wp_n,
    output reg  hld_n

);


// ��������ӹ�ϵʾ��ͼ��dpy1ͬ��
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
Disp disp(.clk(clk_50M), .sseg_ca(SSEG_CA), .sseg_an(SSEG_AN), .number(number)); // ��ʾ�����

assign UART_RTS = 1'b0;

reg app_en; // ָ��ʹ�ܣ���app_addr��app_cmd��׼���ú󣬽����������ͳ�ָ��
reg app_wdf_end; // д����ĩ���źţ�����������������һ��ʱ�������ź����ߣ���ʾ����������
reg [2:0] app_cmd; // �û�ָ�3'b001Ϊ����3'b000Ϊд
reg [26:0] app_addr;  // ���ݵ�ַ���Ӹ�λ����λ�ֱ��� bank 4λ���е�ַ13λ���е�ַ10λ
reg [127:0] app_wdf_data; // д���ݣ������Ⱦ���app_wdf_mask����ָ�����ָ���Ϊȫ1���ͳ�
reg app_wdf_wren; // дʹ�ܣ�������׼����ʱ�������ź�����
wire [127:0] app_rd_data;  // ������
wire [15:0] app_wdf_mask;  // д����mask��16λ��mask��ÿһλ��Ӧ�����е�8λ����mask��[0]Ϊ��ʱ��app_wdf_data[7:0]����DDRʱ����ȫ1����mask��[15]Ϊ��ʱ��app_wdf_data[127:120]����DDRʱ����ȫ1
wire app_rdy; // ָ������źţ����ź����߱�ʾ�����ָ���Ѿ������ܡ�����ٳٲ����ߣ��п���DDR�ڳ�ʼ��������FIFO�����޷��ڶ�д���������ڴ��������Ķ�����
wire app_rd_data_end; // ������ĩ���źţ����һ���������ź�
wire app_rd_data_valid; // ������׼�������ź����߱�ʾ������׼�������Խ�������
wire app_wdf_rdy; // д����׼�������ź����߱�ʾFIFO�Ѿ�׼���ý���������
wire app_sr_active; // ����������ţ�����
wire app_ref_ack; // ���ź����߱�ʾrefreshˢ��ָ�ȷ��
wire app_zq_ack; // ���ź����߱�ʾZQУ׼ָ�ȷ��
wire init_calib_complete;
wire app_write_en;



// ��ʼ��LED�Ƶ���ʾ
reg[15:0] led_bits = 16'b0000_0000_0000_0000;
assign LED = led_bits;


reg [15:0] counter = 16'h0;
parameter cnt_init = 16'h1;	// minimum: 1
reg [26:0] addr0 = 27'h000_0008;
reg [26:0] addr1 = 27'h003_0100;
reg [127:0] data0 = 128'h1111_2222_3333_4444_5555_6666_7777_8888;
reg [127:0] data1 = 128'h9999_0000_aaaa_bbbb_cccc_dddd_eeee_ffff;
reg [1:0] stop_w = 2'b00;
(* mark_debug = "TRUE" *) reg [1:0] read_valid = 2'b0;
(* mark_debug = "TRUE" *) reg [127:0] read_data = 128'h0;
always@ (posedge app_rd_data_valid) begin
    read_data = app_rd_data;
    read_valid[0] = (app_rd_data == data0);
    read_valid[1] = (app_rd_data == data1);
end
	


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
    end else begin
        if (counter == cnt_init && ~stop_w[0])
            if (app_rdy & app_wdf_rdy) begin
                app_wdf_data = data0;
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
                app_wdf_data = data1;
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
    end
end

sdram_ddr u_ddr (

		// �ڴ�ӿڶ�
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

		// ���ݽӿڶ�
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

		// ϵͳʱ��
		.sys_clk_i					(clk_50M),

		// Reference Clock Ports
		.clk_ref_i					(clk_50M),
		.sys_rst					(CPU_RESETN)
	);



reg [`RegBus] digit_data;
//reg [`RegBus] write_data;

//wire[`RegBus] mem_data_i = app_rd_data[`RegBus];
//wire[`RegBus] mem_data_o = app_wdf_data[`RegBus];
wire[`RegBus] mem_data_i;
wire[`RegBus] mem_data_o;
wire[`RegBus] ram_data_i;
wire[`RegBus] ram_data_o;


//assign app_wdf_data[`RegBus] = write_data;
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


//ֱ�����ڽ��շ�����ʾ����ֱ�������յ��������ٷ��ͳ�ȥ
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
        led_bits <= 16'hA; // ����LED
        ext_uart_tx_reg <= 8'b0;
        ext_uart_start_reg <= 1'b0;
        counters <= 2'b0;
    end else begin
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
    end
end

async_receiver #(.ClkFrequency(50000000),.Baud(115200)) //����ģ�飬115200�޼���λ
    ext_uart_r(
        .clk(clk_50M),                       //�ⲿʱ���ź�
        .RxD(UART_TXD),                   //�ⲿ�����ź�����
        .RxD_data_ready(ext_uart_ready), 	 //���ݽ��յ���־
        .RxD_clear(ext_uart_ready),       	 //������ձ�־
        .RxD_data(ext_uart_rx)             	 //���յ���һ�ֽ�����
    );
    
async_transmitter #(.ClkFrequency(50000000),.Baud(115200)) //����ģ�飬115200�޼���λ
    ext_uart_t(
        .clk(clk_50M),                       //�ⲿʱ���ź�
        .TxD(UART_TXD_IN),                      //�����ź����
        .TxD_busy(ext_uart_busy),            //������æ״ָ̬ʾ
        .TxD_start(ext_uart_start_reg),      //��ʼ�����ź�
        .TxD_data(ext_uart_tx_reg)           //�����͵�����
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


//����ָ��洢��

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

		.ram_we_o(app_write_en),
		.ram_addr_o(mem_addr_i),
		.ram_sel_o(mem_sel_i),
		.ram_data_o(ram_data_i),
		.ram_data_i(ram_data_o),
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
		.we(app_write_en),
		.addr(mem_addr_i),
		.sel(mem_sel_i),
		.data_i(digit_data),
		.data_o(mem_data_o)	
	);


endmodule