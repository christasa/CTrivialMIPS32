# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir D:/coding/vivado/CNotion/CNotion.cache/wt [current_project]
set_property parent.project_path D:/coding/vivado/CNotion/CNotion.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo d:/coding/vivado/CNotion/CNotion.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_mem D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/rom.data
read_verilog -library xil_defaultlib {
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/Disp.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/defines.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/LLbit_reg.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/async.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/cp0_reg.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/ctrl.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/div.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/ex.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/ex_mem.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/hilo_reg.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/id.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/id_ex.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/if_id.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/inst_rom.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/mem.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/mem_wb.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/openmips.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/pc_reg.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/regfile.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/rom.v
  D:/coding/vivado/CNotion/CNotion.srcs/sources_1/imports/CNotion_MIPS32/nexys_ddr_top.v
}
read_ip -quiet D:/coding/vivado/CNotion/CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr.xci
set_property used_in_implementation false [get_files -all d:/coding/vivado/CNotion/CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/constraints/sdram_ddr.xdc]
set_property used_in_implementation false [get_files -all d:/coding/vivado/CNotion/CNotion.srcs/sources_1/ip/sdram_ddr/sdram_ddr/user_design/constraints/sdram_ddr_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc D:/coding/vivado/CNotion/CNotion.srcs/constrs_1/imports/CNotion_MIPS32/Nexys-4-DDR-Master.xdc
set_property used_in_implementation false [get_files D:/coding/vivado/CNotion/CNotion.srcs/constrs_1/imports/CNotion_MIPS32/Nexys-4-DDR-Master.xdc]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top nexys_ddr_top -part xc7a100tcsg324-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef nexys_ddr_top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file nexys_ddr_top_utilization_synth.rpt -pb nexys_ddr_top_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
