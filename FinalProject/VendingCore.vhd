LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.numeric_std.all;

Entity VendingCore is
	Port (
		-- Out Data
		CurrencyOut : buffer std_logic_vector(3 downto 0); -- for led pusles for money out
		ItemOut : out std_Logic; -- Led pulses for item out
		
		-- In data
		CoinSensor : In Std_logic_vector(3 downto 0);
		StartReset : In std_logic;
		Refund : Inout std_logic; -- triggers a full refund
		Buy : In std_logic; -- triggers a purchuse of an item
		Clk : IN std_logic;
		
		rows : inout std_logic_vector(3 downto 0);  -- row and column inout, shared with reader component
		
		columns : inout std_logic_vector(2 downto 0); -- needs to be here to be included as input for reader
		
		output1 : out std_logic_vector(6 downto 0);

      output2 : out std_logic_vector(6 downto 0);                        -- 7seg values, for the 6 displays used (left to right)

      output3 : out std_logic_vector(6 downto 0);

      output4 : out std_logic_vector(6 downto 0);

      output5 : out std_logic_vector(6 downto 0);

      output6 : out std_logic_vector(6 downto 0);
		
		debug : out std_logic
	
	);
End VendingCore;

Architecture VendingMachine of VendingCore is
	
	Signal BalanceBuffer : std_logic_vector(15 downto 0);
	Signal RefundingBalance : std_logic_vector(15 downto 0);
	Signal BalanceActual : std_logic_vector(15 downto 0);
	Signal CurrencyOverflow : std_logic_vector(3 downto 0); -- for coin_reader
	Signal CurrencyDis : std_logic_vector(3 downto 0); -- for refund process
	
	Signal isRefunding : std_logic;
	Signal showbalance : std_logic;
	Signal Activity : std_Logic;
	signal not_enough : std_logic;
	
	Signal Price : std_logic_vector(11 downto 0); -- price of current item
	Signal slowClk : std_logic;
	Signal slowerClk : std_logic;
	
	Signal InternalReset : std_logic;
	Signal accReset : std_Logic; -- Reset when refund is complete

Begin

	U0: entity work.Clk_Div port map(Clk, slowerCLK); -- slower divided clock for LEDs (money dispenser)
	
	U1: entity work.clk_div_inter port map(clk, slowclk);   -- faster divided clock for debounce and Keypad reader (all else)
	
	U2: entity work.coin_reader port map (CoinSensor, InternalReset, slowClk, BalanceBuffer, CurrencyOverflow, Activity);

	U3: entity work.MoneyDispenser port map(BalanceBuffer, CurrencyDis, ItemOut, accReset, RefundingBalance, isRefunding,not_enough ,Price, Refund, Buy, startreset, clk, slowerClk);

	U4: entity work.keypad_ram port map(slowclk, StartReset, InternalReset, rows, columns, price, BalanceActual, ShowBalance, not_enough,output1, output2, output3, output4, output5, output6);
	
	
	ShowBalance <= isrefunding or activity;

	CurrencyOut <= CurrencyDis or CurrencyOverflow;
	InternalReset <= accReset and StartReset; -- or with the negative logic, so and
	
	with isRefunding select -- switch between the input buffer and the output tempbalance buffer
		BalanceActual <=  RefundingBalance when '1',
								BalanceBuffer when others;

	debug <= showBalance;
End Architecture;