----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/14/2026 03:39:24 PM
-- Design Name: 
-- Module Name: tb_alu4 - Behavioral
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

entity tb_alu4 is
end tb_alu4;

architecture sim of tb_alu4 is
    signal a, b     : STD_LOGIC_VECTOR(3 downto 0);
    signal opcode   : STD_LOGIC_VECTOR(1 downto 0);
    signal result   : STD_LOGIC_VECTOR(7 downto 0);
    signal carry    : STD_LOGIC;
begin
    uut: entity work.alu4
        port map (a => a, b => b, opcode => opcode, result => result, carry => carry);

    process
    begin
        -- tambah: 7 + 1 = 8, carry=0
        a <= "0111"; b <= "0001"; opcode <= "00"; wait for 10 ns;
        assert result = "00001000" and carry = '0' report "FAIL: 7+1" severity error;

        -- tambah dengan carry: 15 + 1 = 16 -> result=0, carry=1
        a <= "1111"; b <= "0001"; opcode <= "00"; wait for 10 ns;
        assert result = "00000000" and carry = '1' report "FAIL: 15+1 overflow" severity error;

        -- kurang: 5 - 3 = 2, carry=0 (no borrow)
        a <= "0101"; b <= "0011"; opcode <= "01"; wait for 10 ns;
        assert result = "00000010" and carry = '0' report "FAIL: 5-3" severity error;

        -- kurang dengan borrow: 3 - 5 = -2 -> "11111110", carry=1
        a <= "0011"; b <= "0101"; opcode <= "01"; wait for 10 ns;
        assert result = "11111110" and carry = '1' report "FAIL: 3-5 borrow" severity error;

        -- kali: 3 x 4 = 12
        a <= "0011"; b <= "0100"; opcode <= "10"; wait for 10 ns;
        assert result = "00001100" report "FAIL: 3x4" severity error;

        -- kali maksimum: 15 x 15 = 225
        a <= "1111"; b <= "1111"; opcode <= "10"; wait for 10 ns;
        assert result = "11100001" report "FAIL: 15x15" severity error;

        -- kali dengan nol: 9 x 0 = 0
        a <= "1001"; b <= "0000"; opcode <= "10"; wait for 10 ns;
        assert result = "00000000" report "FAIL: 9x0" severity error;

        report "Simulasi selesai";
        wait;
    end process;
end sim;