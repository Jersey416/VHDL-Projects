library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM_Module2 is port (
	r_w_sw 		: in std_logic;
	nibble_sw 	: in std_logic;
	chip_sel		: in std_logic;
	init			: in std_logic;
	addr_bus 	: in std_logic_vector(3 downto 0);
	data_in 		: in std_logic_vector(3 downto 0);
	hex_0			: out std_logic_vector(6 downto 0);
	hex_1 		: out std_logic_vector(6 downto 0)
	);
end RAM_Module2;

architecture RAM_Module2 of RAM_Module2 is

	type byte_block is array(natural range <>) of std_logic_vector(7 downto 0);
	
	signal data7_4 : std_logic_vector(3 downto 0);
	signal data3_0 : std_logic_vector(3 downto 0);
	signal ram_block : byte_block(15 downto 0);
	
begin
	
	dual_display : entity work.DualHexDisplay port map (	Sw7_4 => data7_4, 
																			Sw3_0 => data3_0, 
																			hexOut0 => hex_0, 
																			hexOut1 => hex_1);
	process(r_w_sw, nibble_sw, chip_sel, init, addr_bus, data_in) is
	begin
		if(init='0') then
			ram_block(0)(7 downto 0) <= x"00";
			ram_block(1)(7 downto 0) <= x"00";
			ram_block(2)(7 downto 0) <= x"00";
			ram_block(3)(7 downto 0) <= x"00";
			ram_block(4)(7 downto 0) <= x"00";
			ram_block(5)(7 downto 0) <= x"00";
			ram_block(6)(7 downto 0) <= x"00";
			ram_block(7)(7 downto 0) <= x"00";
			ram_block(8)(7 downto 0) <= x"00";
			ram_block(9)(7 downto 0) <= x"00";
			ram_block(10)(7 downto 0) <= x"00";
			ram_block(11)(7 downto 0) <= x"00";
			ram_block(12)(7 downto 0) <= x"00";
			ram_block(13)(7 downto 0) <= x"00";
			ram_block(14)(7 downto 0) <= x"00";
			ram_block(15)(7 downto 0) <= x"00";
		elsif(chip_sel'event and chip_sel='0') then
			if(r_w_sw = '1') then
				if(nibble_sw = '0') then
					ram_block(to_integer(unsigned(addr_bus)))(3 downto 0) <= data_in;
				elsif(nibble_sw = '1') then
					ram_block(to_integer(unsigned(addr_bus)))(7 downto 4) <= data_in;
				end if;
			elsif(r_w_sw = '0') then
				data7_4 <= ram_block(to_integer(unsigned(addr_bus)))(7 downto 4);
				data3_0 <= ram_block(to_integer(unsigned(addr_bus)))(3 downto 0);
			end if;
		end if;
	end process;
	
end RAM_Module2;