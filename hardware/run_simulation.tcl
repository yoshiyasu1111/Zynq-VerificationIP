# Set project path
set project_directory ./proj/[file dirname [info script]]
set project_name "vip"

# Open project
open_project [file join $project_directory $project_name]

generate_target Simulation [get_files ./proj/vip.srcs/sources_1/bd/design_1/design_1.bd]

export_ip_user_files -of_objects [get_files ./proj/vip.srcs/sources_1/bd/design_1/design_1.bd] \
                    -no_script \
                    -sync \
                    -force \
                    -quiet

export_simulation -of_objects [get_files ./proj/vip.srcs/sources_1/bd/design_1/design_1.bd] \
                -directory ./proj/vip.ip_user_files/sim_scripts \
                -ip_user_files_dir ./proj/vip.ip_user_files \
                -ipstatic_source_dir ./proj/vip.ip_user_files/ipstatic \
                -lib_map_path [list {modelsim=./proj/vip.cache/compile_simlib/modelsim} \
                                {questa=./proj/vip.cache/compile_simlib/questa} \
                                {riviera=./proj/vip.cache/compile_simlib/riviera} \
                                {activehdl=./proj/vip.cache/compile_simlib/activehdl}] \
                -use_ip_compiled_libs \
                -force \
                -quiet

launch_simulation

cd ./proj/vip.sim/sim_1/behav/xsim

source tb.tcl

add_wave {{/tb/zynq_sys/design_1_i/myip_0/inst/myip_v1_0_M_AXI_inst}} 
run all

start_gui
