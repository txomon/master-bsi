--
-------------------------------------------------------------------------------
-- description    : parametrizable wb master bus arbitrer              --
-------------------------------------------------------------------------------
-- entity for wb_arb unit                                                  --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity wb_arb is
generic (n_master : integer := 3);
  port (
    --
    -- wishbone signals
    --
    rst_i:  in  std_logic;              -- wb : global reset signal
    clk_i:  in  std_logic;              -- wb : global bus clock
    cyc_i:  in  std_logic_vector(n_master-1 downto 0);   -- wb : master bus request
    gnt_o:  out  std_logic_vector(n_master-1 downto 0);   -- wb : master bus access grant
    cyc_shared_o : out  std_logic        -- wb : master bus request for the slaves
  );
end wb_arb;


architecture behavioral of wb_arb is
  -- Sta = Active status ; Stn = Next status
  type arb_state is (grant_master, wait_master);
  signal sta, stn : arb_state;

  -- Internal signals to use with decoders
  signal cyc, gnt : std_logic;
  signal sel, in_sel : std_logic_vector(n_master-1 downto 0);
begin
  --
  -- State machine

  process(sta, cyc, gnt)
  begin
    case(sta) is
    when grant_master =>
      if gnt = '1' then
        stn <= wait_master;
      end if;
    when wait_master =>
      if cyc = '0' then
        stn <= grant_master;
      end if;
    end case;
  end process;

  process(clk_i,rst_i)
  begin
    if rst_i = '1' then
      sta <= grant_master;
    elsif rising_edge(clk_i) then
      sta <= stn;
    end if;
  end process;


  -- Control signals
  gnt_o <= sel;


  -- Selection must be maintained within the state
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if sta = grant_master then
        sel <= in_sel;
      end if;
    end if;
  end process;

  in_sel <= (0=>'1', others=>'0') when cyc_i(0) = '1' else
            (1=>'1', others=>'0') when cyc_i(1) = '1' else
            (2=>'1', others=>'0') when cyc_i(2) = '1' else
            (others=>'0');

end behavioral;