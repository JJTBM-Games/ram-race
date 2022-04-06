library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    
entity music is
    Port ( clk : in STD_LOGIC;
           note_out : out STD_LOGIC_VECTOR (3 downto 0);
           beat_out : out STD_LOGIC);
end music;

architecture Behavioral of music is
component bpm_gen
Port (  clk : in STD_LOGIC;
        beat_clk : out STD_LOGIC);
end component;

component music_player
Port ( beat : in STD_LOGIC;                          
       note_out : out STD_LOGIC_VECTOR (3 downto 0));
end component;

signal beat : STD_LOGIC;
begin

    bpm : bpm_gen port map(
        clk => clk,
        beat_clk => beat);
    
    mp : music_player port map(
        beat => beat,
        note_out => note_out);
        
    beat_out <= beat;

end Behavioral;
