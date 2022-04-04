library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity clock_gen is
    Port ( clk_in : in STD_LOGIC;
           output : out integer;
           note_sel : in STD_LOGIC_VECTOR (3 downto 0));
end clock_gen;

architecture Behavioral of clock_gen is

begin
    output <=   384615 WHEN note_sel="0000" else
                342466 WHEN note_sel="0001" else
                304878 WHEN note_sel="0010" else
                287356 WHEN note_sel="0011" else
                255102 WHEN note_sel="0100" else
                227273 WHEN note_sel="0101" else
                214592 WHEN note_sel="0110" else
                191571 WHEN note_sel="0111" else
                170648 WHEN note_sel="1000" else
                151976 WHEN note_sel="1001" else
                143266 WHEN note_sel="1010" else
                127551 WHEN note_sel="1011" else
                113636 WHEN note_sel="1100" else
                101420 WHEN note_sel="1101" else
                 95602 WHEN note_sel="1110";
end Behavioral;
