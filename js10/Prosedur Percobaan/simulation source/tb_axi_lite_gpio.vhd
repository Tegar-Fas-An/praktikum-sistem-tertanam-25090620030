library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_axi_lite_gpio is
end tb_axi_lite_gpio;

architecture sim of tb_axi_lite_gpio is

    constant C_ADDR_WIDTH : integer := 4;
    constant C_DATA_WIDTH : integer := 32;
    constant CLK_PERIOD   : time := 10 ns; -- 100 MHz

    -- Sinyal lokal untuk disambungkan ke DUT
    signal s_axi_aclk    : STD_LOGIC := '0';
    signal s_axi_aresetn : STD_LOGIC := '0';

    signal s_axi_awaddr  : STD_LOGIC_VECTOR(C_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal s_axi_awvalid : STD_LOGIC := '0';
    signal s_axi_awready : STD_LOGIC;

    signal s_axi_wdata   : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0) := (others => '0');
    signal s_axi_wvalid  : STD_LOGIC := '0';
    signal s_axi_wready  : STD_LOGIC;

    signal s_axi_bresp   : STD_LOGIC_VECTOR(1 downto 0);
    signal s_axi_bvalid  : STD_LOGIC;
    signal s_axi_bready  : STD_LOGIC := '0';

    signal s_axi_araddr  : STD_LOGIC_VECTOR(C_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal s_axi_arvalid : STD_LOGIC := '0';
    signal s_axi_arready : STD_LOGIC;

    signal s_axi_rdata   : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
    signal s_axi_rresp   : STD_LOGIC_VECTOR(1 downto 0);
    signal s_axi_rvalid  : STD_LOGIC;
    signal s_axi_rready  : STD_LOGIC := '0';

    signal gpio_out      : STD_LOGIC_VECTOR(15 downto 0);

    -- Prosedur AXI-Lite WRITE
    procedure axi_write(
        signal clk     : in  STD_LOGIC;
        signal awaddr  : out STD_LOGIC_VECTOR(C_ADDR_WIDTH-1 downto 0);
        signal awvalid : out STD_LOGIC;
        signal awready : in  STD_LOGIC;
        signal wdata   : out STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        signal wvalid  : out STD_LOGIC;
        signal wready  : in  STD_LOGIC;
        signal bvalid  : in  STD_LOGIC;
        signal bready  : out STD_LOGIC;
        addr : in STD_LOGIC_VECTOR(C_ADDR_WIDTH-1 downto 0);
        data : in STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0)
    ) is
    begin
        wait until rising_edge(clk);
        awaddr  <= addr;
        awvalid <= '1';
        wdata   <= data;
        wvalid  <= '1';

        wait until rising_edge(clk) and awready = '1' and wready = '1';
        wait until rising_edge(clk);
        awvalid <= '0';
        wvalid  <= '0';

        bready <= '1';
        wait until rising_edge(clk) and bvalid = '1';
        wait until rising_edge(clk);
        bready <= '0';
    end procedure;

    -- Prosedur AXI-Lite READ
    procedure axi_read(
        signal clk     : in  STD_LOGIC;
        signal araddr  : out STD_LOGIC_VECTOR(C_ADDR_WIDTH-1 downto 0);
        signal arvalid : out STD_LOGIC;
        signal arready : in  STD_LOGIC;
        signal rdata   : in  STD_LOGIC_VECTOR(C_DATA_WIDTH-1 downto 0);
        signal rvalid  : in  STD_LOGIC;
        signal rready  : out STD_LOGIC;
        addr : in STD_LOGIC_VECTOR(C_ADDR_WIDTH-1 downto 0)
    ) is
    begin
        wait until rising_edge(clk);
        araddr  <= addr;
        arvalid <= '1';

        wait until rising_edge(clk) and arready = '1';
        wait until rising_edge(clk);
        arvalid <= '0';

        rready <= '1';
        wait until rising_edge(clk) and rvalid = '1';
        report "READ addr=" & integer'image(to_integer(unsigned(addr))) & 
               "  data_dec=" & integer'image(to_integer(unsigned(rdata)));
        wait until rising_edge(clk);
        rready <= '0';
    end procedure;

begin

    ----------------------------------------------------------------
    -- Instansiasi DUT (Menghubungkan ke Verilog Wrapper)
    ----------------------------------------------------------------
    DUT : entity work.design_1_wrapper
    port map (
        S_AXI_ACLK_0    => s_axi_aclk,
        S_AXI_ARESETN_0 => s_axi_aresetn,
        S_AXI_AWADDR_0  => s_axi_awaddr,
        S_AXI_AWVALID_0 => s_axi_awvalid,
        S_AXI_AWREADY_0 => s_axi_awready,
        S_AXI_WDATA_0   => s_axi_wdata,
        S_AXI_WVALID_0  => s_axi_wvalid,
        S_AXI_WREADY_0  => s_axi_wready,
        S_AXI_BRESP_0   => s_axi_bresp,
        S_AXI_BVALID_0  => s_axi_bvalid,
        S_AXI_BREADY_0  => s_axi_bready,
        S_AXI_ARADDR_0  => s_axi_araddr,
        S_AXI_ARVALID_0 => s_axi_arvalid,
        S_AXI_ARREADY_0 => s_axi_arready,
        S_AXI_RDATA_0   => s_axi_rdata,
        S_AXI_RRESP_0   => s_axi_rresp,
        S_AXI_RVALID_0  => s_axi_rvalid,
        S_AXI_RREADY_0  => s_axi_rready,
        gpio_out_0      => gpio_out
    );

    ----------------------------------------------------------------
    -- Clock Generation
    ----------------------------------------------------------------
    clk_process : process
    begin
        s_axi_aclk <= '0';
        wait for CLK_PERIOD/2;
        s_axi_aclk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    ----------------------------------------------------------------
    -- Stimulus Process
    ----------------------------------------------------------------
    stim_process : process
    begin
        -- Reset
        s_axi_aresetn <= '0';
        wait for CLK_PERIOD * 5;
        s_axi_aresetn <= '1';
        wait for CLK_PERIOD * 2;

        -- Write ke reg0 (alamat 0x0)
        axi_write(s_axi_aclk,
                  s_axi_awaddr, s_axi_awvalid, s_axi_awready,
                  s_axi_wdata, s_axi_wvalid, s_axi_wready,
                  s_axi_bvalid, s_axi_bready,
                  addr => "0000", data => x"00000001");

        wait for CLK_PERIOD * 4;

        -- Read dari reg0
        axi_read(s_axi_aclk,
                 s_axi_araddr, s_axi_arvalid, s_axi_arready,
                 s_axi_rdata, s_axi_rvalid, s_axi_rready,
                 addr => "0000");

        wait for CLK_PERIOD * 4;

        -- Write ke reg0 nilai lain
        axi_write(s_axi_aclk,
                  s_axi_awaddr, s_axi_awvalid, s_axi_awready,
                  s_axi_wdata, s_axi_wvalid, s_axi_wready,
                  s_axi_bvalid, s_axi_bready,
                  addr => "0000", data => x"0000AAAA");

        wait for CLK_PERIOD * 4;

        axi_read(s_axi_aclk,
                 s_axi_araddr, s_axi_arvalid, s_axi_arready,
                 s_axi_rdata, s_axi_rvalid, s_axi_rready,
                 addr => "0000");

        wait for CLK_PERIOD * 10;
        report "SIMULASI SELESAI";
        std.env.stop;
    end process;

end sim;