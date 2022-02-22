library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
    Port (  CLK_100 : in STD_LOGIC;
            
            -- Player 1 joystick input
            JS1_UP, JS1_RIGHT, JS1_DOWN, JS1_LEFT  : in STD_LOGIC;
            
            -- Player 2 joystick input
            JS2_UP, JS2_RIGHT, JS2_DOWN, JS2_LEFT  : in STD_LOGIC;

            -- VGA values
            HSYNC : out STD_LOGIC;  
            VSYNC : out STD_LOGIC;
            
            RED : out STD_LOGIC_VECTOR (0 to 3); 
            GREEN : out STD_LOGIC_VECTOR (0 to 3);
            BLUE : out STD_LOGIC_VECTOR (0 to 3));
end main;

architecture Behavioral of main is
 
    signal clk_25_buff : STD_LOGIC;
    
    -- Buffer for the player 1 controls to player 1 ,from C1 to P1
    signal c1_up_buff, c1_right_buff, c1_down_buff, c1_left_buff, c1_neut_buff  : STD_LOGIC;
    
    -- Buffer for the player 1 controls, from P1 to D1
    signal p1_up_buff, p1_right_buff, p1_down_buff, p1_left_buff : STD_LOGIC;

    -- 25Mhz clock prescaler mainly for the VGA controller
    component clk_25 is
        Port (  clk_in1 : in STD_LOGIC;
                reset : in STD_LOGIC;
                   
                locked : out STD_LOGIC;
                CLK_25MHz : out STD_LOGIC);
    end component clk_25;
    
    component controls is
        Port (  CLK : in STD_LOGIC;
    
                JS_UP : in STD_LOGIC;
                JS_RIGHT : in STD_LOGIC;
                JS_DOWN : in STD_LOGIC;
                JS_LEFT : in STD_LOGIC;
                
                P_GO_UP : out STD_LOGIC;
                P_GO_RIGHT : out STD_LOGIC;
                P_GO_DOWN : out STD_LOGIC;
                P_GO_LEFT : out STD_LOGIC;
                P_GO_NEUT : out STD_LOGIC);
    end component controls;

    component player_entity is
        Port (  up, down, left, right, neut : in STD_LOGIC;
                
		        clk : in STD_LOGIC;
		        go_up, go_down, go_left, go_right : out STD_LOGIC);
    end component player_entity;
    
    component display is   
        Port (  CLK_100 : in STD_LOGIC;
                CLK_25 : in STD_LOGIC;
                
                P1_UP, P1_RIGHT, P1_DOWN, P1_LEFT : in STD_LOGIC;

                HSYNC : out STD_LOGIC;  
                VSYNC : out STD_LOGIC;
            
                RED : out STD_LOGIC_VECTOR (0 TO 3); 
                GREEN : out STD_LOGIC_VECTOR (0 TO 3);
                BLUE : out STD_LOGIC_VECTOR (0 TO 3));
    end component display;

begin

CD1 : clk_25 port map (
    clk_in1 => CLK_100,
    
    reset => '0',
    clk_25mhz => clk_25_buff
);

C1 : controls port map (
    CLK => CLK_100,
    
    JS_UP => JS1_UP,
    JS_RIGHT => JS1_RIGHT,
    JS_DOWN => JS1_DOWN,
    JS_LEFT => JS1_LEFT,
    
    P_GO_UP => c1_up_buff,
    P_GO_RIGHT => c1_right_buff,
    P_GO_DOWN => c1_down_buff,
    P_GO_LEFT => c1_left_buff,
    P_GO_NEUT => c1_neut_buff
);

--C2 : controls port map (
--    CLK => CLK_100,
    
--    JS_UP => JS2_UP,
--    JS_RIGHT => JS2_RIGHT,
--    JS_DOWN => JS2_DOWN,
--    JS_LEFT => JS2_LEFT,
    
--    Left => sleft,
--    Right => sright,
--    Up => sup,
--    Down => sdown,
--    Neutral => sneut
--);

P1 : player_entity port map (
    clk  => CLK_100,
    
    up => c1_up_buff, 
    right => c1_right_buff, 
    down => c1_down_buff, 
    left => c1_left_buff,  
    neut => c1_neut_buff,
    
    go_up => p1_up_buff,
    go_right => p1_right_buff,
    go_down => p1_down_buff,
    go_left => p1_left_buff
);

D1 : display port map (
    CLK_100 => CLK_100,
    CLK_25 => clk_25_buff,
   
    P1_UP => p1_up_buff,
    P1_RIGHT => p1_right_buff,
    P1_DOWN => p1_down_buff,
    P1_LEFT => p1_left_buff,
    
    HSYNC =>  HSYNC,
    VSYNC =>  VSYNC,
    
    RED => RED,
    GREEN => GREEN,
    BLUE => BLUE
);

end Behavioral;
