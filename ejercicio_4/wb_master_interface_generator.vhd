--
-------------------------------------------------------------------------------
-- description    : it writes a squence of numbers to an slave.
--
-------------------------------------------------------------------------------
-- entity for wb_master_interface unit                                    --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity wb_master_interface_generator is
  generic (
    count_module_factor : integer := 20; -- counter prescaler
    output_address : std_logic_vector(15 downto 0)
  );
  port (
    -- wishbone signals
    -- global
    rst_i :in std_logic; -- wb : global reset signal
    clk_i :in std_logic; -- wb : global bus clock
    -- transaction control
    adr_o :out std_logic_vector(15 downto 0 ) := output_address; -- wb : address
    cyc_o :out std_logic; -- wb : bus request to the arbitrer
    gnt_i :in std_logic; -- wb : bus grant from the arbitrer
    stb_o :out std_logic; -- wb : access qualify
    we_o :out std_logic; -- wb : read/write request
    ack_i :in std_logic; -- wb : ack from the slave
    -- data
    dat_o:  out  std_logic_vector(15 downto 0 ); -- data output wb : 16 bits
    -- Other inputs
    switches: in std_logic_vector (3 downto 0);
    pulsador: in std_logic
  );
end wb_master_interface_generator;

architecture struct of wb_master_interface_generator is
  --  internal signals
  constant count_module : integer := 1*count_module_factor; -- simulation
  --constant count_module : integer := 1000000*count_module_factor; -- prototype
  -- if tclk = 20 ns => one transfer each 0,4 s if count_module_factor = 20

  signal count: integer range 0 to count_module; -- prescaler value for the count value
  signal temporal_register_ce : std_logic; -- clock enable for the temporal register
  signal init_transfer_node : std_logic; -- inits the transfer to the slave
  signal data_out_node: std_logic_vector(15 downto 0); -- internal data out

  signal stb_o_out : std_logic;
  signal we_o_out : std_logic;
  signal ack_i_in : std_logic;

  -- wishbone master interface control state machine
  type wb_state is (init_transfer_wait, ack_wait);
  signal act_wb, next_wb : wb_state;

begin

  we_o <= we_o_out when gnt_i='1' else '0';
  stb_o <= stb_o_out when gnt_i='1' else '0';
  ack_i_in <= ack_i when gnt_i='1' else '0';

  -- wishbone bus composition
  dat_o <= data_out_node when (we_o_out ='1' and
  stb_o_out ='1' and gnt_i='1') else (others => '0');

  -- wishbone master interface control
  process (rst_i, clk_i)
  begin
    if rst_i = '1' then
      act_wb <= init_transfer_wait;
    elsif (clk_i'event and clk_i = '1') then
      act_wb <= next_wb;
    end if;
  end process;

  process(act_wb,init_transfer_node,ack_i_in)
  begin
    case act_wb is
      when init_transfer_wait =>
        if init_transfer_node ='1' then
          next_wb <= ack_wait;
         else
          next_wb <= init_transfer_wait;
        end if;
      when ack_wait =>
        if ack_i_in ='1' then
          next_wb <= init_transfer_wait;
        else
          next_wb <= ack_wait;
        end if;
    end case;
  end process;

  with act_wb select
    stb_o_out <=  '1' when ack_wait,
                  '0' when others;

  with act_wb select
    cyc_o <=  '1' when ack_wait,
              '0' when others;

  we_o_out <= '1';

  -- temporal counter
  process (clk_i, rst_i)
  begin
    if rst_i='1' then
        temporal_register_ce <= '0';
    elsif clk_i'event and clk_i = '1' then
      if pulsador='1' then
        temporal_register_ce <= '1';
      else
        temporal_register_ce <= '0';
      end if;
    end if;
  end process;

  -- temporal counter (data to transfer to slave)
  process (clk_i, rst_i)
  begin
    if rst_i='1' then
      -- reset values
      data_out_node <= (others=>'0');
      init_transfer_node <= '0';
    elsif clk_i'event and clk_i='1' then
      -- init the transference
      if temporal_register_ce='1' then
        init_transfer_node <= '1';
        data_out_node (3 downto 0) <= switches;
        data_out_node (15 downto 4) <= (others=>'0');
      else
        init_transfer_node <= '0';
        data_out_node <= data_out_node;
      end if;
    end if;
  end process;

end struct;