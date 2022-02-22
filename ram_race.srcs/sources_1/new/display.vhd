library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display is
    Port (  CLK_100 : in STD_LOGIC;
            CLK_25 : in STD_LOGIC;
           
            P1_UP, P1_RIGHT, P1_DOWN, P1_LEFT : IN STD_LOGIC;
    
            HSYNC : out STD_LOGIC;  
            VSYNC : out STD_LOGIC;
            
            RED : out STD_LOGIC_VECTOR (0 TO 3); 
            GREEN : out STD_LOGIC_VECTOR (0 TO 3);
            BLUE : out STD_LOGIC_VECTOR (0 TO 3));
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
           
           go_up, go_down, go_left, go_right : IN std_logic;
           
           RGB_DATA : out STD_LOGIC_VECTOR (0 TO 11));
END COMPONENT;

    signal HLOC_BUFFER : integer := 0;
    signal VLOC_BUFFER : integer := 0;
    
    signal RGB_DATA_BUFFER : STD_LOGIC_VECTOR (0 TO 11);
    
begin

GC: grid_controller Port Map (clk => CLK_100,
                                hloc => hloc_buffer,
                                vloc => vloc_buffer,
                                RGB_DATA => RGB_DATA_BUFFER,
                                
                                go_up => P1_UP,
                                go_right => P1_RIGHT,
                                go_down => P1_DOWN,
                                go_left => P1_LEFT
);

VC: vga_controller Port Map (clk => CLK_25,
                                RGB_DATA => RGB_DATA_BUFFER,
                                HSYNC => HSYNC,
                                VSYNC => VSYNC,
                                HLOC => HLOC_BUFFER,
                                VLOC => VLOC_BUFFER,
                                RED => RED,
                                GREEN => GREEN,
                                BLUE => BLUE);

end Behavioral;
