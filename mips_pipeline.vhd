library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_bit.all;
use work.p_MI0.all;

entity mips_pipeline is
	port (
		clk: in std_logic;
		reset: in std_logic
	);
end mips_pipeline;


architecture arq_mips_pipeline of mips_pipeline is
   

    -- ********************************************************************
    --                              Signal Declarations
    -- ********************************************************************
     
    -- IF Signal Declarations
    
    signal IF_instr, IF_pc, IF_pc_next, IF_pc4, IF_pc_stall : reg32 := (others => '0');
	signal IF_pc_enable: std_logic;

    -- ID Signal Declarations

    signal ID_instr, ID_pc4 :reg32;  -- pipeline register values from EX
    signal ID_op, ID_funct, ID_op_mux: std_logic_vector(5 downto 0);
    signal ID_rs, ID_rt, ID_rd: std_logic_vector(4 downto 0);
    signal ID_immed: std_logic_vector(15 downto 0);
    signal ID_extend, ID_A, ID_B, ID_ALUOutlw, ID_alua, ID_alub, ID_ALUOut, ID_offset, ID_pc_branch: reg32;
    signal ID_RegWrite, ID_Branch, ID_RegDst, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_ReadBack, ID_SelExt: std_logic; --ID Control Signals
    signal ID_ALUOp, ID_ALUSrcA, ID_ALUsrcB: std_logic_vector(1 downto 0);
	signal ID_stall, ID_Zero, ID_PCSrc: std_logic := '0';
	signal ID_Operation: std_logic_vector(2 downto 0);

    -- EX Signals

    signal EX_pc4, EX_extend, EX_A, EX_B: reg32;
    signal EX_offset, EX_alub, EX_ALUOut, EX_alua, EX_alub_ext, EX_alub_final: reg32;
    signal EX_rs, EX_rt, EX_rd: std_logic_vector(4 downto 0);
    signal EX_RegRd: std_logic_vector(4 downto 0);
    signal EX_funct: std_logic_vector(5 downto 0);
    signal EX_RegWrite, EX_RegDst, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_ReadBack, EX_SelExt, EX_SelAddress: std_logic;  -- EX Control Signals
	signal EX_ALUSrcA, EX_ALUSrcB: std_logic_vector(1 downto 0);
	signal EX_zero_branch: std_logic;
    signal EX_ALUOp: std_logic_vector(1 downto 0);
    signal EX_Operation: std_logic_vector(2 downto 0);
	signal EX_zero32: reg32 := "00000000000000000000000000000000";--Entrada 0 para B no caso de LWDI
	signal EX_stall: std_logic := '0';

    

   -- MEM Signals

    signal MEM_RegWrite, MEM_MemtoReg, MEM_MemRead, MEM_MemWrite, MEM_ReadBack, MEM_SelAddress: std_logic;
    signal MEM_ALUOut, MEM_B, MEM_Address: reg32;
    signal MEM_memout: reg32;
    signal MEM_RegRd: std_logic_vector(4 downto 0);


    -- WB Signals

    signal WB_RegWrite, WB_MemtoReg, WB_ReadBack: std_logic;  -- WB Control Signals
    signal WB_memout, WB_ALUOut: reg32;
    signal WB_wd: reg32;
	signal WB_RegRd: std_logic_vector(4 downto 0);
	

	signal UP_ReadBack, UP_RegWrite, UP_MemRead: std_logic := '0';
	signal UP_RegRd, UP_RegRd_final: std_logic_vector(4 downto 0);



begin -- BEGIN MIPS_PIPELINE ARCHITECTURE

    -- ********************************************************************
    --                              IF Stage
    -- ********************************************************************

    -- IF Hardware

    PC: entity work.reg port map (clk, reset, IF_pc_enable, IF_pc_next, IF_pc_stall, IF_pc); -- Adicionado IF_pc_enable e IF_pc_stall para detecção de riscos

    PC4: entity work.add32 port map (IF_pc, x"00000004", IF_pc4);

    MX2: entity work.mux2 port map (ID_PCSrc, IF_pc4, ID_pc_branch, IF_pc_next);

    ROM_INST: entity work.rom32 port map (IF_pc, IF_instr);


    IF_s: process(clk)
    begin     			-- IF/ID Pipeline Register
    	if rising_edge(clk) then
        	if reset = '1' then
            	ID_instr <= (others => '0');
            	ID_pc4   <= (others => '0');
			elsif ID_stall = '0' and EX_stall = '0' then
				ID_instr <= IF_instr;
				ID_pc4 <= IF_pc4;
			elsif ID_stall = '1' or EX_stall = '1' then -- Se tiver risco
				ID_instr <= ID_instr; -- Mantém instrução
				ID_pc4 <= ID_pc4; 	  -- Mantém PC
			end if;
	end if;
    end process;



    -- ********************************************************************
    --                              ID Stage
	-- ********************************************************************


	ID_op <= ID_instr(31 downto 26);
    ID_rs <= ID_instr(25 downto 21);
    ID_rt <= ID_instr(20 downto 16);
    ID_rd <= ID_instr(15 downto 11);
	ID_immed <= ID_instr(15 downto 0);


	HAZARD: entity work.hazard_unit port map (EX_MemRead, EX_rt, ID_rs, ID_rt, ID_stall);

	MX2_STALL: process(ID_stall,IF_pc)
    begin
	if ID_stall = '0' then
		IF_pc_enable <= '0';
	elsif ID_stall = '1' then
		IF_pc_enable <= '1';  -- Ativa escrita no PC
		IF_pc_stall <= IF_pc; -- Guarda PC atual
	end if;
    end process;

	UP_RegWrite <= WB_RegWrite or UP_ReadBack;
	REGD: process(WB_RegRd)
	begin
		if UP_ReadBack = '1' then
			UP_RegRd_final <= UP_RegRd;
		elsif UP_ReadBack = '0' then
			UP_RegRd_final <= WB_RegRd;
		end if;
	end process;

	REG_FILE: entity work.reg_bank port map ( clk, reset, UP_RegWrite, ID_rs, ID_rt, UP_RegRd_final, ID_A, ID_B, WB_wd);


	-- sign-extender
    EXT: process(ID_immed)
    begin
	if ID_immed(15) = '1' then
		ID_extend <= x"FFFF" & ID_immed(15 downto 0);
	else
		ID_extend <= x"0000" & ID_immed(15 downto 0);
	end if;
	end process;

	Forward_branch : process (ID_stall,ID_Branch,MEM_RegRd,ID_rt,ID_rs,EX_RegRd,MEM_RegWrite)--Forward para Branch
	begin
		if ID_stall /= '1'  then --Caso Hazard LW esperar próximo ciclo(para não pegar valores errados).
			if (ID_Branch = '1') and (EX_RegRd /= "00000") and (EX_RegRd = ID_rs) then	
				ID_ALUSrcA <= "01";

			elsif (ID_Branch = '1' and MEM_RegRd /="00000") and (MEM_RegRd = ID_rs) then
				ID_ALUSrcA <= "10";

			else
				ID_ALUSrcA <= "00";

			end if;

			if (ID_Branch = '1') and (EX_RegRd /= "00000") and (EX_RegRd = ID_rt) then
				ID_ALUsrcB <= "01";
		
			elsif (ID_Branch = '1' and MEM_RegRd /="00000") and (MEM_RegRd = ID_rt) then
				ID_ALUSrcB <= "10";
			else
				ID_ALUSrcB  <= "00";
			end if;

			if MEM_MemtoReg = '1' and MEM_RegRd /= "00000" and MEM_RegWrite = '1' then --Caso Hazard LW devo pegar saida da memória não da ALU.
				ID_ALUOutlw <= MEM_memout;
			else
				ID_ALUOutlw <= MEM_ALUOut;
			end if;
		end if;
	end process;

	ALU_MUX_B_Branch: entity work.mux3 port map (ID_ALUSrcB, ID_B, EX_ALUOut, ID_ALUOutlw, ID_alub);--Entrada B ULA para Branch

	ALU_MUX_A_Branch: entity work.mux3 port map (ID_ALUSrcA, ID_A, EX_ALUOut, ID_ALUOutlw, ID_alua);--Entrada A ULA para BRanch

	ALU_h_Branch: entity work.alu port map (ID_Operation, ID_alua, ID_alub, ID_ALUOut, ID_Zero);--ULA -> Comparador para Branch

	ALU_c_Branch: entity work.alu_ctl port map (ID_ALUOp, ID_funct, ID_Operation);


	-- calcula endereço do branch
	SHIFT_EXT: entity work.shift_left port map (ID_extend, 2, ID_offset);
	BRANCH_ADD: entity work.add32 port map (ID_pc4, ID_offset, ID_pc_branch);
	ID_PCSrc <= ID_Branch and ID_Zero;




    CTRL: entity work.control_pipeline port map (ID_op, ID_RegDst, ID_ReadBack, ID_SelExt, ID_MemtoReg, ID_RegWrite, ID_MemRead, ID_MemWrite, ID_Branch, ID_ALUOp);


    ID_EX_pip: process(clk)		    -- ID/EX Pipeline Register
    begin
	if rising_edge(clk) then
        	if reset = '1' then
            	EX_RegDst   <= '0';
	    		EX_ALUOp    <= (others => '0');
            	EX_ReadBack <= '0';
				EX_MemRead  <= '0';
				EX_MemWrite <= '0';
				EX_RegWrite <= '0';
				EX_MemtoReg <= '0';
				EX_SelExt	<= '0';

				EX_pc4      <= (others => '0');
				EX_A        <= (others => '0');
				EX_B        <= (others => '0');
				EX_extend   <= (others => '0');
				EX_rt       <= (others => '0');
				EX_rd       <= (others => '0');
        	elsif ID_stall = '0' then
            	EX_RegDst   <= ID_RegDst;
            	EX_ALUOp    <= ID_ALUOp;
            	EX_ReadBack <= ID_ReadBack;
            	EX_MemRead  <= ID_MemRead;
            	EX_MemWrite <= ID_MemWrite;
            	EX_RegWrite <= ID_RegWrite;
            	EX_MemtoReg <= ID_MemtoReg;
				EX_SelExt	<= ID_SelExt;
          
            	EX_pc4      <= ID_pc4;
            	EX_A        <= ID_A;
            	EX_B        <= ID_B;
            	EX_extend   <= ID_extend;
            	EX_rt       <= ID_rt;
				EX_rd       <= ID_rd;
				EX_rs       <= ID_rs;
			elsif ID_stall = '1' then -- Zera os sinais
				EX_MemRead  <= '0';
				EX_MemWrite <= '0';
				EX_RegWrite <= '0';
				EX_pc4      <= ID_pc4;
				EX_A        <= ID_A;
				EX_B        <= ID_B;
				EX_extend   <= ID_extend;
				EX_rt       <= ID_rt;
				EX_rd       <= ID_rd;
				EX_rs       <= ID_rs;
				EX_RegDst   <= ID_RegDst;
				EX_ALUOp    <= ID_ALUOp;
				EX_ReadBack <= ID_ReadBack;
				EX_SelExt	<= ID_SelExt;
        	end if;
	end if;
    end process;

    -- ********************************************************************
    --                              EX Stage
    -- ********************************************************************

	MX2_STALL_EX: process(EX_ReadBack,IF_pc)
    begin
	if EX_ReadBack = '0' then
		EX_stall <= '0';
		IF_pc_enable <= '0';
	elsif EX_ReadBack = '1' then
		EX_stall <= '1';
		IF_pc_enable <= '1';  -- Ativa escrita no PC
		IF_pc_stall <= IF_pc; -- Guarda PC atual
	end if;
    end process;




	FORWARD: entity work.forward_unit port map (MEM_RegRd, MEM_RegWrite, WB_RegRd, WB_RegWrite, EX_rs, EX_rt, Ex_ALUSrcA, EX_ALUSrcB);

	EX_funct <= EX_extend(5 downto 0);




	ALU_MUX_A1: entity work.mux3 port map (EX_ALUSrcA, EX_A, WB_wd, MEM_ALUOut, EX_alua); --Forward para a entrada A

	ALU_MUX_B1: entity work.mux3 port map (EX_ALUSrcB, EX_B, WB_wd, MEM_ALUOut, EX_alub); --Forward para a entrada B

	ALU_MUX_B2: entity work.mux2 port map (EX_SelExt, EX_alub, EX_extend, EX_alub_ext); --Forward para a entrada B

	ALU_MUX_B3: entity work.mux2 port map (EX_ReadBack, EX_alub_ext, EX_zero32, EX_alub_final); --Decide se soma 0 para o LWDI




	ALU_h: entity work.alu port map (EX_Operation, EX_alua, EX_alub_final, EX_ALUOut, EX_zero_branch);

	DEST_MUX2: entity work.mux2 generic map (5) port map (EX_RegDst, EX_rt, EX_rd, EX_RegRd);

	ALU_c: entity work.alu_ctl port map (EX_ALUOp, EX_funct, EX_Operation);





    EX_MEM_pip: process (clk)		    -- EX/MEM Pipeline Register
    begin
	if rising_edge(clk) then
        	if reset = '1' then
        
            		MEM_MemRead  <= '0';
            		MEM_MemWrite <= '0';
            		MEM_RegWrite <= '0';
            		MEM_MemtoReg <= '0';

            		MEM_ALUOut   <= (others => '0');
            		MEM_B        <= (others => '0');
            		MEM_RegRd    <= (others => '0');
			elsif EX_stall = '0' then
					MEM_MemWrite <= EX_MemWrite;
					MEM_MemRead  <= EX_MemRead;
            		MEM_RegWrite <= EX_RegWrite;
            		MEM_MemtoReg <= EX_MemtoReg;
					MEM_ReadBack <= EX_ReadBack;

            		MEM_ALUOut   <= EX_ALUOut;
            		MEM_B        <= EX_alub;
					MEM_RegRd    <= EX_RegRd;
					MEM_SelAddress <= EX_SelAddress;
			elsif EX_stall = '1' then
				if EX_ReadBack = '1' then
					MEM_MemRead  <= '1';
				elsif EX_ReadBack = '0' then
					MEM_MemRead  <= '0';
				end if;
					MEM_MemWrite <= '0';
					MEM_RegWrite <= '0';
            		MEM_MemtoReg <= EX_MemtoReg;
					MEM_ReadBack <= EX_ReadBack;

            		MEM_ALUOut   <= EX_ALUOut;
            		MEM_B        <= EX_alub;
					MEM_RegRd    <= EX_RegRd;
					MEM_SelAddress <= EX_SelAddress;
        	end if;
	end if;
    end process;

    -- ********************************************************************
    --                              MEM Stage
	-- ********************************************************************

	MX2_STALL_MEM: process(MEM_ReadBack)
    begin
	if MEM_ReadBack = '0' then
		EX_SelAddress	<= '0';
	elsif MEM_ReadBack = '1' then
		EX_SelAddress	<= '1';
	end if;
    end process;


	MEM_MUX2: entity work.mux2 port map (MEM_SelAddress, MEM_ALUOut, WB_memout, MEM_Address); --Decide o endereço da memória


	UP_MemRead <= MEM_MemRead or WB_ReadBack;

	MEM_ACCESS: entity work.mem32 port map (clk, UP_MemRead, MEM_MemWrite, MEM_Address, MEM_B, MEM_memout);
	

    MEM_WB_pip: process (clk)		-- MEM/WB Pipeline Register
    begin
	if rising_edge(clk) then
	        if reset = '1' then
            		WB_RegWrite <= '0';
            		WB_MemtoReg <= '0';
            		WB_ALUOut   <= (others => '0');
            		WB_memout   <= (others => '0');
            		WB_RegRd    <= (others => '0');
        	else
            		WB_RegWrite <= MEM_RegWrite;
            		WB_MemtoReg <= MEM_MemtoReg;
            		WB_ALUOut   <= MEM_ALUOut;
            		WB_memout   <= MEM_memout;
					WB_RegRd    <= MEM_RegRd;
					WB_ReadBack <= MEM_ReadBack;
        	end if;
	end if;
    end process;       


    -- ********************************************************************
    --                              WB Stage
	-- ********************************************************************
	
	WB_pip: process (clk)
    begin
	if rising_edge(clk) then
		if reset = '1' then
			UP_ReadBack <= '0';
			UP_RegRd	<= (others => '0');
		else
			UP_ReadBack <= WB_ReadBack;
			UP_RegRd	<= WB_RegRd;
		end if;
	end if;
	end process;


    MUX_DEST: entity work.mux2 port map (WB_MemtoReg, WB_ALUOut, WB_memout, WB_wd);


end arq_mips_pipeline;

