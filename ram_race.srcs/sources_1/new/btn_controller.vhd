----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.03.2022 11:01:33
-- Design Name: 
-- Module Name: btn_controller - Behavioral
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

entity btn_controller is
    Port (
            CLK         : in STD_LOGIC;
            BTN_ACTION1 : in STD_LOGIC;
            BTN_ACTION2 : in STD_LOGIC;
            
            P_ACTION1 : out STD_LOGIC;
            P_ACTION2 : out STD_LOGIC 
          );
end btn_controller;

architecture Behavioral of btn_controller is

signal count : integer;

begin
fetch_btn : process(CLK)
begin
    if rising_edge(CLK) then
        if count = 200000 then
        
            if BTN_ACTION1 = '1' THEN
                P_ACTION1 <= '1';
            ELSIF BTN_ACTION1 = '0' THEN
                P_ACTION1 <= '0';
            END IF;
            
            if BTN_ACTION2 = '1' THEN
                P_ACTION2 <= '1';
            ELSIF BTN_ACTION2 = '0' THEN
                P_ACTION2 <= '0';
            END IF;            
            count <= 0;
             
        else
            count <= count + 1;
        end if;
    end if;
end process fetch_btn;

end Behavioral;
