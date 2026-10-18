library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port ( clk : in  STD_LOGIC;                        -- 100 MHz
           btnC : in  STD_LOGIC;                       -- reset
           led : out STD_LOGIC_VECTOR(5 downto 0) );
end top;

architecture Behavioral of top is
    signal tick : std_logic;
begin
    u_tick : entity work.tick_1hz
        generic map ( CLK_FREQ_HZ => 100_000_000 )
        port map ( clk => clk, rst => btnC, tick => tick );

    u_fsm : entity work.traffic_light_fsm
        generic map ( T_GREEN => 10, T_YELLOW => 3 )
        port map ( clk => clk, rst => btnC, tick => tick, led => led );
end Behavioral;