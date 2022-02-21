----------------------------------------------------------------------------------
-- Company: JJTBM-games
-- Engineer: Tim Laheij
--
-- Create Date: 08.02.2022 19:31:06
-- Design Name:
-- Module Name: SM_player - Behavioral
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
ENTITY SM_player IS
	PORT
	(
		clk      : IN STD_LOGIC;
		neutral  : IN STD_LOGIC;
		calc     : OUT STD_LOGIC
	);
END SM_player;

ARCHITECTURE Behavioral OF SM_player IS

	TYPE FSM_States IS (Idle, calculate, update, updated);
	
	SIGNAL state, next_state : FSM_States;
	
BEGIN
	State_process : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			state <= next_state;
		END IF;
	END PROCESS;
	
	NSL : PROCESS (state, neutral)
	BEGIN
		next_state <= state;
		CASE state IS
			WHEN Idle =>
				IF (neutral = '1') THEN
					calc <= '0';
					next_state <= state;
				ELSE
					next_state <= calculate;
				END IF;
			WHEN calculate =>
				calc <= '1';
				next_state <= update;
			WHEN update =>
				calc <= '0';
				next_state <= updated;
			WHEN updated =>
				IF (neutral = '1') THEN
					next_state <= idle;
				ELSE
					next_state <= state;
				END IF;
		END CASE;
	END PROCESS;
END Behavioral;