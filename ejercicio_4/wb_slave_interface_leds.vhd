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

entity wb_slave_interface_leds is
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
    dat_i :in std_logic_vector(15 downto 0); -- wb : 16 bits data bus input
    dat_o :in std_logic_vector(15 downto 0) -- wb : 16 bits data bus output
  );
end wb_slave_interface_leds;

architecture behavioral of wb_slave_interface_leds is
  signal en_reg: std_logic;
  --
  -- wishbone slave interface control state machine
  --
  type wb_state is (stb_in_wait, write_data, send_ack_o);
  signal act_wb, next_wb : wb_state;
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
        if stb_i ='1' and cyc_i = '1' and we_i='1' and adr_i = address then
          next_wb <= write_data;
        else
          next_wb <= stb_in_wait;
        end if;
      when write_data =>
        next_wb <= send_ack_o;
      when send_ack_o =>
        -- send the ack signal
        -- it si possible to do it in write_data state
        next_wb <= stb_in_wait;
    end case;
  end process;

  with act_wb select
  ack_o <= '1' when send_ack_o,
         '0' when others;

  with act_wb select
  en_reg <= '1' when write_data,
         '0' when others;
  --
  -- registers synchronous load
  --
  process (clk_i, rst_i)
  begin
    if rst_i='1' then
      leds <= (others => '0');
    elsif clk_i'event and clk_i = '1' then
      if en_reg='1' then
        leds <= dat_i(7 downto 0);
      end if;
    end if;
  end process;

end behavioral;