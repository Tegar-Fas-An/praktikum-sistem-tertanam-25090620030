## Constraint untuk Tugas 1 (js12_top_tugas1) - SAMA PERSIS dengan prosedur awal
## Port: clk, PS2Clk, PS2Data, seg[6:0], an[3:0] -- tidak ada port 'led'

## Clock sistem 100 MHz (WAJIB aktif - penyebab error NSTD-1/UCIO-1 jika dikomentari)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## PS2 (via USB-HID Host, dikendalikan mikrokontroler PIC24FJ128, port USB Tipe-A J2)
set_property PACKAGE_PIN C17 [get_ports PS2Clk]
set_property IOSTANDARD LVCMOS33 [get_ports PS2Clk]
set_property PULLUP true [get_ports PS2Clk]

set_property PACKAGE_PIN B17 [get_ports PS2Data]
set_property IOSTANDARD LVCMOS33 [get_ports PS2Data]
set_property PULLUP true [get_ports PS2Data]

## Seven-segment display (7 segmen + 4 anode)
set_property PACKAGE_PIN W7  [get_ports {seg[0]}]
set_property PACKAGE_PIN W6  [get_ports {seg[1]}]
set_property PACKAGE_PIN U8  [get_ports {seg[2]}]
set_property PACKAGE_PIN V8  [get_ports {seg[3]}]
set_property PACKAGE_PIN U5  [get_ports {seg[4]}]
set_property PACKAGE_PIN V5  [get_ports {seg[5]}]
set_property PACKAGE_PIN U7  [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]

set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]
