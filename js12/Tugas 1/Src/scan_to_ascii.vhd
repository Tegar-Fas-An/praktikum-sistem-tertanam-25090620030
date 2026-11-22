library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Modul ini menerjemahkan make code Scan Code Set 2 (standar PS/2) menjadi
-- kode ASCII untuk huruf 'A'-'Z' dan angka '0'-'9'.
-- Scan code yang tidak dikenali akan menghasilkan ASCII '?' (0x3F)
-- supaya mudah dibedakan dari huruf/angka yang valid.

entity scan_to_ascii is
    Port ( scan_code  : in  STD_LOGIC_VECTOR(7 downto 0);
           ascii_out  : out STD_LOGIC_VECTOR(7 downto 0);
           ascii_valid: out STD_LOGIC );  -- '1' jika scan_code dikenali (ada di tabel), '0' jika tidak
end scan_to_ascii;

architecture Behavioral of scan_to_ascii is
begin

    process(scan_code)
    begin
        ascii_valid <= '1';  -- default: dikenali, kecuali masuk 'others' di bawah
        case scan_code is
            -- ===== HURUF A - Z (Scan Code Set 2, make code) =====
            when x"1C" => ascii_out <= x"41"; -- A
            when x"32" => ascii_out <= x"42"; -- B
            when x"21" => ascii_out <= x"43"; -- C
            when x"23" => ascii_out <= x"44"; -- D
            when x"24" => ascii_out <= x"45"; -- E
            when x"2B" => ascii_out <= x"46"; -- F
            when x"34" => ascii_out <= x"47"; -- G
            when x"33" => ascii_out <= x"48"; -- H
            when x"43" => ascii_out <= x"49"; -- I
            when x"3B" => ascii_out <= x"4A"; -- J
            when x"42" => ascii_out <= x"4B"; -- K
            when x"4B" => ascii_out <= x"4C"; -- L
            when x"3A" => ascii_out <= x"4D"; -- M
            when x"31" => ascii_out <= x"4E"; -- N
            when x"44" => ascii_out <= x"4F"; -- O
            when x"4D" => ascii_out <= x"50"; -- P
            when x"15" => ascii_out <= x"51"; -- Q
            when x"2D" => ascii_out <= x"52"; -- R
            when x"1B" => ascii_out <= x"53"; -- S
            when x"2C" => ascii_out <= x"54"; -- T
            when x"3C" => ascii_out <= x"55"; -- U
            when x"2A" => ascii_out <= x"56"; -- V
            when x"1D" => ascii_out <= x"57"; -- W
            when x"22" => ascii_out <= x"58"; -- X
            when x"35" => ascii_out <= x"59"; -- Y
            when x"1A" => ascii_out <= x"5A"; -- Z

            -- ===== ANGKA 0 - 9 (baris atas keyboard) =====
            when x"45" => ascii_out <= x"30"; -- 0
            when x"16" => ascii_out <= x"31"; -- 1
            when x"1E" => ascii_out <= x"32"; -- 2
            when x"26" => ascii_out <= x"33"; -- 3
            when x"25" => ascii_out <= x"34"; -- 4
            when x"2E" => ascii_out <= x"35"; -- 5
            when x"36" => ascii_out <= x"36"; -- 6
            when x"3D" => ascii_out <= x"37"; -- 7
            when x"3E" => ascii_out <= x"38"; -- 8
            when x"46" => ascii_out <= x"39"; -- 9

            -- ===== Tombol umum lain (opsional, memudahkan pengujian) =====
            when x"29" => ascii_out <= x"20"; -- Spasi
            when x"5A" => ascii_out <= x"0D"; -- Enter

            when others =>
                ascii_out   <= x"3F"; -- '?' = scan code tidak dikenali / break code 0xF0
                ascii_valid <= '0';   -- tandai tidak dikenali, dipakai top-level untuk blank digit
        end case;
    end process;

end Behavioral;