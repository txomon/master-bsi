--
-------------------------------------------------------------------------------
-- Description    : Interconects 2 WB master cores with an slave one (Shared Bus).
--
-------------------------------------------------------------------------------
-- Entity for wb_intercon_shared Unit                                         --
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;

entity wb_intercon_sh_bus is
    Port (
      PIN_RESET:  in  std_logic;    -- External RESET signal
        PIN_CLOCK_50:  in  std_logic;    -- External CLOCK signal
      --
      -- LEDS OUTPUTS
      --
      PIN_LEDS:  out  std_logic_vector(7 downto 0)
      );
end wb_intercon_sh_bus;

architecture struct of wb_intercon_sh_bus is
--
--  COMPONENT DECLARATION
--
  COMPONENT wb_slave_interface_leds
  PORT(
    RST_I : IN std_logic;
    --ADR_I : IN std_logic;
    CLK_I : IN std_logic;
    DAT_I : IN std_logic_vector(15 downto 0);
    STB_I : IN std_logic;
    CYC_I : IN std_logic;
    WE_I : IN std_logic;
    ACK_O : OUT std_logic;
    DAT_O : OUT std_logic_vector(15 downto 0);
    LEDS : OUT std_logic_vector(7 downto 0)
    );
  END COMPONENT;

  COMPONENT wb_master_interface_counter
  generic (count_module_factor : integer := 3);

  PORT(
    RST_I : IN std_logic;
    ACK_I : IN std_logic;
    CLK_I : IN std_logic;
    GNT_I : IN std_logic;
    DAT_I : IN std_logic_vector(15 downto 0);
    DAT_O : OUT std_logic_vector(15 downto 0);
    --ADR_O : OUT std_logic;
    STB_O : OUT std_logic;
    WE_O : OUT std_logic;
    CYC_O : OUT std_logic
    );
  END COMPONENT;

  COMPONENT wb_arb
  generic (n_master : integer := 2);
  PORT(          --
    RST_I:  in  std_logic;
    CLK_I:  in  std_logic;        	
    CYC_I:  in  std_logic_vector(n_master-1 downto 0);
    GNT_O:  out  std_logic_vector(n_master-1 downto 0);
    CYC_SHARED_O : out  std_logic        	
    );
  END COMPONENT;

--
-- NUMBER OF MASTERS
--
constant n_master:integer := 2; -- number of masters
--type T_OUTPUT_DATA_BUS is array (natural range <>) of std_logic_vector(15 downto 0);
type OUTPUT_DATA_BUS is array (n_master-1 downto 0) of std_logic_vector(15 downto 0);
--
-- WISHBONE INTERCONNECTION SIGNALS
--

signal RST_I : std_logic;
signal CLK_I : std_logic;
signal ACK   : std_logic;
signal ACK_MASTER: std_logic_VECTOR(n_master-1 downto 0);
signal WE_OUT   : std_logic;
signal STB_OUT  : std_logic;
signal ADR_OUT  : std_logic;
signal WE   : std_logic_VECTOR(n_master-1 downto 0);
signal STB  : std_logic_VECTOR(n_master-1 downto 0);
signal DAT_SLAVE: std_logic_VECTOR(15 downto 0);
signal DAT_MASTER: std_logic_VECTOR(15 downto 0);
signal DAT_OUT : OUTPUT_DATA_BUS;
signal CYC : std_logic_VECTOR(n_master-1 downto 0);
signal GNT : std_logic_VECTOR(n_master-1 downto 0);
signal CYC_SHARED: std_logic;

begin
--
-- COMPONENTS INSTANTATION
--
--
-- WISHBONE MASTER CORE (TIMER)
--
Gen_master: for I in 0 to n_master-1 generate
  inst_wb_master_interface_counter: wb_master_interface_counter
  generic map(
  count_module_factor => 20*(I+1))    -- Display timer prescaler
  PORT MAP
    (RST_I => RST_I,
    ACK_I => ACK_MASTER(I),
    --ADR_O => ADR(I),
    CLK_I => CLK_I,
    DAT_I => DAT_SLAVE,
    DAT_O => DAT_OUT(I),
    STB_O => STB(I),
    WE_O => WE(I),
    CYC_O => CYC(I),
    GNT_I => GNT(I)
  );
end generate;

-- WISHBONE SLAVE CORE (LEDS)
  Inst_wb_slave_interface_leds: wb_slave_interface_leds PORT MAP(
    RST_I => RST_I,
    ACK_O => ACK,
    --ADR_I => ADR,
    CLK_I => CLK_I,
    DAT_I => DAT_MASTER,
    DAT_O => DAT_SLAVE,
    STB_I => STB_OUT,
    CYC_I => CYC_SHARED,
    WE_I => WE_OUT,
    LEDS => PIN_LEDS
  );

-- WISHBONE BUS ARBITRER
--

inst_wb_arb:wb_arb
  generic map (n_master)
    Port map(
   --
  -- WISHBONE SIGNALS
  --
  RST_I => RST_I,
  CLK_I => CLK_I,
  CYC_I => CYC,
  GNT_O => GNT,
  CYC_SHARED_O => CYC_SHARED
  );

--
-- MULTIPLEXORS FOR WISHBONE BUS SIGNALS
--

process(GNT,STB)
begin
  case GNT is
    when "01" => STB_OUT <= STB(0);
    when "10" => STB_OUT <= STB(1);
    when others => STB_OUT <= '0';
  end case;
end process;

process(GNT,WE)
begin
  case GNT is
    when "01" => WE_OUT <= WE(0);
    when "10" => WE_OUT <= WE(1);
    when others => WE_OUT <= '0';
  end case;
end process;

process(GNT,DAT_OUT)
begin
  case GNT is
    when "01" => DAT_MASTER <= DAT_OUT(0);
    when "10" => DAT_MASTER <= DAT_OUT(1);
    when others => DAT_MASTER <= (others=>'0');
  end case;
end process;

ACK_MASTER(0) <= ACK and GNT(0);
ACK_MASTER(1) <= ACK and GNT(1);


RST_I <= PIN_RESET;
CLK_I <= PIN_CLOCK_50;

end struct;