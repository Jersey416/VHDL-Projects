library ieee;

use ieee.std_logic_1164.all;

use ieee.numeric_std.all;


entity displays is port(

        item_in : in std_logic_vector(7 downto 0);        -- two concatenated BCDs for item location coordinates

        price_in : in std_logic_vector(11 downto 0);        -- 12 bit price vector (3 BCDs, one per digit)

        balance : in std_logic_vector(15 downto 0);        -- 16 bit vector for balance (four BCDs)

        display_bal : in std_logic;                        -- boolean for whether or not to display balance

        mtn_price : in std_logic_vector(11 downto 0);--

        mtn_mode : in std_logic;    		  --
		  
		  not_enough : in std_logic;
		  
		  CLK : in std_logic;

        output1 : out std_logic_vector(6 downto 0);        -- value for rightmost seven segment display (third price digit)

        output2 : out std_logic_vector(6 downto 0);        -- value for second seven seg display (second price digit)

        output3 : out std_logic_vector(6 downto 0);        -- value for third seven seg display (first price digit)

        output4 : out std_logic_vector(6 downto 0);        -- next display isn't used, for readability

        output5 : out std_logic_vector(6 downto 0);        -- value for fourth seven seg display (second location digit)

        output6 : out std_logic_vector(6 downto 0));        -- value for leftmost seven seg display (first location digit)

end displays;


architecture display_arch of displays is

        signal item : std_logic_vector(7 downto 0);                -- item location inputs of leftmost two displays

        signal price : std_logic_vector(15 downto 0);        -- price, rightmost four displays. balance or item price

        signal price_full : std_logic;
		  
		  signal not_enough_buf : std_logic;
		  
		  signal output_buf1 : std_logic_vector(6 downto 0);

		  signal output_buf2 : std_logic_vector(6 downto 0);
		  
		  signal output_buf3 : std_logic_vector(6 downto 0);

		  signal output_buf4 : std_logic_vector(6 downto 0);

		  signal output_buf5 : std_logic_vector(6 downto 0);

		  signal output_buf6 : std_logic_vector(6 downto 0);
begin
		process(not_enough_buf) begin
			if (not_enough_buf = '1') then 
				output1 <= "1010101";
				
				not_enough_buf <= '0';
			else
				not_enough_buf <= not_enough;
				output1 <= output_buf1;
				output2 <= output_buf2;
				output3 <= output_buf3;
				output4 <= output_buf4;
				output5 <= output_buf5;
				output6 <= output_buf6;
			end if;
		end process;
		
		
        price_full <= '0' when item(3 downto 0) = "1111" else '1';

        item(7 downto 4) <= item_in(7 downto 4) when display_bal = '0' else "1111";        -- displays item location when

        item(3 downto 0) <= item_in(3 downto 0) when display_bal = '0' else "1111";        --         not displaying balance

        price(15 downto 12) <= "1111" when display_bal = '0'

                else balance(15 downto 12);                        -- displays balance values when not displaying item price, else empty

        price(11 downto 8) <= balance(11 downto 8) when display_bal = '1'

                else mtn_price(11 downto 8) when mtn_mode = '1'

                else price_in(11 downto 8) when price_full = '1'

                else "1111";                        -- displays item values when not displaying balance, empty when location incomplete

        price(7 downto 4) <= balance(7 downto 4) when display_bal = '1'

                else mtn_price(7 downto 4) when mtn_mode = '1'

                else price_in(7 downto 4) when price_full = '1'

                else "1111";                        -- displays item values when not displaying balance, empty when location incomplete

        price(3 downto 0) <= balance(3 downto 0) when display_bal = '1'

                else mtn_price(3 downto 0) when mtn_mode = '1'

                else price_in(3 downto 0) when price_full = '1'

                else "1111";                        -- displays item values when not displaying balance, empty when location incomplete

        display1: entity work.sevenseg_decode port map(item(7 downto 4), output_buf1);                --

        display2: entity work.sevenseg_decode port map(item(3 downto 0), output_buf2);                --

        display3: entity work.sevenseg_decode port map(price(15 downto 12), output_buf3);        --

        display4: entity work.sevenseg_decode port map(price(11 downto 8), output_buf4);        --

        display5: entity work.sevenseg_decode port map(price(7 downto 4), output_buf5);        --

        display6: entity work.sevenseg_decode port map(price(3 downto 0), output_buf6);        --

end display_arch;



