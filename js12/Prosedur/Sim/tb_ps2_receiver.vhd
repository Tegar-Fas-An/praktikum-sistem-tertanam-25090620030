library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ps2_receiver is
end tb_ps2_receiver;

architecture sim of tb_ps2_receiver is
    signal clk        : STD_LOGIC := '0';
    signal ps2_clk    : STD_LOGIC := '1';
    signal ps2_data   : STD_LOGIC := '1';
    signal scan_code  : STD_LOGIC_VECTOR(7 downto 0);
    signal data_ready : STD_LOGIC;

    constant CLK_PERIOD      : time := 10 ns;   -- 100 MHz sistem
    constant PS2_HALF_PERIOD : time := 30 us;   -- ~16.7 kHz -> periode 60us, half 30us

begin

    uut: entity work.ps2_receiver
        port map (
            clk        => clk,
            ps2_clk    => ps2_clk,
            ps2_data   => ps2_data,
            scan_code  => scan_code,
            data_ready => data_ready
        );

    -- clock sistem 100 MHz
    clk_proc: process
    begin
        while true loop
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- stimulus: kirim 1 frame PS/2 lengkap (11 bit), disampel saat falling edge
    stim_proc: process
        variable data_bits  : STD_LOGIC_VECTOR(7 downto 0) := "01000001"; -- contoh scan code 0x41
        variable parity_bit : STD_LOGIC;
    begin
        -- hitung odd parity dari data_bits
        parity_bit := not (data_bits(0) xor data_bits(1) xor data_bits(2) xor data_bits(3) xor
                            data_bits(4) xor data_bits(5) xor data_bits(6) xor data_bits(7));

        ps2_clk  <= '1';
        ps2_data <= '1';
        wait for 100 us;

        -- Bit 0: START ('0')
        ps2_data <= '0';
        ps2_clk  <= '0'; wait for PS2_HALF_PERIOD;
        ps2_clk  <= '1'; wait for PS2_HALF_PERIOD;

        -- Bit 1-8: DATA, LSB dulu
        for i in 0 to 7 loop
            ps2_data <= data_bits(i);
            ps2_clk  <= '0'; wait for PS2_HALF_PERIOD;
            ps2_clk  <= '1'; wait for PS2_HALF_PERIOD;
        end loop;

        -- Bit 9: PARITY
        ps2_data <= parity_bit;
        ps2_clk  <= '0'; wait for PS2_HALF_PERIOD;
        ps2_clk  <= '1'; wait for PS2_HALF_PERIOD;

        -- Bit 10: STOP ('1')
        ps2_data <= '1';
        ps2_clk  <= '0';
        wait until data_ready = '1';
        ps2_clk  <= '1';

        -- VERIFIKASI
        assert data_ready = '1'
            report "GAGAL: data_ready tidak aktif setelah frame lengkap"
            severity error;

        assert scan_code = data_bits
            report "GAGAL: scan_code tidak sesuai data yang dikirim (" &
                   integer'image(to_integer(unsigned(scan_code))) & ")"
            severity error;
        
        report "PASS: data_ready dan scan_code sesuai ekspektasi.";
        
        report "Test selesai. scan_code = " & integer'image(to_integer(unsigned(scan_code)));

        wait;
    end process;

end sim;