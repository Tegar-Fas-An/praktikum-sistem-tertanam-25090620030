----------------------------------------------------------------------------
-- Jobsheet 7 - TUGAS PRAKTIKUM NOMOR 1 SAJA
-- (dibangun di atas versi dasar Prosedur Praktikum)
-- File   : traffic_light_fsm.vhd
--
-- Tugas Praktikum butir 1:
--   "Tambahkan fase all-red (kedua arah sama-sama "merah") berdurasi
--    singkat (misalnya 1 detik) sebagai jeda keselamatan sebelum
--    pergantian arah, sisipkan pada diagram status dan implementasi."
--
-- Dibanding versi dasar (Prosedur Praktikum, 4-state), di sini ditambah
-- DUA state baru: ALLRED_1 (setelah NS_KUNING) dan ALLRED_2 (setelah
-- EW_KUNING), masing-masing berdurasi 1 detik. Durasi hijau & kuning
-- MASIH KONSTANTA TETAP (10s / 3s) -- belum memakai switch, karena itu
-- baru Tugas Praktikum nomor 2 (file terpisah).
--
-- Gaya 2-process (sama seperti versi dasar):
--   Process 1 : register state & timer (sequential)
--   Process 2 : next-state & next-timer logic (combinational)
--   Process 3 : decoding keluaran LED (Moore)
--
-- State & urutan (6 state):
--   NS_HIJAU -> NS_KUNING -> ALLRED_1 -> EW_HIJAU -> EW_KUNING -> ALLRED_2 -> (ulang)
--
-- Pemetaan LED (6 bit, sesuai adaptasi krn Basys 3 tidak punya LED RGB):
--   led(2 downto 0) -> arah NS : bit0=hijau, bit1=kuning, bit2=merah
--   led(5 downto 3) -> arah EW : bit3=hijau, bit4=kuning, bit5=merah
--   Pada ALLRED_1/ALLRED_2: NS dan EW SAMA-SAMA merah (jeda keselamatan).
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity traffic_light_fsm is
    Port ( clk  : in  STD_LOGIC;
           rst  : in  STD_LOGIC;
           tick : in  STD_LOGIC;                     -- dari tick_1hz, 1 pulsa/detik
           led  : out STD_LOGIC_VECTOR(5 downto 0) );
end traffic_light_fsm;

architecture Behavioral of traffic_light_fsm is

    type state_t is (NS_HIJAU, NS_KUNING, ALLRED_1, EW_HIJAU, EW_KUNING, ALLRED_2);
    signal state_reg, state_next : state_t := NS_HIJAU;

    -- Durasi tiap fase (detik) -- konstanta tetap
    constant DUR_HIJAU  : integer := 10;
    constant DUR_KUNING : integer := 3;
    constant DUR_ALLRED : integer := 1;   -- <<< Tugas 1: jeda keselamatan

    -- Timer internal disimpan sbg (durasi_fase - 1): dikurangi tiap tick='1',
    -- transisi state terjadi saat timer mencapai 0.
    signal timer_reg, timer_next : integer range 0 to DUR_HIJAU-1;

begin

    ------------------------------------------------------------------
    -- Process 1 : register state & timer (sequential)
    ------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_reg <= NS_HIJAU;
                timer_reg <= DUR_HIJAU - 1;
            else
                state_reg <= state_next;
                timer_reg <= timer_next;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- Process 2 : next-state & next-timer logic (combinational)
    ------------------------------------------------------------------
    process(state_reg, timer_reg, tick)
    begin
        state_next <= state_reg;
        timer_next <= timer_reg;

        if tick = '1' then
            if timer_reg = 0 then
                case state_reg is
                    when NS_HIJAU =>
                        state_next <= NS_KUNING;
                        timer_next <= DUR_KUNING - 1;
                    when NS_KUNING =>
                        state_next <= ALLRED_1;              -- <<< Tugas 1
                        timer_next <= DUR_ALLRED - 1;
                    when ALLRED_1 =>                          -- <<< Tugas 1
                        state_next <= EW_HIJAU;
                        timer_next <= DUR_HIJAU - 1;
                    when EW_HIJAU =>
                        state_next <= EW_KUNING;
                        timer_next <= DUR_KUNING - 1;
                    when EW_KUNING =>
                        state_next <= ALLRED_2;               -- <<< Tugas 1
                        timer_next <= DUR_ALLRED - 1;
                    when ALLRED_2 =>                           -- <<< Tugas 1
                        state_next <= NS_HIJAU;
                        timer_next <= DUR_HIJAU - 1;
                end case;
            else
                timer_next <= timer_reg - 1;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- Process 3 : decoding keluaran LED (Moore, hanya dari state_reg)
    ------------------------------------------------------------------
    process(state_reg)
    begin
        case state_reg is
            when NS_HIJAU  => led <= "100" & "001";  -- EW merah | NS hijau
            when NS_KUNING => led <= "100" & "010";  -- EW merah | NS kuning
            when ALLRED_1  => led <= "100" & "100";  -- EW merah | NS merah  (Tugas 1)
            when EW_HIJAU  => led <= "001" & "100";  -- EW hijau | NS merah
            when EW_KUNING => led <= "010" & "100";  -- EW kuning| NS merah
            when ALLRED_2  => led <= "100" & "100";  -- EW merah | NS merah  (Tugas 1)
        end case;
    end process;

end Behavioral;
