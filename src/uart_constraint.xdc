## Clock
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { clk }]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 4} [get_ports { clk }]

## Input 
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { rx_in }]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { tx_start }]
set_property -dict { PACKAGE_PIN U20   IOSTANDARD LVCMOS33 } [get_ports { tx_in[0] }]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { tx_in[1] }]
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { tx_in[2] }]
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { tx_in[3] }]
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { tx_in[4] }]
set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { tx_in[5] }]
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { tx_in[6] }]
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { tx_in[7] }]

## Output
set_property -dict { PACKAGE_PIN N20   IOSTANDARD LVCMOS33 } [get_ports { rx_out[0] }]
set_property -dict { PACKAGE_PIN P20   IOSTANDARD LVCMOS33 } [get_ports { rx_out[1] }]
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { rx_out[2] }]
set_property -dict { PACKAGE_PIN T20   IOSTANDARD LVCMOS33 } [get_ports { rx_out[3] }]
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { rx_out[4] }]
set_property -dict { PACKAGE_PIN W20   IOSTANDARD LVCMOS33 } [get_ports { rx_out[5] }]
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { rx_out[6] }]
set_property -dict { PACKAGE_PIN V20   IOSTANDARD LVCMOS33 } [get_ports { rx_out[7] }]
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { rx_dv }]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { tx_dv }]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { tx_out }] 
