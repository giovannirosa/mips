library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MI0.all;

entity forward_unit is
	port 	(
            clk : in std_logic;
            reset : in std_logic;
            EX_MEM_rd : in std_logic_vector(4 downto 0);
            MEM_WB_rd : in std_logic_vector(4 downto 0);
            MEM_WB_RegWrite : in std_logic;
            ID_EX_rs : in std_logic_vector(4 downto 0);
            ID_EX_rt : in std_logic_vector(4 downto 0);
            EX_MEM_RegWrite : in std_logic;

            ForwardA : out std_logic_vector(1 downto 0);
            ForwardB : out std_logic_vector(1 downto 0)
		);
end forward_unit;


architecture arq_forward_unit of forward_unit is

begin
   
    

end arq_forward_unit;
