--------------------------------------------------------------------------------
-- company:
-- engineer:
--
-- create date:   16:05:18 11/27/2013
-- design name:
-- module name:   /home/javier/proyectos/master/master-bsi/ejercicio_3/testbench.vhd
-- project name:  ejercicio_3
-- target device:
-- tool versions:
-- description:
--
-- vhdl test bench created by ise for module: wb_intercon_sh_bus
--
-- dependencies:
--
-- revision:
-- revision 0.01 - file created
-- additional comments:
--
-- notes:
-- this testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  xilinx recommends
-- that these types always be used for the top-level i/o of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture behavior of testbench is

    -- component declaration for the unit under test (uut)

    component wb_intercon_sh_bus
    port(
         pin_reset : in  std_logic;
         pin_clock_50 : in  std_logic;
         pin_leds : out  std_logic_vector(7 downto 0);
         alarm : in std_logic
        );
    end component;


   --inputs
   signal pin_reset : std_logic := '0';
   signal pin_clock_50 : std_logic := '0';
   signal alarm : std_logic := '0';

   --outputs
   signal pin_leds : std_logic_vector(7 downto 0);
   -- no clocks detected in port list. replace pin_clock_50 below with
   -- appropriate port name

   constant pin_clock_50_period : time := 10 ns;

begin

  -- instantiate the unit under test (uut)
   uut: wb_intercon_sh_bus port map (
          alarm => alarm,
          pin_reset => pin_reset,
          pin_clock_50 => pin_clock_50,
          pin_leds => pin_leds
        );

   -- clock process definitions
   pin_clock_50_process :process
   begin
    pin_clock_50 <= '0';
    wait for pin_clock_50_period/2;
    pin_clock_50 <= '1';
    wait for pin_clock_50_period/2;
   end process;


   -- stimulus process
   stim_proc: process
   begin
      pin_reset <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;
      pin_reset <= '0';

      wait for pin_clock_50_period*10;

      -- insert stimulus here

      wait for 2 ms;
      alarm <= '1';
      wait;
   end process;

end;
