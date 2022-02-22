library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity player_entity is
    Port (  CLK : in STD_LOGIC;
            P_GO_UP, P_GO_RIGHT, P_GO_DOWN, P_GO_LEFT, P_GO_NEUT : in STD_LOGIC;
		
		    P_UP, P_RIGHT, P_DOWN, P_LEFT : out STD_LOGIC);
end player_entity;

architecture Behavioral of player_entity is
    
	signal calc_buff : STD_LOGIC;

	component player is
	   Port (  CLK : in STD_LOGIC;
            
               CALC : in STD_LOGIC;
               P_GO_UP, P_GO_RIGHT, P_GO_DOWN, P_GO_LEFT, P_GO_NEUT : in STD_LOGIC;
                
               P_UP, P_RIGHT, P_DOWN, P_LEFT : out STD_LOGIC);
	end component player;
	
	component player_state is
	   Port (  CLK : in STD_LOGIC;
	   
			   P_GO_NEUT  : in STD_LOGIC;
			   
			   CALC     : out STD_LOGIC);
	end component player_state;

begin

P : player port map (
    CLK => CLK,

    CALC => calc_buff,

    P_GO_UP => P_GO_UP,
    P_GO_RIGHT => P_GO_RIGHT,
    P_GO_DOWN => P_GO_DOWN,
    P_GO_LEFT => P_GO_LEFT,
    P_GO_NEUT => P_GO_NEUT,
  
    P_UP => P_UP,
	P_RIGHT => P_RIGHT,
	P_DOWN => P_DOWN,
	P_LEFT => P_LEFT
);
	
PS : player_state port map (
    CLK => CLK,
    
    P_GO_NEUT => P_GO_NEUT,
    
	CALC => calc_buff
);

end Behavioral;