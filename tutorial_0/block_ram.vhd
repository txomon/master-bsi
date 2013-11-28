library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;  

entity block_ram is 
  generic(
    addr_width: natural := 2;
    data_width: natural := 8);
  port (
    clk : in std_logic; 
    rst: in std_logic;
    pulsa: in std_logic;
    -- do para sacar el contenido del bram hacia fuera 
    do  : out std_logic_vector(data_width-1 downto 0)); 
end block_ram; 
 
architecture arch of block_ram is 
  type ram_type is array (2**(addr_width)-1 downto 0) of std_logic_vector (data_width-1 downto 0); 
  signal ram : ram_type:= (
  0=>x"00",
  1=>x"45",
  2=>x"89",
  3=>x"ff");

  signal a, read_a : std_logic_vector(addr_width-1 downto 0);
  -- si se usa como ram we y di se usan para escribir
  -- en este ejemplo se usa la memoria como rom 
  signal we: std_logic;
  signal di: std_logic_vector(data_width-1 downto 0);
begin 

  memoria_rom: process (clk) 
  begin 
  if (clk'event and clk = '1') then  
    if (we = '1') then 
      ram(conv_integer(a)) <= di; 
    end if; 
    read_a <= a; 
  end if; 
  end process; 

  cont_direc: process (clk)
  begin
  if (clk'event and clk = '1') then  
    if rst='1' then
      a <= (others=>'0');
    elsif pulsa = '1' then
      a <= a + 1;
    end if;
  end if;
  end process; 

  do <= ram(conv_integer(read_a));

end arch;