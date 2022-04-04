library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_controller is
     Port ( CLK : in STD_LOGIC;
        
            VIS : out STD_LOGIC;
        
            HSYNC : out STD_LOGIC;   
            VSYNC : out STD_LOGIC;  
    
            HLOC : out integer; 
            VLOC : out integer);        
end display_controller;

architecture Behavioral of display_controller is

    -- VGA timings overview: http://tinyvga.com/vga-timing
    --                     : https://www.ibm.com/docs/en/power8?topic=display-supported-resolution-timing-charts
    
    constant  HD : integer := 640;         -- Horizontal display (1280 pixels) 
    constant  HFP : integer := 16;          -- Horizontal front porch (48 pixels)
    constant  HBP : integer := 48;         -- Horizontal back porch (248 pixels)
    constant  HSP : integer := 96;         -- Horizontal sync pulse (112 pixels)
       
    constant  VD : integer := 480;         -- Vertical display (1024 pixels)
    constant  VFP : integer := 10;           -- Vertical front porch (1 pixel)
    constant  VBP : integer := 33;          -- Vertical back porch (38 pixels)
    constant  VSP : integer := 2;           -- Vertical sync pulse (3 pixels)
    
    signal hCount : integer := 0;           -- Start counting at one
    signal vCount : integer := 0;
    
    signal h_vis : STD_LOGIC;
    signal v_vis : STD_LOGIC;

begin

pos_controller : process(CLK, hCount)
begin  
    if (rising_edge(CLK)) then
        -- Horizontal position
        if (hCount < HD + HFP + HBP + HSP - 1) then   -- Check if horizontal count is max (end of line reached)
            hCount <= hCount + 1;
        else
            hCount <= 0;
            
            -- Vertical position
            if (vCount < VD + VFP + VBP + VSP) then
                vCount <= vCount + 1;
		    else
                vCount <= 0;
            end if;
        end if;
        
        -- Horizontal sync
        if (hCount >= (HD + HFP + HFP) and hCount < (HD + HFP + HSP - HFP)) then
            HSYNC <= '0';   -- Active low sync pulse after front porch and before back porch
        else
            HSYNC <= '1';
        end if;
        
        -- Vertical sync
        if (vCount >= (VD + VFP) and vCount < (VD + VFP + VSP)) then
            VSYNC <= '0';   -- Active low sync pulse after front porch and before back porch
        else
            VSYNC <= '1';
        end if;
        
        -- Flags to say that this pixel is in the visible range
		if (hCount >= HFP and hCount < (HD + HFP)) then
		    h_vis <= '1';
		else
		    h_vis <= '0';
		end if;
		
		if (vCount < VD) then
		    v_vis <= '1';
	    else
			v_vis <= '0';
		end if;
		
		HLOC <= hCount - 16;   
        VLOC <= vCount;
    end if;
end process;

-- Handles the color visibility on the screen
visibility_handler : process(CLK)
begin
    if (rising_edge(CLK)) then
        if (h_vis = '1' AND v_vis = '1') then
            VIS <= '1';
        else
            VIS <= '0';
        end if;
    end if;
end process;

end Behavioral;
