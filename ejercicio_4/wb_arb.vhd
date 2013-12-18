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
  generic (
    n_master : integer := 2
  );
  port (
    -- wishbone signals
    rst_i :in std_logic; -- wb : global reset signal
    clk_i :in std_logic; -- wb : global bus clock
    cyc_i :in std_logic_vector(n_master-1 downto 0); -- wb : master bus request
    gnt_o :out std_logic_vector(n_master-1 downto 0); -- wb : master bus access grant
    cyc_shared_o :out std_logic -- wb : master bus request for the slaves
  );
end wb_arb;


architecture behavioral of wb_arb is
  -- Sta = Active status ; Stn = Next status
  type arb_state is (s_wait, s_g1, s_g2);
  signal sta, stn : arb_state;
  
  type priorities is (none, g1, g2);
  signal pri : priorities;
  

  -- Internal signals to use with decoders
  signal sel, status, prior : std_logic_vector(n_master-1 downto 0);
  signal cyc : std_logic;
begin

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        sta <= s_wait;
      else
        sta <= stn;
      end if;
    end if;
  end process;


  process(sta,cyc)
  begin
    case(sta) is
    when s_wait =>
      if pri = g1 then
        stn <= s_g1;
      elsif pri = g2 then
        stn <= s_g2;
      else
        stn <= s_wait;
      end if;
    when s_g1 =>
      if cyc_i(0) = '1' then
        stn <= s_g1;
      else
        stn <= s_wait;
      end if;
    when s_g2 =>
      if cyc_i(1) = '1' then
        stn <= s_g2;
      else
        stn <= s_wait;
      end if;
    end case;
  end process;

  pri <=  g1 when cyc_i(0)='1' else
          g2 when cyc_i(1)='1' else
          none;

  with sta select
  cyc_shared_o <= '1' when s_g1 | s_g2,
                  '0' when others;

  with sta select
  gnt_o <=  "01" when s_g1,
            "10" when s_g2,
            (others=>'0') when others;


end behavioral;