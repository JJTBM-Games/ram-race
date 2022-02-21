----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.02.2022 12:49:39
-- Design Name: 
-- Module Name: JoystickParser - Behavioral
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

entity JoystickParser is
    Port ( Direction : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           Left : out STD_LOGIC;
           Right : out STD_LOGIC;
           Up : out STD_LOGIC;
           Down : out STD_LOGIC;
           Neutral : out STD_LOGIC);
end JoystickParser;

architecture Behavioral of JoystickParser is

begin

Up      <= '1' when Direction = "001" else '0';
Down    <= '1' when Direction = "010" else '0';
Left    <= '1' when Direction = "011" else '0';
Right   <= '1' when Direction = "100" else '0';
Neutral <= '1' when Direction = "000" else '0';

end Behavioral;