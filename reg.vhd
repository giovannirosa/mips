--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Registrador genérico sensível à borda de subida do clock
-- com possibilidade de inicialização de valor
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MI0.all;

entity reg is
	generic( 
		width : integer := 32
	);

	port(  	ck, rst, E : in std_logic; -- PC Enable
               	D : in  std_logic_vector(width-1 downto 0);
                S : in  std_logic_vector(width-1 downto 0); -- PC Stall
               	Q : out std_logic_vector(width-1 downto 0)
        );
end reg;

architecture arq_reg of reg is 
begin

  process(ck, rst)
  begin
       if rst = '1' then
              Q <= (others => '0');
       elsif ck'event and ck = '1' and E = '0' then
              Q <= D;
       elsif E = '1' then
				      Q <= S;
       end if;
  end process;
        
end arq_reg;
