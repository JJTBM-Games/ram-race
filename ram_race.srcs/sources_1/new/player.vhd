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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
ENTITY player IS
	PORT
	(
		up, down, left, right, neut  : IN std_logic;
		clk                          : IN std_logic;
		calc                         : IN std_logic;
		true_pos                     : IN INTEGER;
		pos                          : OUT INTEGER := 161;
		old_pos                      : OUT INTEGER := 161
	);
END player;
ARCHITECTURE Behavioral OF player IS
	SIGNAL position : INTEGER := 1170;
	SIGNAL old_position : INTEGER := 1170;
BEGIN
	old_pos <= old_position;
	pos <= true_pos;
	PROCESS (clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF (calc = '1') THEN
				old_position <= position;
				IF (up = '1') THEN
					old_position <= (position - 40);
				ELSIF (left = '1') THEN
					old_position <= (position - 1);
				ELSIF (right = '1') THEN
					old_position <= (position + 1);
				ELSIF (down = '1') THEN
					old_position <= (position + 40);
				END IF;
			END IF;
		END IF;
	END PROCESS;
END Behavioral;