-- =============================================================
-- fixed_mul_pipe2.vhd
-- Versi pipeline 2 tahap dari fixed_mul_q8_8:
--   Tahap 1 = perkalian penuh (disimpan ke register)
--   Tahap 2 = scaling (geser 8 bit) + register output
-- Latency = 2 siklus clock, throughput = 1 hasil / siklus (steady state)
-- Jobsheet 9 - Prosedur 2
-- =============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fixed_mul_pipe2 is
    Port ( clk    : in  STD_LOGIC;
           a      : in  STD_LOGIC_VECTOR (15 downto 0);
           b      : in  STD_LOGIC_VECTOR (15 downto 0);
           result : out STD_LOGIC_VECTOR (15 downto 0) );
end fixed_mul_pipe2;

architecture Behavioral of fixed_mul_pipe2 is
    signal product_reg : unsigned(31 downto 0);       -- register tahap 1
    signal result_reg  : STD_LOGIC_VECTOR(15 downto 0); -- register tahap 2
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Tahap 1: hitung perkalian penuh, simpan ke register
            product_reg <= unsigned(a) * unsigned(b);
            -- Tahap 2: ambil hasil tahap 1 (dari siklus sebelumnya), lakukan scaling
            result_reg  <= STD_LOGIC_VECTOR(product_reg(23 downto 8));
        end if;
    end process;

    result <= result_reg;
    -- Catatan: latency menjadi 2 siklus clock (dibanding 0 siklus/kombinasional murni
    -- pada Kode 9.1), namun setiap siklus dapat menerima pasangan a,b BARU (throughput tinggi).
end Behavioral;
