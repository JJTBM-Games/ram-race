----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.02.2022 14:32:03
-- Design Name: 
-- Module Name: main - Behavioral
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
    Port (clk : in STD_LOGIC;
    	   jsup, jsdown, jsleft, jsright  : IN std_logic;

    
           HSYNC : out STD_LOGIC;  
           VSYNC : out STD_LOGIC;
            
           RED : out STD_LOGIC_VECTOR (0 TO 3); 
           GREEN : out STD_LOGIC_VECTOR (0 TO 3);
           BLUE : out STD_LOGIC_VECTOR (0 TO 3) );
end main;


architecture Behavioral of main is

COMPONENT display IS
    Port ( CLK : in STD_LOGIC;
           CLK_board : in STD_LOGIC;

           HSYNC : out STD_LOGIC;  
           VSYNC : out STD_LOGIC;
            
           RED : out STD_LOGIC_VECTOR (0 TO 3); 
           GREEN : out STD_LOGIC_VECTOR (0 TO 3);
           BLUE : out STD_LOGIC_VECTOR (0 TO 3);
           
           go_up, go_down, go_left, go_right : IN std_logic);
END COMPONENT display;

COMPONENT player_entity IS
    PORT
	(
	            up, down, left, right, neut  : IN std_logic;

		clk                          : IN std_logic;
		go_up, go_down, go_left, go_right : OUT std_logic
	);
END COMPONENT player_entity;

COMPONENT controls IS
Port ( Clk              : in STD_LOGIC;
           JoystickLeft     : in STD_LOGIC;
           JoystickRight    : in STD_LOGIC;
           JoystickUp       : in STD_LOGIC;
           JoystickDown     : in STD_LOGIC;
           Left : out STD_LOGIC;
           Right : out STD_LOGIC;
           Up : out STD_LOGIC;
           Down : out STD_LOGIC;
           Neutral : out STD_LOGIC);
END COMPONENT controls;

COMPONENT clk_25 IS
        Port ( clk_in1 : in STD_LOGIC;
               reset : in STD_LOGIC;
               
               locked : out STD_LOGIC;
               CLK_25MHz : out STD_LOGIC);
END COMPONENT clk_25;

SIGNAL clk_25mhz : std_logic;
signal go_up_buff, go_down_buff, go_left_buff, go_right_buff : std_logic;

SIGNAL sup, sdown, sleft, sright, sneut  : std_logic;

begin

CD1 : clk_25 Port Map(clk_in1 => clk,
                        reset => '0',
                        clk_25mhz => clk_25mhz);

D1 : display Port Map (CLK => clk_25mhz,
                       CLK_board => clk,
                       HSYNC =>  HSYNC,
                       VSYNC =>  VSYNC,
                       RED => RED,
                       GREEN => GREEN,
                       BLUE => BLUE,
                       go_up => go_up_buff,
                       go_down => go_down_buff,
                       go_left => go_left_buff,
                       go_right => go_right_buff);

P1 : player_entity Port Map(up => sup, 
                            down => sdown, 
                            left => sleft, 
                            right => sright, 
                            neut => sneut,
                            clk  => clk,
                            go_up => go_up_buff,
                            go_down => go_down_buff,
                            go_left => go_left_buff,
                            go_right => go_right_buff);

C1 : controls Port Map(Clk => clk,
                       JoystickLeft => jsleft,
                       JoystickRight => jsright,
                       JoystickUp => jsup,
                       JoystickDown => jsdown,
                       Left => sleft,
                       Right => sright,
                       Up => sup,
                       Down => sdown,
                       Neutral => sneut);

end Behavioral;
