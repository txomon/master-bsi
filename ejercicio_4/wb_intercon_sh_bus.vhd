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
    pin_reset :in std_logic; -- external reset signal
    pin_clock_50 :in std_logic; -- external clock signal
    pin_leds :out std_logic_vector(7 downto 0); -- leds outputs
    m1trigger :in std_logic; -- trigger buttons for master 1
    data : in std_logic_vector(3 downto 0); -- Data to have as a reference
    m2trigger :in std_logic; -- trigger
    s1trigger :in std_logic -- trigger for slave processing
  );
end wb_intercon_sh_bus;

architecture struct of wb_intercon_sh_bus is

  -- number of masters
  constant n_master :integer := 2; -- number of masters
  constant n_slave :integer := 2; -- number of slaves
  -- Address designation
  constant processor_address :std_logic_vector(15 downto 0) := "0000000000000000"; -- Processor's address
  constant leds_address :std_logic_vector(15 downto 0) := "0000000000000001"; -- Led output address

  component wb_master_interface_generator is
    generic (
      count_module_factor :in integer := 20; -- counter prescaler
      output_address :in std_logic_vector(15 downto 0)
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
      address: std_logic_vector(15 downto 0)
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
      input_address :in std_logic_vector(15 downto 0); -- Address of the slave to read from
      output_address :in std_logic_vector(15 downto 0) -- Address of the slave to write to
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
      address :in std_logic_vector(15 downto 0)
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
      dat_i :in std_logic_vector(15 downto 0);      -- wb : 16 bits data bus input
      dat_o :in std_logic_vector(15 downto 0) -- wb : 16 bits data bus output
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

  type master_bus is array (n_master-1 downto 0) of std_logic_vector(15 downto 0);
  type slave_bus is array (n_slave-1 downto 0) of std_logic_vector(15 downto 0);

  -- Wishbone interconnection signals
  -- Global
  signal rst_i : std_logic;
  signal clk_i : std_logic;
  -- Control signals from slaves
  signal ack_slave : std_logic_vector(1 downto 0); -- Ack from slaves to multiplexor
  signal ack : std_logic; -- Ack from mult to master
  -- Control signals from masters
  signal we_o : std_logic_vector(n_master-1 downto 0); -- all we_o masters
  signal we : std_logic; -- we_o from masters
  signal stb_o : std_logic_vector(n_master-1 downto 0); -- all stb_o master
  signal stb : std_logic; -- stb_o from masters
  signal adr_o : master_bus; -- all adr_o masters
  signal adr : std_logic_vector(15 downto 0); -- adr_o from masters
  signal dat_s_o : slave_bus; -- all dat_o slaves
  signal dat_s : std_logic_vector(15 downto 0); -- dat_o from slave
  signal dat_m_o : master_bus; -- all dat_o masters
  signal dat_m : std_logic_vector(15 downto 0);
  signal cyc : std_logic_vector(n_master-1 downto 0);
  signal gnt : std_logic_vector(n_master-1 downto 0);
  signal cyc_shared : std_logic;

begin

  -- Generator of the different data, only connects to one slave
  generator : wb_master_interface_generator
    generic map (
      count_module_factor => 20, -- display timer prescaler
      output_address => processor_address -- Address of the processor slave
    )
    port map (
      switches => data,
      pulsador => m1trigger,
      -- wishbone signals
      -- global
      rst_i => rst_i,
      clk_i => clk_i,
      -- transaction control
      adr_o => adr_o(0),
      cyc_o => cyc(0),
      gnt_i => gnt(0),
      stb_o => stb_o(0),
      we_o => we_o(0),
      ack_i => ack,
      -- data
      dat_o => dat_m_o(0)
    );

  -- Processor slave, between both masters
  processor: wb_slave_interface_processor
    generic map (
      address => processor_address
    )
    port map(
      pulsador => s1trigger,
      switches => data,
      rst_i => rst_i,
      clk_i => clk_i,
      stb_i => stb,
      cyc_i => cyc_shared,
      we_i => we,
      adr_i => adr,
      ack_o => ack_slave(0),
      dat_i => dat_m,
      dat_o => dat_s_o(0)
    );

  transfer : wb_master_interface_transfer
    generic map (
      input_address => processor_address,
      output_address => leds_address
    )
    port map (
      active => m2trigger,
      rst_i => rst_i,
      clk_i => clk_i,
      cyc_o => cyc(1),
      adr_o => adr_o(1),
      gnt_i => gnt(1),
      stb_o => stb_o(1),
      we_o => we_o(1),
      ack_i => ack,
      dat_i => dat_s,
      dat_o => dat_m_o(1)
    );

  -- wishbone slave core (leds)
  output : wb_slave_interface_leds
    generic map(
      address => leds_address
    )
    port map(
      rst_i => rst_i,
      ack_o => ack_slave(1),
      adr_i => adr,
      clk_i => clk_i,
      dat_i => dat_m,
      dat_o => dat_s_o(1),
      stb_i => stb,
      cyc_i => cyc_shared,
      we_i => we,
      leds => pin_leds
    );

  -- wishbone bus arbitrer
  arbiter : wb_arb
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
      when "01" => stb <= stb_o(0);
      when "10" => stb <= stb_o(1);
      when others => stb <= '0';
    end case;
  end process;

  process(gnt,we_o)
  begin
    case gnt is
      when "01" => we <= we_o(0);
      when "10" => we <= we_o(1);
      when others => we <= '0';
    end case;
  end process;

  process(gnt,dat_m_o)
  begin
    case gnt is
      when "01" => dat_m <= dat_m_o(0);
      when "10" => dat_m <= dat_m_o(1);
      when others => dat_m <= (others=>'0');
    end case;
  end process;

  process(gnt,adr_o) --direccion a los esclavos
  begin
    case gnt is
      when "01" => adr <= adr_o(0);
      when "10" => adr <= adr_o(1);
      when others => adr <= (others=>'0');
    end case;
  end process;

  rst_i <= pin_reset;
  clk_i <= pin_clock_50;

end struct;