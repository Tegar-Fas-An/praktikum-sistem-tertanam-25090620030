----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/14/2026 03:20:58 PM
-- Design Name: 
-- Module Name: tb_leading_one_detector - Behavioral
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

entity tb_leading_one_detector is
end tb_leading_one_detector;

architecture sim of tb_leading_one_detector is
    signal din   : STD_LOGIC_VECTOR(7 downto 0);
    signal pos   : STD_LOGIC_VECTOR(2 downto 0);
    signal valid : STD_LOGIC;
begin
    uut: entity work.leading_one_detector
        generic map (WIDTH => 8)
        port map (din => din, pos => pos, valid => valid);

    process
    begin
        din <= "00000000"; wait for 10 ns;
        assert valid = '0' report "FAIL: all-zero harusnya valid=0" severity error;

        din <= "00000001"; wait for 10 ns;
        assert pos = "000" and valid = '1' report "FAIL case bit0" severity error;

        din <= "00000110"; wait for 10 ns;
        assert pos = "010" and valid = '1' report "FAIL case bit2" severity error;

        din <= "01010000"; wait for 10 ns;
        assert pos = "110" and valid = '1' report "FAIL case bit6" severity error;

        din <= "10000000"; wait for 10 ns;
        assert pos = "111" and valid = '1' report "FAIL case bit7" severity error;

        din <= "11111111"; wait for 10 ns;
        assert pos = "111" and valid = '1' report "FAIL case all-one" severity error;

        report "Simulasi selesai";
        wait;
    end process;
end sim;