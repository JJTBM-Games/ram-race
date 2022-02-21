----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.02.2022 15:45:08
-- Design Name: 
-- Module Name: display - Behavioral
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

entity display is
 Port (    CLK : in STD_LOGIC;
           CLK_board : in STD_LOGIC;
    
           HSYNC : out STD_LOGIC;  
           VSYNC : out STD_LOGIC;
            
           RED : out STD_LOGIC_VECTOR (0 TO 3); 
           GREEN : out STD_LOGIC_VECTOR (0 TO 3);
           BLUE : out STD_LOGIC_VECTOR (0 TO 3);
           
           PLOC : in integer;
           PLOC_old : in integer);
end display;

architecture Behavioral of display is

COMPONENT vga_controller IS
    Port ( CLK : in STD_LOGIC;

           RGB_DATA : in STD_LOGIC_VECTOR (0 to 11);
    
           HSYNC : out STD_LOGIC;   
           VSYNC : out STD_LOGIC;  

           HLOC : out integer; 
           VLOC : out integer;
           
           RED : out STD_LOGIC_VECTOR (0 to 3); 
           GREEN : out STD_LOGIC_VECTOR (0 to 3);
           BLUE : out STD_LOGIC_VECTOR (0 to 3));
           
END COMPONENT vga_controller;

COMPONENT grid_controller IS
    Port ( CLK : in STD_LOGIC;
    
           HLOC : in integer; 
           VLOC : in integer;
           
           PLOC : in integer;
           PLOC_old : in integer;
           
           RGB_DATA : out STD_LOGIC_VECTOR (0 TO 11));
END COMPONENT;

    signal HLOC_BUFFER : integer := 0;
    signal VLOC_BUFFER : integer := 0;
    
    signal RGB_DATA_BUFFER : STD_LOGIC_VECTOR (0 TO 11);
    
begin

GC: grid_controller Port Map (clk => clk_board,
                                hloc => hloc_buffer,
                                vloc => vloc_buffer,
                                PLOC => PLOC,
                                PLOC_old => PLOC_old,
                                RGB_DATA => RGB_DATA_BUFFER
);

VC: vga_controller Port Map (clk => clk,
                                RGB_DATA => RGB_DATA_BUFFER,
                                HSYNC => HSYNC,
                                VSYNC => VSYNC,
                                HLOC => HLOC_BUFFER,
                                VLOC => VLOC_BUFFER,
                                RED => RED,
                                GREEN => GREEN,
                                BLUE => BLUE);

end Behavioral;
