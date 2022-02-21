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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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
           
           PLOC : in integer;
           PLOC_old : in integer);
END COMPONENT display;

COMPONENT player_entity IS
    PORT
	(
	            up, down, left, right, neut  : IN std_logic;

		clk                          : IN std_logic;
		pos                          : OUT INTEGER := 161;
		old_pos                      : OUT INTEGER := 161
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

COMPONENT clk_108 IS
        Port ( clk_in1 : in STD_LOGIC;
               reset : in STD_LOGIC;
               
               locked : out STD_LOGIC;
               CLK_108MHz : out STD_LOGIC);
END COMPONENT clk_108;

SIGNAL clk_108mhz : std_logic;
SIGNAL position : INTEGER;
SIGNAL position_old : INTEGER;

SIGNAL sup, sdown, sleft, sright, sneut  : std_logic;

begin

CD1 : clk_108 Port Map(clk_in1 => clk,
                        reset => '0',
                        clk_108mhz => clk_108mhz);

D1 : display Port Map (CLK => clk_108mhz,
                       CLK_board => clk,
                       HSYNC =>  HSYNC,
                       VSYNC =>  VSYNC,
                       RED => RED,
                       GREEN => GREEN,
                       BLUE => BLUE,
                       PLOC => position,
                       PLOC_old => position_old);

P1 : player_entity Port Map(up => sup, 
                            down => sdown, 
                            left => sleft, 
                            right => sright, 
                            neut => sneut,
                            clk  => clk,
                            pos => position,
                            old_pos => position_old);

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
