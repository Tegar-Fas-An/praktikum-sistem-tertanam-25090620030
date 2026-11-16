## JOBSHEET 11 - Constraints untuk js11_top (Basys 3)
## Pemetaan pin sesuai Tabel 11.2 dan Basys 3 Master XDC (Digilent)

## -------------------------------------------------------------
## Clock onboard 100 MHz
## -------------------------------------------------------------
set_property PACKAGE_PIN W5 [get_ports clk100MHz]
set_property IOSTANDARD LVCMOS33 [get_ports clk100MHz]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk100MHz]

## -------------------------------------------------------------
## Tombol reset (btnC - tombol tengah)
## -------------------------------------------------------------
set_property PACKAGE_PIN U18 [get_ports btnC]
set_property IOSTANDARD LVCMOS33 [get_ports btnC]

## -------------------------------------------------------------
## Switch sw[3:0] (dipakai pada TUGAS PRAKTIKUM no.2)
## -------------------------------------------------------------
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]

## -------------------------------------------------------------
## Port VGA (Tabel 11.2) - IOSTANDARD = LVCMOS33
## -------------------------------------------------------------
# vgaRed[3:0]
set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[*]}]

# vgaGreen[3:0]
set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]
set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]
set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]
set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[*]}]

# vgaBlue[3:0]
set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]
set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]
set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]
set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[*]}]

# Hsync / Vsync
set_property PACKAGE_PIN P19 [get_ports Hsync]
set_property IOSTANDARD LVCMOS33 [get_ports Hsync]
set_property PACKAGE_PIN R19 [get_ports Vsync]
set_property IOSTANDARD LVCMOS33 [get_ports Vsync]

## -------------------------------------------------------------
## Catatan: create_clock untuk clk_out1 (25 MHz) pada Clocking Wizard
## umumnya dibuat otomatis oleh IP saat digenerate. Bila tidak muncul
## otomatis pada report timing, tambahkan baris berikut (sesuaikan nama
## net clk_out1 hasil generate IP, mis. CLK_WIZ_INST/clk_out1):
## create_clock -period 40.000 -name pclk_25MHz [get_pins CLK_WIZ_INST/clk_out1]
