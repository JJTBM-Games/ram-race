library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.STD_LOGIC_UNSigned.ALL;

entity grid_controller is
    Port ( CLK_100 : in STD_LOGIC;
           CLK_400 : in STD_LOGIC;
           
           enGame : in STD_LOGIC;
           reset : in STD_LOGIC;
           
           HLOC_IN : in integer; 
           VLOC_IN : in integer;
           
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
    signal p1_powerup : integer := 0;
    
    signal p2_loc : integer := 1151;       -- Starting position as default value for first level
    signal p2_allowed_up, p2_allowed_down, p2_allowed_right, p2_allowed_left : std_logic;
    signal p2_powerup : integer := 0;
    
    ---------------------------
    -- Powerup locations
    signal mb_loc1 : integer := 1139;
    
    ---------------------------
    
    
    ---------------------------
    --Constants containing cell sprite number standard (sn stands for sprite number)
    
    constant a_sn : integer := 0;
    constant b_sn : integer := 1;
    constant c_sn : integer := 2;
    constant d_sn : integer := 3;
    constant e_sn : integer := 4;
    constant f_sn : integer := 5;
    constant g_sn : integer := 6;
    constant h_sn : integer := 7;
    constant i_sn : integer := 8;
    constant j_sn : integer := 9;
    constant k_sn : integer := 10;
    constant l_sn : integer := 11;
    constant m_sn : integer := 12;
    constant n_sn : integer := 13;
    constant o_sn : integer := 14;
    constant p_sn : integer := 15;
    constant q_sn : integer := 16;
    constant r_sn : integer := 17;
    constant s_sn : integer := 18;
    constant t_sn : integer := 19;
    constant u_sn : integer := 20;
    constant v_sn : integer := 21;
    constant w_sn : integer := 22;
    constant x_sn : integer := 23;
    constant y_sn : integer := 24;
    constant z_sn : integer := 25;
    
    constant colon_sn : integer := 26;
    constant exclamation_sn : integer := 27;
    constant question_sn : integer := 28;
    
    constant zero_sn : integer := 29;
    constant one_sn : integer := 30;
    constant two_sn : integer := 31;
    constant three_sn : integer := 32;
    constant four_sn : integer := 33;
    constant five_sn : integer := 34;
    constant six_sn : integer := 35;
    constant seven_sn : integer := 36;
    constant eight_sn : integer := 37;
    constant nine_sn : integer := 38;
    
    constant border_sn : integer := 40;
    constant wall_sn : integer := 41;
    constant floor_sn : integer := 42;
    
    constant red_sn : integer := 43;
    constant blue_sn : integer := 44;
    constant wood_sn : integer := 45;
    
    constant finish_sn : integer := 46;
    constant powerup_slot_sn : integer := 47;
    constant wall_break_sn : integer := 48;
    constant sky_sn : integer := 49;
    constant gray_sn : integer := 50;
    
    constant trophy1_sn : integer := 51; 
    constant trophy2_sn : integer := 52;
    constant trophy3_sn : integer := 53;
    constant trophy4_sn : integer := 54;
    
    ---------------------------
    
    
    signal level_addra : STD_LOGIC_VECTOR( 10 downto 0 );
    signal level_douta : STD_LOGIC_VECTOR( 30 downto 0 );
   
    component level is
            port (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
                douta : OUT STD_LOGIC_VECTOR(30 DOWNTO 0));    
    end component level;
    
    signal font_addra : STD_LOGIC_VECTOR(13 downto 0);
    signal font_douta : STD_LOGIC_VECTOR(11 downto 0);
   
    component font_sprites is
            port (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
                douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));    
    end component font_sprites;
    
    signal player_addra : STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal player_douta : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    component player_sprite IS
      Port (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
      );
    end component player_sprite;
    
    signal powerup_addra : STD_LOGIC_VECTOR(13 downto 0);
    signal powerup_douta : STD_LOGIC_VECTOR(11 downto 0);
    
    component powerup_sprites is
            port (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
                douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));    
    end component powerup_sprites;
    
    signal asset_addra : STD_LOGIC_VECTOR(11 downto 0);
    signal asset_douta : STD_LOGIC_VECTOR(11 downto 0);
    
    component asset_sprites is
            port (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
                douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));    
    end component asset_sprites;
begin

levels : level port map(
    clka => CLK_400,
    ena => '1',
    
    addra => level_addra,
    douta => level_douta
  );
  
font : font_sprites port map (
    clka => CLK_400,
    ena => '1',
    
    addra => font_addra,
    douta => font_douta
);
  
player : player_sprite port map (
    clka => CLK_400,
    ena => '1',
    
    addra => player_addra,
    douta => player_douta
);

powerup : powerup_sprites port map (
    clka => CLK_400,
    ena => '1',
    
    addra => powerup_addra,
    douta => powerup_douta
);

assets : asset_sprites port map (
    clka => CLK_400,
    ena => '1',
    
    addra => asset_addra,
    douta => asset_douta
);

current_cell_number : process(CLK_400)
begin
    if (rising_edge(CLK_400)) then
        -- Calculate cell x index by dividing the horizontal pixel location by the cell width
        -- The half of cell width (16 pixels) is added to the HLOC to fix the screen from determining cells to late
        -- We also add 0.5 to the result to make sure the rounding is done correctly
        -- Lowest number is 1
        cellX <= integer(((HLOC_IN + (CELL_WIDTH / 2)) + (CELL_WIDTH / 2)) / CELL_WIDTH);
        
        -- Calculate cell y index by dividing the vertical pixel location by the cell height
         -- The half of cell height (16 pixels) is added to the HLOC to fix the screen from determining cells to late
         -- Lowest number is 1
        cellY <= integer(((VLOC_IN + (CELL_HEIGHT / 2)) + (CELL_HEIGHT / 2)) / CELL_HEIGHT);
        
        -- Calculate current cell number by multiplying y index with amount of horizontal cells
        -- Substrect the amount of horizontal cells minus the x index from this value to get the right number
        cellNumber <= (cellY * CELL_X_AMOUNT) - (CELL_X_AMOUNT - cellX);
    end if;
end process;

current_cell_pixel : process(CLK_100)
begin
    if (rising_edge(CLK_100)) then
        -- Magic formula don't touch  
        cellPixel <= ((((VLOC_IN - ((cellY - 1) * CELL_HEIGHT)) + 1) * CELL_WIDTH) - (CELL_WIDTH - ((HLOC_IN - ((cellX - 1) * CELL_WIDTH)) + 1))) - 1;
    end if;
end process;

level_count_test : process(CLK_100)
begin
    if (rising_edge(CLK_100)) then
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

current_cell_sprite : process(CLK_100)
begin
    if (rising_edge(CLK_100)) then
        if( reset = '1' ) THEN
            p1_loc <= 1130;
            p2_loc <= 1151;
        END IF;
    
        -- If enGame = 0 (playing) and reset (menu) = 1, than show main menu
        -- If enGame = 1 (playing) and reset (menu) = 1, show settings
        
        -- Determine the sprite of the current cell and it's RGB values using the current cell number (minus one because array starts at zero)
        level_addra <=  std_logic_vector(to_unsigned((cellNumber - 1), 11));
        cellSpriteNumber <= to_integer(unsigned(level_douta));
      
        if (cellSpriteNumber = border_sn) then  -- Border
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
        
            RGB_DATA <= "000000110101";
            
        elsif (cellSpriteNumber = wall_sn) then -- Wall
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
            
            RGB_DATA <= "010001000100";

        elsif (cellSpriteNumber = red_sn) then -- Red
            RGB_DATA <= "110000010010";
                    
        elsif (cellSpriteNumber = blue_sn) then -- Blue
            RGB_DATA <= "000010011111";
            
        elsif (cellSpriteNumber = gray_sn) then -- Gray
            RGB_DATA <= "101010111100";
            
        elsif (cellSpriteNumber = sky_sn) then -- Sky
            RGB_DATA <= "101011011111";
            
        elsif (cellSpriteNumber = wood_sn) then -- Wood
            RGB_DATA <= "010100110000";  
            
        elsif (cellSpriteNumber = finish_sn) then -- Finish
            asset_addra <= std_logic_vector(to_unsigned(((0 * 256) + cellPixel), 12));
            RGB_DATA <= asset_douta;  
        
        -- Trophy
        elsif (cellSpriteNumber = trophy1_sn) then 
            asset_addra <= std_logic_vector(to_unsigned(((1 * 256) + cellPixel), 12));
            RGB_DATA <= asset_douta;  
        elsif (cellSpriteNumber = trophy2_sn) then 
            asset_addra <= std_logic_vector(to_unsigned(((2 * 256) + cellPixel), 12));
            RGB_DATA <= asset_douta;   
        elsif (cellSpriteNumber = trophy3_sn) then 
            asset_addra <= std_logic_vector(to_unsigned(((3 * 256) + cellPixel), 12));
            RGB_DATA <= asset_douta;   
        elsif (cellSpriteNumber = trophy4_sn) then 
            asset_addra <= std_logic_vector(to_unsigned(((4 * 256) + cellPixel), 12));
            RGB_DATA <= asset_douta;  

        elsif (cellSpriteNumber = floor_sn) then -- Floor
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
                player_addra <= std_logic_vector(to_unsigned(((0 * 256) + cellPixel), 10));
                RGB_DATA <= player_douta;
            elsif (cellNumber = p2_loc) then
                player_addra <= std_logic_vector(to_unsigned(((0 * 256) + cellPixel), 10));
                RGB_DATA <= player_douta;
            else
                RGB_DATA <= "000010100010"; -- Player is not on floor
            end if;
            
        elsif (cellSpriteNumber = a_sn) then -- Letter A
            font_addra <= std_logic_vector(to_unsigned(((a_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = b_sn) then -- Letter B
            font_addra <= std_logic_vector(to_unsigned(((b_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = c_sn) then -- Letter C
            font_addra <= std_logic_vector(to_unsigned(((c_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = d_sn) then -- Letter D
            font_addra <= std_logic_vector(to_unsigned(((d_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = e_sn) then -- Letter E
            font_addra <= std_logic_vector(to_unsigned(((e_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = f_sn) then -- Letter F
            font_addra <= std_logic_vector(to_unsigned(((f_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = g_sn) then -- Letter G
            font_addra <= std_logic_vector(to_unsigned(((g_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = h_sn) then -- Letter H
            font_addra <= std_logic_vector(to_unsigned(((h_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = i_sn) then -- Letter I
            font_addra <= std_logic_vector(to_unsigned(((i_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = j_sn) then -- Letter J
            font_addra <= std_logic_vector(to_unsigned(((j_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = k_sn) then -- Letter K
            font_addra <= std_logic_vector(to_unsigned(((k_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = l_sn) then -- Letter L
            font_addra <= std_logic_vector(to_unsigned(((l_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = m_sn) then -- Letter M
            font_addra <= std_logic_vector(to_unsigned(((m_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = n_sn) then -- Letter N
            font_addra <= std_logic_vector(to_unsigned(((n_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = o_sn) then -- Letter O
            font_addra <= std_logic_vector(to_unsigned(((o_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = p_sn) then -- Letter P
            font_addra <= std_logic_vector(to_unsigned(((p_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = q_sn) then -- Letter Q
            font_addra <= std_logic_vector(to_unsigned(((q_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = r_sn) then -- Letter R
            font_addra <= std_logic_vector(to_unsigned(((r_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = s_sn) then -- Letter S
            font_addra <= std_logic_vector(to_unsigned(((s_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;   
        elsif (cellSpriteNumber = t_sn) then -- Letter T
            font_addra <= std_logic_vector(to_unsigned(((t_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;     
        elsif (cellSpriteNumber = u_sn) then -- Letter U
            font_addra <= std_logic_vector(to_unsigned(((u_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;       
        elsif (cellSpriteNumber = v_sn) then -- Letter V
            font_addra <= std_logic_vector(to_unsigned(((v_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;     
        elsif (cellSpriteNumber = w_sn) then -- Letter W
            font_addra <= std_logic_vector(to_unsigned(((w_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = x_sn) then -- Letter X
            font_addra <= std_logic_vector(to_unsigned(((x_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = y_sn) then -- Letter Y
            font_addra <= std_logic_vector(to_unsigned(((y_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;         
        elsif (cellSpriteNumber = z_sn) then -- Letter Z
            font_addra <= std_logic_vector(to_unsigned(((z_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;  
            
        elsif (cellSpriteNumber = zero_sn) then -- Number 0
            font_addra <= std_logic_vector(to_unsigned(((zero_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = one_sn) then -- Number 1
            font_addra <= std_logic_vector(to_unsigned(((one_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = two_sn) then -- Number 2
            font_addra <= std_logic_vector(to_unsigned(((two_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = three_sn) then -- Number 3
            font_addra <= std_logic_vector(to_unsigned(((three_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = four_sn) then -- Number 4
            font_addra <= std_logic_vector(to_unsigned(((four_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = five_sn) then -- Number 5
            font_addra <= std_logic_vector(to_unsigned(((five_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = six_sn) then -- Number 6
            font_addra <= std_logic_vector(to_unsigned(((six_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = seven_sn) then -- Number 7
            font_addra <= std_logic_vector(to_unsigned(((seven_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = eight_sn) then -- Number 8
            font_addra <= std_logic_vector(to_unsigned(((eight_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = nine_sn) then -- Number 9
            font_addra <= std_logic_vector(to_unsigned(((nine_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = question_sn) then -- Question mark
            font_addra <= std_logic_vector(to_unsigned(((question_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = exclamation_sn) then -- Exclamation mark
            font_addra <= std_logic_vector(to_unsigned(((exclamation_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = colon_sn) then -- Colon
            font_addra <= std_logic_vector(to_unsigned(((colon_sn * 256) + cellPixel), 14));
            RGB_DATA <= font_douta; 
            
        elsif (cellSpriteNumber = powerup_slot_sn) then -- Powerup slot
            if (p1_powerup = 1) then
                powerup_addra <= std_logic_vector(to_unsigned(((0 * 256) + cellPixel), 14));
                RGB_DATA <= powerup_douta;   
            else
                font_addra <= std_logic_vector(to_unsigned(((question_sn * 256) + cellPixel), 14));
                RGB_DATA <= font_douta; 
            end if;   
        elsif (cellSpriteNumber = 1139) then -- Mystery box
            powerup_addra <= std_logic_vector(to_unsigned(((0 * 256) + cellPixel), 14));
            RGB_DATA <= powerup_douta;          
                                                                     
        elsif (cellSpriteNumber = 10) then -- Level display
--            if (level_test_count = 0) then 
--                zero_sprite_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 8));
--                RGB_DATA <= zero_sprite_douta;
--            elsif (level_test_count = 1) then
--                one_sprite_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 8));
--                RGB_DATA <= one_sprite_douta;
--            elsif (level_test_count = 2) then
--                two_sprite_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 8));
--                RGB_DATA <= two_sprite_douta;
--            elsif (level_test_count = 3) then
--                three_sprite_addra <= std_logic_vector(to_unsigned((cellPixel - 1), 8));
--                RGB_DATA <= three_sprite_douta;
--            end if;
            RGB_DATA <= "101010111100";
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

gameplay : process(CLK_100)
    BEGIN
    IF(rising_edge(CLK_100)) THEN
          -- Finish
          IF (p1_loc = 298) THEN
            endGame <= '1';
          ELSIF (p2_loc = 303) THEN
            endGame <= '1';
            
          -- Powerups
          ELSIF (p1_loc = 1139) THEN
            mb_loc1 <= -1;
            p1_powerup <= 1;
          ELSIF (reset = '1') THEN
            endGame <= '0';
          else
            endGame <= '0';
          END IF;  
      END IF;
    END PROCESS;
end Behavioral;