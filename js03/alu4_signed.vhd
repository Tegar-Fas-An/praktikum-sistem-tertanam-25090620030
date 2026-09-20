----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/20/2026 10:15:17 PM
-- Design Name: 
-- Module Name: alu4_signed - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use IEEE.NUMERIC_STD.ALL;

entity alu4_signed is
    Port ( a        : in  STD_LOGIC_VECTOR (3 downto 0);
           b        : in  STD_LOGIC_VECTOR (3 downto 0);
           opcode   : in  STD_LOGIC;  -- '0'=tambah, '1'=kurang
           result   : out STD_LOGIC_VECTOR (3 downto 0);
           overflow : out STD_LOGIC );
end alu4_signed;

architecture Behavioral of alu4_signed is
    signal a_s, b_s : signed(3 downto 0);
    signal sum_ext  : signed(4 downto 0);  -- 5 bit: hasil sebelum dipotong
begin
    a_s <= signed(a);
    b_s <= signed(b);

    process(a_s, b_s, opcode)
    begin
        if opcode = '0' then
            sum_ext <= resize(a_s, 5) + resize(b_s, 5);
        else
            sum_ext <= resize(a_s, 5) - resize(b_s, 5);
        end if;
    end process;

    result <= std_logic_vector(sum_ext(3 downto 0));
    -- overflow: bit ke-4 (extended sign) beda dari bit tanda hasil (bit 3)
    overflow <= sum_ext(4) xor sum_ext(3);
end Behavioral;
