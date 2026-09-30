library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_driver is
    Generic (
        DIGITS  : integer := 4;
        CLK_DIV : integer := 100_000
    );
    Port (
        clk  : in  STD_LOGIC;
        data : in  STD_LOGIC_VECTOR(4*DIGITS-1 downto 0);
        seg  : out STD_LOGIC_VECTOR(6 downto 0);
        dp   : out STD_LOGIC;
        an   : out STD_LOGIC_VECTOR(DIGITS-1 downto 0)
    );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is
    signal tick_cnt : integer range 0 to CLK_DIV-1 := 0;
    signal idx      : integer range 0 to DIGITS-1 := 0;
    signal digit    : unsigned(3 downto 0);

    function bcd_to_seg(digit : unsigned(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case digit is
            when "0000" => return "1000000";
            when "0001" => return "1111001";
            when "0010" => return "0100100";
            when "0011" => return "0110000";
            when "0100" => return "0011001";
            when "0101" => return "0010010";
            when "0110" => return "0000010";
            when "0111" => return "1111000";
            when "1000" => return "0000000";
            when "1001" => return "0010000";
            when others => return "0111111";
        end case;
    end function;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if tick_cnt = CLK_DIV-1 then
                tick_cnt <= 0;
                if idx = DIGITS-1 then
                    idx <= 0;
                else
                    idx <= idx + 1;
                end if;
            else
                tick_cnt <= tick_cnt + 1;
            end if;
        end if;
    end process;

    digit <= unsigned(data(4*idx+3 downto 4*idx));
    seg   <= bcd_to_seg(digit);
    dp    <= '1';

    process(idx)
    begin
        an <= (others => '1');
        an(idx) <= '0';
    end process;
end Behavioral;
