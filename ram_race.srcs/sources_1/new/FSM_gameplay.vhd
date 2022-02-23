----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.02.2022 15:38:12
-- Design Name: 
-- Module Name: FSM_gameplay - Behavioral
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

entity FSM_gameplay is
    Port ( clk              : in STD_LOGIC;
           btnStart         : in STD_LOGIC;
           
           PLOC             : in INTEGER;
           
           menu_out         : out STD_LOGIC;
           name_out         : out STD_LOGIC;
           playing_out      : out STD_LOGIC;
           save_score_out   : out STD_LOGIC );
end FSM_gameplay;

architecture Behavioral of FSM_gameplay is

TYPE game_state IS (menu, starting, set_name, playing, save_score);

SIGNAL state, next_state : game_state;

begin

state_process : process (CLK)
    begin
        if (rising_edge(CLK)) then
            state <= next_state;
        end if;
    end process state_process;

NSL : process (CLK)
    begin
        
    end process NSL;

end Behavioral;
