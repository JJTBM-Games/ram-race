library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display is
    Port (  CLK_100 : in STD_LOGIC;
            CLK_25 : in STD_LOGIC;
            CLK_400 : in STD_LOGIC;
            enGame : in STD_LOGIC;
            reset : in STD_LOGIC;
           
            P1_UP, P1_RIGHT, P1_DOWN, P1_LEFT : in STD_LOGIC;
            P2_UP, P2_RIGHT, P2_DOWN, P2_LEFT : in STD_LOGIC;
            
            endGame : out STD_LOGIC;
            HSYNC : out STD_LOGIC;  
            VSYNC : out STD_LOGIC;
            
            RED : out STD_LOGIC_VECTOR (0 to 3); 
            GREEN : out STD_LOGIC_VECTOR (0 to 3);
            BLUE : out STD_LOGIC_VECTOR (0 to 3));
end display;

architecture Behavioral of display is

    signal hloc_buff : integer := 0;
    signal vloc_buff : integer := 0;
    
    signal vis_buff : STD_LOGIC;
    
    signal rgb_data_buff : STD_LOGIC_VECTOR (0 to 11);

    component display_controller is
        Port ( CLK : in STD_LOGIC;
        
               VIS : out STD_LOGIC;
            
               HSYNC : out STD_LOGIC;   
               VSYNC : out STD_LOGIC;  
        
               HLOC : out integer; 
               VLOC : out integer);       
    end component display_controller;

    component grid_controller is
        Port ( CLK_100 : in STD_LOGIC;
               CLK_400 : in STD_LOGIC;
           
               enGame : in STD_LOGIC;
               reset : in STD_LOGIC;
               
               HLOC_IN : in integer; 
               VLOC_IN : in integer;
               
               endGame : out STD_LOGIC;
               
               P1_UP, P1_RIGHT, P1_DOWN, P1_LEFT : in STD_LOGIC;
               P2_UP, P2_RIGHT, P2_DOWN, P2_LEFT : in STD_LOGIC;
    
               RGB_DATA : out STD_LOGIC_VECTOR (0 TO 11));
    end component grid_controller;

    component vga_controller is
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
    end component vga_controller;
    
begin

DC: display_controller port map (
    CLK => CLK_25,
    
    VIS => vis_buff,
    
    HSYNC => HSYNC,
    VSYNC => VSYNC,
    
    HLOC => hloc_buff,
    VLOC => vloc_buff
);

GC: grid_controller port map (
    CLK_100 => CLK_100,
    CLK_400 => CLK_400,
    
    enGame => enGame,
    reset => reset,
    HLOC_IN => hloc_buff,
    VLOC_IN => vloc_buff,
    
    endGame => endGame,
    
    P1_UP => P1_UP,
    P1_RIGHT => P1_RIGHT,
    P1_DOWN => P1_DOWN,
    P1_LEFT => P1_LEFT,
    
    P2_UP => P2_UP,
    P2_RIGHT => P2_RIGHT,
    P2_DOWN => P2_DOWN,
    P2_LEFT => P2_LEFT,
    
    RGB_DATA => rgb_data_buff
);

VC: vga_controller port map (
    CLK => CLK_25,
    
    VIS => vis_buff,
    RGB_DATA => rgb_data_buff,
    
    HSYNC => HSYNC,
    VSYNC => VSYNC,
    
    RED => RED,
    GREEN => GREEN,
    BLUE => BLUE
);

end Behavioral;
