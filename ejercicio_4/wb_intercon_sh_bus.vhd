--
-------------------------------------------------------------------------------
-- description    : interconects 2 wb master cores with two slaves in a shared bus.
--
-------------------------------------------------------------------------------
-- entity for wb_intercon_shared unit                                         --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity wb_intercon_sh_bus is
  port (
    pin_reset:  in  std_logic;    -- external reset signal
    pin_clock_50:  in  std_logic;    -- external clock signal
    -- leds outputs
    pin_leds:  out  std_logic_vector(7 downto 0);
    alarm : in std_logic --Alarm clock
  );
end wb_intercon_sh_bus;

architecture struct of wb_intercon_sh_bus is

  -- number of masters
  constant n_master:integer := 2; -- number of masters

  entity wb_master_interface_generator is
    generic (
      count_module_factor : integer := 20 -- counter prescaler
    );
    port (
      -- wishbone signals
      -- global
      rst_i : in std_logic; -- wb : global reset signal
      clk_i : in std_logic; -- wb : global bus clock
      -- transaction control
      adr_o : out std_logic_vector(15 downto 0 ); -- wb : address
      cyc_o : out std_logic; -- wb : bus request to the arbitrer
      gnt_i : in std_logic; -- wb : bus grant from the arbitrer
      stb_o : out std_logic; -- wb : access qualify
      we_o : out std_logic; -- wb : read/write request
      ack_i : in std_logic; -- wb : ack from the slave
      -- data
      dat_o : out std_logic_vector(15 downto 0 ); -- data output wb : 16 bits
      -- Other inputs
      switches : in std_logic_vector (3 downto 0);
      pulsador : in std_logic
    );
  end component;

  component wb_slave_interface_processor is
    generic(
      addr: std_logic_vector(3 downto 0) := "0001"
    );
    port (
      -- wishbone signals
      -- global
      rst_i : in  std_logic; -- wb : global reset signal
      clk_i : in  std_logic; -- wb : global bus clock
      -- transaction control
      adr_i : in  std_logic_vector(15 downto 0 ); -- wb : adress
      stb_i : in  std_logic; -- wb : access qualify from the master
      cyc_i : in  std_logic; -- wb : access qualify
      we_i : in  std_logic; -- wb : read/write request
      ack_o : out std_logic; -- wb : ack from to the master
      -- data
      dat_i : in std_logic_vector(15 downto 0 ); -- wb : 16 bits data bus
      dat_o : out std_logic_vector(15 downto 0 ); -- wb : 16 bits data bus
      -- non whishbone
      pulsador : in std_logic;
      switches : in std_logic_vector(3 downto 0)
    );
  end component;

  component wb_master_interface_transfer is
    generic (
      read_slave :in std_logic_vector(15 downto 0); -- Address of the slave to read from
      write_slave :in std_logic_vector(15 downto 0) -- Address of the slave to write to
    );
    port (
      active :in std_logic; -- Activation of the master for one complete flow
      -- wishbone signals
      -- Global signals
      rst_i :in std_logic; -- wb : global reset signal
      clk_i :in std_logic; -- wb : global bus clock
      -- Control signals
      cyc_o :out std_logic; -- wb : bus request to the arbitrer
      adr_o :out std_logic_vector(15 downto 0); -- wb : address
      gnt_i :in std_logic; -- wb : bus grant from the arbitrer
      stb_o :out std_logic; -- wb : access qualify
      we_o :out std_logic; -- wb : read/write request
      ack_i :in std_logic; -- wb : ack from the slave
      -- Data signals
      dat_i :in std_logic_vector(15 downto 0); -- wb : 16 bits data bus input
      dat_o :out std_logic_vector(15 downto 0) -- wb : 16 bits data bus output
    );
  end component;

  --  component declaration

  component wb_slave_interface_leds is
    generic (
      slave_address :in std_logic_vector(15 downto 0)
    );
    port (
      -- Leds output
      leds :out std_logic_vector(7 downto 0);

      --- Wishbone signals
      -- Global
      rst_i :in  std_logic; -- wb : global reset signal
      clk_i :in  std_logic; -- wb : global bus clock
      -- Control
      stb_i :in  std_logic; -- wb : access qualify from the master
      cyc_i :in  std_logic; -- wb : access qualify
      adr_i :in  std_logic_vector(15 downto 0); -- wb : adress,
      we_i :in  std_logic; -- wb : read/write request
      ack_o :out std_logic; -- wb : ack from to the master
      -- Data
      dat_i :in std_logic_vector(15 downto 0); -- wb : 16 bits data bus input
    );
  end component;

  component wb_arb
    generic (
      n_master :in integer := n_master
    );
    port(          --
      rst_i :in  std_logic;
      clk_i:  in  std_logic;
      cyc_i:  in  std_logic_vector(n_master-1 downto 0);
      gnt_o:  out  std_logic_vector(n_master-1 downto 0);
      cyc_shared_o : out  std_logic
    );
  end component;

  type output_data_bus is array (n_master-1 downto 0) of std_logic_vector(15 downto 0);

  -- wishbone interconnection signals
  signal rst_i : std_logic;
  signal clk_i : std_logic;
  signal ack   : std_logic;
  signal ack_master: std_logic_vector(n_master-1 downto 0);
  signal we_out   : std_logic;
  signal stb_out  : std_logic;
  signal adr_out  : std_logic;
  signal we   : std_logic_vector(n_master-1 downto 0);
  signal stb  : std_logic_vector(n_master-1 downto 0);
  signal dat_slave: std_logic_vector(15 downto 0);
  signal dat_master: std_logic_vector(15 downto 0);
  signal dat_out : output_data_bus;
  signal cyc : std_logic_vector(n_master-1 downto 0);
  signal gnt : std_logic_vector(n_master-1 downto 0);
  signal cyc_shared: std_logic;

begin

  -- Generator of the different data, only connects to one slave
  wb_master_interface_generator
    generic map (
      count_module_factor => 20*(i+1) -- display timer prescaler
    )
    port map (
      rst_i => rst_i,
      ack_i => ack_master(i),
      --adr_o => adr(i),
      clk_i => clk_i,
      dat_i => dat_slave,
      dat_o => dat_out(i),
      stb_o => stb(i),
      we_o => we(i),
      cyc_o => cyc(i),
      gnt_i => gnt(i)
    );

  wb_master_interface_transfer
    port map (
      active => active,
      rst_i => rst_i,
      ack_i => ack_master(i),
      adr_o => adr(i),
      clk_i => clk_i,
      dat_i => dat_slave,
      dat_o => dat_out(i),
      stb_o => stb(i),
      we_o => we(i),
      cyc_o => cyc(i),
      gnt_i => gnt(i)
    );

  -- wishbone slave core (leds)
  wb_slave_interface_leds
    port map(
      rst_i => rst_i,
      ack_o => ack,
      --adr_i => adr,
      clk_i => clk_i,
      dat_i => dat_master,
      dat_o => dat_slave,
      stb_i => stb_out,
      cyc_i => cyc_shared,
      we_i => we_out,
      leds => pin_leds
    );

  -- wishbone bus arbitrer
  wb_arb
    generic map (
      n_master
    )
    port map(
      -- wishbone signals
      rst_i => rst_i,
      clk_i => clk_i,
      cyc_i => cyc,
      gnt_o => gnt,
      cyc_shared_o => cyc_shared
    );

  -- multiplexors for wishbone bus signals
  process(gnt,stb)
  begin
    case gnt is
      when "01" => stb_out <= stb(0);
      when "10" => stb_out <= stb(1);
      when others => stb_out <= '0';
    end case;
  end process;

  process(gnt,we)
  begin
    case gnt is
      when "01" => we_out <= we(0);
      when "10" => we_out <= we(1);
      when others => we_out <= '0';
    end case;
  end process;

  process(gnt,dat_out)
  begin
    case gnt is
      when "01" => dat_master <= dat_out(0);
      when "10" => dat_master <= dat_out(1);
      when others => dat_master <= (others=>'0');
    end case;
  end process;

  ack_master(0) <= ack and gnt(0);
  ack_master(1) <= ack and gnt(1);

  rst_i <= pin_reset;
  clk_i <= pin_clock_50;

end struct;