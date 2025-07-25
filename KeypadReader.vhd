library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity KeypadReader is
	port (
		CLK_50MHz : in std_logic;
		rows : inout std_logic_vector(3 downto 0);
		cols : inout std_logic_vector(2 downto 0);
		hex_out : out std_logic_vector(6 downto 0)
	);
end entity KeypadReader;

architecture rtl of KeypadReader is

	type state is (read_row, read_col);

	signal row_cat_col : std_logic_vector(6 downto 0); 
   signal num_out : std_logic_vector(3 downto 0);  --bin num out
	signal CLK : std_logic;
	
	
begin
	HEX_inst : entity work.HexDisplay 
		port map(bin_num_in => num_out, hex_bits_out => hex_out);
	Clk_inst : entity work.clk_div 
		generic map (divisor => 12500000)
		port map(clock_in => CLK_50MHz, clock_out => CLK);
	
	num_out <= 	"0001" when row_cat_col = "1110110" else	--1
					"0010" when row_cat_col = "1110101" else 	--2
					"0011" when row_cat_col = "1110011" else	--3
					"0100" when row_cat_col = "1101110" else	--4
					"0101" when row_cat_col = "1101101" else	--5
					"0110" when row_cat_col = "1101011" else	--6
					"0111" when row_cat_col = "1011110" else	--7
					"1000" when row_cat_col = "1011101" else	--8
					"1001" when row_cat_col = "1011011" else	--9
					"1010" when row_cat_col = "0111110" else 	--*
					"0000" when row_cat_col = "0111101" else	--0
					"1011" when row_cat_col = "0111011" else	--#
					"1111";		--__
					
	process( CLK ) 
		variable curr_state : state := read_row;
	begin
		
		if (CLK'event and CLK = '1') then	--on pos edge
			case curr_state is
				when read_row =>			--if read row state
			
					row_cat_col(6 downto 3) <= rows;    	--store rows (4bits)
					
				when read_col =>			--if read col state
					   
					row_cat_col(2 downto 0) <= cols;   	--store cols (3bits)	
			end case;
		elsif (CLK'event and CLK = '0') then			--on negative edge
			case curr_state is
				when read_row =>							--if we just read rows
				
					rows <= "0000";                	--GND rows
					cols <= "ZZZ"; 					  	--set cols for reading
					
					curr_state := read_col;			  	--go to read_col state
					
				when read_col =>							--if we read cols
				
					cols <= "000";                  	--GND cols
					rows <= "ZZZZ";						--set rows for reading
					
					curr_state := read_row;				--go to read_row state
	
			end case;
		end if;
	end process;
end architecture rtl;