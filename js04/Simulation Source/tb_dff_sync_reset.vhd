library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_dff_sync_reset is
-- Testbench tidak memiliki port
end tb_dff_sync_reset;

architecture Behavioral of tb_dff_sync_reset is
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal d   : STD_LOGIC := '0';
    signal q   : STD_LOGIC;

    constant CLK_PERIOD : time := 20 ns;
begin
    -- Instansiasi Unit Under Test (UUT)
    uut: entity work.dff_sync_reset
        port map ( clk => clk, rst => rst, d => d, q => q );

    -- Generator Clock (Periode 20 ns)
    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus Sinyal
    stim_proc: process
    begin
        rst <= '1'; wait for 40 ns;
        rst <= '0';
        
        -- Ubah 'd' di luar tepi clock untuk mengamati penundaan pembaruan 'q'
        wait for 5 ns; d <= '1';
        wait for 30 ns; d <= '0';
        wait for 20 ns; d <= '1';
        wait for 10 ns; rst <= '1'; -- Uji reset sinkron
        wait for 20 ns; rst <= '0';
        wait;
    end process;
end Behavioral;