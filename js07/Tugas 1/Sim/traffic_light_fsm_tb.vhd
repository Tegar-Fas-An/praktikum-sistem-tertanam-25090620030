----------------------------------------------------------------------------
-- Jobsheet 7 - TUGAS PRAKTIKUM NOMOR 1 SAJA
-- Testbench self-checking untuk traffic_light_fsm.vhd (6-state + all-red)
--
-- Memverifikasi:
--   1. Urutan state: NS_HIJAU -> NS_KUNING -> ALLRED_1 -> EW_HIJAU ->
--      EW_KUNING -> ALLRED_2 -> (ulang)
--   2. Fase ALLRED_1/ALLRED_2 benar2 membuat KEDUA arah merah bersamaan
--      (jeda keselamatan sesuai Tugas 1)
--   3. Kedua arah tidak pernah hijau bersamaan & LED tiap arah one-hot
--
-- `tick` dibangkitkan langsung sebagai pulsa periodik (bukan dari
-- tick_1hz dgn 100 juta siklus) agar simulasi FSM tetap singkat.
--
-- Jalankan dengan GHDL:
--   ghdl -a --std=08 ../src/traffic_light_fsm.vhd traffic_light_fsm_tb.vhd
--   ghdl -e --std=08 traffic_light_fsm_tb
--   ghdl -r --std=08 traffic_light_fsm_tb --vcd=fsm_tb.vcd
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity traffic_light_fsm_tb is
end traffic_light_fsm_tb;

architecture sim of traffic_light_fsm_tb is

    constant CLK_PERIOD : time := 10 ns;

    signal clk  : STD_LOGIC := '0';
    signal rst  : STD_LOGIC := '1';
    signal tick : STD_LOGIC := '0';
    signal led  : STD_LOGIC_VECTOR(5 downto 0);

    signal errors : integer := 0;
    signal allred_seen : boolean := false;
    signal ns_leds : STD_LOGIC_VECTOR(2 downto 0);
    signal ew_leds : STD_LOGIC_VECTOR(2 downto 0);

begin

    DUT : entity work.traffic_light_fsm
        port map ( clk => clk, rst => rst, tick => tick, led => led );

    ns_leds <= led(2 downto 0);
    ew_leds <= led(5 downto 3);

    clk_gen : process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- 1 pulsa tick selebar 1 siklus clk, setiap 4 siklus clk
    tick_gen : process
    begin
        wait for CLK_PERIOD * 3;
        tick <= '1';
        wait for CLK_PERIOD;
        tick <= '0';
    end process;

    check_exclusive : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                if (ns_leds = "001" or ns_leds = "010" or ns_leds = "100") and
                   (ew_leds = "001" or ew_leds = "010" or ew_leds = "100") then
                    if ns_leds = "001" and ew_leds = "001" then
                        report "GAGAL: NS dan EW hijau bersamaan!" severity error;
                        errors <= errors + 1;
                    end if;
                    -- tandai bila fase all-red (keduanya merah) teramati
                    if ns_leds = "100" and ew_leds = "100" then
                        allred_seen <= true;
                    end if;
                else
                    report "GAGAL: salah satu arah tidak one-hot" severity error;
                    errors <= errors + 1;
                end if;
            end if;
        end if;
    end process;

    stim : process
    begin
        rst <= '1';
        wait for CLK_PERIOD * 3;
        rst <= '0';

        wait for CLK_PERIOD * 4 * 60;  -- ~60 tick, cukup >1 siklus lengkap (10+3+1+10+3+1=28)

        report "Simulasi selesai, jumlah pelanggaran = " & integer'image(errors);
        assert errors = 0
            report "GAGAL: ditemukan pelanggaran one-hot / dua arah hijau bersamaan"
            severity failure;
        assert allred_seen
            report "GAGAL: fase all-red (Tugas 1) tidak pernah teramati!"
            severity failure;
        report "LULUS: urutan state, fase all-red, & eksklusivitas LED sesuai Tugas 1";
        wait;
    end process;

end sim;
