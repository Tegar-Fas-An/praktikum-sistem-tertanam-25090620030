library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Unit kendali (FSM Moore, 2-process style) + datapath kalkulator.
-- Masukan tombol sudah berupa pulsa 1 siklus (keluaran debounce_edge).
entity calculator_fsm is
    Port (
        clk, rst   : in  STD_LOGIC;
        sw         : in  STD_LOGIC_VECTOR (7 downto 0);
        p_load_a   : in  STD_LOGIC; -- btnU
        p_load_b   : in  STD_LOGIC; -- btnD
        p_add      : in  STD_LOGIC; -- btnL
        p_sub      : in  STD_LOGIC; -- btnR
        p_calc     : in  STD_LOGIC; -- btnC
        result     : out STD_LOGIC_VECTOR (15 downto 0);
        disp       : out STD_LOGIC_VECTOR (15 downto 0);
        state_led  : out STD_LOGIC_VECTOR (3 downto 0)
    );
end calculator_fsm;

architecture Behavioral of calculator_fsm is
    type calc_state is (S_WAIT_A, S_WAIT_B, S_COMPUTE, S_SHOW);
    signal state, next_state : calc_state := S_WAIT_A;

    signal reg_a, reg_b : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal op_sel       : STD_LOGIC := '0';  -- '0'=tambah, '1'=kurang
    signal alu_y        : STD_LOGIC_VECTOR (15 downto 0);
    signal reg_res      : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

    -- keluaran Moore (hanya fungsi state)
    signal do_compute, show_res : STD_LOGIC;

    component alu8 is
        Port ( a, b : in STD_LOGIC_VECTOR (7 downto 0);
               op   : in STD_LOGIC;
               y    : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
begin
    ---------------- Process 1: register state (sinkron) ----------------
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= S_WAIT_A;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    ---------------- Process 2: next_state + output Moore (kombinasional) --
    process (state, p_load_a, p_calc)
    begin
        next_state <= state;
        do_compute <= '0';
        show_res   <= '0';
        state_led  <= "0000";
        case state is
            when S_WAIT_A =>
                state_led <= "0001";
                if p_load_a = '1' then next_state <= S_WAIT_B; end if;
            when S_WAIT_B =>
                state_led <= "0010";
                if p_calc = '1' then next_state <= S_COMPUTE; end if;
            when S_COMPUTE =>
                state_led  <= "0100";
                do_compute <= '1';
                next_state <= S_SHOW;
            when S_SHOW =>
                state_led <= "1000";
                show_res  <= '1';
                if p_calc = '1' then next_state <= S_WAIT_A; end if;
        end case;
    end process;

    ---------------- Datapath ----------------
    U_ALU : alu8 port map (a => reg_a, b => reg_b, op => op_sel, y => alu_y);

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg_a <= (others => '0'); reg_b <= (others => '0');
                op_sel <= '0'; reg_res <= (others => '0');
            else
                if state = S_WAIT_A and p_load_a = '1' then reg_a <= sw; end if;
                if state = S_WAIT_B then
                    if p_load_b = '1' then reg_b <= sw; end if;
                    if p_add = '1' then op_sel <= '0'; end if;
                    if p_sub = '1' then op_sel <= '1'; end if;
                end if;
                if do_compute = '1' then reg_res <= alu_y; end if;
            end if;
        end if;
    end process;

    result <= reg_res;
    disp   <= reg_res when show_res = '1' else reg_a & reg_b;
end Behavioral;
