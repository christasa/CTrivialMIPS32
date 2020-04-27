vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/clocking/mig_7series_v4_2_clk_ibuf.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/clocking/mig_7series_v4_2_infrastructure.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/clocking/mig_7series_v4_2_iodelay_ctrl.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/clocking/mig_7series_v4_2_tempmon.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_arb_mux.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_arb_row_col.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_arb_select.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_bank_cntrl.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_bank_common.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_bank_compare.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_bank_mach.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_bank_queue.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_bank_state.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_col_mach.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_mc.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_rank_cntrl.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_rank_common.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_rank_mach.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/controller/mig_7series_v4_2_round_robin_arb.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/ecc/mig_7series_v4_2_ecc_buf.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/ecc/mig_7series_v4_2_ecc_dec_fix.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/ecc/mig_7series_v4_2_ecc_gen.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/ecc/mig_7series_v4_2_ecc_merge_enc.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/ecc/mig_7series_v4_2_fi_xor.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/ip_top/mig_7series_v4_2_memc_ui_top_std.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/ip_top/mig_7series_v4_2_mem_intfc.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_group_io.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_lane.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_calib_top.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_if_post_fifo.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy_wrapper.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_of_pre_fifo.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_4lanes.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ck_addr_cmd_delay.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal_hr.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_init.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_cntlr.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_data.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_edge.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_lim.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_mux.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_po_cntlr.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_samp.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_oclkdelay_cal.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_prbs_rdlvl.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_rdlvl.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_tempmon.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_top.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrcal.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl_off_delay.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_ddr_prbs_gen.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_poc_cc.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_poc_edge_store.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_poc_meta.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_poc_pd.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_poc_tap_base.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/phy/mig_7series_v4_2_poc_top.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/ui/mig_7series_v4_2_ui_cmd.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/ui/mig_7series_v4_2_ui_rd_data.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/ui/mig_7series_v4_2_ui_top.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/ui/mig_7series_v4_2_ui_wr_data.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/sdram_ddr_mig_sim.v" \
"../../../../CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/rtl/sdram_ddr.v" \


vlog -work xil_defaultlib \
"glbl.v"

