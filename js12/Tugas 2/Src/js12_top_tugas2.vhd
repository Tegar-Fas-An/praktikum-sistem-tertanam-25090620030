library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Tugas Praktikum 2 (revisi):
-- - Seven-segment 4 digit SAMA PERSIS seperti Tugas 1:
--     digit3 digit2 | digit1 digit0
--     (ASCII hex)     (scan code mentah, hex)
--   2 digit kanan = scan code mentah (setiap byte dari ps2_receiver, termasuk 0xF0),
--   2 digit kiri  = ASCII hasil decode byte tsb, padam jika tidak dikenali (ascii_valid='0').
-- - LED: led(0) menyala SELAMA tombol target (default 'A', scan code 0x1C) ditekan,
--   padam saat dilepas. Logika ini memakai key_event_decoder yang membaca stream
--   scan_code/data_ready yang SAMA, secara paralel dengan tampilan seven-segment.

entity js12_top_tugas2 is
    Port ( clk      : in  STD_LOGIC;                     -- 100 MHz onboard
           PS2Clk   : in  STD_LOGIC;                     -- dari mikrokontroler PIC24 (via port USB J2)
           PS2Data  : in  STD_LOGIC;
           seg      : out STD_LOGIC_VECTOR(6 downto 0);  -- segmen a..g
           an       : out STD_LOGIC_VECTOR(3 downto 0);  -- anode 4 digit
           led      : out STD_LOGIC_VECTOR(15 downto 0) ); -- led(0) = indikator tombol target ditekan
end js12_top_tugas2;

architecture Behavioral of js12_top_tugas2 is

    component ps2_receiver is
        Port ( clk        : in  STD_LOGIC;
               ps2_clk    : in  STD_LOGIC;
               ps2_data   : in  STD_LOGIC;
               scan_code  : out STD_LOGIC_VECTOR(7 downto 0);
               data_ready : out STD_LOGIC );
    end component;

    component key_event_decoder is
        Port ( clk         : in  STD_LOGIC;
               scan_code   : in  STD_LOGIC_VECTOR(7 downto 0);
               data_ready  : in  STD_LOGIC;
               key_code    : out STD_LOGIC_VECTOR(7 downto 0);
               key_pressed : out STD_LOGIC;
               event_valid : out STD_LOGIC );
    end component;

    component scan_to_ascii is
        Port ( scan_code   : in  STD_LOGIC_VECTOR(7 downto 0);
               ascii_out   : out STD_LOGIC_VECTOR(7 downto 0);
               ascii_valid : out STD_LOGIC );
    end component;

    -- Pilih tombol target untuk indikator LED di sini (default: tombol 'A')
    constant TARGET_KEY : STD_LOGIC_VECTOR(7 downto 0) := x"1C"; -- scan code 'A'

    signal scan_code    : STD_LOGIC_VECTOR(7 downto 0);
    signal data_ready   : STD_LOGIC;

    -- ===== Jalur LED (lewat key_event_decoder, membedakan make/break code) =====
    signal key_code     : STD_LOGIC_VECTOR(7 downto 0);
    signal key_pressed  : STD_LOGIC;
    signal event_valid  : STD_LOGIC;
    signal led_target   : STD_LOGIC := '0';

    -- ===== Jalur seven-segment (identik dengan Tugas 1: tampilkan scan code mentah + ASCII) =====
    signal ascii_code    : STD_LOGIC_VECTOR(7 downto 0);
    signal ascii_valid   : STD_LOGIC;

    signal latched_scan  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal latched_ascii : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal latched_valid : STD_LOGIC := '0';

    signal digit0, digit1, digit2, digit3 : STD_LOGIC_VECTOR(3 downto 0);

    signal refresh_cnt    : STD_LOGIC_VECTOR(19 downto 0) := (others => '0');
    signal digit_sel      : STD_LOGIC_VECTOR(1 downto 0);
    signal current_nibble : STD_LOGIC_VECTOR(3 downto 0);
    signal blank_digit    : STD_LOGIC;

begin

    u_ps2: ps2_receiver
        port map ( clk        => clk,
                   ps2_clk    => PS2Clk,
                   ps2_data   => PS2Data,
                   scan_code  => scan_code,
                   data_ready => data_ready );

    -- ===== Cabang 1: LED (pakai key_event_decoder, scan_code yang SAMA) =====
    u_decoder: key_event_decoder
        port map ( clk         => clk,
                   scan_code   => scan_code,
                   data_ready  => data_ready,
                   key_code    => key_code,
                   key_pressed => key_pressed,
                   event_valid => event_valid );

    process(clk)
    begin
        if rising_edge(clk) then
            if event_valid = '1' and key_code = TARGET_KEY then
                led_target <= key_pressed;  -- '1' saat ditekan, '0' saat dilepas
            end if;
        end if;
    end process;

    led(0)           <= led_target;
    led(15 downto 1) <= (others => '0');

    -- ===== Cabang 2: Seven-segment 4 digit (identik dengan Tugas 1) =====
    u_lookup: scan_to_ascii
        port map ( scan_code   => scan_code,
                    ascii_out   => ascii_code,
                    ascii_valid => ascii_valid );

    process(clk)
    begin
        if rising_edge(clk) then
            if data_ready = '1' then
                latched_scan  <= scan_code;
                latched_ascii <= ascii_code;
                latched_valid <= ascii_valid;
            end if;
        end if;
    end process;

    digit0 <= latched_scan(3 downto 0);   -- scan code mentah, nibble bawah
    digit1 <= latched_scan(7 downto 4);   -- scan code mentah, nibble atas
    digit2 <= latched_ascii(3 downto 0);  -- ASCII, nibble bawah
    digit3 <= latched_ascii(7 downto 4);  -- ASCII, nibble atas

    process(clk)
    begin
        if rising_edge(clk) then
            refresh_cnt <= std_logic_vector(unsigned(refresh_cnt) + 1);
        end if;
    end process;

    digit_sel <= refresh_cnt(19 downto 18);

    process(digit_sel, digit0, digit1, digit2, digit3, latched_valid)
    begin
        case digit_sel is
            when "00" =>
                an <= "1110";
                current_nibble <= digit0;
                blank_digit <= '0';
            when "01" =>
                an <= "1101";
                current_nibble <= digit1;
                blank_digit <= '0';
            when "10" =>
                an <= "1011";
                current_nibble <= digit2;
                blank_digit <= not latched_valid;
            when others =>
                an <= "0111";
                current_nibble <= digit3;
                blank_digit <= not latched_valid;
        end case;
    end process;

    process(current_nibble, blank_digit)
    begin
        if blank_digit = '1' then
            seg <= "1111111";
        else
            case current_nibble is
                when "0000" => seg <= "1000000"; -- 0
                when "0001" => seg <= "1111001"; -- 1
                when "0010" => seg <= "0100100"; -- 2
                when "0011" => seg <= "0110000"; -- 3
                when "0100" => seg <= "0011001"; -- 4
                when "0101" => seg <= "0010010"; -- 5
                when "0110" => seg <= "0000010"; -- 6
                when "0111" => seg <= "1111000"; -- 7
                when "1000" => seg <= "0000000"; -- 8
                when "1001" => seg <= "0010000"; -- 9
                when "1010" => seg <= "0001000"; -- A
                when "1011" => seg <= "0000011"; -- b
                when "1100" => seg <= "1000110"; -- C
                when "1101" => seg <= "0100001"; -- d
                when "1110" => seg <= "0000110"; -- E
                when "1111" => seg <= "0001110"; -- F
                when others => seg <= "1111111"; -- off
            end case;
        end if;
    end process;

end Behavioral;