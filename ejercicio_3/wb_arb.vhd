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
generic (n_master : integer := 2);
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
  type arb_state is (start, check_which_master, do_round, set_grant, check_end_cyc);
  signal act_arb : arb_state;
  signal next_arb: arb_state;

  signal master_match_turn : std_logic;  -- comparation cyc and counter value decoded
                                        -- counter to know the turn
  signal counter_value: std_logic_vector(n_master-1 downto 0);
                                        -- clock enable for the sync. counter
  signal counter_value_ce: std_logic;
  signal counter_decoded: std_logic_vector(n_master-1 downto 0);
  signal cyc_and_counter: std_logic_vector(n_master-1 downto 0);

begin

  --
  -- auxiliary signals generation
  --

  --
  -- counter control
  --
  process (clk_i,rst_i)
  begin
    if rst_i = '1' then
      counter_value <= (others => '0');
    elsif (clk_i'event and clk_i = '1') then
      if counter_value_ce = '1' then
        counter_value <= counter_value + 1;
      end if;
    end if;
  end process;

  --
  -- decoder control
  --
  gen_counter_dec:
    for i in 0 to n_master-1 generate
      counter_decoded(i)  <= '1' when
      (counter_value = conv_std_logic_vector(i,n_master))
      else '0';
    end generate;

  --
  -- comparation between the cyc_i and the counter (master matches)
  --
  cyc_and_counter <= cyc_i and counter_decoded;

  --
  -- match detection
  master_match_turn <=  '1' when  (cyc_and_counter /= "0")
                            else '0';

  --
  -- arbitration control
  --
  arb_control: process (rst_i, clk_i)
  begin
    if rst_i = '1' then
      act_arb <= start;
    elsif (clk_i'event and clk_i = '1') then
      act_arb <= next_arb;
    end if;
  end process;

  process(act_arb,master_match_turn)
  begin

  case act_arb is
    when start =>
      -- reset output signals
      next_arb <= check_which_master;


    when check_which_master =>
      -- check if it is the allowed master for this turn
      if master_match_turn = '1' then
        -- go to grant the bus to that master
        next_arb <= set_grant;
      else
        -- pass this turn
        next_arb <= do_round;
      end if;

    when do_round =>
      -- increment the counter
      -- go to the idle state
      next_arb <= check_which_master;

    when set_grant =>
      -- set the correct grant signal to the current master
      next_arb <= check_end_cyc;

    when check_end_cyc =>
      -- check the end of the master transfer
      if master_match_turn = '1' then
        -- continues the access
        next_arb <= check_end_cyc;
        else
           -- the bus access is finished
        next_arb <= do_round;
      end if;

    end case;

  end process;

  with act_arb select
    counter_value_ce <= '1' when do_round,
                        '0' when others;


  gen_gnt:
    for i in 0 to n_master-1 generate
      with act_arb select
        gnt_o(i) <= counter_decoded(i) when set_grant|check_end_cyc,
                    '0' when others;
    end generate;

  with act_arb select
    cyc_shared_o <= '1' when set_grant|check_end_cyc,
                    '0' when others;

end behavioral;