----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/20/2026 10:17:02 PM
-- Design Name: 
-- Module Name: js03_signed_top - Behavioral
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


entity js03_signed_top is
    Port ( sw  : in  STD_LOGIC_VECTOR (8 downto 0);
           led : out STD_LOGIC_VECTOR (4 downto 0) );
end js03_signed_top;

architecture Behavioral of js03_signed_top is
begin
    inst_alu_signed: entity work.alu4_signed
        port map (
            a        => sw(3 downto 0),
            b        => sw(7 downto 4),
            opcode   => sw(8),
            result   => led(3 downto 0),
            overflow => led(4)
        );
end Behavioral;

