# Create project
create_project vip ./proj -part xc7z010clg400-1

# Set board file to zybo-z7-10
set_property board_part digilentinc.com:zybo-z7-10:part0:1.0 [current_project]

# Set IP Repositories 
set_property  ip_repo_paths  ./ip_repo [current_project]
update_ip_catalog

# Create base design
create_bd_design "design_1"

# Allocate zynq ip and Run block automation
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

# Setting zynq ip
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_USE_S_AXI_ACP {1}] [get_bd_cells processing_system7_0]

# Allocate my ip
create_bd_cell -type ip -vlnv xilinx.com:user:myip:1.0 myip_0

# Setting my ip
set_property -dict [list CONFIG.C_M_AXI_TARGET_SLAVE_BASE_ADDR {0x00080000}] [get_bd_cells myip_0]

# Run connection Automation
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/myip_0/M_AXI} Slave {/processing_system7_0/S_AXI_ACP} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins processing_system7_0/S_AXI_ACP]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/myip_0/S_AXI} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins myip_0/S_AXI]

# 
regenerate_bd_layout
regenerate_bd_layout -routing

# Create Wrapper of Base Design
make_wrapper -files [get_files ./proj/vip.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse ./proj/vip.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.v

# Add TestBench file
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ./src/sim/tb.sv

update_compile_order -fileset sim_1

save_bd_design

