----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.03.2022 10:43:02
-- Design Name: 
-- Module Name: music - Behavioral
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

entity music is
    Port ( clk : in STD_LOGIC;
           note_out : out STD_LOGIC_VECTOR (3 downto 0);
           en : in STD_LOGIC;
           sel : in STD_LOGIC_VECTOR(1 downto 0));
end music;

architecture Behavioral of music is

component bpm_gen
        Port ( clk : in STD_LOGIC;
           beat_clk : out STD_LOGIC;
           bpm_count : in integer);
end component;

component music_player
         Port ( beat : in STD_LOGIC;
           note_out : out STD_LOGIC_VECTOR (3 downto 0);
           en : in STD_LOGIC;
           sel : in STD_LOGIC_VECTOR(1 downto 0));
end component;

signal beat : STD_LOGIC;
        
begin
    bpm : bpm_gen port map(
        clk => clk,
        beat_clk => beat,
        bpm_count => 16806722
        );
        
    player : music_player port map(
        beat => beat,
        note_out => note_out,
        en => en,
        sel => sel);


end Behavioral;
