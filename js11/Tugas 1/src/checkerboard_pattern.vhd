library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity checkerboard_pattern is
    Generic ( BLOCK_SIZE_BITS : integer := 5 );  -- 2^5 = 32 piksel per kotak
    Port ( h_count : in  integer range 0 to 799;
           v_count : in  integer range 0 to 524;
           rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
end checkerboard_pattern;

architecture Behavioral of checkerboard_pattern is

    signal h_blk_bit, v_blk_bit : STD_LOGIC;
    signal checker              : STD_LOGIC;

begin

    -- Ambil bit ke-BLOCK_SIZE_BITS dari h_count/v_count sebagai penentu
    -- kotak ganjil/genap (ekuivalen dengan h_count(BLOCK_SIZE_BITS) pada
    -- representasi biner, didapat lewat operasi bagi & modulo integer).
    h_blk_bit <= '1' when ((h_count / (2**BLOCK_SIZE_BITS)) mod 2) = 1 else '0';
    v_blk_bit <= '1' when ((v_count / (2**BLOCK_SIZE_BITS)) mod 2) = 1 else '0';

    checker <= h_blk_bit xor v_blk_bit;

    rgb <= "111111111111" when checker = '0' else  -- putih
           "000000000000";                          -- hitam

end Behavioral;
