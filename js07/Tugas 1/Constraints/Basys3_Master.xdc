## Jobsheet 7 - PROSEDUR PRAKTIKUM SAJA (versi dasar)
## Constraint file untuk top_traffic_light (Basys 3)
## Hanya pin yang dipakai: clk, btnC, led(5:0) -- belum ada switch
## (switch baru dipakai di Tugas Praktikum 2)
## Nomor pin & nama sinyal sesuai Digilent Basys 3 Master XDC resmi.

## Clock onboard 100 MHz
set_property PACKAGE_PIN W5 [get_ports clk]
    set_property IOSTANDARD LVCMOS33 [get_ports clk]
    create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Tombol tengah (btnC) dipakai sebagai reset, aktif-tinggi
set_property PACKAGE_PIN U18 [get_ports btnC]
    set_property IOSTANDARD LVCMOS33 [get_ports btnC]

## LED led(5 downto 0): led(2:0)=NS (bit0 hijau,bit1 kuning,bit2 merah)
##                      led(5:3)=EW (bit3 hijau,bit4 kuning,bit5 merah)
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]

## Konfigurasi bitstream standar Basys 3 (biarkan default, umum dipakai)
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
