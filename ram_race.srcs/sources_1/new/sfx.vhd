----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.04.2022 11:45:05
-- Design Name: 
-- Module Name: sfx - Behavioral
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

entity sfx is
    Port ( clk : in STD_LOGIC;
           note_out : out STD_LOGIC_VECTOR (3 downto 0);
           sel : in STD_LOGIC_VECTOR(1 downto 0);
           en : in STD_LOGIC;
           play_out : out STD_LOGIC);
end sfx;

architecture Behavioral of sfx is

component bpm_gen
Port ( clk : in STD_LOGIC;
           beat_clk : out STD_LOGIC;
           bpm_count : in integer);
end component;

component sfx_play_unit
Port ( beat : in STD_LOGIC;
           note_out : buffer STD_LOGIC_VECTOR (3 downto 0);
           sel : in STD_LOGIC_VECTOR(1 downto 0);
           en : in STD_LOGIC;
           play : out STD_LOGIC);
end component;

signal beat_clk : STD_LOGIC;

begin

bpm : bpm_gen port map(
        clk => clk,
        beat_clk => beat_clk,
        bpm_count => 4200000);
        
play : sfx_play_unit port map(
        beat => beat_clk,
        en => en,
        sel => sel,
        note_out => note_out,
        play => play_out);


end Behavioral;
