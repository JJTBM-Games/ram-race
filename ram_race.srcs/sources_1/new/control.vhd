library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity control is
    Port ( msc_mute : in STD_LOGIC;
           msc_in : in STD_LOGIC;
           sfx_mute : in STD_LOGIC;
           sfx_in : in STD_LOGIC;
           mute : in STD_LOGIC;
           msc_out : out STD_LOGIC;
           sfx_out : out STD_LOGIC);
end control;

architecture Behavioral of control is

--signal msc_out : STD_LOGIC;
--signal sfx_out : STD_LOGIC;

begin
    msc_out <= (NOT mute) AND (NOT msc_mute) AND msc_in;
    sfx_out <= (NOT mute) AND (NOT sfx_mute) AND sfx_in;
    --main_out <= sfx_out XOR msc_out;
end Behavioral;
