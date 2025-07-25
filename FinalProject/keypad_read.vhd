library ieee;

use ieee.std_logic_1164.all;

use ieee.numeric_std.all;


entity keypad_read is port(

        clock_in: in std_logic;                                                                        -- clock, divided to some amount

        read_key : out std_logic_vector(3 downto 0);                -- bcd output for key pressed

        latch : buffer std_logic;                                  -- boolean to decide when a new output can be used

        rows: inout std_logic_vector(3 downto 0);                        -- rows, to be made into result

        columns: inout std_logic_vector(2 downto 0));        -- columns, to be made into result

end keypad_read;


architecture keypad_arch of keypad_read is

        signal key_bcd : std_logic_vector(3 downto 0);                        -- the bcd value of the key, output when appropriate

        signal read_columns : std_logic_vector(2 downto 0);        -- current read columns, to be combined into "result"

        signal read_rows : std_logic_vector(3 downto 0);                -- current read rows, to be combined into "result"

        signal result : std_logic_vector(6 downto 0);                        -- result, to be decoded into an int output

        signal current_state : std_logic;                                                        -- state is 0 when reading rows, 1 when columns

begin

        decoder: entity work.result_decode

                port map (result, key_bcd);                                                                -- decoder entity to output a bcd for the key

                

        rows <= "ZZZZ" when current_state = '0' else "0000";        -- ensure that rows and columns are ready to be read

        columns <= "ZZZ" when current_state = '1' else "000";        --         depending on the current state
		  
		  
        process(clock_in) is

        begin

                if(clock_in'event and clock_in = '1') then
                        case current_state is

                                when '0' =>

                                        read_rows <= rows;                                        -- read rows to a register

                                        current_state <= '1';                                -- change state to read columns during next clock edge

                                when '1' =>

                                        read_columns <= columns;                        -- read columns to a register

                                        current_state <= '0';                                -- change state to read rows during next clock edge

                                when others =>

                                        current_state <= '0';                                -- if any problems, default state to read rows next clock edge

                        end case;

                        result <= read_columns & read_rows;                -- result of the current cycle of reading rows and columns

                        if(key_bcd = "1111") then                                        -- if result is readble (no transition states or repeat reads),

                                latch <= '1';                                                                --         then set latch to 1 to get ready to output

                        elsif(latch = '1') then                                                -- if latch is 1, output value and then set latch to zero

                                read_key <= key_bcd;                                                --         to prepare for next read cycles

                                latch <= '0';

                        end if;

                end if;

        end process;

end keypad_arch;