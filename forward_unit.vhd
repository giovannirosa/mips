library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MI0.all;

entity forward_unit is
	port 	(
            EX_MEM_rd : in std_logic_vector(4 downto 0);
            EX_MEM_RegWrite : in std_logic;
            MEM_WB_rd : in std_logic_vector(4 downto 0);
            MEM_WB_RegWrite : in std_logic;
            ID_EX_rs : in std_logic_vector(4 downto 0);
            ID_EX_rt : in std_logic_vector(4 downto 0);

            ForwardA : out std_logic_vector(1 downto 0);
            ForwardB : out std_logic_vector(1 downto 0)
		);
end forward_unit;


architecture arq_forward_unit of forward_unit is

begin
      process(EX_MEM_RegWrite, EX_MEM_rd, MEM_WB_RegWrite, 
			  MEM_WB_rd, ID_EX_rs, ID_EX_rt) is
      begin
            -- first alu register
            if ((EX_MEM_RegWrite = '1') -- EX HAZARD
                  and (EX_MEM_rd /="00000") 
                  and (EX_MEM_rd = ID_EX_rs)) then
                        ForwardA <= b"10"; 
                        
            elsif ((MEM_WB_RegWrite = '1') -- MEM HAZARD
                  and (MEM_WB_rd /="00000") 
                  and not(EX_MEM_RegWrite = '1' and (EX_MEM_rd /= "00000")
                        and (EX_MEM_rd = ID_EX_rs))
                  and (MEM_WB_rd = ID_EX_rs)) then
                        ForwardA <= b"01"; 
            else 
                  ForwardA <= b"00";
            end if;

            -- second alu register
            if ((EX_MEM_RegWrite = '1') -- MEM HAZARD
                  and (EX_MEM_rd /="00000") 
                  and (EX_MEM_rd = ID_EX_rt)) then
                        ForwardB <= b"10"; 
                        
            elsif ((MEM_WB_RegWrite = '1') -- MEM HAZARD
                  and (MEM_WB_rd /="00000") 
                        and not(EX_MEM_RegWrite = '1' and (EX_MEM_rd /= "00000")
                        and (EX_MEM_rd = ID_EX_rt))
                  and (MEM_WB_rd = ID_EX_rt)) then
                        ForwardB <= b"01"; 

            else 
                  ForwardB <= b"00";
            end if;

      end process;

end arq_forward_unit;
