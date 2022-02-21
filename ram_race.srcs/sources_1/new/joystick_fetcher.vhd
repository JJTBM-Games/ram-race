----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.02.2022 13:00:05
-- Design Name: 
-- Module Name: JoystickFetcher - Behavioral
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

entity JoystickFetcher is
    Port ( JoystickLeft : in STD_LOGIC;
           JoystickRight : in STD_LOGIC;
           JoystickUp : in STD_LOGIC;
           JoystickDown : in STD_LOGIC;
           Clk : in STD_LOGIC;
           Direction : out STD_LOGIC_VECTOR(2 DOWNTO 0));
end JoystickFetcher;

architecture Behavioral of JoystickFetcher is

signal count : integer;

begin
process(clk)
begin
    if rising_edge(clk) then
        if count = 200000 then
            if JoystickUp = '1' then
                Direction <= "001";
            elsif JoystickDown = '1' then
                Direction <= "010";
            elsif JoystickLeft = '1' then
                Direction <= "011";
            elsif JoystickRight = '1' then
                Direction <= "100";
            else
                Direction <=  "000";
            end if;
            
            count <= 0;
        else
            count <= count + 1;
        end if;
    end if;
             
end process;

end Behavioral;