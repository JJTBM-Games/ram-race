----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.03.2022 10:01:44
-- Design Name: 
-- Module Name: control - Behavioral
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

begin
    msc_out <= (NOT mute) AND (NOT msc_mute) AND msc_in;
    sfx_out <= (NOT mute) AND (NOT sfx_mute) AND sfx_in;
end Behavioral;
