----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/20/2026 10:01:16 PM
-- Design Name: 
-- Module Name: js03_priority_encoder_top - Behavioral
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

entity js03_priority_encoder_top is
    Port ( sw  : in  STD_LOGIC_VECTOR (7 downto 0);
           led : out STD_LOGIC_VECTOR (3 downto 0) );
end js03_priority_encoder_top;

architecture Behavioral of js03_priority_encoder_top is
begin
    inst_encoder: entity work.leading_one_detector
        generic map (WIDTH => 8)
        port map (
            din   => sw,
            pos   => led(2 downto 0),
            valid => led(3)
        );
end Behavioral;