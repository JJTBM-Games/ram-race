library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.STD_LOGIC_UNSigned.ALL;

entity grid_controller is
    Port ( CLK : in STD_LOGIC;
           
           enGame : in STD_LOGIC;
           reset : in STD_LOGIC;
           
           HLOC : in integer; 
           VLOC : in integer;
           
           endGame : out STD_LOGIC;
           
           P1_UP, P1_RIGHT, P1_DOWN, P1_LEFT : in STD_LOGIC;
           P2_UP, P2_RIGHT, P2_DOWN, P2_LEFT : in STD_LOGIC;

           RGB_DATA : out STD_LOGIC_VECTOR (0 TO 11));
end grid_controller;

architecture Behavioral of grid_controller is

    constant HD : integer := 640;      -- Horizontal display (640 pixels) 
    constant VD : integer := 480;      -- Vertical display (480 pixels)

    constant CELL_WIDTH : integer := 16;
    constant CELL_HEIGHT : integer := 16;
    
    constant CELL_X_AMOUNT : integer := HD / CELL_WIDTH;    -- Should result in 40
    constant CELL_Y_AMOUNT : integer := VD / CELL_HEIGHT;   -- Should result in 30
    
    signal cellX : integer := 0;
    signal cellY : integer := 0;
    
    signal cellNumber : integer := 0;
    signal cellPixel : integer := 0;
    signal cellSpriteNumber : integer := 0;
    
    signal count : integer := 0;
    signal level_test_count : integer := 0;

    signal p1_loc : integer := 1130;       -- Starting position as default value for first level
    signal p1_allowed_up, p1_allowed_down, p1_allowed_right, p1_allowed_left : std_logic;
    
    signal p2_loc : integer := 1151;       -- Starting position as default value for first level
    signal p2_allowed_up, p2_allowed_down, p2_allowed_right, p2_allowed_left : std_logic;
    
    signal DATA_level : STD_LOGIC_VECTOR( 31 downto 0 );
    signal addr_level : STD_LOGIC_VECTOR( 10 downto 0 ) := (others => '0');
   
    component level is
            port (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
                douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));    
    end component level;
    
    signal L_sprite_addra : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal L_sprite_douta : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    component L_sprite is
        Port (  clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
                douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));
    end component;
    
    signal E_sprite_addra : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal E_sprite_douta : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    component E_sprite is
        Port ( clka : IN STD_LOGIC;
               ena : IN STD_LOGIC;
               addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
               douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));
    end component;
    
    signal V_sprite_addra : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal V_sprite_douta : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    component V_sprite is
        Port ( clka : IN STD_LOGIC;
               ena : IN STD_LOGIC;
               addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
               douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));
    end component;
    
    signal zero_sprite_addra : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal zero_sprite_douta : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    component zero_sprite is
        Port ( clka : IN STD_LOGIC;
               ena : IN STD_LOGIC;
               addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
               douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));
    end component;
    
    signal one_sprite_addra : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal one_sprite_douta : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    component one_sprite is
        Port ( clka : IN STD_LOGIC;
               ena : IN STD_LOGIC;
               addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
               douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));
    end component;
    
    signal two_sprite_addra : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal two_sprite_douta : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    component two_sprite is
        Port ( clka : IN STD_LOGIC;
               ena : IN STD_LOGIC;
               addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
               douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));
    end component;
    
    signal three_sprite_addra : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal three_sprite_douta : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    component three_sprite is
        Port ( clka : IN STD_LOGIC;
               ena : IN STD_LOGIC;
               addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
               douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));
    end component;
    
    signal Player_one_addra : STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal Player_one_douta : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    signal Player_two_addra : STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal Player_two_douta : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    component player_one_sprite IS
      Port (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
      );
    end component player_one_sprite;
begin

L_sprite_map : L_sprite port map (
    clka => CLK,
    ena => '1',
    
    addra => L_sprite_addra,
    douta => L_sprite_douta
);

E_sprite_map : E_sprite port map (
    clka => CLK,
    ena => '1',
    
    addra => E_sprite_addra,
    douta => E_sprite_douta
);

V_sprite_map : V_sprite port map (
    clka => CLK,
    ena => '1',
    
    addra => V_sprite_addra,
    douta => V_sprite_douta
);

zero_sprite_map : zero_sprite port map (
    clka => CLK,
    ena => '1',
    
    addra => zero_sprite_addra,
    douta => zero_sprite_douta
);

one_sprite_map : one_sprite port map (
    clka => CLK,
    ena => '1',
    
    addra => one_sprite_addra,
    douta => one_sprite_douta
);

two_sprite_map : two_sprite port map (
    clka => CLK,
    ena => '1',
    
    addra => two_sprite_addra,
    douta => two_sprite_douta
);

three_sprite_map : three_sprite port map (
    clka => CLK,
    ena => '1',
    
    addra => three_sprite_addra,
    douta => three_sprite_douta
);

level_one : level port map(
    clka => CLK,
    ena => '1',
    
    addra => addr_level,
    douta => DATA_level
  );
  
player_one : player_one_sprite port map (
    clka => CLK,
    ena => '1',
    
    addra => Player_one_addra,
    douta => Player_one_douta
);

player_two : player_one_sprite port map (
    clka => CLK,
    ena => '1',
    
    addra => Player_two_addra,
    douta => Player_two_douta
);

current_cell_number : process(CLK)
begin
    if (rising_edge(CLK)) then
        -- Calculate cell x index by dividing the horizontal pixel location by the cell width
        -- The half of cell width (16 pixels) is added to the HLOC to fix the screen from determining cells to late
        -- We also add 0.5 to the result to make sure the rounding is done correctly
        cellX <= integer(((HLOC + (CELL_WIDTH / 2)) + (CELL_WIDTH / 2)) / CELL_WIDTH);
        
        -- Calculate cell y index by dividing the vertical pixel location by the cell height
         -- The half of cell height (16 pixels) is added to the HLOC to fix the screen from determining cells to late
        cellY <= integer(((VLOC + (CELL_HEIGHT / 2)) + (CELL_HEIGHT / 2)) / CELL_HEIGHT);
        
        -- Calculate current cell number by multiplying y index with amount of horizontal cells
        -- Substrect the amount of horizontal cells minus the x index from this value to get the right number
        cellNumber <= (cellY * CELL_X_AMOUNT) - (CELL_X_AMOUNT - cellX);
    end if;
end process;

current_cell_pixel : process(CLK)
begin
    if (rising_edge(CLK)) then
        -- Magic formula don't touch
        cellPixel <= ((CELL_WIDTH * ((cellY * CELL_HEIGHT) - (CELL_HEIGHT * (cellY - 1)) - (cellY * CELL_HEIGHT - VLOC))) - ((cellX * CELL_WIDTH) - HLOC));
    end if;
end process;

level_count_test : process(CLK)
begin
    if (rising_edge(CLK)) then
        count <= count + 1;
        
        if (count = 100000000) then
            level_test_count <= level_test_count + 1;
            
            if (level_test_count = 3) then
                level_test_count <= 0;
            end if;
            
            count <= 0;
        end if;
    end if;
end process;

current_cell_sprite : process(CLK)
begin
    if (rising_edge(CLK)) then
        -- Determine the sprite of the current cell and it's RGB values using the current cell number (minus one because array starts at zero)
        addr_level <=  std_logic_vector(to_unsigned((cellNumber - 1), 11));
        cellSpriteNumber <= to_integer(unsigned(DATA_level));
      
        if (cellSpriteNumber = 0) then    -- White
            RGB_DATA <= "111111111111";
            
        elsif (cellSpriteNumber = 1) then -- Dark blue
            if (cellNumber = p1_loc - 40) then
                p1_allowed_up <= '0';
            elsif (cellNumber = p1_loc + 40) then
                p1_allowed_down <= '0';
            elsif (cellNumber = p1_loc - 1) then
                p1_allowed_left <= '0';
            elsif (cellNumber = p1_loc + 1) then
                p1_allowed_right <= '0';
            end if;
            if (cellNumber = p2_loc - 40) then
                p2_allowed_up <= '0';
            elsif (cellNumber = p2_loc + 40) then
                p2_allowed_down <= '0';
            elsif (cellNumber = p2_loc - 1) then
                p2_allowed_left <= '0';
            elsif (cellNumber = p2_loc + 1) then
                p2_allowed_right <= '0';
            end if;
        
            RGB_DATA <= "000000010101";
            
        elsif (cellSpriteNumber = 2) then -- Black / Wall
            if (cellNumber = p1_loc - 40) then
                p1_allowed_up <= '0';
            elsif (cellNumber = p1_loc + 40) then
                p1_allowed_down <= '0';
            elsif (cellNumber = p1_loc - 1) then
                p1_allowed_left <= '0';
            elsif (cellNumber = p1_loc + 1) then
                p1_allowed_right <= '0';
            end if;
            
            if (cellNumber = p2_loc - 40) then
                p2_allowed_up <= '0';
            elsif (cellNumber = p2_loc + 40) then
                p2_allowed_down <= '0';
            elsif (cellNumber = p2_loc - 1) then
                p2_allowed_left <= '0';
            elsif (cellNumber = p2_loc + 1) then
                p2_allowed_right <= '0';
            end if;
            
            RGB_DATA <= "000000000000";

        elsif (cellSpriteNumber = 3) then -- Red
            RGB_DATA <= "110000010010";
            
        elsif (cellSpriteNumber = 4) then -- Gray
            RGB_DATA <= "100110011001";
            
        elsif (cellSpriteNumber = 5) then -- Light blue
            RGB_DATA <= "000010011111";
            
        elsif (cellSpriteNumber = 6) then -- Floor
            if (cellNumber = p1_loc - 40) then
                p1_allowed_up <= '1';
            elsif (cellNumber = p1_loc + 40) then
                p1_allowed_down <= '1';
            elsif (cellNumber = p1_loc - 1) then
                p1_allowed_left <= '1';
            elsif (cellNumber = p1_loc + 1) then
                p1_allowed_right <= '1';
            end if;
            
            if (cellNumber = p2_loc - 40) then
                p2_allowed_up <= '1';
            elsif (cellNumber = p2_loc + 40) then
                p2_allowed_down <= '1';
            elsif (cellNumber = p2_loc - 1) then
                p2_allowed_left <= '1';
            elsif (cellNumber = p2_loc + 1) then
                p2_allowed_right <= '1';
            end if;
            
            if (cellNumber = p1_loc) then
                player_one_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 10));
                RGB_DATA <= player_one_douta;
            elsif (cellNumber = p2_loc) then
                player_two_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 10));
                RGB_DATA <= player_two_douta;
            else
                RGB_DATA <= "000010000000"; -- Player is not on floor
            end if;
            
        elsif (cellSpriteNumber = 7) then -- Letter L 
            L_sprite_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 8));
            RGB_DATA <= L_sprite_douta;
            
        elsif (cellSpriteNumber = 8) then -- Letter E 
            E_sprite_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 8));
            RGB_DATA <= E_sprite_douta;
            
        elsif (cellSpriteNumber = 9) then -- Letter V
            V_sprite_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 8));
            RGB_DATA <= V_sprite_douta;
            
        elsif (cellSpriteNumber = 10) then -- Level display
            if (level_test_count = 0) then 
                zero_sprite_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 8));
                RGB_DATA <= zero_sprite_douta;
            elsif (level_test_count = 1) then
                one_sprite_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 8));
                RGB_DATA <= one_sprite_douta;
            elsif (level_test_count = 2) then
                two_sprite_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 8));
                RGB_DATA <= two_sprite_douta;
            elsif (level_test_count = 3) then
                three_sprite_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 8));
                RGB_DATA <= three_sprite_douta;
            end if;
        elsif(cellSpriteNumber = 11) THEN
            RGB_DATA <= "111111000100";
        end if;
        
        IF ( enGame = '1' ) THEN
            
                if (P1_UP = '1') then
                if (p1_allowed_up = '1') then
                    p1_loc <= p1_loc - 40;
                    p1_allowed_up <= '0';
                end if;
            elsif (P1_RIGHT = '1') then
                if (p1_allowed_right = '1') then
                    p1_loc <= p1_loc + 1;
                    p1_allowed_right <= '0';
                end if;
            elsif (P1_DOWN = '1') then
                if (p1_allowed_down = '1') then
                    p1_loc <= p1_loc + 40;
                    p1_allowed_down <= '0';
                end if;
            elsif (P1_LEFT = '1') then
                if (p1_allowed_left = '1') then
                    p1_loc <= p1_loc - 1;
                    p1_allowed_left <= '0';
                end if;
            end if;
            
            if (P2_UP = '1') then
                if (p2_allowed_up = '1') then
                    p2_loc <= p2_loc - 40;
                    p2_allowed_up <= '0';
                end if;
            elsif (P2_RIGHT = '1') then
                if (p2_allowed_right = '1') then
                    p2_loc <= p2_loc + 1;
                    p2_allowed_right <= '0';
                end if;
            elsif (P2_DOWN = '1') then
                if (p2_allowed_down = '1') then
                    p2_loc <= p2_loc + 40;
                    p2_allowed_down <= '0';
                end if;
            elsif (P2_LEFT = '1') then
                if (p2_allowed_left = '1') then
                    p2_loc <= p2_loc - 1;
                    p2_allowed_left <= '0';
                end if;
            end if;
        END IF;
    end if;
end process;

gameplay : process(CLK)
    BEGIN
    IF(rising_edge(CLK)) THEN
          IF (p1_loc = 300) THEN
            endGame <= '1';
          ELSIF (p2_loc = 301) THEN
            endGame <= '1';
          ELSIF (reset = '1') THEN
            p1_loc <= 1130;
            p2_loc <= 1151;
            endGame <= '0';
          else
            endGame <= '0';
          END IF;  
      END IF;
    END PROCESS;

end Behavioral;