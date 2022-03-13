library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    Port ( CLK : in STD_LOGIC;

           VIS : in STD_LOGIC;
           RGB_DATA : in STD_LOGIC_VECTOR (0 to 11);
    
           HSYNC : out STD_LOGIC;   -- At output pin P19 on board
           VSYNC : out STD_LOGIC;   -- At output pin R19 on board
           
           -- We are using RGB values with a 12-bit depth so 4 bits per color
           -- 4 bits per color results in a color amount of 4096 (16x16x16)
           RED : out STD_LOGIC_VECTOR (0 to 3); 
           GREEN : out STD_LOGIC_VECTOR (0 to 3);
           BLUE : out STD_LOGIC_VECTOR (0 to 3));   
end vga_controller;

architecture Behavioral of vga_controller is
    
begin

-- Handles RGB values send to screen
color_handler : process(CLK, RGB_DATA, vis)
begin
    if (VIS = '1') then
        -- These are the right RGB indexes, pls don't change it will fuck up the colors
        RED(3) <= RGB_DATA(0);
        RED(2) <= RGB_DATA(1);
        RED(1) <= RGB_DATA(2);
        RED(0) <= RGB_DATA(3);
        
        GREEN(3) <= RGB_DATA(4);
        GREEN(2) <= RGB_DATA(5);
        GREEN(1) <= RGB_DATA(6);
        GREEN(0) <= RGB_DATA(7);
        
        BLUE(3) <= RGB_DATA(8);
        BLUE(2) <= RGB_DATA(9);
        BLUE(1) <= RGB_DATA(10);
        BLUE(0) <= RGB_DATA(11);
    else
        RED <= "0000";
        GREEN <= "0000";
        BLUE <= "0000";
    end if;
end process;

end Behavioral;