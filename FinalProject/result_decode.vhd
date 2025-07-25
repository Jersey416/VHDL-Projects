library ieee;

use ieee.std_logic_1164.all;


entity result_decode is port(

        result: in std_logic_vector(6 downto 0);                -- row + column concatenated value

        output: out std_logic_vector(3 downto 0));        -- output number

end result_decode;


architecture decode of result_decode is

begin

        output <="0000" when result="1011110" else        -- 0

                                "0001" when result="0110111" else        -- 1

                                "0010" when result="1010111" else        -- 2

                                "0011" when result="1100111" else        -- 3

                                "0100" when result="0111011" else        -- 4

                                "0101" when result="1011011" else        -- 5

                                "0110" when result="1101011" else        -- 6

                                "0111" when result="0111101" else        -- 7

                                "1000" when result="1011101" else        -- 8

                                "1001" when result="1101101" else        -- 9

                                "1010" when result="0111110" else        -- *

                                "1011" when result="1101110" else        -- H

                                "1111";                                                                                -- extranneous value, perhaps transitionary or blank state

end decode;