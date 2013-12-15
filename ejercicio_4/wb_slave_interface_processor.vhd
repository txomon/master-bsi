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
    addr: std_logic_vector(3 downto 0) := "0001"
  );
  port (
    -- wishbone signals
    addr_i: in std_logic_vector (3 downto 0);
    rst_i:  in  std_logic;      -- wb : global reset signal
    ack_o:  out std_logic;      -- wb : ack from to the master
    --adr_i:  in  std_logic_vector(15 downto 0 );-- wb : adress,
    -- not used in this core
    clk_i:  in  std_logic;      -- wb : global bus clock
    dat_i:  in std_logic_vector(15 downto 0 ); -- wb : 16 bits data bus
    -- input
    dat_o:  out std_logic_vector(15 downto 0 ); -- wb : 16 bits data bus
    -- ouput
    stb_i:  in  std_logic;      -- wb : access qualify from the master
    cyc_i:  in  std_logic;      -- wb : access qualify
    we_i:   in  std_logic;      -- wb : read/write request
    pulsador: in std_logic;
    switches: in std_logic_vector(3 downto 0)
  );
end wb_slave_interface_leds;

architecture behavioral of wb_slave_interface_leds is
  signal registro: std_logic_vector(15 downto 0);
  signal registro_m: std_logic_vector(15 downto 0);
  signal en_read: std_logic;
  signal en_write: std_logic;
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
      elsif (clk_i'event and clk_i = '1') then
      act_wb <= next_wb;
    end if;
  end process;

  process(act_wb,stb_i,cyc_i,we_i)
  begin
    case act_wb is
      when stb_in_wait =>
        -- wait for the stb form the master
        if stb_i ='1' and cyc_i = '1' and we_i='0' and addr_i=addr then
          next_wb <= read_data;
        elsif stb_i ='1' and cyc_i = '1' and we_i='1' and addr_i=addr then
          next_wb <= write_data;
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
        next_wb <= stb_in_wait;
    end case;
  end process;

  with act_wb select
  ack_o <=  '1' when send_ack_o,
            '0' when others;

  with act_wb select
  en_read <=  '1' when read_data,
              '0' when others;

  with act_wb select
  en_write <= '1' when write_data,
              '0' when others;
--
-- registers synchronous load
--
  process (clk_i, rst_i)
  begin
     if rst_i='1' then
        registro <= (others => '0');
     elsif clk_i'event and clk_i = '1' then
      if en_write='1' then
        registro <= dat_i;
      else
        registro <= registro;
      end if;
    end if;
  end process;

  process (clk_i, rst_i)
  begin
    if rst_i='1' then
      registro_m <= (others => '0');
    elsif clk_i'event and clk_i = '1' then
      if pulsador='1' then
        registro_m <= dat_i(3 downto 0)*switches & "00000000";
      else
        registro_m <= registro_m;
      end if;
    end if;
  end process;

  process (clk_i, rst_i)
  begin
     if rst_i='1' then
        dat_o <= (others => '0');
     elsif clk_i'event and clk_i = '1' then
      if en_read='1' then
        dat_o <= registro_m;
      end if;
    end if;
  end process;

end behavioral;