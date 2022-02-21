----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.02.2022 15:28:06
-- Design Name: 
-- Module Name: controls - Behavioral
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

entity controls is
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
end controls;

architecture Behavioral of controls is

COMPONENT JoystickFetcher IS
    Port ( JoystickLeft : in STD_LOGIC;
           JoystickRight : in STD_LOGIC;
           JoystickUp : in STD_LOGIC;
           JoystickDown : in STD_LOGIC;
           Clk : in STD_LOGIC;
           Direction : out STD_LOGIC_VECTOR(2 DOWNTO 0));

END COMPONENT JoystickFetcher;

COMPONENT JoystickParser IS
    Port ( Direction : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           Left : out STD_LOGIC;
           Right : out STD_LOGIC;
           Up : out STD_LOGIC;
           Down : out STD_LOGIC;
           Neutral : out STD_LOGIC);
END COMPONENT JoystickParser;

SIGNAL sDirection : STD_LOGIC_VECTOR(2 DOWNTO 0); 

begin

JF : JoystickFetcher Port Map (JoystickLeft => JoystickLeft,
                                JoystickRight => JoystickRight,
                                JoystickUp => JoystickUp,
                                JoystickDown => JoystickDown,
                                clk => clk,
                                direction => sdirection);

JP : JoystickParser Port Map (Direction => sdirection,
                                left => left,
                                right => right,
                                up => up,
                                down => down,
                                neutral => neutral);
end Behavioral;
