----------------------------------------------------------------------------------
-- company:
-- engineer:
--
-- create date:    14:36:48 12/14/2013
-- design name:
-- module name:    wb_master_interface_transfer - behavioral
-- project name:
-- target devices:
-- tool versions:
-- description:
--
-- dependencies:
--
-- revision:
-- revision 0.01 - file created
-- additional comments:
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx primitives in this code.
--library unisim;
--use unisim.vcomponents.all;

entity wb_master_interface_transfer is
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
end wb_master_interface_transfer;

architecture behavioral of wb_master_interface_transfer is
  type wb_state is (wait_s, read_ask_s, read_ack_s, write_ask_s, write_ack_s);
  signal sta, stn : wb_state;
  signal data : std_logic_vector(15 downto 0);
  signal c_data : std_logic := '0';
begin

  -- State machine clock
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        sta <= wait_s;
      else
        sta <= stn;
      end if;
    end if;
  end process;

  -- State machine
  process(sta, active, c_data, gnt_i, ack_i)
  begin
    case sta is
    when wait_s =>
      if active = '1' then
        stn <= read_ask_s;
      else
        stn <= wait_s;
      end  if;
    when read_ask_s =>
      if gnt_i = '1' then
        stn <= read_ack_s;
      else
        stn <= read_ask_s;
      end if;
    when read_ack_s =>
      if c_data = '1' then
        if ack_i = '1' then
          stn <= write_ask_s;
        else
          stn <= read_ack_s;
        end if;
      else
        stn <= read_ack_s;
      end if;
    when write_ask_s =>
      if gnt_i = '1' then
        stn <= write_ack_s;
      else
        stn <= write_ask_s;
      end if;
    when write_ack_s =>
      if ack_i = '1' then
        stn <= wait_s;
      else
        stn <= write_ack_s;
      end if;
    end case;
  end process;

  -- Control signals
  -- adr_o for selecting slave
  with sta select
  adr_o <=  input_address when read_ask_s | read_ack_s,
            output_address when write_ask_s | write_ack_s,
            (others => '0') when others;

  -- we_o to write or read access
  with sta select
  we_o <= '1' when write_ack_s,
          '0' when others;

  -- dat_o to write
  with sta select
  dat_o <=  data when write_ack_s,
            (others => '0') when others;

  -- stb_o to write or read
  with sta select
  stb_o <=  '1' when read_ack_s | write_ack_s,
            '0' when others;

  -- cyc_o to read or write
  with sta select
  cyc_o <=  '1' when read_ask_s | read_ack_s | write_ask_s | write_ack_s,
            '0' when others;

  -- data processing on read and write
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if sta = read_ack_s then
          data <= dat_i;
          c_data <= '1';
      elsif sta = write_ack_s then
          c_data <= '0';
      end if;
    end if;
  end process;
end behavioral;

