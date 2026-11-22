library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2_receiver is
    Port ( clk        : in  STD_LOGIC;                     -- clock sistem, 100 MHz
           ps2_clk    : in  STD_LOGIC;                     -- dari mikrokontroler PIC24 (via port USB HID)
           ps2_data   : in  STD_LOGIC;
           scan_code  : out STD_LOGIC_VECTOR (7 downto 0);
           data_ready : out STD_LOGIC );                   -- pulsa 1 siklus saat scan_code baru valid
end ps2_receiver;

architecture Behavioral of ps2_receiver is
    -- Synchronizer 2-tingkat untuk ps2_clk & ps2_data (lihat Jobsheet 4)
    signal clk_ff1, clk_ff2, clk_ff3 : STD_LOGIC := '1';   -- 3 tingkat: deteksi tepi turun
    signal data_ff1, data_ff2        : STD_LOGIC := '1';
    signal falling_edge              : STD_LOGIC;
    signal shift_reg                 : STD_LOGIC_VECTOR (10 downto 0) := (others => '1');
    signal bit_cnt                   : integer range 0 to 10 := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            -- Sinkronisasi kedua sinyal asinkron dari mikrokontroler PIC24
            clk_ff1 <= ps2_clk; clk_ff2 <= clk_ff1; clk_ff3 <= clk_ff2;
            data_ff1 <= ps2_data; data_ff2 <= data_ff1;
        end if;
    end process;

    falling_edge <= clk_ff3 and not clk_ff2;  -- deteksi tepi turun ps2_clk (lihat Jobsheet 5)

    process(clk)
    begin
        if rising_edge(clk) then
            data_ready <= '0';
            if falling_edge = '1' then
                shift_reg(bit_cnt) <= data_ff2;
                if bit_cnt = 10 then
                    bit_cnt <= 0;
                    -- shift_reg(0)=start, (8 downto 1)=data(LSB..MSB), (9)=parity, (10)=stop
                    scan_code  <= shift_reg(8 downto 1);
                    data_ready <= '1';
                else
                    bit_cnt <= bit_cnt + 1;
                end if;
            end if;
        end if;
    end process;

end Behavioral;