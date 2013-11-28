--
-------------------------------------------------------------------------------
-- description    : interconnects a wb master core p2p with an slave one.
--
-------------------------------------------------------------------------------
-- entity for wb_intercon_p2p unit                                            --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;

entity wb_intercon_p2p is
    port (
      pin_reset:  in  std_logic;    -- external reset signal
        pin_clock_50:  in  std_logic;    -- external clock signal; 50 mhz
      --
      -- display outputs
      --
      pin_leds:  out  std_logic_vector(7 downto 0)
      );
end wb_intercon_p2p;

architecture struct of wb_intercon_p2p is
--
--  component declaration
--
  component wb_slave_interface_leds
  port(
    rst_i : in std_logic;
    --adr_i : in std_logic;
    clk_i : in std_logic;
    dat_i : in std_logic_vector(15 downto 0);
    stb_i : in std_logic;
    cyc_i : in std_logic;
    we_i : in std_logic;
    ack_o : out std_logic;
    dat_o : out std_logic_vector(15 downto 0);
    leds : out std_logic_vector(7 downto 0)
    );
  end component;

  component wb_master_interface_counter
  generic (count_module_factor : integer := 3);

  port(
    rst_i : in std_logic;
    ack_i : in std_logic;
    clk_i : in std_logic;
    gnt_i : in std_logic;
    dat_i : in std_logic_vector(15 downto 0);
    dat_o : out std_logic_vector(15 downto 0);
    --adr_o : out std_logic;
    stb_o : out std_logic;
    we_o : out std_logic;
    cyc_o : out std_logic
    );
  end component;

--
-- wishbone interconnection signals
--

signal rst_i : std_logic;
signal clk_i : std_logic;
signal ack   : std_logic;
signal we   : std_logic;
signal stb  : std_logic;
signal cyc  : std_logic;
--signal adr  : std_logic;
signal dat_i_node : std_logic_vector(15 downto 0);
signal dat_o_node : std_logic_vector(15 downto 0);

begin

rst_i <= pin_reset;
clk_i <= pin_clock_50;
--
-- components instantation
--
-- wishbone master core (counter)
  inst_wb_master_interface: wb_master_interface_counter
  generic map(
  count_module_factor => 20)    -- timer prescaler
  port map(
    rst_i => rst_i,
    ack_i => ack,
    --adr_o => adr,
    clk_i => clk_i,
    dat_i => dat_i_node,
    dat_o => dat_o_node,
    stb_o => stb,
    we_o => we,
    cyc_o => cyc,
    gnt_i => '1'
  );

-- wishbone slave core (leds)
  inst_wb_slave_interface_leds: wb_slave_interface_leds port map(
    rst_i => rst_i,
    ack_o => ack,
    --adr_i => adr,
    clk_i => clk_i,
    dat_i => dat_o_node,
    dat_o => dat_i_node,
    stb_i => stb,
    cyc_i => cyc,
    we_i => we,
    leds => pin_leds
  );

end struct;