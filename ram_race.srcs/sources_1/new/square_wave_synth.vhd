library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity square_wave_synth is
    Port ( count : in integer;
            en : in STD_LOGIC;
           clk : in STD_LOGIC;
           sound_out : out STD_LOGIC);
end square_wave_synth;

architecture Behavioral of square_wave_synth is
signal value : integer := 0;
signal output : STD_LOGIC;
begin

process(clk)
begin
    if rising_edge(clk) then
        if value >= count then
            value <= 0;
            if output = '1' then
                output <= '0';
            else
                output <= '1';
            end if;
        else
            value <= value + 1;
        end if;
    end if;
    
    sound_out <= output AND en;
    
end process;
        
    
end Behavioral;
