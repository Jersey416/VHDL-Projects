LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.numeric_std.all; 

Entity clk_div is
	generic
		(cnt_max: integer := 5500500);
		port
		(clock_in: std_logic;
		clock_out: out std_logic);
	end clk_div;
	
	architecture clk_div_arch of clk_div is
	begin
		process(clock_in) is
			variable cntr : integer range 0 to cnt_max;
			variable tog : std_logic;
		begin
			if(clock_in'event AND clock_in = '1') then
				cntr := cntr + 1;
				if(cntr = cnt_max) then
					cntr := 0;
					
					tog := not tog;
				end if;
			end if;
			clock_out <= tog;
		end process;
	end clk_div_arch;