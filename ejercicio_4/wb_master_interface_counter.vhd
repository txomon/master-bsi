--
-------------------------------------------------------------------------------
-- Description    : It writes a squence of numbers to an slave.
--
-------------------------------------------------------------------------------
-- Entity for wb_master_interface Unit                                    --
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;

entity wb_master_interface_counter is
  generic (count_module_factor : integer := 20);       -- counter prescaler
    Port (
         --
        -- WISHBONE SIGNALS
        --
        RST_I:  in  std_logic;    -- WB : Global RESET signal
         ACK_I:  in std_logic;    -- WB : Ack from the slave
        --ADR_O:  out  std_logic_vector(15 downto 0 );   -- WB : Adresss
                          -- not used in this core
            CLK_I:  in  std_logic;    -- WB : Global bus clock
          DAT_I:  in  std_logic_vector(15 downto 0 );     -- WB : 16 bits
                          -- data bus input
            DAT_O:  out  std_logic_vector(15 downto 0 );   -- WB : 16 bits
                          -- data bus output
            STB_O:  out  std_logic;    -- WB : Access qualify
            WE_O:   out  std_logic;    -- WB : Read/write request
            CYC_O:   out  std_logic;  -- WB : Bus request to the arbitrer
            GNT_I:   in  std_logic;    -- WB : Bus grant from the arbitrer
        Switches: in std_logic_vector (3 DOWNTO 0);
        pulsador: in std_logic
      );
end wb_master_interface_counter;

architecture struct of wb_master_interface_counter is
--
--  INTERNAL SIGNALS
--
constant count_module : INTEGER := 1*count_module_factor;    -- Simulation
--constant count_module : INTEGER := 1000000*count_module_factor;  -- Prototype
-- one master transfer each Tclk * 1000000*count_module_factor
-- if Tclk = 20 ns => one transfer each 0,4 s if count_module_factor = 20
signal COUNT: INTEGER range 0 to count_module;        -- Prescaler value
                                      -- for the count value
--signal TEMPORAL_REGISTER : INTEGER range 0 to 64;      -- Temporal register to store
                                      -- the data for the slave
signal TEMPORAL_REGISTER_CE : std_logic;            -- Clock enable for the temporal
                                      -- register
signal INIT_TRANSFER_NODE : std_logic;              -- Inits the transfer to the slave
signal DATA_IN_NODE: std_logic_vector(15 downto 0);   -- INTERNAL DATA IN
                                    -- (Removed by synthesis)
signal DATA_OUT_NODE: std_logic_vector(15 downto 0);  -- INTERNAL DATA OUT
                                    -- (Removed by synthesis)
-- makes easier architecture with more than one masters
signal STB_O_OUT : std_logic;              
signal WE_O_OUT : std_logic;              
signal ACK_I_IN : std_logic;              

--
-- WISHBONE MASTER INTERFACE CONTROL STATE MACHINE
--

type wb_state is (init_transfer_wait, ack_wait);
signal act_wb : wb_state;
signal next_wb: wb_state;


begin

WE_O <= WE_O_OUT when GNT_I='1' else '0';
STB_O <= STB_O_OUT when GNT_I='1' else '0';
ACK_I_IN <= ACK_I when GNT_I='1' else '0';

  -- WISHBONE BUS COMPOSITION
  DATA_IN_NODE <= DAT_I(15 downto 0);
  DAT_O <= DATA_OUT_NODE when (WE_O_OUT ='1' and
  STB_O_OUT ='1' and GNT_I='1') else (others => '0');
--
-- WISHBONE MASTER INTERFACE CONTROL
--
master_control: process (RST_I, CLK_I)
begin
  if RST_I = '1' then
    act_wb <= init_transfer_wait;
    elsif (CLK_I'event and CLK_I = '1') then
    act_wb <= next_wb;
  end if;
end process;

process(act_wb,INIT_TRANSFER_NODE,ACK_I_IN)
begin
    case act_wb is
      when init_transfer_wait =>
        -- The state machine waits for the internal
        -- INIT_TRANSFER_NODE request from the internal logic.
        -- Then performs an access to the WB bus.
        if INIT_TRANSFER_NODE ='1' then
          next_wb <= ack_wait;
         else
          next_wb <= init_transfer_wait;
        end if;

      when ack_wait =>
        -- In this state the STB_OUT and the CYC_O
        --  are set. The STB_OUT is written to the  wb
        -- when the GNT_I='1'. The state changes when
        -- the ACK from the slave is received.
        if ACK_I_IN ='1' then
          next_wb <= init_transfer_wait;
        else
          next_wb <= ack_wait;
        end if;
      end case;
 end process;

with act_wb select
  STB_O_OUT <= '1' when ack_wait,
        '0' when others;

with act_wb select
  CYC_O <= '1' when ack_wait,
        '0' when others;

  WE_O_OUT <= '1';

  
--
-- TEMPORAL COUNTER PRESCALER
--

process (CLK_I, RST_I)
begin
   if RST_I='1' then
      TEMPORAL_REGISTER_CE <= '0';
   elsif CLK_I'event and CLK_I = '1' then
      if pulsador='1' then
      TEMPORAL_REGISTER_CE <= '1';
      else
      TEMPORAL_REGISTER_CE <= '0';
      end if;
   end if;
end process;

--
-- TEMPORAL COUNTER (DATA TO TRANSFER TO SLAVE)
--

process (CLK_I, RST_I)
begin
   if RST_I='1' then
    -- RESET VALUES
      DATA_OUT_NODE <= (others=>'0');
    INIT_TRANSFER_NODE <= '0';
   elsif CLK_I'event and CLK_I='1' then
    -- INIT THE TRANSFERENCE
    if TEMPORAL_REGISTER_CE='1' then
      INIT_TRANSFER_NODE <= '1';
      DATA_OUT_NODE (3 DOWNTO 0) <= Switches;
      DATA_OUT_NODE (15 DOWNTO 4) <= (others=>'0');
    else
      INIT_TRANSFER_NODE <= '0';
      DATA_OUT_NODE <= DATA_OUT_NODE;
    end if;
  end if;
end process;
--
-- COBINATIONAL ASSIGMENTS
--
end struct;