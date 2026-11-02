-- =============================================================
-- fixed_mul_pipe3.vhd
-- TUGAS PRAKTIKUM 1
-- Pipeline 3 tahap dari perkalian fixed-point Q8.8 x Q8.8 -> Q8.8.
-- Perkalian 16x16 dipecah menjadi perkalian parsial 8x16 agar
-- tiap tahap kombinasional lebih pendek dari versi pipe2:
--
--   Tahap 1 : pisahkan a menjadi a_hi(8 msb)/a_lo(8 lsb),
--             hitung dua perkalian PARSIAL: a_lo*b dan a_hi*b (8x16 bit)
--   Tahap 2 : JUMLAHKAN hasil parsial (a_hi*b digeser 8 bit) -> produk
--             penuh 32-bit (setara Q16.16)
--   Tahap 3 : SCALING -> ambil bit (23 downto 8) sebagai hasil Q8.8
--
-- Latency = 3 siklus clock, throughput tetap 1 hasil/siklus (steady
-- state), tetapi logika kombinasional tiap tahap lebih pendek
-- dibanding pipe2 (perkalian 16x16 dipecah) sehingga fmax diharapkan
-- lebih tinggi / WNS lebih longgar pada 100 MHz.
-- =============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fixed_mul_pipe3 is
    Port ( clk    : in  STD_LOGIC;
           a      : in  STD_LOGIC_VECTOR (15 downto 0); -- format Q8.8
           b      : in  STD_LOGIC_VECTOR (15 downto 0); -- format Q8.8
           result : out STD_LOGIC_VECTOR (15 downto 0) ); -- format Q8.8
end fixed_mul_pipe3;

architecture Behavioral of fixed_mul_pipe3 is

    -- ---- Register tahap 1 : hasil perkalian parsial ----
    signal pp_lo_reg : unsigned(23 downto 0); -- a_lo(8) * b(16) -> 24 bit
    signal pp_hi_reg : unsigned(23 downto 0); -- a_hi(8) * b(16) -> 24 bit

    -- ---- Register tahap 2 : produk penuh (Q16.16, 32-bit) ----
    signal product_reg : unsigned(31 downto 0);

    -- ---- Register tahap 3 : hasil akhir setelah scaling (Q8.8) ----
    signal result_reg : STD_LOGIC_VECTOR(15 downto 0);

    -- sinyal kombinasional pembantu tahap 1
    signal a_hi, a_lo : unsigned(7 downto 0);
    signal b_u         : unsigned(15 downto 0);

begin

    a_hi <= unsigned(a(15 downto 8));
    a_lo <= unsigned(a(7 downto 0));
    b_u  <= unsigned(b);

    ----------------------------------------------------------------
    -- TAHAP 1 : perkalian parsial 8x16, hasil langsung diregister
    ----------------------------------------------------------------
    stage1 : process(clk)
    begin
        if rising_edge(clk) then
            pp_lo_reg <= a_lo * b_u;  -- kontribusi 8 bit LSB dari a
            pp_hi_reg <= a_hi * b_u;  -- kontribusi 8 bit MSB dari a (perlu digeser 8 bit)
        end if;
    end process;

    ----------------------------------------------------------------
    -- TAHAP 2 : penjumlahan hasil parsial -> produk penuh Q16.16
    ----------------------------------------------------------------
    stage2 : process(clk)
    begin
        if rising_edge(clk) then
            product_reg <= resize(pp_lo_reg, 32) +
                           shift_left(resize(pp_hi_reg, 32), 8);
        end if;
    end process;

    ----------------------------------------------------------------
    -- TAHAP 3 : scaling kembali ke Q8.8 (geser 8 bit, ambil 16 bit)
    ----------------------------------------------------------------
    stage3 : process(clk)
    begin
        if rising_edge(clk) then
            result_reg <= STD_LOGIC_VECTOR(product_reg(23 downto 8));
        end if;
    end process;

    result <= result_reg;
    -- Catatan: latency = 3 siklus clock, throughput tetap 1 pasangan
    -- input baru per siklus dapat diterima (pipa terus mengalir).

end Behavioral;
