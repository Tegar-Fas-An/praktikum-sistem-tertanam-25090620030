library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity synchronizer_2ff is
    Port ( 
        clk      : in  STD_LOGIC;
        async_in : in  STD_LOGIC;
        sync_out : out STD_LOGIC 
    );
end synchronizer_2ff;

architecture Behavioral of synchronizer_2ff is
    signal ff1, ff2 : STD_LOGIC := '0';
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of ff1 : signal is "TRUE";
    attribute ASYNC_REG of ff2 : signal is "TRUE";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            ff1 <= async_in;
            ff2 <= ff1;
        end if;
    end process;
    sync_out <= ff2;
end Behavioral;