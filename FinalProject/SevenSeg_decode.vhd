library ieee;

use ieee.std_logic_1164.all;


entity sevenseg_decode is port(

        sel: in std_logic_vector(3 downto 0);                -- input bcd number

        data: out std_logic_vector(6 downto 0));        -- seveseg code corresponding to input bcd

end sevenseg_decode;


architecture sevenseg of sevenseg_decode is

begin

        data <=        "1000000" when sel = "0000" else        -- 0

                                "1111001" when sel = "0001" else        -- 1

                                "0100100" when sel = "0010" else        -- 2

                                "0110000" when sel = "0011" else        -- 3

                                "0011001" when sel = "0100" else        -- 4

                                "0010010" when sel = "0101" else        -- 5

                                "0000010" when sel = "0110" else        -- 6

                                "1011000" when sel = "0111" else        -- 7

                                "0000000" when sel = "1000" else        -- 8

                                "0010000" when sel = "1001" else        -- 9

                                "1111111";                                                                -- 0-9 are the only values that need to be displayed

end sevenseg;