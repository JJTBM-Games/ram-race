library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
    Port (  CLK_100 : in STD_LOGIC;
            
            -- Player 1 joystick input
            JS1_UP, JS1_RIGHT, JS1_DOWN, JS1_LEFT, BTN1_ACT1, BTN1_ACT2  : in STD_LOGIC;
            
            -- Player 2 joystick input
            JS2_UP, JS2_RIGHT, JS2_DOWN, JS2_LEFT, BTN2_ACT1, BTN2_ACT2  : in STD_LOGIC;
            
            -- State inputs
            btnStart, reset : in STD_LOGIC;
            cheat_mode : in STD_LOGIC;
            
            sfx_mute : in STD_LOGIC;
            msc_mute: in STD_LOGIC;
            mute : in STD_LOGIC;

           
            -- Action button test
            P1_ACT1, P1_ACT2 : out STD_LOGIC;
            
            P2_ACT1, P2_ACT2 : out STD_LOGIC;
            
            -- Sound

            msc_out : out STD_LOGIC;
            sfx_out : out STD_LOGIC;

            -- VGA values
            HSYNC : out STD_LOGIC;  
            VSYNC : out STD_LOGIC;
            
            RED : out STD_LOGIC_VECTOR (0 to 3); 
            GREEN : out STD_LOGIC_VECTOR (0 to 3);
            BLUE : out STD_LOGIC_VECTOR (0 to 3));
end main;

architecture Behavioral of main is
 
    signal clk_25_buff : STD_LOGIC;
    signal clk_400_buff : STD_LOGIC;
    
    -- Buffer for the player 1 controls to player 1 ,from C1 to P1
    signal c1_up_buff, c1_right_buff, c1_down_buff, c1_left_buff, c1_neut_buff  : STD_LOGIC;
    
    -- Buffer for the player 1 controls, from P1 to D1
    signal p1_up_buff, p1_right_buff, p1_down_buff, p1_left_buff : STD_LOGIC;
    
    -- Buffer for the player 1 controls to player 1 ,from C2 to P2
    signal c2_up_buff, c2_right_buff, c2_down_buff, c2_left_buff, c2_neut_buff  : STD_LOGIC;
    
    -- Buffer for the player 1 controls, from P2 to D1
    signal p2_up_buff, p2_right_buff, p2_down_buff, p2_left_buff : STD_LOGIC;
    
    -- Buffer for buttons from controls to output
    signal p1_action1_buff, p2_action1_buff, p1_action2_buff, p2_action2_buff : STD_LOGIC;
    
    -- Buffer for MENU btns
    SIGNAL p1_menu_btn, p2_menu_btn : STD_LOGIC;
    
    -- PLOC for checking winner
    SIGNAL endGame_buffer, creds_buffer : STD_LOGIC;
    
    -- State output buffers
    SIGNAL menu_buffer, name_buffer, playing_buffer, score_buffer, save, reset_score_buff : STD_LOGIC;
    
    SIGNAL selection_s, score_s, both_ok_s : STD_LOGIC;

    -- 25Mhz clock prescaler mainly for the VGA controller
    component clk_25 is
        Port (  clk_in1 : in STD_LOGIC;
                reset : in STD_LOGIC;
                   
                locked : out STD_LOGIC;
                CLK_25MHz : out STD_LOGIC;
                CLK_400MHz : out STD_LOGIC);
    end component clk_25;
    
    component controls is
        Port (  CLK : in STD_LOGIC;
    
                JS_UP : in STD_LOGIC;
                JS_RIGHT : in STD_LOGIC;
                JS_DOWN : in STD_LOGIC;
                JS_LEFT : in STD_LOGIC;
                
                BTN_ACTION1 : in STD_LOGIC;
                BTN_ACTION2 : in STD_LOGIC;
                BTN_MENU : in STD_LOGIC;
                
                MENU_OUT    : out STD_LOGIC;
                P_ACTION1 : out STD_LOGIC;
                P_ACTION2 : out STD_LOGIC;
                    
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
                CLK_400 : in STD_LOGIC;
                enGame : in STD_LOGIC;
                reset : in STD_LOGIC;
                show_score : in STD_LOGIC;
                show_name : in STD_LOGIC;
                save_score : in STD_LOGIC;
                score_saved : out STD_LOGIC;
                P1_UP, P1_RIGHT, P1_DOWN, P1_LEFT : in STD_LOGIC;
                P2_UP, P2_RIGHT, P2_DOWN, P2_LEFT : in STD_LOGIC;
                creds            : in STD_LOGIC;
                endGame : out STD_LOGIC;
                HSYNC : out STD_LOGIC;  
                VSYNC : out STD_LOGIC;
                both_ok : out STD_LOGIC;
              
                cheat_mode : in STD_LOGIC;
                reset_score : in STD_LOGIC;
                sfx_mute : in STD_LOGIC;
                msc_mute: in STD_LOGIC;
                mute : in STD_LOGIC;
               
                msc_out : out STD_LOGIC;
                sfx_out : out STD_LOGIC;

                selection : out STD_LOGIC;

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
           selection        : in STD_LOGIC;
           both_ok          : in STD_LOGIC;
           reset_score      : out STD_LOGIC;
           score_out        : out STD_LOGIC;
           menu_out         : out STD_LOGIC;
           name_out         : out STD_LOGIC;
           playing_out      : out STD_LOGIC;
           save_score_out   : out STD_LOGIC;
           creds            : out STD_LOGIC );

    end COMPONENT FSM_gameplay;
begin

CD1 : clk_25 port map (
    clk_in1 => CLK_100,
    
    reset => '0',
    clk_25mhz => clk_25_buff,
    clk_400mhz => clk_400_buff
);

-- TEMPORARY TEST
P1_ACT1 <= p1_action1_buff;
P1_ACT2 <= p1_action2_buff;

C1 : controls port map (
    CLK => CLK_100,
    
    JS_UP => JS1_UP,
    JS_RIGHT => JS1_RIGHT,
    JS_DOWN => JS1_DOWN,
    JS_LEFT => JS1_LEFT,
    
    BTN_ACTION1 => BTN1_ACT1,
    BTN_ACTION2 => BTN1_ACT2,
    BTN_MENU => btnstart,
    
    MENU_OUT => p1_menu_btn,
    P_ACTION1 => p1_action1_buff,
    P_ACTION2 => p1_action2_buff,
    
    P_GO_UP => c1_up_buff,
    P_GO_RIGHT => c1_right_buff,
    P_GO_DOWN => c1_down_buff,
    P_GO_LEFT => c1_left_buff,
    P_GO_NEUT => c1_neut_buff
);

-- TEMPORARY TEST
P2_ACT1 <= p2_action1_buff;
P2_ACT2 <= p2_action2_buff;

-- Port map for the player 2 controls
C2 : controls port map (
    CLK => CLK_100,
    
    JS_UP => JS2_UP,
    JS_RIGHT => JS2_RIGHT,
    JS_DOWN => JS2_DOWN,
    JS_LEFT => JS2_LEFT,
    
    BTN_ACTION1 => BTN2_ACT1,
    BTN_ACTION2 => BTN2_ACT2,
    BTN_MENU => reset,            
    
    MENU_OUT => p2_menu_btn,
    P_ACTION1 => p2_action1_buff,
    P_ACTION2 => p2_action2_buff,
    
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
    CLK_400 => clk_400_buff,
    enGame => playing_buffer,
    cheat_mode => cheat_mode,
    reset => menu_buffer,
    show_score => score_s,
    show_name => name_buffer,
    save_score => score_buffer,
    score_saved => save,
    P1_UP => p1_up_buff,
    P1_RIGHT => p1_right_buff,
    P1_DOWN => p1_down_buff,
    P1_LEFT => p1_left_buff,
    both_ok => both_ok_s,
    sfx_mute => sfx_mute,
    msc_mute => msc_mute,
    mute => mute,
    msc_out => msc_out,
    sfx_out => sfx_out,
    P2_UP => p2_up_buff,
    P2_RIGHT => p2_right_buff,
    P2_DOWN => p2_down_buff,
    P2_LEFT => p2_left_buff,
    reset_score => reset_score_buff,
    endGame => endGame_buffer,
    creds => creds_buffer,
    selection => selection_s,
    
    HSYNC =>  HSYNC,
    VSYNC =>  VSYNC,
    
    RED => RED,
    GREEN => GREEN,
    BLUE => BLUE
);

FSM : FSM_gameplay Port Map(   clk => clk_100,
                               btnStart => p1_menu_btn,
                               score_saved => save,
                               async_reset => p2_menu_btn,
                               reset_score => reset_score_buff,
                               endGame => endGame_buffer,
                               selection => selection_s,
                               both_ok => both_ok_s,
                               score_out => score_s,
                               menu_out => menu_buffer,
                               name_out => name_buffer,
                               playing_out => playing_buffer,
                               save_score_out => score_buffer,
                               creds => creds_buffer);
           
end Behavioral;
