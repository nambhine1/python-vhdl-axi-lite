architecture BasicReadWrite of TestCtrl is
  use    osvvm.ScoreboardPkg_slv.all;
  signal TestDone : integer_barrier := 1 ;
  signal Req_1 : AlertLogIDType;
  signal SB : ScoreboardIDType;


begin
  ------------------------------------------------------------
  -- ControlProc
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbAxi4_BasicReadWrite");
    TranscriptOpen;
    SetTranscriptMirror(TRUE);
    SetLogEnable(PASSED, FALSE);    -- Enable PASSED logs
    SetLogEnable(INFO, FALSE);      -- Enable INFO logs
	
	Req_1 <= GetReqID("PR-0001", PassedGoal => 1, ParentID => REQUIREMENT_ALERTLOG_ID); -- all register shall be writable, readable.
 
    -- Wait for Design Reset
    wait until nReset = '1';
	SB <= NEWID ("Score_Board"); 
    ClearAlerts;
    LOG("Start of Transactions");

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms);
    AlertIf(now >= 35 ms, "Test finished due to timeout");
    AlertIf(GetAffirmCount < 500, "Test is not Self-Checking");
	
	AffirmIf(Req_1, GetAlertCount = 0, GetTestName & "REQUIREMENT Req_1 FAILED!!!!!") ;

    wait for 1 us;

    EndOfTestReports(ReportAll => TRUE);
    TranscriptClose;
    std.env.stop;
    wait;
  end process ControlProc;

  ------------------------------------------------------------
  -- ManagerProc
  ------------------------------------------------------------
	ManagerProc : process
		variable RcvData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
		variable add_value : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
		variable rv : RandomPType;
		variable rand_data : std_logic_vector (AXI_DATA_WIDTH - 1 downto 0);
	begin
		-- Initialization
		wait until nReset = '1';
		WaitForClock(ManagerRec, 2);
		rv.InitSeed("AXIMANAGER_RANDOM");  -- Use string literal or integer seed
	
		-- Write loop
		for int_value in 0 to 511 loop
			add_value := std_logic_vector(to_unsigned(int_value, AXI_ADDR_WIDTH));
			rand_data := rv.RandSlv(AXI_DATA_WIDTH);
			Push(SB, rand_data);
			Write(ManagerRec, add_value * 4, rand_data);
		end loop;
	
		-- Read loop
		for int_value in 0 to 511 loop
			add_value := std_logic_vector(to_unsigned(int_value, AXI_ADDR_WIDTH));
			Read(ManagerRec, add_value * 4, RcvData);
			log("Data Received: " & to_hstring(RcvData), Level => DEBUG);
			Check(SB, RcvData);
		end loop;
	
		WaitForClock(ManagerRec, 2);
		WaitForBarrier(TestDone);
		wait;
	end process ManagerProc;

end architecture BasicReadWrite;

Configuration TbAxi4_BasicReadWrite of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(BasicReadWrite) ; 
    end for ; 
  end for ; 
end TbAxi4_BasicReadWrite ; 

