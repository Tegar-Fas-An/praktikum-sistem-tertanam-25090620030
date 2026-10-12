library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity calculator_top is
    Port (
        clk : in  STD_LOGIC;
        sw  : in  STD_LOGIC_VECTOR (15 downto 0);
        btnU, btnD, btnL, btnR, btnC : in STD_LOGIC;
        led : out STD_LOGIC_VECTOR (15 downto 0);
        seg : out STD_LOGIC_VECTOR (6 downto 0);
        an  : out STD_LOGIC_VECTOR (3 downto 0);
        dp  : out STD_LOGIC
    );
end calculator_top;

architecture Structural of calculator_top is
    signal pu, pd, pl, pr, pc : STD_LOGIC;
    signal disp   : STD_LOGIC_VECTOR (15 downto 0);
    signal result : STD_LOGIC_VECTOR (15 downto 0);
    signal st     : STD_LOGIC_VECTOR (3 downto 0);
    signal rst    : STD_LOGIC := '0';
begin
    -- reset memakai switch paling kiri (sw15)
    rst <= sw(15);

    DU : entity work.debounce_edge port map (clk, btnU, pu);
    DD : entity work.debounce_edge port map (clk, btnD, pd);
    DL : entity work.debounce_edge port map (clk, btnL, pl);
    DR : entity work.debounce_edge port map (clk, btnR, pr);
    DC : entity work.debounce_edge port map (clk, btnC, pc);

    CORE : entity work.calculator_fsm port map (
        clk => clk, rst => rst, sw => sw(7 downto 0),
        p_load_a => pu, p_load_b => pd, p_add => pl, p_sub => pr, p_calc => pc,
        result => result, disp => disp, state_led => st);

    SSD : entity work.seven_seg_driver port map (clk, disp, seg, an, dp);

    led <= (15 downto 4 => '0') & st;
end Structural;
