--
-------------------------------------------------------------------------------
-- description    : interface for two 7 segment display (with memory)
--
-------------------------------------------------------------------------------
-- entity for wb_slave_interface unit                                        --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity wb_slave_interface_processor is
  generic(
    address: std_logic_vector(15 downto 0)
  );
  port (
    -- Inputs
    pulsador: in std_logic;
    switches: in std_logic_vector(3 downto 0);

    -- Wishbone signals
    -- Global
    rst_i :in std_logic; -- wb : global reset signal
    clk_i :in std_logic; -- wb : global bus clock
    -- Control
    stb_i :in std_logic; -- wb : access qualify from the master
    cyc_i :in std_logic; -- wb : access qualify
    we_i :in std_logic; -- wb : read/write request
    adr_i :in std_logic_vector(15 downto 0); -- wb : adress,
    ack_o :out std_logic; -- wb : ack to the master
    -- input
    dat_i :in std_logic_vector(15 downto 0); -- wb : 16 bits data bus
    dat_o :out std_logic_vector(15 downto 0) -- wb : 16 bits data bus
  );
end wb_slave_interface_processor;

architecture behavioral of wb_slave_interface_processor is
  signal registro: std_logic_vector(15 downto 0); -- Will keep data from dat_i
  signal registro_m: std_logic_vector(15 downto 0); -- Will be logical multiplication of switches and dat_i
  --
  -- wishbone slave interface control state machine
  --
  type wb_state is (stb_in_wait, write_data, read_data, send_ack_o);
  signal act_wb : wb_state;
  signal next_wb: wb_state;

begin
-- wishbone slave interface control
  ack_control: process (rst_i, clk_i)
  -- declarations
  begin
    if rst_i = '1' then
      act_wb <= stb_in_wait;
    elsif rising_edge(clk_i) then
      act_wb <= next_wb;
    end if;
  end process;

  process(act_wb, stb_i, cyc_i, we_i, adr_i)
  begin
    case act_wb is
      when stb_in_wait =>
        -- wait for the stb form the master
        if adr_i = address then
          if stb_i ='1' and cyc_i = '1' then
            if we_i='0' then
              next_wb <= read_data;
            else
              next_wb <= write_data;
            end if;
          else
            next_wb <= stb_in_wait;
          end if;
        else
          next_wb <= stb_in_wait;
        end if;
      when write_data =>
        next_wb <= send_ack_o;
      when read_data =>
        next_wb <= send_ack_o;
      when send_ack_o =>
        -- send the ack signal
        -- it si possible to do it in read_data state
        -- Only ends on stb_i to 0
        if stb_i = '0' then
          next_wb <= stb_in_wait;
        else
          next_wb <= stb_in_wait;
        end if;
    end case;
  end process;

  with act_wb select
  ack_o <=  '1' when send_ack_o,
            '0' when others;
--
-- registro synchronous load of dat_i
--
  process (clk_i, rst_i)
  begin
    if rst_i='1' then
      registro <= (others => '0');
    elsif rising_edge(clk_i) then
      if act_wb = write_data then
        registro <= dat_i;
      end if;
    end if;
  end process;

  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if pulsador='1' then
        registro_m <= X"00" & (registro(3 downto 0) * switches);
      end if;
    end if;
  end process;

  process (clk_i, rst_i)
  begin
    if rising_edge(clk_i) then
      if act_wb = read_data then
        dat_o <= registro_m;
      end if;
    end if;
  end process;

end behavioral;