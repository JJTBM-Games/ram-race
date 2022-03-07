library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
    Port (  CLK_100 : in STD_LOGIC;
            
            -- Player 1 joystick input
            JS1_UP, JS1_RIGHT, JS1_DOWN, JS1_LEFT  : in STD_LOGIC;
            
            -- Player 2 joystick input
            JS2_UP, JS2_RIGHT, JS2_DOWN, JS2_LEFT  : in STD_LOGIC;
            
            -- State inputs
            btnStart, save, reset : in STD_LOGIC;

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
    
    -- Buffer for the player 1 controls to player 1 ,from C2 to P2
    signal c2_up_buff, c2_right_buff, c2_down_buff, c2_left_buff, c2_neut_buff  : STD_LOGIC;
    
    -- Buffer for the player 1 controls, from P2 to D1
    signal p2_up_buff, p2_right_buff, p2_down_buff, p2_left_buff : STD_LOGIC;
    
    -- PLOC for checking winner
    SIGNAL endGame_buffer : STD_LOGIC;
    
    -- State output buffers
    SIGNAL menu_buffer, name_buffer, playing_buffer, score_buffer : STD_LOGIC;

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
        Port (  CLK : in STD_LOGIC;
                P_GO_UP, P_GO_RIGHT, P_GO_DOWN, P_GO_LEFT, P_GO_NEUT : in STD_LOGIC;
            
                P_UP, P_RIGHT, P_DOWN, P_LEFT : out STD_LOGIC);
    end component player_entity;
    
    component display is   
        Port (  CLK_100 : in STD_LOGIC;
            CLK_25 : in STD_LOGIC;
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
    end component display;

    COMPONENT FSM_gameplay is
    Port ( clk              : in STD_LOGIC;
           btnStart         : in STD_LOGIC;
           score_saved      : in STD_LOGIC;
           async_reset      : in STD_LOGIC;
           endGame          : in STD_LOGIC;
           
           menu_out         : out STD_LOGIC;
           name_out         : out STD_LOGIC;
           playing_out      : out STD_LOGIC;
           save_score_out   : out STD_LOGIC );
    end COMPONENT FSM_gameplay;
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


-- Port map for the player 2 controls
C2 : controls port map (
    CLK => CLK_100,
    
    JS_UP => JS2_UP,
    JS_RIGHT => JS2_RIGHT,
    JS_DOWN => JS2_DOWN,
    JS_LEFT => JS2_LEFT,
    
    P_GO_UP => c2_up_buff,
    P_GO_RIGHT => c2_right_buff,
    P_GO_DOWN => c2_down_buff,
    P_GO_LEFT => c2_left_buff,
    P_GO_NEUT => c2_neut_buff
);

P1 : player_entity port map (
    CLK  => CLK_100,
    
    P_GO_UP => c1_up_buff, 
    P_GO_RIGHT => c1_right_buff, 
    P_GO_DOWN => c1_down_buff, 
    P_GO_LEFT => c1_left_buff,  
    P_GO_NEUT => c1_neut_buff,
    
    P_UP => p1_up_buff,
    P_RIGHT => p1_right_buff,
    P_DOWN => p1_down_buff,
    P_LEFT => p1_left_buff
);

-- Port map for the player 2
P2 : player_entity port map (
    CLK  => CLK_100,
    
    P_GO_UP => c2_up_buff, 
    P_GO_RIGHT => c2_right_buff, 
    P_GO_DOWN => c2_down_buff, 
    P_GO_LEFT => c2_left_buff,  
    P_GO_NEUT => c2_neut_buff,
    
    P_UP => p2_up_buff,
    P_RIGHT => p2_right_buff,
    P_DOWN => p2_down_buff,
    P_LEFT => p2_left_buff
);

D1 : display port map (
    CLK_100 => CLK_100,
    CLK_25 => clk_25_buff,
    enGame => playing_buffer,
            reset => menu_buffer,

    P1_UP => p1_up_buff,
    P1_RIGHT => p1_right_buff,
    P1_DOWN => p1_down_buff,
    P1_LEFT => p1_left_buff,
    
    P2_UP => p2_up_buff,
    P2_RIGHT => p2_right_buff,
    P2_DOWN => p2_down_buff,
    P2_LEFT => p2_left_buff,
    
    endGame => endGame_buffer,
    
    HSYNC =>  HSYNC,
    VSYNC =>  VSYNC,
    
    RED => RED,
    GREEN => GREEN,
    BLUE => BLUE
);

FSM : FSM_gameplay Port Map(   clk => clk_100,
                               btnStart => btnStart,
                               score_saved => save,
                               async_reset => reset,
                               
                               endGame => endGame_buffer,
                               
                               menu_out => menu_buffer,
                               name_out => name_buffer,
                               playing_out => playing_buffer,
                               save_score_out => score_buffer);

end Behavioral;
