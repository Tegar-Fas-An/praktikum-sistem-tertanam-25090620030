library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js05_top is
    Port (
        clk  : in  STD_LOGIC;
        btnU : in  STD_LOGIC;
        btnD : in  STD_LOGIC;
        btnC : in  STD_LOGIC;
        seg  : out STD_LOGIC_VECTOR(6 downto 0);
        dp   : out STD_LOGIC;
        an   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end js05_top;

architecture Behavioral of js05_top is
    signal u_clean, d_clean, rst : STD_LOGIC;
    signal u_pulse, d_pulse      : STD_LOGIC;
    signal count                 : STD_LOGIC_VECTOR(15 downto 0);
begin
    deb_u: entity work.debounce port map (clk => clk, btn_in => btnU, btn_out => u_clean);
    deb_d: entity work.debounce port map (clk => clk, btn_in => btnD, btn_out => d_clean);
    deb_c: entity work.debounce port map (clk => clk, btn_in => btnC, btn_out => rst);

    edge_u: entity work.edge_detect port map (clk => clk, sig_in => u_clean, pulse => u_pulse);
    edge_d: entity work.edge_detect port map (clk => clk, sig_in => d_clean, pulse => d_pulse);

    cntr: entity work.updown_counter
        port map (clk => clk, rst => rst, inc => u_pulse, dec => d_pulse, count => count);

    disp: entity work.seven_seg_driver
        generic map (DIGITS => 4)
        port map (clk => clk, data => count, seg => seg, dp => dp, an => an);
end Behavioral;
