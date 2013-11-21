--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:56:22 11/21/2013
-- Design Name:   
-- Module Name:   /home/javier/proyectos/master/master-bsi/ejercicio_2/tb.vhd
-- Project Name:  ejercicio_2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: wb_intercon_p2p
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb IS
END tb;
 
ARCHITECTURE behavior OF tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT wb_intercon_p2p
    PORT(
         pin_reset : IN  std_logic;
         pin_clock_50 : IN  std_logic;
         pin_leds : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal pin_reset : std_logic := '0';
   signal pin_clock_50 : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal pin_leds : std_logic_vector(7 downto 0);
   -- No clocks detected in port list. Replace clk below with 
   -- appropriate port name 
 
   constant clk_period : time := 1 s;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: wb_intercon_p2p PORT MAP (
          pin_reset => pin_reset,
          pin_clock_50 => pin_clock_50,
          pin_leds => pin_leds
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   pin_clock_50 <= clk;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
