library IEEE;
use IEEE.std_logic_1164.all;

entity clk_div is 
generic(
	divisor : integer range 1 to 50000000 := 1  );
port(
	clock_in : in std_logic;
	clock_out : buffer std_logic 	);
end clk_div;

architecture clk_div_arch of clk_div is begin
	process(clock_in) is
		variable cnt : integer range 0 to 50000000 := 0;
	begin
		if(clock_in'event and clock_in = '1') then
			cnt := cnt + 1;
			if(cnt = divisor) then
				if(clock_out = '1') then
					clock_out <= '0';
				else clock_out <= '1';
				end if;
				cnt := 0;
			end if;
		end if;
	end process;
end clk_div_arch;
