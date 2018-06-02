library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MI0.all;

entity forward_unit is
	port 	(
            MEM_rd : in std_logic_vector(4 downto 0);
            MEM_RegWrite : in std_logic;
            WB_rd : in std_logic_vector(4 downto 0);
            WB_RegWrite : in std_logic;
            WB_ReadBack : in std_logic;
            EX_rs : in std_logic_vector(4 downto 0);
            EX_rt : in std_logic_vector(4 downto 0);

            ForwardA : out std_logic_vector(1 downto 0);
            ForwardB : out std_logic_vector(1 downto 0)
		);
end forward_unit;


architecture arq_forward_unit of forward_unit is

begin
      process(MEM_RegWrite, MEM_rd, WB_RegWrite, 
			  WB_rd, EX_rs, EX_rt) is
      begin
            -- first alu register
            if ((MEM_RegWrite = '1') -- EX HAZARD
                  and (MEM_rd /="00000") 
                  and (MEM_rd = EX_rs)) then
                        ForwardA <= b"10"; 
                        
            elsif ((WB_RegWrite = '1') -- MEM HAZARD
                  and (WB_rd /="00000") 
                  -- and (MEM_rd /= EX_rs)
                  and (WB_rd = EX_rs)) then
                        ForwardA <= b"01"; 
            
            elsif ((WB_ReadBack = '1') -- LWDI HAZARD
                  and (MEM_rd /="00000")
                  and (WB_rd = EX_rs)) then
                        ForwardB <= b"11";
            
            else 
                  ForwardA <= b"00";
            end if;

            -- second alu register
            if ((MEM_RegWrite = '1') -- EX HAZARD
                  and (MEM_rd /="00000") 
                  and (MEM_rd = EX_rt)) then
                        ForwardB <= b"10"; 
                        
            elsif ((WB_RegWrite = '1') -- MEM HAZARD
                  and (WB_rd /="00000") 
                  -- and (MEM_rd /= EX_rt)
                  and (WB_rd = EX_rt)) then
                        ForwardB <= b"01"; 
            
            elsif ((WB_ReadBack = '1') -- LWDI HAZARD
                  and (MEM_rd /="00000")
                  and (WB_rd = EX_rt)) then
                        ForwardB <= b"11";

            else 
                  ForwardB <= b"00";
            end if;

      end process;

end arq_forward_unit;
