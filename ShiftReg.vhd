library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ShiftReg is port(
	usr_key_in		: in std_logic_vector(3 downto 0);	--4 bit user input
	chip_sel			: in std_logic;							--acts as clock
	reset				: in std_logic;
	unlocked_led 	: out std_logic	);
end ShiftReg;

architecture ShiftReg of ShiftReg is
	type state is (locked, unlocked);
	type reg_blk_4bit is array(natural range <>) of std_logic_vector(3 downto 0);	--we have 4 bits, all of which will shifted to the next 4 bits
	signal sh_regs : reg_blk_4bit(2 downto 0);	--so we need 4x 3-bit shift regs
begin
	
	process(usr_key_in, chip_sel, reset, sh_regs) is
		variable curr_state : state := locked;                       
	begin
		if(reset = '0') then	--if reset then shift in 0 & ensure led<=0 && its locked
			sh_regs <= sh_regs(1 downto 0) & x"0";
			unlocked_led <= '0';
			curr_state := locked;
			
		elsif(chip_sel'event and chip_sel='0') then
			sh_regs <= sh_regs(1 downto 0) & usr_key_in;
			
		elsif(chip_sel'event and chip_sel='1') then
			case curr_state is
				when locked =>												--when locked, shift in new input
					if(sh_regs(2) = x"4" and sh_regs(1) = x"7" and sh_regs(0) = x"C") then --if seq is correct, unlock & turn on led
						unlocked_led <= '1';
						curr_state := unlocked;
					end if;
				when unlocked =>											--when unlocked, do not change until reset or "0000" is input; then reset
					if(usr_key_in = "0000") then
							unlocked_led <= '0';
							curr_state := locked;

					end if;
			end case;
		end if;
	end process;
end ShiftReg;