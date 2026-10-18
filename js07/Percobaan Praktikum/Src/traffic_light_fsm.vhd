library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity traffic_light_fsm is
    Generic ( T_GREEN  : integer := 10;   -- detik
              T_YELLOW : integer := 3 );  -- detik
    Port ( clk  : in  STD_LOGIC;
           rst  : in  STD_LOGIC;
           tick : in  STD_LOGIC;                        -- pulsa 1 Hz dari tick_1hz
           led  : out STD_LOGIC_VECTOR(5 downto 0) );   -- 2:0 = NS, 5:3 = EW
end traffic_light_fsm;

architecture Behavioral of traffic_light_fsm is
    type state_t is (NS_HIJAU, NS_KUNING, EW_HIJAU, EW_KUNING);
    signal state, next_state : state_t := NS_HIJAU;
    signal timer : integer range 0 to 63 := T_GREEN - 1;

    -- durasi tiap state (detik)
    function dur(s : state_t) return integer is
    begin
        case s is
            when NS_HIJAU | EW_HIJAU   => return T_GREEN;
            when NS_KUNING | EW_KUNING => return T_YELLOW;
        end case;
    end function;
begin
    -- Proses 1: register state + timer (sinkron)
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= NS_HIJAU;
                timer <= T_GREEN - 1;
            elsif tick = '1' then
                if timer = 0 then
                    state <= next_state;
                    timer <= dur(next_state) - 1;
                else
                    timer <= timer - 1;
                end if;
            end if;
        end if;
    end process;

    -- Proses 2: logika next-state + keluaran (kombinasional)
    -- bit 0 = hijau, bit 1 = kuning, bit 2 = merah (per arah)
    process(state)
    begin
        case state is
            when NS_HIJAU  => next_state <= NS_KUNING; led <= "100" & "001";
            when NS_KUNING => next_state <= EW_HIJAU;  led <= "100" & "010";
            when EW_HIJAU  => next_state <= EW_KUNING; led <= "001" & "100";
            when EW_KUNING => next_state <= NS_HIJAU;  led <= "010" & "100";
        end case;
    end process;
end Behavioral;