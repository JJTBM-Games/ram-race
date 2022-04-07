library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity music_player is
    Port ( beat : in STD_LOGIC;
           note_out : out STD_LOGIC_VECTOR (3 downto 0);
           sel : in STD_LOGIC_VECTOR(1 downto 0);
           en : in STD_LOGIC);
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

constant music1 : MusicType := (
    x"0", x"0", x"4", x"4", x"0", x"0", x"2", x"1", 
    x"3", x"3", x"7", x"7", x"3", x"3", x"5", x"4", 
    x"1", x"1", x"5", x"5", x"1", x"1", x"3", x"2", 
    x"4", x"4", x"8", x"8", x"4", x"4", x"6", x"5" 
);

constant music2 : MusicType := (
    x"0", x"7", x"2", x"9", x"4", x"B", x"2", x"9", 
    x"3", x"A", x"5", x"C", x"7", x"E", x"5", x"C", 
    x"1", x"8", x"3", x"A", x"5", x"C", x"3", x"A", 
    x"2", x"9", x"4", x"B", x"6", x"D", x"4", x"B" 
);

constant music3 : MusicType := (
    x"E", x"D", x"C", x"B", x"A", x"9", x"8", x"7", 
    x"6", x"5", x"4", x"3", x"2", x"1", x"0", x"E", 
    x"D", x"C", x"B", x"A", x"9", x"8", x"7", x"6", 
    x"5", x"4", x"3", x"2", x"1", x"0", x"E", x"D" 
);

type CurrentType is array (3 downto 0) of std_logic_vector(3 downto 0);
signal current_note : CurrentType;
signal current : integer := 0;

begin
    process(beat)
    begin
        if rising_edge(beat) then
            if current <= 0 OR en = '0' then
                current <= 31;
            elsif en = '1' then
                current <= current - 1;
            end if;
            
            current_note(0) <= music0(current);
            current_note(1) <= music1(current);
            current_note(2) <= music2(current);
            current_note(3) <= music3(current);
            
            note_out <= current_note(to_integer(unsigned(sel)));       
            
        end if;
    end process;

end Behavioral;
