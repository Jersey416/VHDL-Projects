library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM_Module is port (
	r_w_sw 		: in std_logic;
	nibble_sw 	: in std_logic;
	chip_sel		: in std_logic;
	addr_bus 	: in std_logic_vector(3 downto 0);
	data_in 		: in std_logic_vector(3 downto 0);
	hex_0			: out std_logic_vector(6 downto 0);
	hex_1 		: out std_logic_vector(6 downto 0)
	);
end RAM_Module;

architecture RAM_Module of RAM_Module is

	type byte_block is array(natural range <>) of std_logic_vector(7 downto 0);
	
	signal data7_4 : std_logic_vector(3 downto 0);
	signal data3_0 : std_logic_vector(3 downto 0);
	signal ram_block : byte_block(15 downto 0);
	
begin
	
	dual_display : entity work.DualHexDisplay port map (	Sw7_4 => data7_4, 
																			Sw3_0 => data3_0, 
																			hexOut0 => hex_0, 
																			hexOut1 => hex_1);
	process(r_w_sw, nibble_sw, chip_sel, addr_bus, data_in) is
	begin
		
		if(chip_sel'event and chip_sel='0') then
			if(r_w_sw = '1') then
				if(nibble_sw = '0') then
					ram_block(to_integer(unsigned(addr_bus)))(3 downto 0) <= data_in;
				elsif(nibble_sw = '1') then
					ram_block(to_integer(unsigned(addr_bus)))(3 downto 0) <= data_in;
				end if;
			elsif(r_w_sw = '0') then
				data7_4 <= ram_block(to_integer(unsigned(addr_bus)))(7 downto 4);
				data3_0 <= ram_block(to_integer(unsigned(addr_bus)))(3 downto 0);
			end if;
		end if;
	end process;
	
end RAM_Module;