library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity sound is
    Port ( clk_in : in STD_LOGIC;
           en_msc : in STD_LOGIC;
           en_sfx : in STD_LOGIC;
           sfx_mute : in STD_LOGIC;
           msc_mute: in STD_LOGIC;
           mute : in STD_LOGIC;
           msc_out : out STD_LOGIC;
           sfx_out : out STD_LOGIC;
           msc_sel : in STD_LOGIC_VECTOR(1 downto 0);
           sfx_sel : in STD_LOGIC_VECTOR(1 downto 0));
end sound;

architecture Behavioral of sound is

component msc_player
Port ( en : in STD_LOGIC;
           clk : in STD_LOGIC;
           sel : in STD_LOGIC_VECTOR (1 downto 0);
           sound_out : out STD_LOGIC);
end component;

component sfx_player
Port (      en : in STD_LOGIC;
           clk : in STD_LOGIC;
           sel : in STD_LOGIC_VECTOR (1 downto 0);
           sound_out : out STD_LOGIC);
end component;

component control
 Port ( msc_mute : in STD_LOGIC;
           msc_in : in STD_LOGIC;
           sfx_mute : in STD_LOGIC;
           sfx_in : in STD_LOGIC;
           mute : in STD_LOGIC;
           msc_out : out STD_LOGIC;
           sfx_out : out STD_LOGIC);
end component;

signal msc_sound : STD_LOGIC;
signal sfx_sound : STD_LOGIC;

begin

    msc : msc_player port map(
        clk => clk_in,
        sel => msc_sel,
        sound_out => msc_sound,
        en => en_msc
        );
        
    sfx : sfx_player port map(
        clk => clk_in,
        sel => sfx_sel,
        sound_out => sfx_sound,
        en => en_sfx
    );
    
    ctr : control port map(
        msc_mute => msc_mute,
        sfx_mute => sfx_mute,
        mute => mute,
        msc_in => msc_sound,
        sfx_in => sfx_sound,
        msc_out => msc_out,
        sfx_out => sfx_out
    );


end Behavioral;
