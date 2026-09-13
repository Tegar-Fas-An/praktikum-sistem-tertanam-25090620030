----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/13/2026 06:56:48 AM
-- Design Name: 
-- Module Name: tb_mux8to1 - Behavioral
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

entity tb_mux8to1 is
--  Port ( );
end tb_mux8to1;

architecture Behavioral of tb_mux8to1 is

    signal sel_tb : STD_LOGIC_VECTOR(2 downto 0);
    signal in0_tb, in1_tb, in2_tb, in3_tb, in4_tb, in5_tb, in6_tb, in7_tb : STD_LOGIC_VECTOR(3 downto 0);
    signal y_tb : STD_LOGIC_VECTOR(3 downto 0);

begin

    DUT: entity work.mux8to1
        port map ( sel => sel_tb, in0 => in0_tb, in1 => in1_tb, in2 => in2_tb, in3 => in3_tb,
                   in4 => in4_tb, in5 => in5_tb, in6 => in6_tb, in7 => in7_tb, y => y_tb );

    stim_proc: process
    begin
        in0_tb <= "0001"; in1_tb <= "0010"; in2_tb <= "0011"; in3_tb <= "0100";
        in4_tb <= "0101"; in5_tb <= "0110"; in6_tb <= "0111"; in7_tb <= "1000";

        sel_tb <= "000"; wait for 20 ns;
        assert (y_tb = in0_tb) report "gagal saat sel=000" severity error;

        sel_tb <= "001"; wait for 20 ns;
        assert (y_tb = in1_tb) report "gagal saat sel=001" severity error;

        sel_tb <= "010"; wait for 20 ns;
        assert (y_tb = in2_tb) report "gagal saat sel=010" severity error;

        sel_tb <= "011"; wait for 20 ns;
        assert (y_tb = in3_tb) report "gagal saat sel=011" severity error;

        sel_tb <= "100"; wait for 20 ns;
        assert (y_tb = in4_tb) report "gagal saat sel=100" severity error;

        sel_tb <= "101"; wait for 20 ns;
        assert (y_tb = in5_tb) report "gagal saat sel=101" severity error;

        sel_tb <= "110"; wait for 20 ns;
        assert (y_tb = in6_tb) report "gagal saat sel=110" severity error;

        sel_tb <= "111"; wait for 20 ns;
        assert (y_tb = in7_tb) report "gagal saat sel=111" severity error;

        wait;
    end process;

end Behavioral;