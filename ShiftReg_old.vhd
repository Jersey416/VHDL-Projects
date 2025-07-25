library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ShiftReg is port(
	usr_key_in		: in std_logic_vector(3 downto 0);
	chip_sel			: in std_logic;
	reset				: in std_logic;
	unlocked_led 	: out std_logic	);
end ShiftReg;

architecture ShiftReg of ShiftReg is
	type state is (locked, unlocked);
	signal shiftR : std_logic_vector(2 downto 0);
begin
	
	process(usr_key_in, chip_sel, reset, shiftR) is
		variable curr_state : state := locked;
	begin
		if(reset = '0') then
			shiftR <= shiftR(1 downto 0) & '0';
			unlocked_led <= '0';
			curr_state := locked;
		elsif(chip_sel'event and chip_sel='0') then
			case curr_state is
				when locked =>
			
					if(shiftR(0) = '0' and usr_key_in = x"4") then
						shiftR <= shiftR(1 downto 0) & '1';
						
					elsif(shiftR(1 downto 0) = "01" and usr_key_in = x"7") then
						shiftR <= shiftR(1 downto 0) & '1';
						
					elsif(shiftR(2 downto 0) = "011" and usr_key_in = x"C") then
						shiftR <= shiftR(1 downto 0) & '1';
						curr_state := unlocked;
						unlocked_led <= '1';
						
					else
						shiftR <= shiftR(1 downto 0) & '0';
						
					end if;
				when unlocked =>
					if(usr_key_in = "0000") then
							unlocked_led <= '0';
							curr_state := locked;
					else
							unlocked_led <= '1';
					end if;
			end case;
		end if;
	end process;
end ShiftReg;