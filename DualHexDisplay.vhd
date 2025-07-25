library IEEE;
use IEEE.std_logic_1164.all;
entity DualHexDisplay is port 
	(
	Sw3_0, Sw7_4 : in std_logic_vector(3 downto 0);
	HexOut0, HexOut1 : buffer std_logic_vector(6 downto 0)	
	);
end DualHexDisplay;

architecture DualHexLogic of DualHexDisplay is
begin
	Hex0 : entity work.HexDisplay port map(Sw3_0,HexOut0);
	Hex1 : entity work.HexDisplay port map(Sw7_4,HexOut1);
end;