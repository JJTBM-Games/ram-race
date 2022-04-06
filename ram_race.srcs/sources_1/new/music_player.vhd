library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity music_player is
    Port ( beat : in STD_LOGIC;
           note_out : out STD_LOGIC_VECTOR (3 downto 0));
end music_player;

architecture Behavioral of music_player is

--0x0	C3
--0x1	D3
--0x2	E3
--0x3	F3
--0x4	G3
--0x5	A3
--0x6	B3
--0x7	C4
--0x8	D4
--0x9	E4
--0xA	F4
--0xB	G4
--0xC	A4
--0xD	B4
--0xE	C5

type MusicType is array (31 downto 0) of std_logic_vector(3 downto 0);
constant music0 : MusicType := (
    x"7", x"B", x"9", x"7", x"B", x"9", x"7", x"B", 
    x"C", x"9", x"E", x"C", x"9", x"E", x"C", x"9", 
    x"C", x"B", x"8", x"C", x"A", x"8", x"C", x"A", 
    x"5", x"9", x"7", x"5", x"9", x"7", x"5", x"9" 
);

signal current : integer := 0;

begin
    process(beat)
    begin
        if rising_edge(beat) then
            if current >= 31 then
                current <= 0;
            else
                current <= current + 1;
            end if;
            note_out <= music0(current);
        end if;
    end process;

end Behavioral;
