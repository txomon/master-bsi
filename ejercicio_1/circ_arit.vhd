library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;


entity circ_arit is
	generic(
		width: natural := 32);
   port (
   	clk, reset, en: in std_logic;
		a, b, c, d: in std_logic_vector(width-1 downto 0);
		aritout: out std_logic_vector(width-1 downto 0));
end circ_arit;

architecture arch of circ_arit is
signal areg, breg, creg, dreg: std_logic_vector(width-1 downto 0);
signal s1, s2, s3: std_logic_vector(width-1 downto 0);
begin
abcdreg: process (clk)
begin
   if clk'event and clk='1' then
		if reset='1' then
			areg <= (others => '0');
			breg <= (others => '0');
			creg <= (others => '0');
			dreg <= (others => '0');
   	elsif (en='1') then 
			areg <= a;
			breg <= b;
			creg <= c;
			dreg <= d;
   	end if;
   end if;
end process;
s1 <= areg + breg;
s2 <= creg + dreg;
s3 <= s1 + s2;
aritoutreg: process (clk)
begin
   if clk'event and clk='1' then
		if reset='1' then
			aritout <= (others => '0');
   	elsif (en='1') then 
			aritout <= s3;
   	end if;
   end if;
end process;
end arch;
