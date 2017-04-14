library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.fixed_pkg.all;
use work.math_utility_pkg.all;

Entity DDA is
	Port(
		clock : in std_logic;
		ro, go, bo, vo, ho : out std_logic;
		gnd1,gnd2 : out std_logic;
		led1 : out std_logic := '0';
		led2 : out std_logic := '0'
	);
End Entity;

Architecture Analyze of DDA is
	type int_array is array(integer range<>) of integer;
	signal reset, pixel_on, dir : std_logic;
	signal vx : std_logic;
	signal rd,gr,bl : std_logic;
	signal pix_row, pix_col : unsigned(9 downto 0);
	signal size : integer := 320;
	signal data_points : int_array(2 to 321) ;
	signal qu : integer := 300;
	Signal count : integer := 1;
	Signal count1 : integer := 1;
	Signal dt : sfixed(3 downto -2) := to_sfixed(1,3,-2);
	Signal x : sfixed(32 downto -32) := to_sfixed(0,32,-32);
	Signal y : sfixed(32 downto -32) := to_sfixed(1,32,-32);
	signal abc : sfixed(3 downto -6) := to_sfixed(0.03125,3,-6);
	Signal tempx : sfixed(x'left downto x'right);
	Signal max : integer := 0;
	signal min : integer := 100000;
	signal ran : integer := 0;

	Component VGAS
		Port(
			clk, red, green, blue : in std_logic;
			red_out, green_out, blue_out : out std_logic;
			horiz_sync_out, vert_sync_out : out std_logic;
			pixel_row, pixel_col : out unsigned (9 downto 0)
		);
	End Component;

	Component Divide
		Port( 
			a,b : in integer; 
			q : out integer
		);
	End Component;

	Begin
		vga: VGAS Port Map(
			clk => clock,
			red => rd,
			green => gr,
			blue => bl,
			red_out => ro,
			green_out => go,
			blue_out => bo,
			horiz_sync_out => ho,
			vert_sync_out => vx,
			pixel_row => pix_row,
			pixel_col => pix_col
		);

		div: Divide Port Map(
			a => 640,
			b => size,
			q => qu
		);

		gnd1 <= '0';
		gnd2 <= '0';
		vo <= vx;
		rd <= '1';
		gr <= not pixel_on;
		bl <= not pixel_on;

		display_ball:
		Process(pix_row, pix_col)
		variable temp : integer := to_integer(unsigned(pix_col))/(qu);
			Begin
				if(ran*to_integer(unsigned(pix_row)) < 480*(data_points(temp)-min) AND ran*to_integer(unsigned(pix_row)) > 480*(data_points(temp)-min)-5*ran) then
					pixel_on <= '1';
				else 
					pixel_on <= '0';
				end if;
		End Process display_ball;

		Process(clock)
			Begin
				if(clock'EVENT AND clock = '1' AND count1 < 321) then
					count <= count + 1;
					if(count = 10) then
						tempx <= x;
						count1 <= count1 + 1;
					end if;
					if(count = 20) then
						x <= resize(y*dt + x,x);
						y <= resize(y,y);
					end if;
					if(count = 40) then
						data_points(count1) <= to_integer(x);
						if(to_integer(x) < min) then 
							min <= to_integer(x);
						end if;
						if(to_integer(x) > max) then 
							max <= to_integer(x);	
						end if;
						count <= 0;
					end if;
				end if;
				if(count1 = 321) then
					ran <= max - min;
				end if;
		End Process;
End Analyze;
		
		