----------------------------------------------------------------------------------
-- Company: JJTBM Games
-- Engineer: Joas Onvlee
-- 
-- Create Date: 02/03/2022 07:22:02 PM
-- Design Name: 
-- Module Name: vga_controller - Behavioral
-- Project Name: POC Grid
-- Target Devices: 
-- Tool Versions: 
-- Description: Proof of concept for grid
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
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    Port ( CLK : in STD_LOGIC;

           RGB_DATA : in STD_LOGIC_VECTOR (0 to 11);
    
           HSYNC : out STD_LOGIC;   -- At output pin P19 on board
           VSYNC : out STD_LOGIC;   -- At output pin R19 on board

           HLOC : out integer; 
           VLOC : out integer;
           
           -- We are using RGB values with a 12-bit depth so 4 bits per color
           -- 4 bits per color results in a color amount of 4096 (16x16x16)
           RED : out STD_LOGIC_VECTOR (0 to 3); 
           GREEN : out STD_LOGIC_VECTOR (0 to 3);
           BLUE : out STD_LOGIC_VECTOR (0 to 3));   
end vga_controller;

architecture Behavioral of vga_controller is

    -- VGA timings overview: http://tinyvga.com/vga-timing
    --                     : https://www.ibm.com/docs/en/power8?topic=display-supported-resolution-timing-charts
    -- VGA 1280x1024 @ 60Hz timings: http://tinyvga.com/vga-timing/1280x1024@60Hz
    
    constant  HD : integer := 640;         -- Horizontal display (1280 pixels) 
    constant  HFP : integer := 16;          -- Horizontal front porch (48 pixels)
    constant  HBP : integer := 48;         -- Horizontal back porch (248 pixels)
    constant  HSP : integer := 96;         -- Horizontal sync pulse (112 pixels)
       
    constant  VD : integer := 480;         -- Vertical display (1024 pixels)
    constant  VFP : integer := 10;           -- Vertical front porch (1 pixel)
    constant  VBP : integer := 33;          -- Vertical back porch (38 pixels)
    constant  VSP : integer := 2;           -- Vertical sync pulse (3 pixels)
    
    signal hCount : integer := 1;           -- Start counting at one
    signal vCount : integer := 1;
    
    signal vis : STD_LOGIC := '0';
    
begin

horizontal_pos_counter : process(CLK)
begin
    if (rising_edge(CLK)) then
        if (hCount = (HD + HFP + HBP + HSP)) then   -- Check if horizontal count is 1688 (end of line reached)
            hCount <= 0; 
        else
            hCount <= hCount + 1;
        end if;
        
        HLOC <= hCount;
    end if;
end process;

vertical_pos_counter : process(CLK, hCount)
begin
    if (rising_edge(CLK)) then
        if (hCount = (HD + HFP + HBP + HSP)) then
            if (vCount = (VD + VFP + VBP + VSP)) then   -- Check if vertical count is 1066 (bottom line of screen reached)
                vCount <= 0;    -- End of screen/frame is reached, go back to top left
            else
                vCount <= vCount + 1;   -- End of line is reached, go to next line
            end if;
        end if;
        
        VLOC <= vCount;
    end if;
end process;

-- Horizontal sync pulse indicates start of new line to VGA monitor
horizontal_sync : process(CLK)
begin
    if (rising_edge(CLK)) then
        if (hCount > (HD + HFP) and hCount < (HD + HFP + HSP)) then
            HSYNC <= '0';   -- Active low sync pulse after front porch and before back porch
        else
            HSYNC <= '1';
        end if;
    end if;
end process;

-- Vertical sync pulse indicated start of new frame to VGA monitor
vertical_sync : process(CLK)
begin
    if (rising_edge(CLK)) then
        if (vCount > (VD + VFP) and vCount < (VD + VFP + VSP)) then
            VSYNC <= '0';   -- Active low sync pulse after front porch and before back porch
        else
            VSYNC <= '1';
        end if;
    end if;
end process;

-- Handles the color visibility on the screen
visibility_handler : process(CLK)
begin
    if (rising_edge(CLK)) then
        if (hCount <= HD and vCount <= VD) then
            vis <= '1';
        else
            vis <= '0';
        end if;
    end if;
end process;

-- Handles RGB values send to screen
color_handler : process(CLK, vis)
begin
    if (vis = '1') then
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