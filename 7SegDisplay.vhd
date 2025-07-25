library IEEE;
use IEEE.std_logic_1164.all;

entity HexDisplay is port(
	bin_num_in : in std_logic_vector(3 downto 0);
	hex_bits_out : buffer std_logic_vector(6 downto 0)	);
end HexDisplay;

architecture HexLogic of HexDisplay is begin
	hex_bits_out <=	"1000000" when bin_num_in="0000" else --0
					"1111001" when bin_num_in="0001" else --1
					"0100100" when bin_num_in="0010" else --2
					"0110000" when bin_num_in="0011" else --3
					"0011001" when bin_num_in="0100" else --4
					"0010010" when bin_num_in="0101" else --5
					"0000010" when bin_num_in="0110" else --6
					"1111000" when bin_num_in="0111" else --7
					"0000000" when bin_num_in="1000" else --8
					"0011000" when bin_num_in="1001" else --9
					"0111100" when bin_num_in="1010" else --* (A)
					"0001001" when bin_num_in="1011" else --# (B)
					"1000110" when bin_num_in="1100" else --C
					"0100001" when bin_num_in="1101" else	--D
					"0000110" when bin_num_in="1110" else	--E
					"1111111" when bin_num_in="1111";		--blank (F))
end;

