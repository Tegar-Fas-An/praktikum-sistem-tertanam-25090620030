## Constraint untuk Tugas 2 (js12_top_tugas2) - SAMA seperti Tugas 1 + tambahan port 'led'

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

## LED (Tugas 2) - led(0) = indikator tombol target sedang ditekan
## led(1) s.d. led(15) tidak dipakai tapi tetap WAJIB di-constraint (port 16-bit)
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property PACKAGE_PIN V13 [get_ports {led[8]}]
set_property PACKAGE_PIN V3  [get_ports {led[9]}]
set_property PACKAGE_PIN W3  [get_ports {led[10]}]
set_property PACKAGE_PIN U3  [get_ports {led[11]}]
set_property PACKAGE_PIN P3  [get_ports {led[12]}]
set_property PACKAGE_PIN N3  [get_ports {led[13]}]
set_property PACKAGE_PIN P1  [get_ports {led[14]}]
set_property PACKAGE_PIN L1  [get_ports {led[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
