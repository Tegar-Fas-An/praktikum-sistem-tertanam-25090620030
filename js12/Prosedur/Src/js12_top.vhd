library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity js12_top is
    Port ( clk      : in  STD_LOGIC;                     -- 100 MHz onboard
           PS2Clk   : in  STD_LOGIC;                     -- dari mikrokontroler PIC24 (via port USB J2)
           PS2Data  : in  STD_LOGIC;
           seg      : out STD_LOGIC_VECTOR(6 downto 0);  -- segmen a..g
           an       : out STD_LOGIC_VECTOR(3 downto 0) ); -- anode 4 digit
end js12_top;

architecture Behavioral of js12_top is

    component ps2_receiver is
        Port ( clk        : in  STD_LOGIC;
               ps2_clk    : in  STD_LOGIC;
               ps2_data   : in  STD_LOGIC;
               scan_code  : out STD_LOGIC_VECTOR(7 downto 0);
               data_ready : out STD_LOGIC );
    end component;

    signal scan_code    : STD_LOGIC_VECTOR(7 downto 0);
    signal data_ready   : STD_LOGIC;
    signal latched_code : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- nibble untuk ditampilkan: digit atas = scan_code(7:4), digit bawah = scan_code(3:0)
    signal digit0, digit1 : STD_LOGIC_VECTOR(3 downto 0);

    -- sinyal untuk multiplexing seven-segment (lihat Jobsheet 5)
    signal refresh_cnt : STD_LOGIC_VECTOR(19 downto 0) := (others => '0');
    signal digit_sel    : STD_LOGIC_VECTOR(1 downto 0);
    signal current_nibble : STD_LOGIC_VECTOR(3 downto 0);

begin

    -- simpan scan_code terakhir yang valid (latch saat data_ready)
    process(clk)
    begin
        if rising_edge(clk) then
            if data_ready = '1' then
                latched_code <= scan_code;
            end if;
        end if;
    end process;

    digit0 <= latched_code(3 downto 0);   -- nibble bawah (LSB)
    digit1 <= latched_code(7 downto 4);   -- nibble atas  (MSB)

    u_ps2: ps2_receiver
        port map ( clk        => clk,
                   ps2_clk    => PS2Clk,
                   ps2_data   => PS2Data,
                   scan_code  => scan_code,
                   data_ready => data_ready );

    -- counter refresh untuk multiplexing (lihat Jobsheet 5)
    process(clk)
    begin
        if rising_edge(clk) then
            refresh_cnt <= std_logic_vector(unsigned(refresh_cnt) + 1);
        end if;
    end process;

    digit_sel <= refresh_cnt(19 downto 18);

    -- pilih digit aktif (hanya 2 digit kanan dipakai untuk 1 byte scan code)
    process(digit_sel, digit0, digit1)
    begin
        case digit_sel is
            when "00" =>
                an <= "1110";              -- digit paling kanan aktif
                current_nibble <= digit0;  -- nibble bawah
            when "01" =>
                an <= "1101";              -- digit kedua dari kanan aktif
                current_nibble <= digit1;  -- nibble atas
            when others =>
                an <= "1111";              -- digit lain dimatikan
                current_nibble <= "0000";
        end case;
    end process;

    -- decoder hex -> 7-segmen (common anode, aktif LOW), segmen = gfedcba
    process(current_nibble)
    begin
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
    end process;

end Behavioral;