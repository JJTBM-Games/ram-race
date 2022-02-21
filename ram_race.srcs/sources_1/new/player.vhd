----------------------------------------------------------------------------------
-- Company: JJTBM-games
-- Engineer: Tim Laheij
--
-- Create Date: 08.02.2022 10:52:34
-- Design Name:
-- Module Name: player - Behavioral
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
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY player IS
	PORT
	(
		up, down, left, right, neut  : IN std_logic;
		clk                          : IN std_logic;
		calc                         : IN std_logic;
		update_ploc                  : IN STD_LOGIC;
		go_up, go_down, go_left, go_right : OUT std_logic
	);
END player;

ARCHITECTURE Behavioral OF player IS
	
BEGIN
	PROCESS (clk)
	BEGIN
		IF rising_edge(clk) THEN  	
			IF (calc = '1') THEN
				IF (up = '1') THEN
				    go_up <= '1';
				    go_down <= '0';
				    go_left <= '0';
				    go_right <= '0';
				ELSIF (left = '1') THEN
				    go_up <= '0';
				    go_down <= '0';
				    go_left <= '1';
				    go_right <= '0';
				ELSIF (right = '1') THEN
				    go_up <= '0';
				    go_down <= '0';
				    go_left <= '0';
				    go_right <= '1';
				ELSIF (down = '1') THEN
				    go_up <= '0';
				    go_down <= '1';
				    go_left <= '0';
				    go_right <= '0';
				END IF;
		    ELSE
		      go_up <= '0';
				    go_down <= '0';
				    go_left <= '0';
				    go_right <= '0';
			END IF;
		END IF;
	END PROCESS;
END Behavioral;