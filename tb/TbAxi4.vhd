library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

library osvvm_Axi4 ;
  context osvvm_Axi4.Axi4LiteContext ;

entity TbAxi4 is
end entity TbAxi4 ;
architecture TestHarness of TbAxi4 is
  constant AXI_ADDR_WIDTH : integer := 11 ;
  constant AXI_DATA_WIDTH : integer := 32 ;
  constant AXI_STRB_WIDTH : integer := AXI_DATA_WIDTH/8 ;

  constant tperiod_Clk : time := 10 ns ;
  constant tpd         : time := 2 ns ;

  signal Clk         : std_logic ;
  signal nReset      : std_logic ;

  signal ManagerRec  : AddressBusRecType(
          Address(AXI_ADDR_WIDTH-1 downto 0),
          DataToModel(AXI_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI_DATA_WIDTH-1 downto 0)
        ) ;

--  -- AXI Manager Functional Interface
  signal   AxiBus : Axi4LiteRecType(
    WriteAddress( Addr (AXI_ADDR_WIDTH-1 downto 0) ),
    WriteData   ( Data (AXI_DATA_WIDTH-1 downto 0),   Strb(AXI_STRB_WIDTH-1 downto 0) ),
    ReadAddress ( Addr (AXI_ADDR_WIDTH-1 downto 0) ),
    ReadData    ( Data (AXI_DATA_WIDTH-1 downto 0) )
  ) ;


  component TestCtrl is
    port (
      -- Global Signal Interface
      Clk                 : In    std_logic ;
      nReset              : In    std_logic ;

      -- Transaction Interfaces
      ManagerRec          : inout AddressBusRecType 
    ) ;
  end component TestCtrl ;


begin

  -- create Clock
  Osvvm.ClockResetPkg.CreateClock (
    Clk        => Clk,
    Period     => Tperiod_Clk
  )  ;

  -- create nReset
  Osvvm.ClockResetPkg.CreateReset (
    Reset       => nReset,
    ResetActive => '0',
    Clk         => Clk,
    Period      => 7 * tperiod_Clk,
    tpd         => tpd
  ) ;


  Manager_1 : Axi4LiteManager
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Manager Functional Interface
    AxiBus      => AxiBus,

    -- Testbench Transaction Interface
    TransRec    => ManagerRec
  ) ;



  TestCtrl_1 : TestCtrl
  port map (
    -- Globals
    Clk            => Clk,
    nReset         => nReset,

    -- Testbench Transaction Interfaces
    ManagerRec     => ManagerRec
  ) ; 
  
DUT : entity work.axi_lite_ram_wrapper
    generic map (
        C_S00_AXI_DATA_WIDTH => AXI_DATA_WIDTH,
        C_S00_AXI_ADDR_WIDTH => AXI_ADDR_WIDTH
    )
    port map (
        -- AXI Clock and Reset
        s00_axi_aclk    => Clk,
        s00_axi_aresetn => nReset,

        -- AXI Write Address Channel
        s00_axi_awaddr  => AxiBus.WriteAddress.Addr,
        s00_axi_awprot  => (others => '0'),  -- You can customize this if needed
        s00_axi_awvalid => AxiBus.WriteAddress.Valid,
        s00_axi_awready => AxiBus.WriteAddress.Ready,

        -- AXI Write Data Channel
        s00_axi_wdata   => AxiBus.WriteData.Data,
        s00_axi_wstrb   => AxiBus.WriteData.Strb,
        s00_axi_wvalid  => AxiBus.WriteData.Valid,
        s00_axi_wready  => AxiBus.WriteData.Ready,

        -- AXI Write Response Channel
        s00_axi_bresp   => AxiBus.WriteResponse.Resp,
        s00_axi_bvalid  => AxiBus.WriteResponse.Valid,
        s00_axi_bready  => AxiBus.WriteResponse.Ready,

        -- AXI Read Address Channel
        s00_axi_araddr  => AxiBus.ReadAddress.Addr,
        s00_axi_arprot  => (others => '0'),  -- You can customize this if needed
        s00_axi_arvalid => AxiBus.ReadAddress.Valid,
        s00_axi_arready => AxiBus.ReadAddress.Ready,

        -- AXI Read Data Channel
        s00_axi_rdata   => AxiBus.ReadData.Data,
        s00_axi_rresp   => AxiBus.ReadData.Resp,
        s00_axi_rvalid  => AxiBus.ReadData.Valid,
        s00_axi_rready  => AxiBus.ReadData.Ready
    );

	
  
  

end architecture TestHarness ;