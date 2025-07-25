library ieee;

use ieee.std_logic_1164.all;

use ieee.numeric_std.all;


entity clk_div_inter is

        generic

        (cnt_max: integer := 62500);

        port

        (clock_in: in  std_logic;

        clock_out: out std_logic);

end clk_div_inter;


architecture clk_div_arch of clk_div_inter is

begin

        process(clock_in) is

                variable cntr : integer range 0 to cnt_max;

                variable tog  : std_logic;

        begin

                if (clock_in'event AND clock_in = '1') then

                        cntr := cntr + 1;

                        if (cntr = cnt_max) then

                                cntr := 0;


                                tog := not tog;

                        end if;

                end if;

                clock_out <= tog;

        end process;

end clk_div_arch;