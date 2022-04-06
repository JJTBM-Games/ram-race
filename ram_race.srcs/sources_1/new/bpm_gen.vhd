library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity bpm_gen is
    Port ( clk : in STD_LOGIC;
           beat_clk : out STD_LOGIC);
end bpm_gen;

architecture Behavioral of bpm_gen is
signal count : integer := 0;
begin

process(clk)
begin
    if rising_edge(clk) then
        if count >= 16806722 then
            count <= 0;
            beat_clk <= '1';
        else
            count <= count + 1;
            beat_clk <= '0';
        end if;
    end if;
end process;


end Behavioral;
