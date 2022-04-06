----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.03.2022 10:54:18
-- Design Name: 
-- Module Name: msc_player - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity msc_player is
    Port ( en : in STD_LOGIC;
           clk : in STD_LOGIC;
           sel : in STD_LOGIC_VECTOR (1 downto 0);
           sound_out : out STD_LOGIC);
end msc_player;

architecture Behavioral of msc_player is

component sound_gen
    Port (  clk : in STD_LOGIC;
            note_in : in STD_LOGIC_VECTOR(3 downto 0);
            sound_out : out STD_LOGIC;
            en : in STD_LOGIC);
end component;

component music
    Port ( clk : in STD_LOGIC;
           note_out : out STD_LOGIC_VECTOR (3 downto 0));
end component;

signal note : STD_LOGIC_VECTOR(3 downto 0);

begin

    sound : sound_gen port map(
        clk => clk,
        en => en,
        note_in => note,
        sound_out => sound_out
    );
    
    mp : music port map(
        clk => clk,
        note_out => note
    );


end Behavioral;
