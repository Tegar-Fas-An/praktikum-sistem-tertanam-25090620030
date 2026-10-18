----------------------------------------------------------------------------
-- Jobsheet 7 - TUGAS PRAKTIKUM NOMOR 1 SAJA
-- Top-level: Pengendali Lampu Lalu Lintas pada Basys 3
--
-- Menghubungkan:
--   tick_1hz          -> pembagi clock 100 MHz menjadi pulsa 1 Hz
--   traffic_light_fsm -> FSM 6-state (sudah + fase all-red) + decoding LED
--
-- Pemetaan port fisik (lihat constraints/Basys3_Master.xdc):
--   clk            -> W5  (CLK100MHZ onboard)
--   rst            -> btnC (U18), aktif-tinggi
--   led(5 downto 0) -> 6 LED pertama, pola NS/EW sesuai catatan adaptasi
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_traffic_light is
    Port ( clk  : in  STD_LOGIC;
           btnC : in  STD_LOGIC;                   -- reset, aktif-tinggi
           led  : out STD_LOGIC_VECTOR(5 downto 0) );
end top_traffic_light;

architecture Structural of top_traffic_light is

    signal tick_sig : STD_LOGIC;

begin

    U_TICK : entity work.tick_1hz
        generic map ( CLK_FREQ_HZ => 100_000_000 )
        port map ( clk  => clk,
                   rst  => btnC,
                   tick => tick_sig );

    U_FSM : entity work.traffic_light_fsm
        port map ( clk  => clk,
                   rst  => btnC,
                   tick => tick_sig,
                   led  => led );

end Structural;
