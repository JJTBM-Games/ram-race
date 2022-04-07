library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.STD_LOGIC_UNSigned.ALL;

entity grid_controller is
    Port ( CLK_100 : in STD_LOGIC;
           CLK_400 : in STD_LOGIC;
           CLK_25 : in STD_LOGIC;
           
           enGame : in STD_LOGIC;
           reset : in STD_LOGIC;
           show_score : in STD_LOGIC;
           show_name : in STD_LOGIC;
           save_score : in STD_LOGIC;
           score_saved : out STD_LOGIC;
           
           HLOC_IN : in integer; 
           VLOC_IN : in integer;
           
           cheat_mode : in STD_LOGIC;
           reset_score : in STD_LOGIC;
           endGame : out STD_LOGIC;
           selection : out STD_LOGIC;
           both_ok : out STD_LOGIC;
                       
           sfx_mute : in STD_LOGIC;
           msc_mute: in STD_LOGIC;
           mute : in STD_LOGIC;
           
           msc_out : out STD_LOGIC;
           sfx_out : out STD_LOGIC;
           
           P1_UP, P1_RIGHT, P1_DOWN, P1_LEFT : in STD_LOGIC;
           P2_UP, P2_RIGHT, P2_DOWN, P2_LEFT : in STD_LOGIC;

           RGB_DATA : buffer STD_LOGIC_VECTOR (0 TO 11));
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
    
    signal level_start_count_ticks : integer := 0;
    signal level_start_count : integer := 5;

    signal p1_loc : integer := 1130;       -- Starting position as default value for first level
    signal p1_allowed_up, p1_allowed_down, p1_allowed_right, p1_allowed_left : std_logic;
    signal p1_powerup : integer := -1;
    signal p1_shield_remove : STD_LOGIC := '0';
    signal p1_shield_ticks : integer := 0;
    signal p1_score : integer := 0;
    
    signal p2_loc : integer := 1151;       -- Starting position as default value for first level
    signal p2_allowed_up, p2_allowed_down, p2_allowed_right, p2_allowed_left : std_logic;
    signal p2_powerup : integer := -1;
    signal p2_shield_remove : STD_LOGIC := '0';
    signal p2_shield_ticks : integer := 0;
    signal p2_score : integer := 0;
    
    signal current_level : integer := 0;
    signal start_level : STD_LOGIC := '0';
    
    signal level_transistion : STD_LOGIC := '1';
    signal level_transistion_ticks : integer := 0;
    signal level_transistion_count : integer := 0;
    
    signal name_transistion : STD_LOGIC := '1';
    signal name_transistion_ticks : integer := 0;
    signal name_transistion_count : integer := 0;
    
    signal score_transistion : STD_LOGIC := '1';
    signal score_transistion_ticks : integer := 0;
    signal score_transistion_count : integer := 0;
    
    ---------------------------
    -- Powerup locations
    type locations3 is array (0 to 2) of integer;
    signal bw_locations1 : locations3 := (334, 539, 242);
    signal bw_locations2 : locations3 := (347, 542, 279);
    signal shield_locations1 : locations3 := (1125, 1125, -1);
    signal shield_locations2 : locations3 := (1156, 1156, -1);
    signal crystal1_locations1 : locations3 := (1097, 1097, -1);
    signal crystal1_locations2 : locations3 := (1104, 1104, -1);
    signal crystal2_locations1 : locations3 := (739, 739, -1);
    signal crystal2_locations2 : locations3 := (742, 742, -1);
    signal crystal3_locations1 : locations3 := (402, 402, -1);
    signal crystal3_locations2 : locations3 := (439, 439, -1);
    
    signal p1_break_walls : locations3 := (494, 336, 378);
    signal p2_break_walls : locations3 := (507, 345, 383);
    
    ---------------------------
    
    signal time_ticks : integer := 0;
    signal time_seconds : integer := 0;
    signal time_seconds_tens : integer := 0;
    signal time_minutes : integer := 0;

    signal msc_sel, sfx_sel : STD_LOGIC_VECTOR(1 downto 0);
    signal msc_en : STD_LOGIC := '1';
    signal sfx_en : STD_LOGIC := '0';
    signal sfx_count : integer := 0;
    
    ---------------------------
    -- Lazer signals
    signal counter_lazers : integer := 0;
    signal lazer_tick : STD_LOGIC := '0';
    
    constant npc_up_loc : integer := 404;
    constant npc_down_loc : integer := 257;
    constant npc_left_loc : integer := 725;
    constant npc_right_loc : integer := 607;
    
    constant npc2_up_loc : integer := 437;
    constant npc2_down_loc : integer := 264;
    constant npc2_left_loc : integer := 634;
    constant npc2_right_loc : integer := 756;
    
    ---------------------------
    --Player animation
    signal counter_player : integer := 0;
    signal frame_player : STD_LOGIC_VECTOR(1 downto 0);
    signal player_base : integer := 0;
    
    signal animation_index_p1 : integer := 0;
    signal animation_index_p2 : integer := 0;
    
    signal damage_counter_p1 : integer := 0;
    signal damage_counter_p2 : integer := 0;
    
    signal show_damage_p1 : STD_LOGIC := '0';
    signal show_damage_p2 : STD_LOGIC := '0';

    signal damage_p1 : STD_LOGIC := '0';
    signal damage_p2 : STD_LOGIC := '0';
    
    ---------------------------
    --start screen selector
    
    signal sel_position : STD_LOGIC := '1';
    
    ---------------------------
    -- Name selector
    
    signal L11, L12, L13, L14 : integer := 0; -- p1
    signal L21, L22, L23, L24 : integer := 0; -- p2
    signal selected1, selected2 : STD_LOGIC_VECTOR( 2 downto 0) := "000";
    signal cursor1 : integer := 375;
    signal cursor2 : integer := 382;
    
    ---------------------------
    -- Amount of levels for reset cycle
    
    constant amount_of_levels : integer := 3;
    
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
    constant powerup_slot1_sn : integer := 47;
    constant wall_break_sn : integer := 48;
    constant sky_sn : integer := 49;
    constant gray_sn : integer := 50;
    
    constant trophy1_sn : integer := 51; 
    constant trophy2_sn : integer := 52;
    constant trophy3_sn : integer := 53;
    constant trophy4_sn : integer := 54;
    
    constant time_seconds_slot : integer := 55;
    constant time_seconds_tens_slot : integer := 56;
    constant time_minutes_slot : integer := 57;
    
    constant level_slot : integer := 58;
    
    constant npc_down : integer := 59;
    constant npc_left : integer := 60;
    constant npc_right : integer := 61;
    constant npc_up : integer := 62;
    
    constant powerup_slot2_sn : integer := 63;
    
    constant score_ones_slot : integer := 64;
    constant score_tens_slot : integer := 65;
    constant score_hunderds_slot : integer := 66;
    
    constant score2_ones_slot : integer := 67;
    constant score2_tens_slot : integer := 68;
    constant score2_hunderds_slot : integer := 69;

    constant name1_1 : integer := 71;
    constant name1_2 : integer := 72;
    constant name1_3 : integer := 73;
    constant name1_4 : integer := 74;
    constant name2_1 : integer := 75;
    constant name2_2 : integer := 76;
    constant name2_3 : integer := 77;
    constant name2_4 : integer := 78;
    
    constant checkmark : integer := 79; 

    constant cloud : integer := 80; -- #000000
    constant sun_orange : integer := 81; -- #FF9900
    constant sun_yellow : integer := 82; -- #FFDD33
    constant green : integer := 83;
    constant dark_grey : integer := 84;
    constant salmon : integer := 85;
    
    constant sel_highscore : integer := 86;
    constant sel_start : integer := 87;
    
    constant hs_num_100 : integer := 90;
    constant hs_num_10 : integer := 89;
    constant hs_num_1 : integer := 88;
    
    signal high_1, high_2, high_3, high_4, score_to_save : integer := 0;
    signal set_highscore : std_logic := '0';
    signal high_letter_1, high_letter_2, high_letter_3, high_letter_4 : integer := 0;
    signal highscore_saved : integer := 0;
    signal score_ready : std_logic := '0';
    
    component highscores is 
            Port ( clk_100 : in STD_LOGIC;
                   L1 : in integer;
                   L2 : in integer;
                   L3 : in integer;
                   L4 : in integer;
                   set : in STD_LOGIC;
                   score : in integer;
                   highscore : out integer;
                   L1_out : out integer;
                   L2_out : out integer;
                   L3_out : out integer;
                   L4_out : out integer);
   end component highscores;
   
  
    
    signal level_addra : STD_LOGIC_VECTOR( 11 downto 0 );
    signal level_douta : STD_LOGIC_VECTOR( 30 downto 0 );
   
    component level is
            port (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
                douta : OUT STD_LOGIC_VECTOR(30 DOWNTO 0));    
    end component level;
    
    signal score_addra : STD_LOGIC_VECTOR( 10 downto 0 );
    signal score_douta : STD_LOGIC_VECTOR( 30 downto 0 );
   
    component score_screen is
            port (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
                douta : OUT STD_LOGIC_VECTOR(30 DOWNTO 0));    
    end component score_screen;
    
    signal menu_addra : STD_LOGIC_VECTOR( 10 downto 0 );
    signal menu_douta : STD_LOGIC_VECTOR( 30 downto 0 );
   
    component start_screen is
            port (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
                douta : OUT STD_LOGIC_VECTOR(30 DOWNTO 0));    
    end component start_screen;
    
    signal name_addra : STD_LOGIC_VECTOR( 10 downto 0 );
    signal name_douta : STD_LOGIC_VECTOR( 30 downto 0 );
   
    component set_name_sprite is
            port (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
                douta : OUT STD_LOGIC_VECTOR(30 DOWNTO 0));    
    end component set_name_sprite;
    
    signal font_addra : STD_LOGIC_VECTOR(13 downto 0);
    signal font_douta : STD_LOGIC_VECTOR(11 downto 0);
   
    component font_sprites is
            port (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
                douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));    
    end component font_sprites;
    
    signal player_addra : STD_LOGIC_VECTOR(12 DOWNTO 0);
    signal player_douta : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    component player_sprite IS
      Port (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
      );
    end component player_sprite;
    
    signal powerup_addra : STD_LOGIC_VECTOR(11 downto 0);
    signal powerup_douta : STD_LOGIC_VECTOR(11 downto 0);
    
    component powerup_sprites is
            port (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
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
    
    signal npc_addra : STD_LOGIC_VECTOR(11 downto 0);
    signal npc_douta : STD_LOGIC_VECTOR(11 downto 0);
    
    component npc is
            port (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
                douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));    
    end component npc;
    
    
    
    
    COMPONENT sound is
    Port ( clk_in : in STD_LOGIC;
           en_msc : in STD_LOGIC;
           en_sfx : in STD_LOGIC;
           sfx_mute : in STD_LOGIC;
           msc_mute: in STD_LOGIC;
           mute : in STD_LOGIC;
           msc_out : out STD_LOGIC;
           sfx_out : out STD_LOGIC;
           msc_sel : in STD_LOGIC_VECTOR(1 downto 0);
           sfx_sel : in STD_LOGIC_VECTOR(1 downto 0)
           );
    end COMPONENT sound;
    
begin

selection <= sel_position;
sfx_sel <= "01";
sfx_en <= lazer_tick;

score_ram : highscores port map(
               clk_100 => clk_100,
               L1 => high_1,
               L2 => high_2,
               L3 => high_3,
               L4 => high_4,
               set => set_highscore,
               score => score_to_save,
               highscore => highscore_saved,
               L1_out => high_letter_1,
               L2_out => high_letter_2,
               L3_out => high_letter_3,
               L4_out =>high_letter_4
);

scores : score_screen port map(
    clka => CLK_400,
    ena => '1',
    
    addra => score_addra,
    douta => score_douta
    );

levels : level port map(
    clka => CLK_400,
    ena => '1',
    
    addra => level_addra,
    douta => level_douta
  );
  
menu : start_screen port map(
    clka => CLK_400,
    ena => '1',
    
    addra => menu_addra,
    douta => menu_douta
  );
 
set_name : set_name_sprite port map(
    clka => CLK_400,
    ena => '1',
    
    addra => name_addra,
    douta => name_douta
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

npcs : npc port map (
    clka => CLK_400,
    ena => '1',
    
    addra => npc_addra,
    douta => npc_douta
);

S: sound Port Map(
           clk_in => CLK_100, 
           en_msc => msc_en,
           en_sfx => sfx_en,
           sfx_mute => sfx_mute,
           msc_mute => msc_mute,
           mute => mute,
           msc_out => msc_out,
           sfx_out => sfx_out,
           msc_sel => msc_sel,
           sfx_sel => sfx_sel);

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

current_cell_sprite : process(CLK_100)
begin
    if (rising_edge(CLK_100)) then
        if(reset_score = '1') then
            p1_score <= 0;
            p2_score <= 0;
            
            current_level <= 0;
            
            bw_locations1(0)  <= 334;
            bw_locations2(0)  <= 347;
            shield_locations1(0)  <= 1125;
            shield_locations2(0)  <= 1156;
            crystal1_locations1(0)  <= 1097;
            crystal1_locations2(0)  <= 1104;
            crystal2_locations1(0)  <= 739;
            crystal2_locations2(0)  <= 742;
            crystal3_locations1(0)  <= 402;
            crystal3_locations2(0) <= 439;
    
            p1_break_walls(0)  <= 494;
            p2_break_walls(0)  <= 507;

        end if;
        
       
        
        -- Resets player location (this is just for testing now, but will removed later)
        if( reset = '1' ) THEN
            p1_loc <= 1130;
            p2_loc <= 1151;
        END IF;
        
    
        -- If enGame = 0 (playing) and reset (menu) = 1, then show main menu
        if (enGame = '0' AND reset = '1') then  
            msc_sel <= "01";
            menu_addra <=  std_logic_vector(to_unsigned(cellNumber - 1, 11));
            cellSpriteNumber <= to_integer(unsigned(menu_douta));
            if ( p1_up = '1' ) then
                sel_position <= '0';
            elsif ( p1_down = '1') then
                sel_position <= '1';
            end if;
   
        elsif ( show_score = '1' ) then
            score_addra <=  std_logic_vector(to_unsigned(cellNumber - 1, 11));
            cellSpriteNumber <= to_integer(unsigned(score_douta));
            msc_sel <= "10";
            
            if (score_transistion = '1') then
                if (cellNumber <= score_transistion_count) then
                    score_addra <=  std_logic_vector(to_unsigned(cellNumber - 1, 11));
                    cellSpriteNumber <= to_integer(unsigned(score_douta));
                else
                    menu_addra <=  std_logic_vector(to_unsigned(cellNumber - 1, 11));
                    cellSpriteNumber <= to_integer(unsigned(menu_douta));
                end if;
            else
                score_addra <=  std_logic_vector(to_unsigned(cellNumber - 1, 11));
                cellSpriteNumber <= to_integer(unsigned(score_douta));
            end if;

        
        elsif (show_name = '1') then
            msc_sel <= "10";
                   
            if (name_transistion = '1') then
                if (cellNumber <= name_transistion_count) then
                    name_addra <=  std_logic_vector(to_unsigned(cellNumber - 1, 11));
                    cellSpriteNumber <= to_integer(unsigned(name_douta));
                else
                    menu_addra <=  std_logic_vector(to_unsigned(cellNumber - 1, 11));
                    cellSpriteNumber <= to_integer(unsigned(menu_douta));
                end if;
            else
                name_addra <=  std_logic_vector(to_unsigned(cellNumber - 1, 11));
                cellSpriteNumber <= to_integer(unsigned(name_douta));
            end if;
        
        -- If enGame = 1 (playing) and reset (menu) = 0, show current level
        elsif (enGame = '1' AND reset = '0') then 
            msc_sel <= "00";
        
            if (level_transistion = '1') then
                if (cellNumber <= level_transistion_count) then
                    level_addra <=  std_logic_vector(to_unsigned((current_level * 1200) + cellNumber - 1, 12));
                    cellSpriteNumber <= to_integer(unsigned(level_douta));   
                else
                    name_addra <=  std_logic_vector(to_unsigned(cellNumber - 1, 11));
                    cellSpriteNumber <= to_integer(unsigned(name_douta));
                end if;
            else 
                 level_addra <=  std_logic_vector(to_unsigned((current_level * 1200) + cellNumber - 1, 12));
                  cellSpriteNumber <= to_integer(unsigned(level_douta));   
            end if;
        end if;
        
        
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
                if (cheat_mode = '1') then
                    p1_allowed_up <= '1';
                else
                    p1_allowed_up <= '0';
                end if;
            elsif (cellNumber = p1_loc + 40) then
                if (cheat_mode = '1') then
                    p1_allowed_down <= '1';
                else
                    p1_allowed_down <= '0';
                end if;
            elsif (cellNumber = p1_loc - 1) then
                if (cheat_mode = '1') then
                    p1_allowed_left <= '1';
                else
                    p1_allowed_left <= '0';
                end if;
            elsif (cellNumber = p1_loc + 1) then
                if (cheat_mode = '1') then
                    p1_allowed_right <= '1';
                else
                    p1_allowed_right <= '0';
                end if;
            end if;
            
            if (cellNumber = p2_loc - 40) then
                if (cheat_mode = '1') then
                    p2_allowed_up <= '1';
                else
                    p2_allowed_up <= '0';
                end if;
            elsif (cellNumber = p2_loc + 40) then
                if (cheat_mode = '1') then
                    p2_allowed_down <= '1';
                else
                    p2_allowed_down <= '0';
                end if;
            elsif (cellNumber = p2_loc - 1) then
                if (cheat_mode = '1') then
                    p2_allowed_left <= '1';
                else
                    p2_allowed_left <= '0';
                end if;
            elsif (cellNumber = p2_loc + 1) then
                if (cheat_mode = '1') then
                    p2_allowed_right <= '1';
                else
                    p2_allowed_right <= '0';
                end if;
            end if;
            
            RGB_DATA <= "010001000100";
            
        elsif (cellSpriteNumber = red_sn) then -- Red
            RGB_DATA <= "110000010010";
                    
        elsif (cellSpriteNumber = blue_sn) then -- Blue
            RGB_DATA <= "000010011111";
            
        elsif (cellSpriteNumber = gray_sn) then -- Gray
        if (show_name = '1') then
                if (cellNumber = cursor1) then
                    font_addra <= std_logic_vector(to_unsigned(((39 * 256) + cellPixel), 14));
                    RGB_DATA <= font_douta;
                elsif (cellNumber = cursor2) then
                    font_addra <= std_logic_vector(to_unsigned(((39 * 256) + cellPixel), 14));
                    RGB_DATA <= font_douta;
                else
                    RGB_DATA <= "101010111100";
                end if;
            else
                RGB_DATA <= "101010111100";
            end if;
            
        elsif (cellSpriteNumber = sky_sn) then -- Sky
            RGB_DATA <= "101011011111";
        elsif (cellSpriteNumber = wood_sn) then -- Wood
            RGB_DATA <= "010100110000";  
            
        elsif (cellSpriteNumber = finish_sn) then -- Finish
            asset_addra <= std_logic_vector(to_unsigned(((0 * 256) + cellPixel), 12));
            RGB_DATA <= asset_douta;
            
            if (cellNumber = p1_loc - 40) then
                p1_allowed_up <= '1';
            elsif (cellNumber = p1_loc + 40) then
                p1_allowed_down <= '1';
            elsif (cellNumber = p1_loc - 1) then
                p1_allowed_left <= '1';
            elsif (cellNumber = p1_loc + 1) then
                p1_allowed_right <= '1';
            end if;
        
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
        
        -- Lazer display
            if (cellNumber = p1_loc - 40) then
                p1_allowed_up <= '1';
            elsif (cellNumber = p1_loc + 40) then
                p1_allowed_down <= '1';
            elsif (cellNumber = p1_loc - 1) then
                p1_allowed_left <= '1';
            elsif (cellNumber = p1_loc + 1) then
                p1_allowed_right <= '1';
            end if;
            
            if (p1_powerup /= 7) then
                -- Check if there is a breakable wall for p1
                if (cellNumber = p1_loc - 40 AND cellNumber = p1_break_walls(current_level)) then
                    p1_allowed_up <= '0';
                elsif (cellNumber = p1_loc + 40 AND cellNumber = p1_break_walls(current_level)) then
                    p1_allowed_down <= '0';
                elsif (cellNumber = p1_loc - 1 AND cellNumber = p1_break_walls(current_level)) then
                    p1_allowed_left <= '0';
                elsif (cellNumber = p1_loc + 1 AND cellNumber = p1_break_walls(current_level)) then
                    p1_allowed_right <= '0';
                end if;
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
            
            if (p2_powerup /= 7) then
                 -- Check if there is a breakable wall for p2
                if (cellNumber = p2_loc - 40 AND cellNumber = p2_break_walls(current_level)) then
                    p2_allowed_up <= '0';
                elsif (cellNumber = p2_loc + 40 AND cellNumber = p2_break_walls(current_level)) then
                    p2_allowed_down <= '0';
                elsif (cellNumber = p2_loc - 1 AND cellNumber = p2_break_walls(current_level)) then
                    p2_allowed_left <= '0';
                elsif (cellNumber = p2_loc + 1 AND cellNumber = p2_break_walls(current_level)) then
                    p2_allowed_right <= '0';
                end if;
            end if;
           
            if (cellNumber = p1_loc) then
                player_addra <= std_logic_vector(to_unsigned((((animation_index_p1 + player_base) * 256) + cellPixel), 13));
                RGB_DATA <= player_douta;
            elsif (cellNumber = p2_loc) then
                player_addra <= std_logic_vector(to_unsigned((((animation_index_p2 + player_base) * 256) + cellPixel), 13));
                RGB_DATA <= player_douta;
            elsif (cellNumber = npc_up_loc - 40) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((13 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc_up_loc - 80) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((12 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc_up_loc - 120) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((11 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc_down_loc + 40) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((11 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc_down_loc + 80) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((12 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc_down_loc + 120) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((13 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc_right_loc + 1) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((8 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc_right_loc + 2) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((9 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc_right_loc + 3) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((10 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc_left_loc - 1) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((10 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc_left_loc - 2) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((9 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc_left_loc - 3) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((8 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc2_up_loc - 40) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((13 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc2_up_loc - 80) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((12 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc2_up_loc - 120) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((11 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc2_down_loc + 40) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((11 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc2_down_loc + 80) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((12 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc2_down_loc + 120) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((13 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc2_right_loc + 1) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((8 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc2_right_loc + 2) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((9 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc2_right_loc + 3) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((10 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc2_left_loc - 1) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((10 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc2_left_loc - 2) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((9 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = npc2_left_loc - 3) then
                if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((8 * 256) + cellPixel), 12));
                RGB_DATA <= npc_douta;
                else
                RGB_DATA <= "000010100010";
                end if;
            elsif (cellNumber = bw_locations1(current_level) OR cellNumber = bw_locations2(current_level)) then
                powerup_addra <= std_logic_vector(to_unsigned(((7 * 256) + cellPixel), 12));
                RGB_DATA <= powerup_douta;
            elsif (cellNumber = shield_locations1(current_level) OR cellNumber = shield_locations2(current_level)) then
                powerup_addra <= std_logic_vector(to_unsigned(((1 * 256) + cellPixel), 12));
                RGB_DATA <= powerup_douta;
             elsif (cellNumber = crystal1_locations1(current_level) OR cellNumber = crystal1_locations2(current_level)) then
                powerup_addra <= std_logic_vector(to_unsigned(((8 * 256) + cellPixel), 12));
                RGB_DATA <= powerup_douta;
            elsif (cellNumber = crystal2_locations1(current_level) OR cellNumber = crystal2_locations2(current_level)) then
                powerup_addra <= std_logic_vector(to_unsigned(((9 * 256) + cellPixel), 12));
                RGB_DATA <= powerup_douta;
            elsif (cellNumber = crystal3_locations1(current_level) OR cellNumber = crystal3_locations2(current_level)) then
                powerup_addra <= std_logic_vector(to_unsigned(((10 * 256) + cellPixel), 12));
                RGB_DATA <= powerup_douta;
            elsif (cellNumber = p1_break_walls(current_level) OR cellNumber = p2_break_walls(current_level)) then
                asset_addra <= std_logic_vector(to_unsigned(((5 * 256) + cellPixel), 12));
                RGB_DATA <= asset_douta;  
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

        elsif (cellSpriteNumber = powerup_slot1_sn) then -- Powerup slot / start count display
            if (level_start_count /= 0) then
                font_addra <= std_logic_vector(to_unsigned((((29 + level_start_count) * 256) + cellPixel), 14));
                RGB_DATA <= font_douta; 
            else 
                if (p1_powerup /= -1) then
                    powerup_addra <= std_logic_vector(to_unsigned(((p1_powerup * 256) + cellPixel), 12));
                
                     -- Replace green floor with gray
                    if (powerup_douta = "000010100010") then
                        RGB_DATA <= "101010111100";
                    else
                        RGB_DATA <= powerup_douta;  
                    end if;
                else 
                    font_addra <= std_logic_vector(to_unsigned(((question_sn * 256) + cellPixel), 14));
                    RGB_DATA <= font_douta;
                end if;
                
            end if;
        
   
      elsif (cellSpriteNumber = powerup_slot2_sn) then -- Powerup slot / start count display
            if (level_start_count /= 0) then
                font_addra <= std_logic_vector(to_unsigned((((29 + level_start_count) * 256) + cellPixel), 14));
                RGB_DATA <= font_douta; 
            else
                if (p2_powerup /= -1) then
                    powerup_addra <= std_logic_vector(to_unsigned(((p2_powerup * 256) + cellPixel), 12));
                
                     -- Replace green floor with gray
                    if (powerup_douta = "000010100010") then
                        RGB_DATA <= "101010111100";
                    else
                        RGB_DATA <= powerup_douta;  
                    end if;
                else 
                    font_addra <= std_logic_vector(to_unsigned(((question_sn * 256) + cellPixel), 14));
                    RGB_DATA <= font_douta;
                end if;
            end if;
              
        elsif ( cellSpriteNumber = sel_highscore) then
            if ( sel_position = '0' ) then
                font_addra <= std_logic_vector(to_unsigned(((exclamation_sn * 256) + cellPixel), 14));
                RGB_DATA <= font_douta;
            else
            RGB_DATA <= "101010111100";
            end if;
       elsif ( cellSpriteNumber = sel_start) then
            if ( sel_position = '1' ) then
                font_addra <= std_logic_vector(to_unsigned(((exclamation_sn * 256) + cellPixel), 14));
                RGB_DATA <= font_douta;
            else
            RGB_DATA <= "101010111100";
            end if;
         
        -- NPC display
        elsif (cellSpriteNumber = npc_up) then
            if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((7 * 256) + cellPixel), 12));
            else
                npc_addra <= std_logic_vector(to_unsigned(((3 * 256) + cellPixel), 12));
            end if;
            RGB_DATA <= npc_douta;
        elsif (cellSpriteNumber = npc_right) then
            if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((4 * 256) + cellPixel), 12));
            else
                npc_addra <= std_logic_vector(to_unsigned(((0 * 256) + cellPixel), 12));
            end if;
            RGB_DATA <= npc_douta;
        elsif (cellSpriteNumber = npc_down) then
            if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((5 * 256) + cellPixel), 12));
            else
                npc_addra <= std_logic_vector(to_unsigned(((1 * 256) + cellPixel), 12));
            end if;
            RGB_DATA <= npc_douta;
        elsif (cellSpriteNumber = npc_left) then
            if lazer_tick = '1' then
                npc_addra <= std_logic_vector(to_unsigned(((6 * 256) + cellPixel), 12));
            else
            npc_addra <= std_logic_vector(to_unsigned(((2 * 256) + cellPixel), 12));
            end if;
            RGB_DATA <= npc_douta;
        
        -- Time display
        elsif (cellSpriteNumber = time_seconds_slot) then
             font_addra <= std_logic_vector(to_unsigned((((29 + time_seconds) * 256) + cellPixel), 14));
             RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = time_seconds_tens_slot) then
             font_addra <= std_logic_vector(to_unsigned((((29 + time_seconds_tens) * 256) + cellPixel), 14));
             RGB_DATA <= font_douta; 
        elsif (cellSpriteNumber = time_minutes_slot) then
             font_addra <= std_logic_vector(to_unsigned((((29 + time_minutes) * 256) + cellPixel), 14));
             RGB_DATA <= font_douta; 
        -- highscore display
        elsif (cellSpriteNumber = hs_num_100) then
             font_addra <= std_logic_vector(to_unsigned((((29 + (highscore_saved mod 10)) * 256) + cellPixel), 14));
             RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = hs_num_10) then
                font_addra <= std_logic_vector(to_unsigned((((29 + ((highscore_saved mod 100) / 10)) * 256) + cellPixel), 14));
                RGB_DATA <= font_douta;
         elsif (cellSpriteNumber = hs_num_1) then
             font_addra <= std_logic_vector(to_unsigned((((29 + ((highscore_saved mod 1000) / 100)) * 256) + cellPixel), 14));
             RGB_DATA <= font_douta;        
             
        -- Score player 1 display
         elsif (cellSpriteNumber = score_hunderds_slot) then
             font_addra <= std_logic_vector(to_unsigned((((29 + (p1_score mod 10)) * 256) + cellPixel), 14));
             RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = score_tens_slot) then
             font_addra <= std_logic_vector(to_unsigned((((29 + ((p1_score mod 100) / 10)) * 256) + cellPixel), 14));
             RGB_DATA <= font_douta;
         elsif (cellSpriteNumber = score_ones_slot) then
             font_addra <= std_logic_vector(to_unsigned((((29 + ((p1_score mod 1000) / 100)) * 256) + cellPixel), 14));
             RGB_DATA <= font_douta;
             
        -- Score player 2 display
         elsif (cellSpriteNumber = score2_hunderds_slot) then
             font_addra <= std_logic_vector(to_unsigned((((29 + (p2_score mod 10)) * 256) + cellPixel), 14));
             RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = score2_tens_slot) then
             font_addra <= std_logic_vector(to_unsigned((((29 + ((p2_score mod 100) / 10)) * 256) + cellPixel), 14));
             RGB_DATA <= font_douta;
         elsif (cellSpriteNumber = score2_ones_slot) then
             font_addra <= std_logic_vector(to_unsigned((((29 + ((p2_score mod 1000) / 100)) * 256) + cellPixel), 14));
             RGB_DATA <= font_douta;
             
        -- Level display
        elsif (cellSpriteNumber = level_slot) then
             font_addra <= std_logic_vector(to_unsigned((((29 + current_level + 1) * 256) + cellPixel), 14));
             RGB_DATA <= font_douta;
             
        elsif (cellSpriteNumber = cloud) then
            RGB_DATA <= "111111111111";
        elsif (cellSpriteNumber = sun_orange) then
            RGB_DATA <= "111110010000";
        elsif (cellSpriteNumber = sun_yellow) then
            RGB_DATA <= "111111010011";
        elsif (cellSpriteNumber = green) then
            RGB_DATA <= "000010100010";
        elsif (cellSpriteNumber = dark_grey) then
            RGB_DATA <= "011001100110";
        elsif (cellSpriteNumber = salmon) then
            RGB_DATA <= "111110000111";
        elsif (cellSpriteNumber = name1_1) then
            if ( show_score = '1') then
                font_addra <= std_logic_vector(to_unsigned(((high_letter_1 * 256) + cellPixel), 14));
                RGB_DATA <= font_douta;
            else
                font_addra <= std_logic_vector(to_unsigned(((L11 * 256) + cellPixel), 14));
                RGB_DATA <= font_douta;
            end if;
        elsif (cellSpriteNumber = name1_2) then
            if ( show_score = '1') then
                font_addra <= std_logic_vector(to_unsigned(((high_letter_2 * 256) + cellPixel), 14));
                RGB_DATA <= font_douta;
            else
                font_addra <= std_logic_vector(to_unsigned(((L12 * 256) + cellPixel), 14));
                RGB_DATA <= font_douta;
            end if;
        elsif (cellSpriteNumber = name1_3) then
            if ( show_score = '1') then
                font_addra <= std_logic_vector(to_unsigned(((high_letter_3 * 256) + cellPixel), 14));
                RGB_DATA <= font_douta;
            else
                font_addra <= std_logic_vector(to_unsigned(((L13 * 256) + cellPixel), 14));
                RGB_DATA <= font_douta;
            end if;
        elsif (cellSpriteNumber = name1_4) then
            if ( show_score = '1') then
                font_addra <= std_logic_vector(to_unsigned(((high_letter_4 * 256) + cellPixel), 14));
                RGB_DATA <= font_douta;
                
                -- Jochem was here
            else
                font_addra <= std_logic_vector(to_unsigned(((L14 * 256) + cellPixel), 14));
                RGB_DATA <= font_douta;
            end if;
        elsif (cellSpriteNumber = name2_1) then
            font_addra <= std_logic_vector(to_unsigned(((L21 * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = name2_2) then
            font_addra <= std_logic_vector(to_unsigned(((L22 * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = name2_3) then
            font_addra <= std_logic_vector(to_unsigned(((L23 * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = name2_4) then
            font_addra <= std_logic_vector(to_unsigned(((L24 * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        elsif (cellSpriteNumber = checkmark) then
            font_addra <= std_logic_vector(to_unsigned(((40 * 256) + cellPixel), 14));
            RGB_DATA <= font_douta;
        end if;
        
        -- Player movement
        IF ( enGame = '1' AND level_start_count = 0) THEN
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
        
        -- Level transistion counter
        if (level_transistion = '1' AND enGame = '1' AND reset = '0') then
            level_transistion_ticks <= level_transistion_ticks + 1;
            
            if (level_transistion_ticks = 100_000) then
                level_transistion_ticks <= 0;
                level_transistion_count <= level_transistion_count + 1;
                
                if (level_transistion_count = 1200) then
                    level_transistion_count <= 0;
                    level_transistion <= '0';
                end if;
            end if;
        end if;
        
        
        -- Set name transistion counter
        if (name_transistion = '1' AND show_name = '1') then
            name_transistion_ticks <= name_transistion_ticks + 1;
            
            if (name_transistion_ticks = 100_000) then
                name_transistion_ticks <= 0;
                name_transistion_count <= name_transistion_count + 1;
                
                if (name_transistion_count = 1200) then
                    name_transistion_count <= 0;
                    name_transistion <= '0';
                end if;
            end if;
        end if;
        
        -- 0x0 level
        -- 0x1 menu
        -- 0x2 name/score
        
        -- 0x0 finish
        -- 0x1 ++
        -- 0x2 --
        -- 0x3 dead
        
        -- High score transistion counter
        if (score_transistion = '1' AND show_score = '1') then
            score_transistion_ticks <= score_transistion_ticks + 1;
            
            if (score_transistion_ticks = 100_000) then
                score_transistion_ticks <= 0;
                score_transistion_count <= score_transistion_count + 1;
                
                if (score_transistion_count = 1200) then
                    score_transistion_count <= 0;
                    score_transistion <= '0';
                end if;
            end if;
        end if;
        
        -- Start countdown
        if( enGame = '1' ) then
            if (level_start_count /= 0) then
                level_start_count_ticks <= level_start_count_ticks + 1;
            
                if (level_start_count_ticks = 100000000) then
                    level_start_count <= level_start_count - 1;
                    
                    level_start_count_ticks <= 0;
                end if; 
            end if;
        end if;
        
        -- Shield timers
        if (p1_shield_remove = '1') then  
            p1_shield_ticks <= p1_shield_ticks + 1;
        
            if (p1_shield_ticks = 100000000) then
                p1_shield_remove <= '0';
                p1_powerup <= -1;
                p1_shield_ticks <= 0;
            end if; 
        end if;
        
        if (p2_shield_remove = '1') then  
            p2_shield_ticks <= p2_shield_ticks + 1;
        
            if (p2_shield_ticks = 100000000) then
                p2_shield_remove <= '0';
                p2_powerup <= -1;
                p2_shield_ticks <= 0;
            end if; 
        end if;
        
        -- Level timer
        if (time_seconds < 10 AND level_start_count = 0 AND level_transistion = '0') then
            time_ticks <= time_ticks + 1;
            
            if (time_ticks = 100000000) then
                time_ticks <= 0;
            
                if (time_seconds < 9) then
                    time_seconds <= time_seconds + 1;
                elsif (time_seconds = 9) then
                    time_seconds <= 0;
                    time_seconds_tens <= time_seconds_tens + 1;
                end if;
            end if;
            
            if (time_seconds_tens = 6) then
                time_seconds_tens <= 0;
                time_minutes <= time_minutes + 1;
            end if;
            
            -- TODO: Check if time minutes is equal to 10, than time should be over, game will end
        end if;
        
        -- Finish
        IF (p1_loc = 298) THEN
            current_level <= current_level + 1;
            p1_loc <= 1130;
            p2_loc <= 1151;
            p1_powerup <= -1;
            p2_powerup <= -1;
            p1_score <= p1_score + 50;
            level_start_count <= 5;
            start_level <= '0';
            
            time_ticks <= 0;
            time_seconds <= 0;
            time_seconds_tens <= 0;
            time_minutes <= 0;
        ELSIF (p2_loc = 303) THEN
            current_level <= current_level + 1;
            p1_loc <= 1130;
            p2_loc <= 1151;
            p1_powerup <= -1;
            p2_powerup <= -1;
            p2_score <= p2_score + 50;
            level_start_count <= 5;
            start_level <= '0';
            
            time_ticks <= 0;
            time_seconds <= 0;
            time_seconds_tens <= 0;
            time_minutes <= 0;
            
        -- Powerups detection
        -- Break wall
        ELSIF (p1_loc = bw_locations1(current_level)) THEN
            bw_locations1(current_level) <= -1;
            p1_powerup <= 7;
            p1_score <= p1_score + 5;
        ELSIF (p2_loc = bw_locations2(current_level)) THEN
            bw_locations2(current_level) <= -1;
            p2_powerup <= 7;
            p2_score <= p2_score + 5;
        
        -- Shield
        ELSIF (p1_loc = shield_locations1(current_level)) THEN
            if (p1_powerup /= 7) then
                shield_locations1(current_level) <= -1;
                p1_powerup <= 1;
                p1_score <= p1_score + 5;
            end if;
        ELSIF (p2_loc = shield_locations2(current_level)) THEN
            if (p1_powerup /= 7) then
                shield_locations2(current_level) <= -1;
                p2_powerup <= 1;
                p2_score <= p2_score + 5;
            end if;
        
        -- 10 Points crystal
        ELSIF (p1_loc = crystal1_locations1(current_level)) THEN
            crystal1_locations1(current_level) <= -1;
            p1_score <= p1_score + 10;
        ELSIF (p2_loc = crystal1_locations2(current_level)) THEN
            crystal1_locations2(current_level) <= -1;
            p2_score <= p2_score + 10;
        
        -- 15 Points crystal
        ELSIF (p1_loc = crystal2_locations1(current_level)) THEN
            crystal2_locations1(current_level) <= -1;
            p1_score <= p1_score + 15;
        ELSIF (p2_loc = crystal2_locations2(current_level)) THEN
            crystal2_locations2(current_level) <= -1;
            p2_score <= p2_score + 15;
            
         -- 20 Points crystal
        ELSIF (p1_loc = crystal3_locations1(current_level)) THEN
            crystal3_locations1(current_level) <= -1;
            p1_score <= p1_score + 20;
        ELSIF (p2_loc = crystal3_locations2(current_level)) THEN
            crystal3_locations2(current_level) <= -1;
            p2_score <= p2_score + 20;
            
        -- Break walls
         ELSIF (p1_loc = p1_break_walls(current_level)) THEN
            p1_break_walls(current_level) <= -1;
            p1_powerup <= -1;
         ELSIF (p2_loc = p2_break_walls(current_level)) THEN
            p2_break_walls(current_level) <= -1;
            p2_powerup <= -1;
        
        -- Reset  
        ELSIF (reset = '1') THEN
            endGame <= '0';
        else
            endGame <= '0';
        END IF;
        
         if ( current_level > amount_of_levels - 1 ) then
            endGame <= '1';
        END IF;
        
        --  Check if player one dies
        CASE p1_loc IS
        WHEN npc_down_loc | (npc_down_loc + 40) | (npc_down_loc + 80) | (npc_down_loc + 120) =>
            if lazer_tick = '1' then
                if (p1_powerup = 1) then
                    p1_shield_remove <= '1';
                else
                    damage_p1 <= '1';
                    p1_loc <= 1130;
                    
                    
                    if (p1_score > 0 ) then
                        p1_score <= p1_score - 1;
                    end if;
                end if;
            end if;
        WHEN npc_up_loc | (npc_up_loc - 40) | (npc_up_loc - 80) | (npc_up_loc - 120) =>
            if lazer_tick = '1' then
                if (p1_powerup = 1) then
                    p1_shield_remove <= '1';
                else
                    damage_p1 <= '1';
                    p1_loc <= 1130;
                    if (p1_score > 0 ) then
                        p1_score <= p1_score - 1;
                    end if;
                end if;
            end if;
        WHEN npc_left_loc | (npc_left_loc - 1) | (npc_left_loc - 2) | (npc_left_loc - 3) =>
            if lazer_tick = '1' then
                if (p1_powerup = 1) then
                     p1_shield_remove <= '1';
                else
                    damage_p1 <= '1';
                    p1_loc <= 1130;
                    
                    if (p1_score > 0 ) then
                        p1_score <= p1_score - 1;
                    end if;
                end if;
            end if;
        WHEN npc_right_loc | (npc_right_loc + 1) | (npc_right_loc + 2) | (npc_right_loc + 3) =>
            if lazer_tick = '1' then
                if (p1_powerup = 1) then
                    p1_shield_remove <= '1';
                else
                    damage_p1 <= '1';
                    p1_loc <= 1130;
                    
                    if (p1_score > 0 ) then
                        p1_score <= p1_score - 1;
                    end if;
                end if;
            end if;
        WHEN OTHERS => 
        END CASE; 
        
        CASE p2_loc IS
        WHEN npc2_down_loc | (npc2_down_loc + 40) | (npc2_down_loc + 80) | (npc2_down_loc + 120) =>
            if lazer_tick = '1' then
                if (p2_powerup = 1) then
                     p2_shield_remove <= '1';
                else
                    damage_p2 <= '1';
                    p2_loc <= 1151;
                    
                    if (p2_score > 0 ) then
                        p2_score <= p2_score - 1;
                    end if;
                end if;
            end if;
        WHEN npc2_up_loc | (npc2_up_loc - 40) | (npc2_up_loc - 80) | (npc2_up_loc - 120) =>
            if lazer_tick = '1' then
                if (p2_powerup = 1) then
                    p2_shield_remove <= '1';
                else
                    damage_p2 <= '1';
                    p2_loc <= 1151;
                   
                    if (p2_score > 0 ) then
                        p2_score <= p2_score - 1;
                    end if;
                end if;
            end if;
        WHEN npc2_left_loc | (npc2_left_loc - 1) | (npc2_left_loc - 2) | (npc2_left_loc - 3) =>
            if lazer_tick = '1' then
                if (p2_powerup = 1) then
                     p2_shield_remove <= '1';
                else
                    damage_p2 <= '1';
                    p2_loc <= 1151;
                    
                    if (p2_score > 0 ) then
                        p2_score <= p2_score - 1;
                    end if;
                end if;
            end if;
        WHEN npc2_right_loc | (npc2_right_loc + 1) | (npc2_right_loc + 2) | (npc2_right_loc + 3) =>
            if lazer_tick = '1' then
                if (p2_powerup = 1) then
                    p2_shield_remove <= '1';
                else
                    damage_p2 <= '1';
                    p2_loc <= 1151;
                    
                    if (p2_score > 0 ) then
                        p2_score <= p2_score - 1;
                    end if;
                end if;
            end if;
        WHEN OTHERS => 
        END CASE;  
        
        if ( damage_p1 = '1' ) then
            damage_counter_p1 <= (damage_counter_p1 + 1);
            if( ( damage_counter_p1 mod 33_000_000 ) = 0 ) then
                show_damage_p1 <= NOT( show_damage_p1 );
            end if;
            if ( damage_counter_p1 = 198_000_001 ) then
                damage_counter_p1 <= 0;
                show_damage_p1 <= '0';
                damage_p1 <= '0';
            end if;
        end if;
        if ( damage_p2 = '1' ) then
            damage_counter_p2 <= (damage_counter_p2 + 1);
            if( ( damage_counter_p2 mod 33_000_000 ) = 0 ) then
                show_damage_p2 <= NOT( show_damage_p2 );
            end if;
            if ( damage_counter_p2 = 198_000_001 ) then
                damage_counter_p2 <= 0;
                show_damage_p2 <= '0';
                damage_p2 <= '0';
            end if;
        end if;
    
        
    end if;
end process;

lazerCounter : process(clk_100)
    begin
        IF ( rising_edge(clk_100) ) THEN
        if (enGame = '1') then
            counter_lazers <= (counter_lazers + 1);
            IF ( counter_lazers = 100_000_000 ) THEN
                lazer_tick <= NOT(lazer_tick);
                counter_lazers <= 0;            
            END IF; 
        END IF;
        END IF;
    end process;

playerCounter : process(clk_100)
    begin
        if ( rising_edge(clk_100) ) then
            counter_player <= ( counter_player + 1 );
            if ( counter_player = 15_000_000 ) then
                frame_player <= ( frame_player + 1 );
                counter_player <= 0;
            end if;
            
            case frame_player is
                when "00" =>
                    player_base <= 0;
                when "01" => 
                    player_base <= 1;
                when "10" =>
                    player_base <= 0;
                when "11" =>
                    player_base <= 2;
            end case;
        end if;
    end process;
    
playerAnimation : process(clk_100)
    begin
        if (show_damage_p1 = '1') then
            animation_index_p1 <= 3;
        else
            if ( p1_powerup = 7 ) then
                animation_index_p1 <= 21;
            elsif ( p1_powerup = 1 ) then
                animation_index_p1 <= 27;
            else
            animation_index_p1 <= 15;
            end if;
        end if;   
        
        if (show_damage_p2 = '1') then
            animation_index_p2 <= 18;
        else
            if ( p2_powerup = 7 ) then
                animation_index_p2 <= 6;
            elsif ( p2_powerup = 1 ) then
                animation_index_p2 <= 12;
            else
            animation_index_p2 <= 0;
            end if;
        end if;
    end process;
    
nameSelector : process(clk_100)
    begin
        if( rising_edge(clk_100) ) then
            if ( show_name = '1' ) then
                if( P1_UP = '1' ) then
                    case selected1 is
                        when "000" =>
                            if ( L11 = 25 ) then
                                L11 <= 0;
                            else
                                L11 <= L11 + 1;
                            end if;
                        when "001" =>
                            if ( L12 = 25 ) then
                                L12 <= 0;
                            else
                                L12 <= L12 + 1;
                            end if;
                        when "010" =>
                            if ( L13 = 25 ) then
                                L13 <= 0;
                            else
                                L13 <= L13 + 1;
                            end if;
                        when "011" =>
                            if ( L14 = 25 ) then
                                L14 <= 0;
                            else
                                L14 <= L14 + 1;
                            end if;
                        when others =>
                            L11 <= L11;
                            L12 <= L12;
                            L13 <= L13;
                            L14 <= L14;
                    end case;
                
                elsif( P1_down = '1' ) then
                    case selected1 is
                        when "000" =>
                            if ( L11 = 0 ) then
                                L11 <= 25;
                            else
                                L11 <= L11 - 1;
                            end if;
                        when "001" =>
                            if ( L12 = 0 ) then
                                L12 <= 25;
                            else
                                L12 <= L12 - 1;
                            end if;
                        when "010" =>
                            if ( L13 = 0 ) then
                                L13 <= 25;
                            else
                                L13 <= L13 - 1;
                            end if;
                        when "011" =>
                            if ( L14 = 0 ) then
                                L14 <= 25;
                            else
                                L14 <= L14 - 1;
                            end if;
                        when others =>
                            L11 <= L11;
                            L12 <= L12;
                            L13 <= L13;
                            L14 <= L14;
                    end case;
                elsif( P1_right = '1' ) then
                    if (cursor1 = 379) then
                        cursor1 <= 375;
                    else
                        cursor1 <= cursor1 + 1;
                    end if;
                    
                    if ( selected1 = "100" ) then
                        selected1 <= "000";
                    else
                        selected1 <= selected1 + 1;
                    end if;
                elsif( P1_left = '1' ) then
                    if (cursor1 = 375) then
                        cursor1 <= 379;
                    else
                        cursor1 <= cursor1 - 1;
                    end if;
                    if ( selected1 = "000" ) then
                        selected1 <= "100";
                    else
                        selected1 <= selected1 - 1;
                    end if;
    
                
                end if;
                if( P2_UP = '1' ) then
                    case selected2 is
                        when "000" =>
                            if ( L21 = 25 ) then
                                L21 <= 0;
                            else
                                L21 <= L21 + 1;
                            end if;
                        when "001" =>
                            if ( L22 = 25 ) then
                                L22 <= 0;
                            else
                                L22 <= L22 + 1;
                            end if;
                        when "010" =>
                            if ( L23 = 25 ) then
                                L23 <= 0;
                            else
                                L23 <= L23 + 1;
                            end if;
                        when "011" =>
                            if ( L24 = 25 ) then
                                L24 <= 0;
                            else
                                L24 <= L24 + 1;
                            end if;
                        when others =>
                            L21 <= L21;
                            L22 <= L22;
                            L23 <= L23;
                            L24 <= L24;
                    end case;
                elsif( P2_down = '1' ) then
                    case selected2 is
                        when "000" =>
                            if ( L21 = 0 ) then
                                L21 <= 25;
                            else
                                L21 <= L21 - 1;
                            end if;
                        when "001" =>
                            if ( L22 = 0 ) then
                                L22 <= 25;
                            else
                                L22 <= L22 - 1;
                            end if;
                        when "010" =>
                            if ( L23 = 0 ) then
                                L23 <= 25;
                            else
                                L23 <= L23 - 1;
                            end if;
                        when "011" =>
                            if ( L24 = 0 ) then
                                L24 <= 25;
                            else
                                L24 <= L24 - 1;
                            end if;
                        when others =>
                            L21 <= L21;
                            L22 <= L22;
                            L23 <= L23;
                            L24 <= L24;
                    end case;
                elsif( P2_right = '1' ) then
                    if (cursor2 = 386) then
                        cursor2 <= 382;
                    else
                        cursor2 <= cursor2 + 1;
                    end if;
                    if ( selected2 = "100" ) then
                        selected2 <= "000";
                    else
                        selected2 <= selected2 + 1;
                    end if;
                elsif( P2_left = '1' ) then
                    if (cursor2 = 382) then
                        cursor2 <= 386;
                    else
                        cursor2 <= cursor2 - 1;
                    end if;
                    if ( selected2 = "000" ) then
                        selected2 <= "100";
                    else
                        selected2 <= selected2 - 1;
                    end if;
                end if;
            end if;
            
            if( selected1 = "100" and selected2 = "100") then
                both_ok <= '1';
            else
                both_ok <= '0';
            end if;
        end if;
    end process;



save_score_to_ram : process ( clk_100 )
    begin
        if ( rising_edge ( clk_100 ) ) then
            set_highscore <= '0';
            score_saved <= '0';
            if ( save_score = '1' ) then
                if (p1_score > p2_score) then
                    high_1 <= L11;
                    high_2 <= L12;
                    high_3 <= L13;
                    high_4 <= L14;
                    score_to_save <= p1_score;
                    score_ready <= '1';
                else
                    high_1 <= L21;
                    high_2 <= L22;
                    high_3 <= L23;
                    high_4 <= L24;
                    score_to_save <= p2_score;
                    score_ready <= '1';
                end if;
                if ( score_ready = '1' ) then
                    set_highscore <= '1';
                    score_ready <= '0';
                    score_saved <= '1';
--                    L11 <=  0;
--                    L12 <=  0;
--                    L13 <=  0; 
--                    L14 <=  0; -- p1
--                    L21 <=  0;
--                    L22 <=  0;
--                    L23 <=  0;
--                    L24 <= 0; -- p2
--                    p1_score <= 0;
--                    p2_score <= 0;
                end if;
            end if;
        end if;
    end process;    
end Behavioral;