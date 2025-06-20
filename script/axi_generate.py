from math import ceil, log2

def generate_axi_lite_vhdl(num_registers, data_width=32, base_addr=0):
    assert num_registers > 0, "Number of registers must be positive"

    addr_lsb_val = int(log2(data_width // 8))  # bytes per word
    opt_mem_addr_bits = max(1, ceil(log2(num_registers)))
    addr_width = addr_lsb_val + opt_mem_addr_bits

    slv_regs_signals = "\n".join(
        f"    signal slv_reg{i} : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);"
        for i in range(num_registers)
    )

    reset_assignments = "\n".join(
        f"            slv_reg{i} <= (others => '0');"
        for i in range(num_registers)
    )

    write_case_branches = ""
    for i in range(num_registers):
        addr_bin = format(i, f'0{opt_mem_addr_bits}b')
        write_case_branches += f"""              when b"{addr_bin}" =>
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    slv_reg{i}(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
"""

    read_case_branches = ""
    for i in range(num_registers):
        addr_bin = format(i, f'0{opt_mem_addr_bits}b')
        read_case_branches += f"""          when b"{addr_bin}" =>
            reg_data_out <= slv_reg{i};
"""

    write_loc_addr_calc = """
    variable addr_full : unsigned(C_S_AXI_ADDR_WIDTH-1 downto 0);
    begin
      addr_full := unsigned(axi_awaddr) - to_unsigned(C_BASE_ADDR, C_S_AXI_ADDR_WIDTH);
      loc_addr := std_logic_vector(addr_full(ADDR_LSB + OPT_MEM_ADDR_BITS - 1 downto ADDR_LSB));
"""

    read_loc_addr_calc = """
    variable addr_full : unsigned(C_S_AXI_ADDR_WIDTH-1 downto 0);
    begin
      addr_full := unsigned(axi_araddr) - to_unsigned(C_BASE_ADDR, C_S_AXI_ADDR_WIDTH);
      loc_addr := std_logic_vector(addr_full(ADDR_LSB + OPT_MEM_ADDR_BITS - 1 downto ADDR_LSB));
"""

    vhdl_code = f"""library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_lite_v1_0_S00_AXI is
    generic (
        C_S_AXI_DATA_WIDTH    : integer := {data_width};
        C_S_AXI_ADDR_WIDTH    : integer := {addr_width};
        C_BASE_ADDR           : integer := {base_addr}
    );
    port (
        S_AXI_ACLK    : in std_logic;
        S_AXI_ARESETN : in std_logic;
        S_AXI_AWADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWPROT  : in std_logic_vector(2 downto 0);
        S_AXI_AWVALID : in std_logic;
        S_AXI_AWREADY : out std_logic;
        S_AXI_WDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB   : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID  : in std_logic;
        S_AXI_WREADY  : out std_logic;
        S_AXI_BRESP   : out std_logic_vector(1 downto 0);
        S_AXI_BVALID  : out std_logic;
        S_AXI_BREADY  : in std_logic;
        S_AXI_ARADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARPROT  : in std_logic_vector(2 downto 0);
        S_AXI_ARVALID : in std_logic;
        S_AXI_ARREADY : out std_logic;
        S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP   : out std_logic_vector(1 downto 0);
        S_AXI_RVALID  : out std_logic;
        S_AXI_RREADY  : in std_logic
    );
end axi_lite_v1_0_S00_AXI;

architecture arch_imp of axi_lite_v1_0_S00_AXI is

    signal axi_awaddr   : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal axi_awready  : std_logic;
    signal axi_wready   : std_logic;
    signal axi_bresp    : std_logic_vector(1 downto 0);
    signal axi_bvalid   : std_logic;
    signal axi_araddr   : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal axi_arready  : std_logic;
    signal axi_rdata    : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal axi_rresp    : std_logic_vector(1 downto 0);
    signal axi_rvalid   : std_logic;

    constant ADDR_LSB  : integer := {addr_lsb_val};
    constant OPT_MEM_ADDR_BITS : integer := {opt_mem_addr_bits};

{slv_regs_signals}

    signal slv_reg_rden : std_logic;
    signal slv_reg_wren : std_logic;
    signal reg_data_out : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal aw_en       : std_logic;

begin

    S_AXI_AWREADY <= axi_awready;
    S_AXI_WREADY  <= axi_wready;
    S_AXI_BRESP   <= axi_bresp;
    S_AXI_BVALID  <= axi_bvalid;
    S_AXI_ARREADY <= axi_arready;
    S_AXI_RDATA   <= axi_rdata;
    S_AXI_RRESP   <= axi_rresp;
    S_AXI_RVALID  <= axi_rvalid;

    -- Write address ready logic
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
          axi_awready <= '0';
          aw_en <= '1';
        else
          if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
            axi_awready <= '1';
            aw_en <= '0';
          elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
            aw_en <= '1';
            axi_awready <= '0';
          else
            axi_awready <= '0';
          end if;
        end if;
      end if;
    end process;

    -- Write address latch
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
          axi_awaddr <= (others => '0');
        else
          if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
            axi_awaddr <= S_AXI_AWADDR;
          end if;
        end if;
      end if;
    end process;

    -- Write ready
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
          axi_wready <= '0';
        else
          if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
            axi_wready <= '1';
          else
            axi_wready <= '0';
          end if;
        end if;
      end if;
    end process;

    slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID;

    -- Write register logic
    process (S_AXI_ACLK)
    variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS-1 downto 0);
{write_loc_addr_calc}
      if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
{reset_assignments}
        else
          if slv_reg_wren = '1' then
            case loc_addr is
{write_case_branches}              when others =>
{"".join([f"                slv_reg{i} <= slv_reg{i};\n" for i in range(num_registers)])}            end case;
          end if;
        end if;
      end if;
    end process;

    -- Write response
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
          axi_bvalid <= '0';
          axi_bresp <= "00";
        else
          if (axi_awready = '1' and S_AXI_AWVALID = '1' and
              axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0') then
            axi_bvalid <= '1';
            axi_bresp <= "00";
          elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
            axi_bvalid <= '0';
          end if;
        end if;
      end if;
    end process;

    -- Read address ready
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
          axi_arready <= '0';
          axi_araddr <= (others => '0');
        else
          if (axi_arready = '0' and S_AXI_ARVALID = '1') then
            axi_arready <= '1';
            axi_araddr <= S_AXI_ARADDR;
          else
            axi_arready <= '0';
          end if;
        end if;
      end if;
    end process;

    -- Read data logic
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
          axi_rvalid <= '0';
          axi_rresp <= "00";
        else
          if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
            axi_rvalid <= '1';
            axi_rresp <= "00";
          elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
            axi_rvalid <= '0';
          end if;
        end if;
      end if;
    end process;

    slv_reg_rden <= axi_arready and S_AXI_ARVALID and not axi_rvalid;

    -- Read register logic
    process (S_AXI_ACLK)
    variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS-1 downto 0);
{read_loc_addr_calc}
      if rising_edge(S_AXI_ACLK) then
        if S_AXI_ARESETN = '0' then
          reg_data_out <= (others => '0');
        else
          if slv_reg_rden = '1' then
            case loc_addr is
{read_case_branches}              when others =>
                reg_data_out <= (others => '0');
            end case;
          end if;
        end if;
      end if;
    end process;

    axi_rdata <= reg_data_out;

end arch_imp;
"""

    return vhdl_code


if __name__ == "__main__":
    while True:
        try:
            num_regs = int(input("Enter the number of registers to generate (positive integer): "))
            if num_regs <= 0:
                print("Please enter a positive integer.")
                continue
            break
        except ValueError:
            print("Invalid input. Please enter a positive integer.")

    filename = "../src/axi_lite_slave.vhd"

    vhdl_text = generate_axi_lite_vhdl(num_regs)

    with open(filename, "w") as f:
        f.write(vhdl_text)

    print(f"VHDL code with {num_regs} registers written to '{filename}'")

