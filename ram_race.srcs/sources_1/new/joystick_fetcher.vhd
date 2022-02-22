library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity joystick_fetcher is 
    Port (  CLK : in STD_LOGIC;
            
            JS_UP : in STD_LOGIC;
            JS_RIGHT : in STD_LOGIC;
            JS_DOWN : in STD_LOGIC;
            JS_LEFT : in STD_LOGIC;
            
            P_GO_UP : out STD_LOGIC;
            P_GO_RIGHT : out STD_LOGIC;
            P_GO_DOWN : out STD_LOGIC;
            P_GO_LEFT : out STD_LOGIC;
            P_GO_NEUT : out STD_LOGIC);
end joystick_fetcher;

architecture Behavioral of joystick_fetcher is

    signal count : integer;
    signal direction : STD_LOGIC_VECTOR (2 DOWNTO 0);

begin

fetch_direction : process(CLK)
begin
    if rising_edge(CLK) then
        if count = 200000 then
            if JS_UP = '1' then
                direction <= "001";
            elsif JS_RIGHT = '1' then
                direction <= "010";
            elsif JS_DOWN = '1' then
                direction <= "011";
            elsif JS_LEFT = '1' then
                direction <= "100";
            else
                direction <=  "000";
            end if;
            
            count <= 0;
        else
            count <= count + 1;
        end if;
    end if;
end process fetch_direction;

P_GO_UP      <= '1' when direction = "001" else '0';
P_GO_RIGHT    <= '1' when direction = "010" else '0';
P_GO_DOWN    <= '1' when direction = "011" else '0';
P_GO_LEFT   <= '1' when Direction = "100" else '0';
P_GO_NEUT <= '1' when direction = "000" else '0';

end Behavioral;