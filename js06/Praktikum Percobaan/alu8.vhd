library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ALU 8-bit (perluasan alu4 Jobsheet 3)
-- op = '0' : y = a + b   (hasil 9 bit, di-zero-extend ke 16 bit)
-- op = '1' : y = a - b   (hasil bertanda, two's complement 16 bit)
entity alu8 is
    Port (
        a  : in  STD_LOGIC_VECTOR (7 downto 0);
        b  : in  STD_LOGIC_VECTOR (7 downto 0);
        op : in  STD_LOGIC;
        y  : out STD_LOGIC_VECTOR (15 downto 0)
    );
end alu8;

architecture Behavioral of alu8 is
begin
    process (a, b, op)
        variable ua, ub : unsigned(15 downto 0);
    begin
        ua := resize(unsigned(a), 16);
        ub := resize(unsigned(b), 16);
        if op = '0' then
            y <= std_logic_vector(ua + ub);
        else
            y <= std_logic_vector(ua - ub); -- modulo 2^16 = two's complement
        end if;
    end process;
end Behavioral;
