--
-------------------------------------------------------------------------------
-- description    : it writes a squence of numbers to an slave. 
--                  
-------------------------------------------------------------------------------
-- entity for wb_master_interface unit 		                       			  --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;

entity wb_master_interface_counter is
	generic (count_module_factor : integer := 20); 			-- counter prescaler
    port (  
	 			--
				-- wishbone signals
				--
				rst_i:  in  std_logic;		-- wb : global reset signal
	 			ack_i:  in std_logic;		-- wb : ack from the slave
				--adr_o:  out  std_logic_vector(15 downto 0 ); 	-- wb : adresss
													-- not used in this core
	        	clk_i:  in  std_logic;		-- wb : global bus clock
  				dat_i:  in  std_logic_vector(15 downto 0 ); 		-- wb : 16 bits 
													-- data bus input
          	dat_o:  out  std_logic_vector(15 downto 0 ); 	-- wb : 16 bits 
													-- data bus output
          	stb_o:  out  std_logic;		-- wb : access qualify 
          	we_o:   out  std_logic;		-- wb : read/write request
          	cyc_o:   out  std_logic;	-- wb : bus request to the arbitrer 
          	gnt_i:   in  std_logic		-- wb : bus grant from the arbitrer
			);
end wb_master_interface_counter;

architecture struct of wb_master_interface_counter is
--
--	internal signals
--
constant count_module : integer := 100*count_module_factor;		-- simulation
--constant count_module : integer := 1000000*count_module_factor;	-- prototype
-- one master transfer each tclk * 1000000*count_module_factor
-- if tclk = 20 ns => one transfer each 0,4 s if count_module_factor = 20
signal count: integer range 0 to count_module;				-- prescaler value 
																			-- for the count value
signal temporal_register : integer range 0 to 64;			-- temporal register to store 
																			-- the data for the slave
signal temporal_register_ce : std_logic;						-- clock enable for the temporal 
																			-- register
signal init_transfer_node : std_logic;							-- inits the transfer to the slave
signal data_in_node: std_logic_vector(15 downto 0); 	-- internal data in 
																		-- (removed by synthesis)
signal data_out_node: std_logic_vector(15 downto 0);	-- internal data out 
																		-- (removed by synthesis)
-- makes easier architecture with more than one masters
signal stb_o_out : std_logic;							
signal we_o_out : std_logic;							
signal ack_i_in : std_logic;							

--
-- wishbone master interface control state machine
--

type wb_state is (init_transfer_wait, ack_wait); 
signal act_wb : wb_state;
signal next_wb: wb_state;


begin

we_o <= we_o_out when gnt_i='1' else '0';
stb_o <= stb_o_out when gnt_i='1' else '0';
ack_i_in <= ack_i when gnt_i='1' else '0';

	-- wishbone bus composition
	data_in_node <= dat_i(15 downto 0);
	dat_o <= data_out_node when (we_o_out ='1' and 
	stb_o_out ='1' and gnt_i='1') else (others => '0');
-- 
-- wishbone master interface control
--
master_control: process (rst_i, clk_i)
begin  
	if rst_i = '1' then
		act_wb <= init_transfer_wait;
  	elsif (clk_i'event and clk_i = '1') then
		act_wb <= next_wb;
	end if;
end process;

process(act_wb,init_transfer_node,ack_i_in)
begin
		case act_wb is
			when init_transfer_wait =>
				-- the state machine waits for the internal
				-- init_transfer_node request from the internal logic.
				-- then performs an access to the wb bus.
				if init_transfer_node ='1' then
					next_wb <= ack_wait;
			 	else
					next_wb <= init_transfer_wait;
				end if;

			when ack_wait =>
				-- in this state the stb_out and the cyc_o
				--	are set. the stb_out is written to the	wb
				-- when the gnt_i='1'. the state changes when
				-- the ack from the slave is received.
				if ack_i_in ='1' then
					next_wb <= init_transfer_wait;
				else
					next_wb <= ack_wait;
				end if;
	  	end case;
 end process;

with act_wb select
	stb_o_out <= '1' when ack_wait,
				'0' when others;

with act_wb select
	cyc_o <= '1' when ack_wait,
				'0' when others;

	we_o_out <= '1';

	
--
-- temporal counter prescaler
--
 
process (clk_i, rst_i) 
begin
   if rst_i='1' then 
      count <= 0;
   elsif clk_i'event and clk_i = '1' then
		count <= count + 1;
      if count=count_module-1 then
			count <= 0;
			temporal_register_ce <= '1';
      else 
			temporal_register_ce <= '0';
      end if;
   end if;
end process;

--
-- temporal counter (data to transfer to slave)
--
 
process (clk_i, rst_i) 
begin
   if rst_i='1' then
		-- reset values 
      temporal_register <= 0;
		init_transfer_node <= '0';
   elsif clk_i'event and clk_i='1' then
		-- init the transference when the value changes
		if temporal_register_ce='1' then
			init_transfer_node <= '1';
			-- only count until 64
	      if temporal_register = 64 then
				temporal_register <= 0;
			else
				temporal_register <= temporal_register + 1;
			end if;
		else
			init_transfer_node <= '0';
			temporal_register <= temporal_register;
		end if;
	end if;
end process;
--
-- cobinational assigments
--
data_out_node <= conv_std_logic_vector (temporal_register, 16); 
end struct;