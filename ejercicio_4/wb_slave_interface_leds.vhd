--
-------------------------------------------------------------------------------
-- Description    : Interface for two 7 segment display (with memory)
--
-------------------------------------------------------------------------------
-- Entity for wb_slave_interface Unit                                        --
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;

entity wb_slave_interface_leds is
   generic(
      addr: std_logic_vector(3 downto 0):="0001");
    Port (
       --
      -- WISHBONE SIGNALS
      --
      ADDR_I: in std_logic_vector (3 downto 0);

      RST_I:  in  std_logic;      -- WB : Global RESET signal
       ACK_O:  out std_logic;      -- WB : Ack from to the master
      --ADR_I:  in  std_logic_vector(15 downto 0 );-- WB : Adress,
                                    -- not used in this core
        CLK_I:  in  std_logic;      -- WB : Global bus clock
          DAT_I:  in std_logic_vector(15 downto 0 ); -- WB : 16 bits data bus
                          -- input
          DAT_O:  out std_logic_vector(15 downto 0 ); -- WB : 16 bits data bus
                          -- ouput
         STB_I:  in  std_logic;      -- WB : Access qualify from the master
      CYC_I:  in  std_logic;      -- WB : Access qualify
         WE_I:   in  std_logic;      -- WB : Read/write request
      pulsador: in std_logic;
      Switches: in std_logic_vector(3 downto 0)
      --
      -- LEDS OUTPUTS
      --
      --LEDS: out std_logic_vector(7 downto 0)
      );
end wb_slave_interface_leds;

architecture Behavioral of wb_slave_interface_leds is
signal registro: std_logic_vector(15 downto 0);
signal registro_m: std_logic_vector(15 downto 0);
signal en_read: std_logic;
signal en_write: std_logic;
--
-- WISHBONE SLAVE INTERFACE CONTROL STATE MACHINE
--
type wb_state is (stb_in_wait, write_data, read_data, send_ack_o);
signal act_wb : wb_state;
signal next_wb: wb_state;

begin
-- WISHBONE SLAVE INTERFACE CONTROL
ack_control: process (RST_I, CLK_I)
-- declarations
begin
  if RST_I = '1' then
    act_wb <= stb_in_wait;
    elsif (CLK_I'event and CLK_I = '1') then
    act_wb <= next_wb;
  end if;
end process;

process(act_wb,STB_I,CYC_I,WE_I)
begin
    case act_wb is
      when stb_in_wait =>
        -- Wait for the STB form the master
        if STB_I ='1' and CYC_I = '1' and WE_I='0' and ADDR_I=addr then
          next_wb <= read_data;
         elsif STB_I ='1' and CYC_I = '1' and WE_I='1' and ADDR_I=addr then
          next_wb <= write_data;
        else
          next_wb <= stb_in_wait;
        end if;
      when write_data =>
          next_wb <= send_ack_o;
      when read_data =>
          next_wb <= send_ack_o;
        when send_ack_o =>
        -- Send the ack signal
        -- it si possible to do it in read_data state
        next_wb <= stb_in_wait;
      end case;
 end process;

with act_wb select
  ACK_O <= '1' when send_ack_o,
         '0' when others;

with act_wb select
  en_read <= '1' when read_data,
         '0' when others;

with act_wb select
  en_write <= '1' when write_data,
         '0' when others;
--
-- REGISTERS SYNCHRONOUS LOAD
--
process (CLK_I, RST_I)
begin
   if RST_I='1' then
      registro <= (others => '0');
   elsif CLK_I'event and CLK_I = '1' then
    if en_write='1' then
      registro <= DAT_I;
    else
      registro <= registro;
    end if;
  end if;
end process;

process (CLK_I, RST_I)
begin
   if RST_I='1' then
      registro_m <= (others => '0');
   elsif CLK_I'event and CLK_I = '1' then
    if pulsador='1' then
      registro_m <= DAT_I(3 downto 0)*Switches & "00000000";
    else
      registro_m <= registro_m;
    end if;
  end if;
end process;

process (CLK_I, RST_I)
begin
   if RST_I='1' then
      DAT_O <= (others => '0');
   elsif CLK_I'event and CLK_I = '1' then
    if en_read='1' then
      DAT_O <= registro_m;
    end if;
  end if;
end process;

end Behavioral;