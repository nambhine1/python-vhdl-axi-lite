library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_lite_ram_wrapper is
    generic (
        -- Parameters of Axi Slave Bus Interface S00_AXI
        C_S00_AXI_DATA_WIDTH : integer := 32;
        C_S00_AXI_ADDR_WIDTH : integer := 11
    );
    port (
        -- Ports of Axi Slave Bus Interface S00_AXI
        s00_axi_aclk    : in  std_logic;
        s00_axi_aresetn : in  std_logic;
        s00_axi_awaddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        s00_axi_awprot  : in  std_logic_vector(2 downto 0);
        s00_axi_awvalid : in  std_logic;
        s00_axi_awready : out std_logic;
        s00_axi_wdata   : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        s00_axi_wstrb   : in  std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
        s00_axi_wvalid  : in  std_logic;
        s00_axi_wready  : out std_logic;
        s00_axi_bresp   : out std_logic_vector(1 downto 0);
        s00_axi_bvalid  : out std_logic;
        s00_axi_bready  : in  std_logic;
        s00_axi_araddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        s00_axi_arprot  : in  std_logic_vector(2 downto 0);
        s00_axi_arvalid : in  std_logic;
        s00_axi_arready : out std_logic;
        s00_axi_rdata   : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        s00_axi_rresp   : out std_logic_vector(1 downto 0);
        s00_axi_rvalid  : out std_logic;
        s00_axi_rready  : in  std_logic
    );
end axi_lite_ram_wrapper;

architecture arch_imp of axi_lite_ram_wrapper is

begin

    u_axi_lite : entity work.axi_lite_v1_0_S00_AXI
        generic map (
            C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH,  -- Adjusted to internal module addr width
            C_BASE_ADDR        => 0
        )
        port map (
            S_AXI_ACLK    => s00_axi_aclk,
            S_AXI_ARESETN => s00_axi_aresetn,
            S_AXI_AWADDR  => s00_axi_awaddr,
            S_AXI_AWPROT  => s00_axi_awprot,
            S_AXI_AWVALID => s00_axi_awvalid,
            S_AXI_AWREADY => s00_axi_awready,
            S_AXI_WDATA   => s00_axi_wdata,
            S_AXI_WSTRB   => s00_axi_wstrb,
            S_AXI_WVALID  => s00_axi_wvalid,
            S_AXI_WREADY  => s00_axi_wready,
            S_AXI_BRESP   => s00_axi_bresp,
            S_AXI_BVALID  => s00_axi_bvalid,
            S_AXI_BREADY  => s00_axi_bready,
            S_AXI_ARADDR  => s00_axi_araddr,
            S_AXI_ARPROT  => s00_axi_arprot,
            S_AXI_ARVALID => s00_axi_arvalid,
            S_AXI_ARREADY => s00_axi_arready,
            S_AXI_RDATA   => s00_axi_rdata,
            S_AXI_RRESP   => s00_axi_rresp,
            S_AXI_RVALID  => s00_axi_rvalid,
            S_AXI_RREADY  => s00_axi_rready
        );

end architecture arch_imp;
