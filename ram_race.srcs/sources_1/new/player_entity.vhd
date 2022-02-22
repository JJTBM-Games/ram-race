LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY player_entity IS
	PORT
	(
		up, down, left, right, neut  : IN std_logic;
		clk                          : IN std_logic;
		go_up, go_down, go_left, go_right : OUT std_logic
	);
END player_entity;

ARCHITECTURE Behavioral OF player_entity IS

	COMPONENT player IS
		PORT
		(
			up, down, left, right, neut  : IN std_logic;
			clk                          : IN std_logic;
			calc                         : IN std_logic;
			go_up, go_down, go_left, go_right : OUT std_logic
		);
	END COMPONENT player;
	
	COMPONENT SM_player IS
		PORT
		(
			clk      : IN STD_LOGIC;
			neutral  : IN STD_LOGIC;
			calc     : OUT STD_LOGIC
		);
	END COMPONENT SM_player;
	
	SIGNAL sCalculation : STD_LOGIC;

BEGIN
	player_one : player
	PORT MAP
	(
		up       => up,
		down     => down,
		left     => left,
		right    => right,
		neut     => neut,
		clk      => clk,
		calc     => sCalculation,
		go_up => go_up,
		go_down => go_down,
		go_left => go_left,
		go_right => go_right
	);
	player_one_states : SM_player
	PORT MAP
	(
		clk      => clk,
		neutral  => neut,
	    calc     => sCalculation);

END Behavioral;