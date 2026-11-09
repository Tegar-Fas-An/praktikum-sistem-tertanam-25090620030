----------------------------------------------------------------------------------
-- Jobsheet 10 - Praktikum Sistem Tertanam
-- IP Custom AXI4-Lite Slave : axi_lite_gpio_v1_0
-- Berisi 4 register 32-bit (reg0..reg3)
-- reg0(15:0) dipetakan ke gpio_out (LED)
-- reg1(15:0) dipetakan ke sw (Switch) - TUGAS 1
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axi_lite_gpio_v1_0 is
    Generic (
        C_S_AXI_ADDR_WIDTH : integer := 4;  -- 4 register -> 4 alamat (2 bit index + 2 bit byte)
        C_S_AXI_DATA_WIDTH : integer := 32
    );
    Port (
        S_AXI_ACLK    : in  STD_LOGIC;
        S_AXI_ARESETN : in  STD_LOGIC;

        S_AXI_AWADDR  : in  STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWVALID : in  STD_LOGIC;
        S_AXI_AWREADY : out STD_LOGIC;

        S_AXI_WDATA   : in  STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WVALID  : in  STD_LOGIC;
        S_AXI_WREADY  : out STD_LOGIC;

        S_AXI_BRESP   : out STD_LOGIC_VECTOR(1 downto 0);
        S_AXI_BVALID  : out STD_LOGIC;
        S_AXI_BREADY  : in  STD_LOGIC;

        S_AXI_ARADDR  : in  STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARVALID : in  STD_LOGIC;
        S_AXI_ARREADY : out STD_LOGIC;

        S_AXI_RDATA   : out STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP   : out STD_LOGIC_VECTOR(1 downto 0);
        S_AXI_RVALID  : out STD_LOGIC;
        S_AXI_RREADY  : in  STD_LOGIC;

        gpio_out      : out STD_LOGIC_VECTOR(15 downto 0);  -- dihubungkan ke LED
        sw            : in  STD_LOGIC_VECTOR(15 downto 0)   -- TUGAS 1: dihubungkan ke Switch
    );
end axi_lite_gpio_v1_0;

architecture Behavioral of axi_lite_gpio_v1_0 is

    -- Sinyal internal AXI handshake
    signal axi_awaddr  : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal axi_awready : STD_LOGIC := '0';
    signal axi_wready  : STD_LOGIC := '0';
    signal axi_bresp   : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal axi_bvalid  : STD_LOGIC := '0';
    signal axi_araddr  : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal axi_arready : STD_LOGIC := '0';
    signal axi_rdata   : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal axi_rresp   : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal axi_rvalid  : STD_LOGIC := '0';

    -- 4 register 32-bit
    type reg_array is array (0 to 3) of STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal regs : reg_array := (others => (others => '0'));

    -- index register dari address (bit 3:2, karena bit 1:0 = byte offset)
    constant ADDR_LSB : integer := (C_S_AXI_DATA_WIDTH/32) + 1;  -- = 2
    constant OPT_MEM_ADDR_BITS : integer := 1;

begin

    S_AXI_AWREADY <= axi_awready;
    S_AXI_WREADY  <= axi_wready;
    S_AXI_BRESP   <= axi_bresp;
    S_AXI_BVALID  <= axi_bvalid;
    S_AXI_ARREADY <= axi_arready;
    S_AXI_RDATA   <= axi_rdata;
    S_AXI_RRESP   <= axi_rresp;
    S_AXI_RVALID  <= axi_rvalid;

    gpio_out <= regs(0)(15 downto 0);

    ----------------------------------------------------------------
    -- Proses WRITE ADDRESS : axi_awready
    ----------------------------------------------------------------
    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_awready <= '0';
                axi_awaddr  <= (others => '0');
            else
                if axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' then
                    axi_awready <= '1';
                    axi_awaddr  <= S_AXI_AWADDR;
                else
                    axi_awready <= '0';
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Proses WRITE DATA : axi_wready
    ----------------------------------------------------------------
    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_wready <= '0';
            else
                if axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' then
                    axi_wready <= '1';
                else
                    axi_wready <= '0';
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Proses WRITE ke register (regs)
    ----------------------------------------------------------------
    process (S_AXI_ACLK)
        variable idx : integer range 0 to 3;
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                regs <= (others => (others => '0'));
            else
                if axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' then
                    idx := to_integer(unsigned(axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB)));
                    regs(idx) <= S_AXI_WDATA;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Proses WRITE RESPONSE : axi_bvalid
    ----------------------------------------------------------------
    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_bvalid <= '0';
                axi_bresp  <= "00";
            else
                if axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0' then
                    axi_bvalid <= '1';
                    axi_bresp  <= "00";  -- OKAY
                elsif S_AXI_BREADY = '1' and axi_bvalid = '1' then
                    axi_bvalid <= '0';
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Proses READ ADDRESS : axi_arready
    ----------------------------------------------------------------
    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_arready <= '0';
                axi_araddr  <= (others => '0');
            else
                if axi_arready = '0' and S_AXI_ARVALID = '1' then
                    axi_arready <= '1';
                    axi_araddr  <= S_AXI_ARADDR;
                else
                    axi_arready <= '0';
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Proses READ DATA : axi_rvalid + axi_rdata
    ----------------------------------------------------------------
    process (S_AXI_ACLK)
        variable idx : integer range 0 to 3;
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_rvalid <= '0';
                axi_rresp  <= "00";
                axi_rdata  <= (others => '0');
            else
                if axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0' then
                    idx := to_integer(unsigned(axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB)));
                    
                    -- TUGAS 1: Jika address mengarah ke reg1 (idx = 1), baca dari port sw
                    if idx = 1 then
                        axi_rdata(15 downto 0)  <= sw;
                        axi_rdata(31 downto 16) <= (others => '0');
                    else
                        axi_rdata <= regs(idx);
                    end if;
                    
                    axi_rvalid <= '1';
                    axi_rresp  <= "00";  -- OKAY
                elsif axi_rvalid = '1' and S_AXI_RREADY = '1' then
                    axi_rvalid <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;