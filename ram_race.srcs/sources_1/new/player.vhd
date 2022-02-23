library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity player is
    Port (  CLK : in STD_LOGIC;
            
            CALC : in STD_LOGIC;
            P_GO_UP, P_GO_RIGHT, P_GO_DOWN, P_GO_LEFT, P_GO_NEUT : in STD_LOGIC;
		    
		    P_UP, P_RIGHT, P_DOWN, P_LEFT : out STD_LOGIC);
end player;

architecture Behavioral of player is
	
begin
    
calculate_direction : process (CLK)
begin
    if rising_edge(CLK) then  	
        if (calc = '1') then
            if (P_GO_UP = '1') then
                P_UP <= '1';
				P_RIGHT <= '0';
				P_DOWN <= '0';
				P_DOWN <= '0';
			elsif (P_GO_RIGHT = '1') then
                P_UP <= '0';
				P_RIGHT <= '1';
				P_DOWN <= '0';
				P_LEFT <= '0';
			elsif (P_GO_DOWN = '1') then
				P_UP <= '0';
				P_RIGHT <= '0';
				P_DOWN <= '1';
				P_LEFT <= '0';
			elsif (P_GO_LEFT = '1') then
				P_UP <= '0';
				P_RIGHT <= '0';
				P_DOWN <= '0';
				P_LEFT <= '1';
			elsif (P_GO_NEUT = '1') then
			    P_UP <= '0';
				P_RIGHT <= '0';
				P_DOWN <= '0';
				P_LEFT <= '0';
			end if;
		else
		    P_UP <= '0';
		    P_RIGHT <= '0';
			P_DOWN <= '0';
			P_LEFT <= '0';
		end if;
	end if;
end process calculate_direction;
	
end Behavioral;