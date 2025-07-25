library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--BCD arithmetic 
--
entity coin_reader is
   port (
      coin_sensor : in std_logic_vector(3 downto 0); 
      reset       : in std_logic;
		CLK_50MHz	: in std_logic;					
      BCD_out : buffer std_logic_vector(15 downto 0) := X"0000";     --we need at least $50.00 so 2^12 = 40.96
		LED_OVFL_out : out std_logic_vector(3 downto 0)
	);
end entity coin_reader;
    
architecture rtl of coin_reader is 
	
   type reader_state is ( ACC, OVFL );				--define states to determin output if max is reached
	 
	signal accumulator : std_logic_vector(15 downto 0) := X"0000";
	signal CLK : std_logic;
	
	function BCD_add(										--function adds 2 BCD digits
		ACC_in : in unsigned(15 downto	0);
		VAR_in : in unsigned(15 downto 0)
		)
		return unsigned is
			variable ACC_out : unsigned(15 downto 0);
		
		variable buff : unsigned(3 downto 0) := X"0";
		variable carr : unsigned(0 downto 0) := "0";
		
	begin
		buff := ACC_in(3 downto 0) + VAR_in(3 downto 0); 	--first 4 bits
		if ( buff > X"9" ) then										--if >9, subtract 10 and carry
			buff := buff - X"A";			
			carr := "1";
		else
			carr := "0";
		end if;
		ACC_out(3 downto 0) := buff;								--insert 1st 4 bits
		
		buff := ACC_in(7 downto 4) + VAR_in(7 downto 4);	--next hex pair
		buff := buff + ("000" & carr);							--add carry (will be 0 if none)
		if ( buff > X"9" ) then										--if >9, subtract 10 and carry
			buff := buff - X"A";
			carr := "1";
		else
			carr := "0";
		end if;
		ACC_out(7 downto 4) := buff;								--insert next hex pair
		
		buff := ACC_in(11 downto 8) + VAR_in(11 downto 8);	--next hex pair
		buff := buff + ("000" & carr);							--add carry (will be 0 if none)
		if ( buff > X"9" ) then										--if >9, subtract 10 and carry
			buff := buff - X"A";
			carr := "1";
		else
			carr := "0";
		end if;
		ACC_out(11 downto 8) := buff;								--insert next hex pair
		
		buff := ACC_in(15 downto 12) + VAR_in(15 downto 12);	--next hex pair; this will never hav a carry bc max is X"1500"
		buff := buff + ("000" & carr);	
		ACC_out(15 downto 12) := buff;								--insert next hex pair
		return ACC_out;
	end function BCD_add;
	
begin
	BCD_out <= accumulator;
	Clk_inst : entity work.clk_div 
		generic map (divisor => 62500)
		port map(clock_in => CLK_50MHz, clock_out => CLK);
	
   process( coin_sensor(3 downto 0), reset )					--pos edge detectors on switches runs statements
		variable curr_state : reader_state := ACC;			--var for curr state
		variable prev_sig : std_logic_vector(3 downto 0) := X"0";
		variable sig_dbnc : std_logic_vector(3 downto 0) := X"0";
   begin
      if ( reset = '0' ) then -- reset when dispenser has grabbed value
			accumulator <= X"0000"; 
			curr_state := ACC;
			LED_OVFL_out <= X"0";
		elsif ( CLK'event and CLK = '1' ) then
			if ( coin_sensor(0) = '1' and prev_sig(0) /= coin_sensor(0) ) then
				sig_dbnc(0) := '1';
			elsif ( coin_sensor(1) = '1' and prev_sig(1) /= coin_sensor(1) ) then
				sig_dbnc(1) := '1';
			elsif ( coin_sensor(2) = '1' and prev_sig(2) /= coin_sensor(2) ) then
				sig_dbnc(2) := '1';
			elsif ( coin_sensor(3) = '1' and prev_sig(3) /= coin_sensor(3) ) then
				sig_dbnc(3) := '1';
			else
				sig_dbnc := X"0";
			end if;
			prev_sig := coin_sensor;
			case curr_state is
				when ACC =>              --not overflown
               if ( sig_dbnc(0) = '1' ) then       --on pos edge of Sw(0)
                  accumulator <= std_logic_vector(BCD_add(unsigned(accumulator), X"0005"));			--accumulate BCD acc + $0.05
               elsif ( sig_dbnc(1) = '1' ) then    --Sw(1)
                  accumulator <= std_logic_vector(BCD_add(unsigned(accumulator), X"0010"));			--acc + $0.10
               elsif ( sig_dbnc(2) = '1' ) then    --Sw(2)
                  accumulator <= std_logic_vector(BCD_add(unsigned(accumulator), X"0025"));			--acc + $0.25
               elsif ( sig_dbnc(3) = '1' ) then    --Sw(3)
                  accumulator <= std_logic_vector(BCD_add(unsigned(accumulator), X"0100"));			--acc + $1.00
               elsif ( accumulator >= X"1500" ) then    -- if max, send to overflow state
                  curr_state := OVFL;
					else 
						null;
               end if;
            when OVFL =>            
               if ( sig_dbnc(0) = '1' ) then       --on pos edge of Sw(0)
                  LED_OVFL_out(0) <= '1';											--led(0) on; off after 5ms
               elsif ( sig_dbnc(1) = '1' ) then    --Sw(1)
                  LED_OVFL_out(1) <= '1';											--led(1)
               elsif ( sig_dbnc(2) = '1' ) then    --Sw(2)
                  LED_OVFL_out(2) <= '1';											--led(2)
               elsif ( sig_dbnc(3) = '1' ) then    --Sw(3)
                  LED_OVFL_out(3) <= '1';											--led(3)
					else
						LED_OVFL_out <= X"0" after 100ms;
					end if;
				when others => null;
			end case;
		end if;     
   end process;
	
end architecture rtl;