LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.numeric_std.all;

Entity MoneyDispenser is
	Port (
		-- In out data
		 -- buffer that stores user balance, read on '1'
		 -- Assuming the balance buffer is fully simplified
		balanceBuffer : In std_logic_vector(15 downto 0);
		
		-- Out Data
		CurrencyOut : buffer std_logic_vector(3 downto 0); -- for led pusles for money out
		ItemOut : out std_Logic; -- Led pulses for item out
		accReset : out std_logic; -- reset external acumulator
		RefundingBalance : out std_logic_vector(15 downto 0); -- output the ballance while refunding
		IsRefunding : buffer std_logic; -- to tell if we are currently refunding
		
		not_enough : buffer std_Logic;
		
		-- In data
		Price : In std_logic_vector(11 downto 0); -- price a
		Refund : In std_logic; -- triggers a full refund
		Buy : In std_logic; -- triggers a purchuse of an item
		reset : IN std_logic;
		Clk : IN std_logic;
		slowClk : In std_logic
	
	);
End MoneyDispenser;

Architecture MoneyCalc of MoneyDispenser is

	Signal Vendbalance: std_logic_vector(8 downto 0); -- copies price then subtracts to 0
	
	-- State values, 1 is processing, 0 is done processing
	Signal IsBuying: std_logic; -- Isrefunding is up as a buffer so it can be read by displays
	signal isbuyInit: std_logic; -- checks if buying is on it's first clock edge or not (buy takes 2 clock cycles to math)
	Signal IsDoneBy: std_logic;
	Signal IsDoneRe: std_logic;
	Signal WholeRefund : std_logic;
	Signal WholeRefundProcessing : std_logic;
	Signal Processhold :std_logic;
	
	
	Signal Dollarbalance: integer range 0 to 15; -- To split values from one value to the BCD segmentss
	Signal Tensbalance: integer range 0 to 9;
	Signal isFivebalance: std_logic;
	Signal DollarDue: integer range 0 to 15;
	Signal TensDue: integer range 0 to 9;
	Signal isFiveDue: std_Logic;
	
	Signal Dollarbalancetemp: integer range 0 to 15; -- BCD temp vallues to calcualte balance
	Signal Tensbalancetemp: integer range 0 to 9;
	Signal isFivebalancetemp: std_logic;


Begin
	
	-- Split the balance into the chuncks
	Dollarbalance <= to_integer(unsigned(balanceBuffer(15 downto 12)))*10 + to_integer(unsigned(balanceBuffer(11 downto 8)));
	Tensbalance <= to_integer(unsigned(balanceBuffer(7 downto 4)));
	
	with balanceBuffer(3 downto 0) select -- translate BCD to is-exist
		isFivebalance <=  '1' when "0101",
								'0' when others;
		
		
	with Price(3 downto 0) select -- translate BCD to is-exist
		isFivedue <=  '1' when "0101",
						  '0' when others;
	
	--Split the Price into the chuncks
	DollarDue <= to_integer(unsigned(Price(11 downto 8)));
	TensDue <= to_integer(unsigned(Price(7 downto 4)));
	
	
	-- Combine the temp balance into an output
	RefundingBalance(7 downto 4) <= std_logic_vector(to_unsigned(TensBalanceTemp, 4));
	
	with isFiveBalanceTemp select -- translate BCD to is exist
		RefundingBalance(3 downto 0) <=  "0101" when '1',
													"0000" when others;
													
	-- process to convert dollarballancetemp into two 4 bit binary numbers
	process (DollarBalanceTemp) is begin
		-- relying on balance never over 15.xx
		if (DollarBalancetemp >= 10) then
			RefundingBalance(15 downto 12) <= "0001";
			RefundingBalance(11 downto 8) <= std_logic_vector(to_unsigned((DollarBalanceTemp - 10), 4));
		else
			RefundingBalance(15 downto 12) <= "0000";
			RefundingBalance(11 downto 8) <= std_logic_vector(to_unsigned((DollarBalanceTemp), 4));
		end if;
	end process;
	
	
	-- Triggers a purchuse and/or refund event
	Process(clk) is begin
		-- if refund then Netbalance is total balance, if buy then Netbalance is price of item
		-- if esif to find currency out
		
		if (reset ='0') then
			isBuying <= '0';
			isRefunding <= '0';
			wholeRefund <= '0';
		
		elsif (clk'Event and clk = '1') then
			not_enough <='0';
			if ( Buy = '0' and refund = '1' and IsBuying = '0' and isRefunding = '0') then
			-- Check if the user has sufficent currency
				if ((Dollarbalance > DollarDue) or ((Dollarbalance = DollarDue) and (Tensbalance >= TensDue) and ((isFiveDue = isFivebalance) or ((isFiveDue ='1') and (Tensbalance > tensDue)) or (isFiveDue = '0')))) then
					
					-- Trigger the price reduction statemachine and mark as global busy
					IsBuying <= '1';
				else
					not_enough <='1';
				end if;
			End If;-- balance Check end if
		
		Elsif (clk'event and clk = '1' and Refund = '0' and Buy = '1' and IsBuying = '0' and isRefunding = '0') then -- Process a refund, also checking that it is not already doing so
			
			-- Trigger the Statemachine, and mark as global busy
			IsRefunding <= '1';
			WholeRefund <= '1';
			
		End If; -- event end if
		
		if (IsDoneBy = '1' and isBuying = '1') then -- ensure nothing is actually processing
			isBuying <= '0';
			isRefunding <= '1';
			wholeRefund <= '0';
		elsif (IsDoneRe = '1' and isRefunding = '1') then
			isBuying <= '0';
			isRefunding <= '0';
			wholeRefund <= '0';
		End if;
		
		
	End Process;
	
	
	
	
	-- Process to subtract price from balance. then refund
	Process (slowCLK, reset) is begin
		if (reset = '0') then
			
			isBuyInit <= '0';
			IsDoneBy <= '0';
			ItemOut <= '0';
			accReset <= '1';
			isDoneRe <= '0';
			WholeRefundProcessing <= '0';
			Processhold <= '0';
		
		elsif (slowClk'event and slowclk = '1') then
			if (isBuying = '1'  and isDoneBy = '0' and isBuyInit = '0') then
				Dollarbalancetemp <= Dollarbalance - DollarDue; -- Dollar balance will always be higher at this point
				tensbalancetemp <= tensbalance;
				isFivebalancetemp <= isFivebalance;
				isBuyInit <= '1';
				
			elsif (isbuyInit <= '1' and IsDoneBy = '0' and isbuying = '1') then	
				if (Tensbalancetemp >= TensDue and (isfivedue = '0' or isFivebalancetemp = isFiveDue)) then
					
					Tensbalancetemp <= Tensbalancetemp - TensDue;
					isFiveBalancetemp <= '0';
					
				Elsif (tensbalancetemp < tensDue and (isfivedue = '0' or isFivebalancetemp = isFiveDue)) then -- needs a dollar to break to be processed, no 5s
				
					Dollarbalancetemp <= Dollarbalancetemp - 1;
					Tensbalancetemp <= (Tensbalancetemp + 10) - TensDue;
					
				elsIf (Tensbalancetemp >= (TensDue + 1) and isFivebalancetemp = '0' and isFiveDue = '1') then
				
					isFivebalancetemp <= '1'; -- becouse it can only be 2-1 so it will be 1
					tensbalancetemp <= tensbalancetemp - tensdue - 1;
			
				Elsif (tensbalancetemp < tensDue and isfivedue = '1' and isFiveBalancetemp = '0') then
					DollarBalanceTemp <= DollarBalancetemp - 1;
					tensbalancetemp <= tensbalancetemp - tensDue + 9;
					isFivebalancetemp <= '1'; -- will always be 2-1 at this point so always one
					
				End if;
			
					IsDoneBy <= '1';
					ItemOut <= '1';
			else
				
				IsBuyInit <= '0'; -- reset so it is ready for next time
				isDoneBy <= '0';
				ItemOut <= '0';
			
			End if;

-- Refund stuff below here		
						-- only go if refund enabled
		if (wholeRefund = '1' and isRefunding = '1' and WholeRefundProcessing = '0') then
		
			Dollarbalancetemp <= Dollarbalance;
			tensbalancetemp <= tensbalance;
			isFivebalancetemp <= isFivebalance;
			WholeRefundProcessing <= '1';
		
		elsif (isrefunding = '1' and CurrencyOut = "0000" and isDoneRe = '0') then
		
			If (Dollarbalancetemp /= 0) then -- dispense a dollar
			
				Dollarbalancetemp <= Dollarbalancetemp - 1;
				CurrencyOut <= "1000"; -- allways tripping at start of refund to be fixed
		
			elsif (tensbalancetemp >= 2 and isfivebalancetemp = '1') then -- dispense a quarter if 5
			
				tensBalancetemp <= tensBalancetemp - 2;
				isfivebalancetemp <= '0';
				CurrencyOUT <= "0100";
				
			elsif (tensbalancetemp >= 3 and isfivebalancetemp = '0') then -- dispense quarter if no 5
			
				tensBalancetemp <= tensbalancetemp - 3;
				isfivebalancetemp <= '1';
				CurrencyOut <= "0100";
				
			elsif (tensbalancetemp /= 0) then -- dispense a dime
			
				tensbalancetemp <= tensbalancetemp - 1;
				currencyOut <= "0010";
				
			elsif (isfivebalancetemp = '1') then -- dispense a nickle
			
				isfivebalancetemp <= '0';
				CurrencyOut <= "0001";
				
			else
				accReset <= '0';-- reset the money accumulator (neg logic)
				IsDoneRe <= '1';
			End if;
		elsif (currencyOut /= "0000") then
		
			currencyout <= "0000";
		
		else
			accReset <= '1';
			isDoneRe <= '0';
			WholeRefundProcessing <= '0';
		End if;
	end if;
	End Process;

End Architecture;