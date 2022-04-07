library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity sfx_play_unit is
    Port ( beat : in STD_LOGIC;
           note_out : buffer STD_LOGIC_VECTOR (3 downto 0);
           sel : in STD_LOGIC_VECTOR(1 downto 0);
           en : in STD_LOGIC;
           play : out STD_LOGIC);
end sfx_play_unit;

architecture Behavioral of sfx_play_unit is

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
constant music0 : MusicType := (   -- laser
    x"2", x"3", x"3", x"4", x"4", x"4", x"4", x"4", 
    x"5", x"5", x"5", x"5", x"5", x"5", x"5", x"5", 
    x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F",
    x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"
);

constant music1 : MusicType := (   -- pickup
    x"6", x"8", x"A", x"B", x"F", x"F", x"F", x"F", 
    x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F",
    x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F",
    x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"
);

constant music2 : MusicType := (
    x"B", x"A", x"8", x"6", x"F", x"F", x"F", x"F", 
    x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F",
    x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F",
    x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F" 
);

constant music3 : MusicType := (
    x"1", x"2", x"1", x"2", x"1", x"2", x"1", x"2", 
    x"3", x"4", x"3", x"4", x"3", x"4", x"3", x"4", 
    x"5", x"6", x"5", x"6", x"5", x"6", x"5", x"6", 
    x"7", x"8", x"7", x"8", x"7", x"8", x"7", x"8" 
);

type CurrentType is array (3 downto 0) of std_logic_vector(3 downto 0);
signal current_note : CurrentType;
signal current : integer := 0;

signal sel_buf : STD_LOGIC_VECTOR(1 downto 0);
signal enable : STD_LOGIC;

begin
    process(beat)
    begin
        if rising_edge(beat) then
            if note_out = x"F" then
                play <= '0';
                current <= 31;
            elsif current <= 0 then
                current <= 31;
            elsif current < 31 then
                current <= current - 1;
                play <= '1';
            elsif current = 31 AND en = '1' then
                current <= 30;
                sel_buf <= sel;
            else
                play <= '0';
            end if;
            
--            if sel_buf /= sel then
--                current <= 31;
--                sel_buf <= sel;
--            end if;
            
            current_note(0) <= music0(current);
            current_note(1) <= music1(current);
            current_note(2) <= music2(current);
            current_note(3) <= music3(current);
            
            note_out <= current_note(to_integer(unsigned(sel)));       
            
        end if;
    end process;

end Behavioral;
