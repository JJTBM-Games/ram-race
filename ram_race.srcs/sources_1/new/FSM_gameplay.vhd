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
           score_saved      : in STD_LOGIC;
           async_reset      : in STD_LOGIC;
           
           P_1_LOC          : in INTEGER;
           P_2_LOC          : in INTEGER;
           
           menu_out         : out STD_LOGIC;
           name_out         : out STD_LOGIC;
           playing_out      : out STD_LOGIC;
           save_score_out   : out STD_LOGIC );
end FSM_gameplay;

architecture Behavioral of FSM_gameplay is

TYPE game_state IS (menu, starting, set_name, playing, save_score);

SIGNAL state, next_state : game_state;

begin

state_process : process (CLK, async_reset)
    begin
        if (rising_edge(CLK)) then
            state <= next_state;
        end if;
        if (async_reset = '1') THEN
            state <= menu;
        END IF;
    end process state_process;

NSL : process (state)
    begin
        next_state <= state;
        case state is 
            when menu =>
            menu_out <= '1';
            name_out <= '0';
            playing_out <= '0';
            save_score_out <= '0';
            
                if (btnStart = '1') THEN
                   next_state <= starting; 
                ELSE
                    next_state <= state;
                END IF;
            WHEN starting =>
            menu_out <= '0';
                if (btnStart = '0') THEN
                    next_state <= set_name;
                ELSE
                    next_state <= state;
                END IF;
            WHEN set_name =>
            name_out <= '1';
                if (btnStart = '1') THEN
                   next_state <= playing; 
                ELSE
                    next_state <= state;
                END IF;
            WHEN playing =>
            name_out <= '0';
            playing_out <= '1';
                if (P_1_LOC = 300) THEN
                    next_state <= save_score; 
                ELSIF (P_1_LOC = 301) THEN
                    next_state <= save_score;
                ELSIF (P_2_LOC = 300) THEN
                    next_state <= save_score;
                ELSIF (P_2_LOC = 301) THEN
                    next_state <= save_score;
                ELSE
                    next_state <= state;
                END IF;
            WHEN save_score =>
            playing_out <= '0';
            save_score_out <= '1';
                IF (score_saved = '1') THEN
                    next_state <= menu;
                ELSE 
                    next_state <= state;
                END IF;
        END CASE;        
    end process NSL;

end Behavioral;
