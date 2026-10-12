library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_calculator_fsm is
end tb_calculator_fsm;

architecture sim of tb_calculator_fsm is
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '1';
    signal sw  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal pu, pd, pl, pr, pc : STD_LOGIC := '0';
    signal result, disp : STD_LOGIC_VECTOR (15 downto 0);
    signal led : STD_LOGIC_VECTOR (3 downto 0);

    procedure pulse(signal s : out STD_LOGIC) is
    begin
        wait until rising_edge(clk); s <= '1';
        wait until rising_edge(clk); s <= '0';
        wait until rising_edge(clk);
    end procedure;
begin
    clk <= not clk after 5 ns;

    UUT : entity work.calculator_fsm port map (
        clk => clk, rst => rst, sw => sw,
        p_load_a => pu, p_load_b => pd, p_add => pl, p_sub => pr, p_calc => pc,
        result => result, disp => disp, state_led => led);

    process
    begin
        wait for 33 ns; rst <= '0';
        wait until rising_edge(clk);

        -- Tes 1: 25 + 17 = 42 (0x2A)
        sw <= x"19"; pulse(pu);
        sw <= x"11"; pulse(pd);
        pulse(pl);
        pulse(pc);
        wait for 20 ns;
        assert result = x"002A" report "GAGAL: 25+17 /= 42" severity error;
        assert disp = x"002A"   report "GAGAL: disp tidak menampilkan hasil" severity error;
        assert led = "1000"     report "GAGAL: state bukan S_SHOW" severity error;
        report "Tes 1 selesai: hasil = " & integer'image(to_integer(unsigned(result)));

        -- kembali ke WAIT_A
        pulse(pc);
        assert led = "0001" report "GAGAL: tidak kembali ke S_WAIT_A" severity error;

        -- Tes 2: 100 - 30 = 70 (0x46)
        sw <= x"64"; pulse(pu);
        sw <= x"1E"; pulse(pd);
        pulse(pr);
        pulse(pc);
        wait for 20 ns;
        assert result = x"0046" report "GAGAL: 100-30 /= 70" severity error;
        report "Tes 2 selesai: hasil = " & integer'image(to_integer(unsigned(result)));
        pulse(pc);

        -- Tes 3: 200 + 100 = 300 (0x012C), uji carry 8-bit
        sw <= x"C8"; pulse(pu);
        sw <= x"64"; pulse(pd);
        pulse(pl);
        pulse(pc);
        wait for 20 ns;
        assert result = x"012C" report "GAGAL: 200+100 /= 300" severity error;
        report "Tes 3 selesai: hasil = " & integer'image(to_integer(unsigned(result)));
        pulse(pc);

        -- Tes 4: 5 - 10 = -5 (0xFFFB, two's complement)
        sw <= x"05"; pulse(pu);
        sw <= x"0A"; pulse(pd);
        pulse(pr);
        pulse(pc);
        wait for 20 ns;
        assert result = x"FFFB" report "GAGAL: 5-10 /= -5" severity error;
        report "Tes 4 selesai: hasil = " & integer'image(to_integer(signed(result)));

        report "SIMULASI SELESAI";
        wait;
    end process;
end sim;
