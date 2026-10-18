library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tick_1hz_tb is
end tick_1hz_tb;

architecture sim of tick_1hz_tb is
    constant CLK_PERIOD : time := 10 ns;
    constant N          : integer := 10;   -- CLK_FREQ_HZ dikecilkan agar simulasi cepat
    signal clk  : std_logic := '0';
    signal rst  : std_logic := '1';
    signal tick : std_logic;
begin
    uut : entity work.tick_1hz
        generic map ( CLK_FREQ_HZ => N )
        port map ( clk => clk, rst => rst, tick => tick );

    clk <= not clk after CLK_PERIOD/2;

    stim : process
        variable t_prev : time := 0 ns;
    begin
        wait for 3*CLK_PERIOD;
        rst <= '0';
        -- ukur periode antar pulsa tick
        for i in 1 to 4 loop
            wait until rising_edge(tick);
            if i > 1 then
                assert (now - t_prev) = N*CLK_PERIOD
                    report "Periode tick salah: " & time'image(now - t_prev)
                    severity error;
                report "Periode tick = " & time'image(now - t_prev);
            end if;
            t_prev := now;
        end loop;
        report "Simulasi selesai" severity note;
        wait;
    end process;
end sim;