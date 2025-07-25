library IEEE;
use IEEE.std_logic_1164.all;

entity Counter is port (
	clock : in std_logic;
	hex_out : out std_logic_vector(6 downto 0)
	);
end Counter;

architecture Counter of Counter is
	type state is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9);
	signal clk_2hz : std_logic;
	signal num_bus : std_logic_vector(3 downto 0);
begin
	clk_divider : entity work.clk_div port map(clock, clk_2hz);
	hex_display : entity work.HexDisplay port map(num_bus, hex_out);
	process(clk_2hz) is 
		variable curr_state : state := s0;
		variable next_state : state := s1;
	begin
		if(clk_2hz'event and clk_2hz = '1') then
			curr_state := next_state;
		end if;
		
		case curr_state is
			when s0 =>
				num_bus <= "0000";
				next_state := s1;
			when s1 =>
				num_bus <= "0001";
				next_state := s2;
			when s2 =>
				num_bus <= "0010";
				next_state := s3;
			when s3 =>
				num_bus <= "0011";
				next_state := s4;
			when s4 =>
				num_bus <= "0100";
				next_state := s5;
			when s5 =>
				num_bus <= "0101";
				next_state := s6;
			when s6 =>
				num_bus <= "0110";
				next_state := s7;
			when s7 =>
				num_bus <= "0111";
				next_state := s8;
			when s8 =>
				num_bus <= "1000";
				next_state := s9;
			when s9 =>
				num_bus <= "1001";
				next_state := s0;
			when others =>
				curr_state := s0;
				num_bus <= "0000";
				next_state := s1;
		end case;
	end process;
end;