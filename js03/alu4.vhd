----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/14/2026 03:33:47 PM
-- Design Name: 
-- Module Name: alu4 - Behavioral
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

entity alu4 is
    Port ( a      : in  STD_LOGIC_VECTOR (3 downto 0);
           b      : in  STD_LOGIC_VECTOR (3 downto 0);
           opcode : in  STD_LOGIC_VECTOR (1 downto 0); -- 00=tambah, 01=kurang, 10=kali
           result : out STD_LOGIC_VECTOR (7 downto 0); -- lebar 8-bit (perlu buat hasil kali)
           carry  : out STD_LOGIC );
end alu4;

architecture Behavioral of alu4 is
    signal a_u, b_u   : unsigned(3 downto 0);
    signal sum_ext    : unsigned(4 downto 0);  -- 5 bit: tambah/kurang + carry
    signal mul_ext    : unsigned(7 downto 0);  -- 8 bit: hasil kali
begin
    a_u <= unsigned(a);
    b_u <= unsigned(b);

    process(a_u, b_u, opcode)
    begin
        sum_ext <= (others => '0');
        mul_ext <= (others => '0');
        result  <= (others => '0');
        carry   <= '0';

        case opcode is
            when "00" =>  -- tambah
                sum_ext <= ('0' & a_u) + ('0' & b_u);
                result  <= "0000" & std_logic_vector(sum_ext(3 downto 0));
                carry   <= sum_ext(4);
            when "01" =>  -- kurang
                sum_ext <= ('0' & a_u) - ('0' & b_u);
                result  <= "0000" & std_logic_vector(sum_ext(3 downto 0));
                carry   <= sum_ext(4);
            when "10" =>  -- kali
                mul_ext <= a_u * b_u;
                result  <= std_logic_vector(mul_ext);
                carry   <= '0';  -- tidak dipakai pada mode kali
            when others =>
                result <= (others => '0');
                carry  <= '0';
        end case;
    end process;
end Behavioral;