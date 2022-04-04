library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity sound_gen is
    Port (  clk : in STD_LOGIC;
            note_in : in STD_LOGIC_VECTOR(3 downto 0);
            sound_out : out STD_LOGIC;
            en : in STD_LOGIC);
end sound_gen;

architecture Behavioral of sound_gen is
    component clock_gen
    Port (  clk_in : in STD_LOGIC;
            output : out integer;
            note_sel : in STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    component square_wave_synth
    Port (  count : in integer;
            clk : in STD_LOGIC;
            en : in STD_LOGIC;
            sound_out : out STD_LOGIC);
    end component;
    
    signal synth_freq : integer;

begin

    clock_generator : clock_gen port map(
        clk_in => clk,
        output => synth_freq,
        note_sel => note_in
    );
    
    synth_core : square_wave_synth port map(
        count => synth_freq,
        en => en,
        clk => clk,
        sound_out => sound_out
    );

end Behavioral;
