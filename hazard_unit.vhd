library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MI0.all;

entity hazard_unit is
	port 	(
			EX_MemRead : in std_logic;
		 	EX_rt, ID_rs, ID_rt : in std_logic_vector(4 downto 0);
            stall : out std_logic
		);
end hazard_unit;


architecture arq_hazard_unit of hazard_unit is

begin
   
	process (EX_MemRead, EX_rt, ID_rs, ID_rt) 
  	begin 
		stall <= '0';
		
		if EX_MemRead = '1' then
			if EX_rt = ID_rs or EX_rt = ID_rt then
				stall <= '1';
			end if;
		end if;
	end process;

end arq_hazard_unit;
