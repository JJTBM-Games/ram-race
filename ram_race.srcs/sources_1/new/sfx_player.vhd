library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity sfx_player is
    Port ( en : in STD_LOGIC;
           clk : in STD_LOGIC;
           sel : in STD_LOGIC_VECTOR (1 downto 0);
           sound_out : out STD_LOGIC);
end sfx_player;

architecture Behavioral of sfx_player is

component sound_gen
    Port (  clk : in STD_LOGIC;
            note_in : in STD_LOGIC_VECTOR(3 downto 0);
            sound_out : out STD_LOGIC;
            en : in STD_LOGIC);
end component;

component sfx
   Port ( clk : in STD_LOGIC;
           note_out : out STD_LOGIC_VECTOR (3 downto 0);
           sel : in STD_LOGIC_VECTOR(1 downto 0);
           en : in STD_LOGIC;
           play_out : out STD_LOGIC);
end component;

signal note : STD_LOGIC_VECTOR(3 downto 0);
signal enable : STD_LOGIC;

begin

sound : sound_gen port map(
            clk => clk,
            note_in => note,
            sound_out => sound_out,
            en => enable);
            
 sp : sfx port map(
            clk => clk,
            note_out => note,
            en => en,
            sel => sel,
            play_out => enable);

end Behavioral;
