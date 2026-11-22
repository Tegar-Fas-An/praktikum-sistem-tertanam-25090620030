library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Modul ini menerima aliran byte scan_code/data_ready dari ps2_receiver,
-- lalu membedakan dua jenis event:
--   - PRESS  : byte scan_code langsung adalah make code (tombol baru ditekan)
--   - RELEASE: byte 0xF0 diikuti byte scan_code (tombol baru dilepas)
--
-- FSM 2 state: IDLE (menunggu byte pertama) dan BREAK (sudah terima 0xF0,
-- menunggu byte kedua yaitu make code tombol yang dilepas).

entity key_event_decoder is
    Port ( clk         : in  STD_LOGIC;
           scan_code   : in  STD_LOGIC_VECTOR(7 downto 0);  -- dari ps2_receiver
           data_ready  : in  STD_LOGIC;                     -- dari ps2_receiver
           key_code    : out STD_LOGIC_VECTOR(7 downto 0);  -- make code tombol (event ini)
           key_pressed : out STD_LOGIC;                     -- '1' = ditekan, '0' = dilepas
           event_valid : out STD_LOGIC );                   -- pulsa 1 siklus saat key_code/key_pressed valid
end key_event_decoder;

architecture Behavioral of key_event_decoder is
    type state_t is (IDLE, BREAK);
    signal state : state_t := IDLE;

    constant BREAK_PREFIX : STD_LOGIC_VECTOR(7 downto 0) := x"F0";
begin

    process(clk)
    begin
        if rising_edge(clk) then
            event_valid <= '0';  -- default tiap siklus, hanya '1' selama 1 siklus saat event baru

            if data_ready = '1' then
                case state is

                    when IDLE =>
                        if scan_code = BREAK_PREFIX then
                            -- byte ini adalah awalan break code, tunggu byte berikutnya
                            state <= BREAK;
                        else
                            -- byte ini langsung make code -> tombol baru ditekan
                            key_code    <= scan_code;
                            key_pressed <= '1';
                            event_valid <= '1';
                            state       <= IDLE;
                        end if;

                    when BREAK =>
                        -- byte ini adalah make code dari tombol yang BARU DILEPAS
                        key_code    <= scan_code;
                        key_pressed <= '0';
                        event_valid <= '1';
                        state       <= IDLE;

                end case;
            end if;
        end if;
    end process;

end Behavioral;