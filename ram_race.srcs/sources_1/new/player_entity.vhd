----------------------------------------------------------------------------------
-- Company: JJTBM-games
-- Engineer: Tim Laheij
--
-- Create Date: 09.02.2022 14:34:39
-- Design Name:
-- Module Name: player_entity - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
ENTITY player_entity IS
	PORT
	(
		up, down, left, right, neut  : IN std_logic;
		clk                          : IN std_logic;
		pos                          : OUT INTEGER := 161;
		old_pos                      : OUT INTEGER := 161
	);
END player_entity;

ARCHITECTURE Behavioral OF player_entity IS

	COMPONENT player IS
		PORT
		(
			up, down, left, right, neut  : IN std_logic;
			clk                          : IN std_logic;
			calc                         : IN std_logic;
			pos                          : OUT INTEGER := 161;
			old_pos                      : OUT INTEGER := 161
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
		pos      => pos,
		old_pos  => old_pos
	);
	player_one_states : SM_player
	PORT MAP
	(
		clk      => clk,
		neutral  => neut,
	    calc     => sCalculation);

END Behavioral;