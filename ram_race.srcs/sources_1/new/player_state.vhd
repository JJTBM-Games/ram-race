library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity player_state is
	Port (  CLK      : IN STD_LOGIC;
		    P_GO_NEUT  : IN STD_LOGIC;
		
		    CALC     : OUT STD_LOGIC);
end player_state;

architecture Behavioral of player_state is

	type FSM_States is (idle, calculate, update, updated);
	
	signal state, next_state : FSM_States;
	
begin

state_process : process (CLK)
begin
    if (rising_edge(CLK)) then
        state <= next_state;
    end if;
end process state_process;
	
NSL : process (state, P_GO_NEUT)
begin
    next_state <= state;
    
	case state is
	   when idle =>
	       if (P_GO_NEUT = '1') then
	           calc <= '0';
	           next_state <= state;
		   else
		      next_state <= calculate;
		   end if;
	   when calculate =>
	       calc <= '1';
		   next_state <= update;
	   when update =>
	       calc <= '0';
		   next_state <= updated;
	   when updated =>
	       if (P_GO_NEUT = '1') then
	           next_state <= idle;
		   else
		      next_state <= state;
		   end if;
	end case;
end process NSL;

end Behavioral;