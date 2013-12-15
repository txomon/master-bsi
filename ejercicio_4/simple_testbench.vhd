--------------------------------------------------------------------------------
-- company:
-- engineer:
--
-- create date:   22:27:33 12/15/2013
-- design name:
-- module name:   /home/javier/proyectos/master/master-bsi/ejercicio_4/simple_testbench.vhd
-- project name:  ejercicio_4
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

entity simple_testbench is
end simple_testbench;

architecture behavior of simple_testbench is

    -- component declaration for the unit under test (uut)

    component wb_intercon_sh_bus
    port(
         pin_reset : in  std_logic;
         pin_clock_50 : in  std_logic;
         pin_leds : out  std_logic_vector(7 downto 0);
         m1trigger : in  std_logic;
         data : in  std_logic_vector(3 downto 0);
         m2trigger : in  std_logic;
         s1trigger : in  std_logic
        );
    end component;


   --inputs
   signal pin_reset : std_logic := '0';
   signal pin_clock_50 : std_logic := '0';
   signal m1trigger : std_logic := '0';
   signal data : std_logic_vector(3 downto 0) := (others => '0');
   signal m2trigger : std_logic := '0';
   signal s1trigger : std_logic := '0';

   --outputs
   signal pin_leds : std_logic_vector(7 downto 0);
   -- no clocks detected in port list. replace pin_clock_50 below with
   -- appropriate port name

   constant pin_clock_50_period : time := 10 ns;

begin

  -- instantiate the unit under test (uut)
   uut: wb_intercon_sh_bus port map (
          pin_reset => pin_reset,
          pin_clock_50 => pin_clock_50,
          pin_leds => pin_leds,
          m1trigger => m1trigger,
          data => data,
          m2trigger => m2trigger,
          s1trigger => s1trigger
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
      -- hold reset state for 100 ns.
      wait for 100 ns;  

      wait for pin_clock_50_period*50;

      -- insert stimulus here


      wait;
   end process;

end;
