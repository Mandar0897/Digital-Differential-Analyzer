library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Divide is 
	Port(
		a, b : in integer; 
		q : out integer
	);
End Divide;

Architecture Division of Divide is 
	Begin
		Process(a,b)
			Begin
				q <= a/b;	
		End Process;
End Division;
