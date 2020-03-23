`include "defines.v"

module id(
	input wire                    rst,
    input wire[`InstAddrBus]      pc_i,
    input wire[`InstBus]          inst_i,

    input wire[`AluOpBus]         ex_aluop_i,
    input wire                    ex_wreg_i,
    input wire[`RegBus]           ex_wdata_i,
    input wire[`RegAddrBus]       ex_wd_i,

    input wire                    mem_wreg_i,
    input wire[`RegBus]           mem_wdata_i,
    input wire[`RegAddrBus]       mem_wd_i,

    input wire[`RegBus]           reg1_data_i,
    input wire[`RegBus]           reg2_data_i,

    input wire                    is_in_delayslot_i,
    input wire[31:0]              excepttype_i,

    output reg                    reg1_read_o,
    output reg                    reg2_read_o,
    output reg[`RegAddrBus]       reg1_addr_o,
    output reg[`RegAddrBus]       reg2_addr_o,

    output reg[`AluOpBus]         aluop_o,
    output reg[`AluSelBus]        alusel_o,
    output reg[`RegBus]           reg1_o,
    output reg[`RegBus]           reg2_o,
    output reg[`RegAddrBus]       wd_o,
    output reg                    wreg_o,
    output wire[`RegBus]          inst_o,

    output reg                    next_inst_in_delayslot_o,

    output reg                    branch_flag_o,
    output reg[`RegBus]           branch_target_address_o,
    output reg[`RegBus]           link_addr_o,
    output reg                    is_in_delayslot_o,

    output wire[31:0]             excepttype_o,
    output wire[`RegBus]          current_inst_address_o,

    output wire                   stallreq
);
	

endmodule
