library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_sync_demo is
    Port (
        clk   : in  STD_LOGIC;
        btnC  : in  STD_LOGIC;
        led0  : out STD_LOGIC
    );
end top_sync_demo;

architecture Behavioral of top_sync_demo is
    signal sync_btn    : STD_LOGIC;
    signal sync_btn_reg: STD_LOGIC := '0';
    signal led_state   : STD_LOGIC := '0';
begin
    -- Instansiasi Synchronizer 2-FF
    sync_inst: entity work.synchronizer_2ff
        port map (
            clk      => clk,
            async_in => btnC,
            sync_out => sync_btn
        );

    -- Deteksi tepi naik (rising edge detector) & Toggle LED
    process(clk)
    begin
        if rising_edge(clk) then
            sync_btn_reg <= sync_btn;
            
            -- Deteksi transisi 0 ke 1 pada sinyal yang sudah disinkronkan
            if (sync_btn = '1' and sync_btn_reg = '0') then
                led_state <= not led_state;
            end if;
        end if;
    end process;

    led0 <= led_state;
end Behavioral;