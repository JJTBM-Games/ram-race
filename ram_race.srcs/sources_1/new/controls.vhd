library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controls is            
    Port (  CLK : in STD_LOGIC;
    
            JS_UP : in STD_LOGIC;
            JS_RIGHT : in STD_LOGIC;
            JS_DOWN : in STD_LOGIC;
            JS_LEFT : in STD_LOGIC;
            
            BTN_ACTION1 : in STD_LOGIC;
            BTN_ACTION2 : in STD_LOGIC;
            
            P_ACTION1 : out STD_LOGIC;
            P_ACTION2 : out STD_LOGIC;
                
            P_GO_UP : out STD_LOGIC;
            P_GO_RIGHT : out STD_LOGIC;
            P_GO_DOWN : out STD_LOGIC;
            P_GO_LEFT : out STD_LOGIC;
            P_GO_NEUT : out STD_LOGIC);
end controls;

architecture Behavioral of controls is

    component joystick_controller is
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
    end component joystick_controller;

    -- Down here should be the button controller later on
    COMPONENT btn_controller is
    Port (
            CLK         : in STD_LOGIC;
            BTN_ACTION1 : in STD_LOGIC;
            BTN_ACTION2 : in STD_LOGIC;
            
            P_ACTION1 : out STD_LOGIC;
            P_ACTION2 : out STD_LOGIC 
          );
    end COMPONENT btn_controller;
    
begin

JC : joystick_controller port map (
    CLK => CLK,

    JS_UP => JS_UP,
    JS_RIGHT => JS_RIGHT,
    JS_DOWN => JS_DOWN,
    JS_LEFT => JS_LEFT,
    
    P_GO_UP => P_GO_UP,
    P_GO_RIGHT => P_GO_RIGHT,
    P_GO_DOWN => P_GO_DOWN,
    P_GO_LEFT => P_GO_LEFT,
    P_GO_NEUT => P_GO_NEUT
);

BC: btn_controller port map (
    CLK => CLK,
    BTN_ACTION1 => BTN_ACTION1,
    BTN_ACTION2 => BTN_ACTION2,
                
    P_ACTION1 => P_ACTION1,
    P_ACTION2 => P_ACTION2
    );
end Behavioral;
