library ieee;

use ieee.std_logic_1164.all;

use ieee.numeric_std.all;


entity keypad_ram is port(

        clock_in : in std_logic;                                      -- for process; will be predevided in final product

        reset : in std_logic;                                                                                -- simulates power on, resets all values

		  RefundReset : in std_logic;   -- reset that also occours on a refund
		  
        rows : inout std_logic_vector(3 downto 0);                        -- row and column inout, shared with reader component

        columns : inout std_logic_vector(2 downto 0);                --         needs to be here to be included as input for reader
		  
		  item_price : buffer std_logic_vector(11 downto 0);                        -- price of item, derived from location and ram
		  
        balance : in std_logic_vector(15 downto 0);                                -- balance value

		  ShowBalance : in std_logic;  													-- '1' for refunding to show balance on 7 seg
		  
		  not_enough : in std_logic;
		  
        output1 : out std_logic_vector(6 downto 0);

        output2 : out std_logic_vector(6 downto 0);                        -- 7seg values, for the 6 displays used (left to right)

        output3 : out std_logic_vector(6 downto 0);

        output4 : out std_logic_vector(6 downto 0);

        output5 : out std_logic_vector(6 downto 0);

        output6 : out std_logic_vector(6 downto 0)
		  );

end keypad_ram;

        

architecture keypad_arch of keypad_ram is

        signal read_key : std_logic_vector(3 downto 0);                -- bcd output from reader component

        signal item_loc : std_logic_vector(7 downto 0);                -- location of item to be displayed

        signal latch : std_logic;                                      -- used to know when to accept key readings

        signal mtn_price : std_logic_vector(11 downto 0);              -- new price to be written in to ram

        signal bal_mode : std_logic;       -- '1' when displaying balance

        signal mtn_mode : std_logic;                                   -- '1' when displaying maintenance prices

        signal price_write : std_logic;                                -- '1' when writing price to ram

        type ctl_state is (price_state, bal_state, mtn_state);

        signal display_state : ctl_state := price_state;                        -- signal for state of displays

begin


        reader : entity work.keypad_read

                port map(clock_in, read_key, latch, rows, columns);                -- outputs BCD for the pressed key

        price_value_ram : entity work.ram

                port map(item_loc, item_price, mtn_price, price_write, clock_in, reset);        -- read/write, has item prices

        display_price_item : entity work.displays

                port map(item_loc, item_price, balance, bal_mode, mtn_price, mtn_mode, not_enough, clock_in,

                output1, output2, output3, output4, output5, output6);        -- displays item location and price on 7segs

        

        bal_mode <= '1' when display_state = bal_state or ShowBalance = '1' else '0';

        mtn_mode <= '1' when display_state = mtn_state else '0';

        

        process(clock_in, reset, refundreset) is

                variable location_var : std_logic_vector(7 downto 0);        -- \

                variable mtn_reg : std_logic_vector(11 downto 0);                -- variables to update signals synchronously

                variable balance_var : std_logic_vector(15 downto 0);        -- /

                variable price_write_var : std_logic;                                                --

                variable odd_press : std_logic := '0';                                                -- keeps track of alternative presses
					 
					 variable rstwait : std_logic := '0';				-- Prevents display from changing without reset

        begin

                if(reset = '0') then

                        display_state <= price_state;                                                        -- resets state to price display

                        location_var := "11111111";                                                        -- resets location to default

                        mtn_reg := "111111111111";                                                                -- resets maintenance price to default
								
								balance_var := "0000000000000000";                                        -- resets balance to default
								
								odd_press := '0';
								rstwait := '0';
								
					elsif (refundreset = '0') then
                        balance_var := "0000000000000000";                                        -- resets balance to default
								location_var := "11111111"; 
								odd_press := '0';
								rstwait := '0';

                elsif(latch'event and latch = '1') then

                        location_var := item_loc;                                                                -- \

                        mtn_reg := mtn_price;                                                                        -- initializes variables to the signal values

                        balance_var := balance;                                                                        -- /

                        price_write_var := '0';                                                                        -- updates price_write to prevent multiple writes

                        case display_state is

                                when price_state =>

                                        if(unsigned(read_key) < 5) and (unsigned(read_key) > 0) then        -- only computes when key is used for location

                                                if(odd_press = '0' and rstwait = '0') then                                                -- if new location: erase display, display first

                                                        location_var := read_key & "1111";                --         digit, and change state to finish location

                                                        odd_press := '1';

                                                elsif (odd_press = '1' and rstwait = '0') then                                 -- if unfinished location: change second display to

                                                        location_var(3 downto 0) := read_key;        --         the new digit without changing first display
																		  
																			rstwait := '1';

                                                end if;

                                        elsif(read_key = "1011") then

                                                display_state <= bal_state;                                        -- changes to balance state when H is pressed

                                        elsif(read_key = "1010") then
													 
																odd_press := '0';

                                                display_state <= mtn_state;                                        -- if full location, changes to mtn mode to write

                                        end if;

                                when bal_state =>

                                        if(read_key = "1011") then

                                                display_state <= price_state;                                        -- changes out of bal state when H is pressed

                                        end if;

                                when mtn_state =>

                                        if(read_key = "1010") then

                                                display_state <= price_state;                                        -- changes out of mtn state when * is pressed

                                        elsif(read_key = "1011") then

                                                price_write_var := '1';                                                        -- impulse to write price when H is pressed in mtn

                                        else                                                                                                                --         mode

                                                mtn_reg := mtn_reg(7 downto 0) & read_key;-- shifts new values into register to be written to

                                        end if;                                                                                                        --         ram

                                end case;

                end if;

                item_loc <= location_var;                                                                    -- \

                mtn_price <= mtn_reg;                                                                        -- synchronously sets the signals to their changed

                price_write <= price_write_var;                                                              -- /

        end process;

end keypad_arch;