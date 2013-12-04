--
-------------------------------------------------------------------------------
-- description    : interconects 2 wb master cores with an slave one (shared bus).
--
-------------------------------------------------------------------------------
-- entity for wb_intercon_shared unit                                         --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;

entity wb_intercon_sh_bus is
    port (
      pin_reset:  in  std_logic;    -- external reset signal
        pin_clock_50:  in  std_logic;    -- external clock signal
      --
      -- leds outputs
      --
      pin_leds:  out  std_logic_vector(7 downto 0)
      );
end wb_intercon_sh_bus;

architecture struct of wb_intercon_sh_bus is
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

  component wb_arb
    generic (n_master : integer := 2);
    port(          --
      rst_i:  in  std_logic;
      clk_i:  in  std_logic;
      cyc_i:  in  std_logic_vector(n_master-1 downto 0);
      gnt_o:  out  std_logic_vector(n_master-1 downto 0);
      cyc_shared_o : out  std_logic
    );
  end component;

  --
  -- number of masters
  --
  constant n_master:integer := 3; -- number of masters
  --type t_output_data_bus is array (natural range <>) of std_logic_vector(15 downto 0);
  type output_data_bus is array (n_master-1 downto 0) of std_logic_vector(15 downto 0);
  --
  -- wishbone interconnection signals
  --

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
  --
  -- components instantation
  --
  --
  -- wishbone master core (timer)
  --
  gen_master: for i in 0 to n_master-1 generate
    inst_wb_master_interface_counter: wb_master_interface_counter
    generic map(
    count_module_factor => 20*(i+1))    -- display timer prescaler
    port map
      (rst_i => rst_i,
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
  end generate;

  -- wishbone slave core (leds)
    inst_wb_slave_interface_leds: wb_slave_interface_leds port map(
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
  --

  inst_wb_arb:wb_arb
    generic map (n_master)
    port map(
      --
      -- wishbone signals
      --
      rst_i => rst_i,
      clk_i => clk_i,
      cyc_i => cyc,
      gnt_o => gnt,
      cyc_shared_o => cyc_shared
    );

  --
  -- multiplexors for wishbone bus signals
  --

  process(gnt,stb)
  begin
    case gnt is
      when "001" => stb_out <= stb(0);
      when "010" => stb_out <= stb(1);
      when "100" => stb_out <= stb(2);
      when others => stb_out <= '0';
    end case;
  end process;

  process(gnt,we)
  begin
    case gnt is
      when "001" => we_out <= we(0);
      when "010" => we_out <= we(1);
      when "100" => we_out <= we(2);
      when others => we_out <= '0';
    end case;
  end process;

  process(gnt,dat_out)
  begin
    case gnt is
      when "001" => dat_master <= dat_out(0);
      when "010" => dat_master <= dat_out(1);
      when "100" => dat_master <= dat_out(2);
      when others => dat_master <= (others=>'0');
    end case;
  end process;

  ack_master(0) <= ack and gnt(0);
  ack_master(1) <= ack and gnt(1);
  ack_master(2) <= ack and gnt(2);


  rst_i <= pin_reset;
  clk_i <= pin_clock_50;

end struct;