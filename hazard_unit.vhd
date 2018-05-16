library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MI0.all;

entity hazard_unit is
	port 	(
			IDEXMemRead : in std_logic;
		 	rs, rt, rd : in  reg32;
            writePC : out std_logic;
            writeIFID : out std_logic;
            stallMux : out std_logic
		);
end hazard_unit;


architecture arq_hazard_unit of hazard_unit is

begin
   
    

end arq_hazard_unit;
