library ieee;

use ieee.std_logic_1164.all;

use ieee.numeric_std.all;


entity ram is port(

        coordinates : in std_logic_vector(7 downto 0);        -- two concatenated BCDs, coordinates in 3d array

        price : out std_logic_vector(11 downto 0);                -- three BCDs, price to be fetched from array at coordinates

        mtn_price : in std_logic_vector(11 downto 0);        -- new price to be written in at coordinates

        price_write : in std_logic;

        clock : in std_logic;                                                                        -- clocks the process to update ram values

        reset : in std_logic);                                                                        -- resets array to default value

end ram;


architecture ram_arch of ram is

        type d3_array is array (3 downto 0, 3 downto 0) of std_logic_vector(11 downto 0);        -- defines maxtrix type

        constant ram_reset : d3_array :=        (                                                                                                -- defines 4x4x12 array constant

                ("000100010101","000100100101","000100110101","000101000101"),                -- 4x4x12 3d array

                ("001000010101","001000100101","001000110101","001001000101"),                -- 12 bit arrays are price

                ("001100010101","001100100101","001100110101","001101000101"),                -- 0,0 at bottom right

                ("010000010101","010000100101","010000110101","010001000101"));        -- counts up, then left

        signal ram_arr : d3_array;                                                                                -- signal for 3d ram array

        signal price_temp : std_logic_vector(11 downto 0);                -- signal to store price to be displayed

begin

        process(clock, reset) is

                variable price_var : std_logic_vector(11 downto 0);

        begin

                if(reset = '0') then

                        ram_arr <= ram_reset;                                                        -- resets ram array to default constant

                elsif(clock'event and clock = '1') then

                        price_var := price_temp;                                                -- instantiates variable for price to displau

                        if(price_write = '1') then

                                ram_arr(        to_integer(unsigned(coordinates(7 downto 4)))-1,        -- writes the maintenance mode new price

                                                        to_integer(unsigned(coordinates(3 downto 0)))-1)        --         to the current location

                                                                <= mtn_price;

                        else

                                price_var := ram_arr(to_integer(unsigned(coordinates(7 downto 4)))-1,        -- first dimension of array

                                                                                        to_integer(unsigned(coordinates(3 downto 0)))-1);        -- second dimension of array

                        end if;

                end if;

                price <= price_var;                                                                         -- synchronously updates display price

        end process;

end ram_arch;


        -- array is read backwards?


