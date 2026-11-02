-- =============================================================
-- fixed_mul_q8_8.vhd
-- Perkalian dua bilangan Q8.8 (16-bit unsigned) -> Q8.8
-- (kombinasional murni, tanpa register)
-- Jobsheet 9 - Prosedur 1
-- =============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fixed_mul_q8_8 is
    Port ( a      : in  STD_LOGIC_VECTOR (15 downto 0); -- format Q8.8
           b      : in  STD_LOGIC_VECTOR (15 downto 0); -- format Q8.8
           result : out STD_LOGIC_VECTOR (15 downto 0) ); -- format Q8.8
end fixed_mul_q8_8;

architecture Behavioral of fixed_mul_q8_8 is
    signal product : unsigned(31 downto 0); -- Q16.16 (hasil kali penuh, 32-bit)
begin
    product <= unsigned(a) * unsigned(b);
    -- Ambil kembali ke format Q8.8: geser 8 bit ke kanan (buang 8 bit pecahan LSB),
    -- lalu ambil 16 bit bawah (buang overflow bagian atas untuk contoh sederhana ini)
    result <= STD_LOGIC_VECTOR(product(23 downto 8));
end Behavioral;
