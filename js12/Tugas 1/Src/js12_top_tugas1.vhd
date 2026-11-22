library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Tugas Praktikum 1 (revisi):
-- Seven-segment 4 digit aktif:
--   digit3 digit2 | digit1 digit0
--   (ASCII hex)     (scan code mentah, hex)
-- - 2 digit KANAN  = scan code mentah dari PS/2 (sama seperti prosedur 1-6)
-- - 2 digit KIRI   = hasil decode Tugas 1 (kode ASCII tombol dalam heksadesimal)
-- - Jika scan_code TIDAK ada di tabel lookup (ascii_valid='0'), 2 digit kiri
--   dipadamkan (hanya 2 digit kanan/scan code mentah yang tetap tampil).

entity js12_top_tugas1 is
    Port ( clk      : in  STD_LOGIC;                     -- 100 MHz onboard
           PS2Clk   : in  STD_LOGIC;                     -- dari mikrokontroler PIC24 (via port USB J2)
           PS2Data  : in  STD_LOGIC;
           seg      : out STD_LOGIC_VECTOR(6 downto 0);  -- segmen a..g
           an       : out STD_LOGIC_VECTOR(3 downto 0) ); -- anode 4 digit
end js12_top_tugas1;

architecture Behavioral of js12_top_tugas1 is

    component ps2_receiver is
        Port ( clk        : in  STD_LOGIC;
               ps2_clk    : in  STD_LOGIC;
               ps2_data   : in  STD_LOGIC;
               scan_code  : out STD_LOGIC_VECTOR(7 downto 0);
               data_ready : out STD_LOGIC );
    end component;

    component scan_to_ascii is
        Port ( scan_code   : in  STD_LOGIC_VECTOR(7 downto 0);
               ascii_out   : out STD_LOGIC_VECTOR(7 downto 0);
               ascii_valid : out STD_LOGIC );
    end component;

    signal scan_code     : STD_LOGIC_VECTOR(7 downto 0);
    signal data_ready    : STD_LOGIC;
    signal ascii_code    : STD_LOGIC_VECTOR(7 downto 0);
    signal ascii_valid   : STD_LOGIC;

    -- Nilai yang di-latch untuk ditampilkan (supaya tidak berkedip/hilang di antara frame)
    signal latched_scan  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal latched_ascii : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal latched_valid : STD_LOGIC := '0';

    -- Nibble per digit: digit0=kanan..digit3=kiri
    signal digit0, digit1, digit2, digit3 : STD_LOGIC_VECTOR(3 downto 0);

    signal refresh_cnt    : STD_LOGIC_VECTOR(19 downto 0) := (others => '0');
    signal digit_sel      : STD_LOGIC_VECTOR(1 downto 0);
    signal current_nibble : STD_LOGIC_VECTOR(3 downto 0);
    signal blank_digit    : STD_LOGIC;  -- '1' = digit ini dipadamkan (dipakai utk digit2/digit3 jika ascii tidak valid)

begin

    u_ps2: ps2_receiver
        port map ( clk        => clk,
                   ps2_clk    => PS2Clk,
                   ps2_data   => PS2Data,
                   scan_code  => scan_code,
                   data_ready => data_ready );

    u_lookup: scan_to_ascii
        port map ( scan_code   => scan_code,
                    ascii_out   => ascii_code,
                    ascii_valid => ascii_valid );

    -- Latch scan_code mentah + hasil ASCII + validitasnya setiap kali ada byte baru
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

    -- 2 digit KANAN = scan code mentah
    digit0 <= latched_scan(3 downto 0);   -- nibble bawah scan code
    digit1 <= latched_scan(7 downto 4);   -- nibble atas scan code

    -- 2 digit KIRI = ASCII hasil decode
    digit2 <= latched_ascii(3 downto 0);  -- nibble bawah ASCII
    digit3 <= latched_ascii(7 downto 4);  -- nibble atas ASCII

    -- counter refresh untuk multiplexing 4 digit (lihat Jobsheet 5)
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
                an <= "1110";              -- digit paling kanan
                current_nibble <= digit0;
                blank_digit <= '0';        -- scan code mentah selalu ditampilkan
            when "01" =>
                an <= "1101";              -- digit kedua dari kanan
                current_nibble <= digit1;
                blank_digit <= '0';
            when "10" =>
                an <= "1011";              -- digit kedua dari kiri
                current_nibble <= digit2;
                blank_digit <= not latched_valid; -- padam jika scan code tidak dikenali
            when others =>
                an <= "0111";              -- digit paling kiri
                current_nibble <= digit3;
                blank_digit <= not latched_valid; -- padam jika scan code tidak dikenali
        end case;
    end process;

    -- decoder hex -> 7-segmen (common anode, aktif LOW), segmen = gfedcba
    process(current_nibble, blank_digit)
    begin
        if blank_digit = '1' then
            seg <= "1111111";  -- padam total
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