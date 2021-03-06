----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:15:42 06/24/2016 
-- Design Name: 
-- Module Name:    controller - rtl 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller is
	generic (N : integer := 32);
	port (enqueue, dequeue : in std_logic;
		clk, reset : in std_logic;
		counter_reset, counter_enable : out std_logic;
		remove, mode : out std_logic;
		index : out std_logic_vector (N - 1 downto 0);
		counter_index : in std_logic_vector (N - 1 downto 0);
		data_in, tid_in : in std_logic_vector (15 downto 0);
		data_out, tid_out : out std_logic_vector (15 downto 0));
end entity;

architecture rtl of controller is
	type state is (RST, EQ0, EQ1, DQ0, DQ1);
	signal current_state, next_state : state := RST;

	signal tid_reg : std_logic_vector (15 downto 0);
	signal inx_reg : std_logic_vector (N - 1 downto 0);
begin
	process (clk)
	begin
		if clk'event and clk = '1' then
			if reset = '1' then
				current_state <= RST;
			else
				current_state <= next_state;
	end process;
	process (current_state, enqueue, dequeue)
	begin
		case current_state is
			when RST =>
				if enqueue = '1' then
					next_state <= EQ0;
				elsif dequeue = '1' then
					next_state <= DQ0;
				else
					next_state <= RST;
				end if;
			when DQ0 =>
				next_state <= DQ1;
			when DQ1 =>
				next_state <= RST;
			when EQ0 =>
				next_state <= EQ1;
			when EQ1 =>
				next_state <= EQ2;
			when EQ2 =>
				next_state <= EQ3;
			when EQ3 =>
				if tid_reg <= tid then
					next_state <= EQ4;
				elsif inx_reg = (others => '1') then
					next_state <= EQ4;
				else
					next_state <= EQ1;
				end if;
			when EQ4 =>
				next_state <= RST;
		end case;
	end process;
	process (current_state)
	begin
		case current_state is
			when RST =>
				index <= (others <= '0');
				remove <= '0';
				mode <= '0';
			when DQ0 =>
				index <= (others <= '1');
				remove <= '0';
				mode <= '0';
			when DQ1 =>
				index <= (others <= '1');
				data_out <= tid_in;
				remove <= '1';
				mode <= '0';
			when EQ0 =>
				counter_reset <= '1';
				counter_enable <= '1';
				tid_reg <= data_in;
			when EQ1 =>
				counter_reset <= '0';
				counter_enable <= '1';
				inx_reg <= counter_index;
			when EQ2 =>
				index <= inx_reg;
				remove <= '0';
				mode <= '0';
				counter_reset <= '0';
				counter_enable <= '0';
			when EQ3 =>
				index <= (others => '0');
				remove <= '0';
				mode <= '0';
				counter_reset <= '0';
				counter_enable <= '0';
			when EQ4 =>
				index <= inx_reg;
				remove <= '1';
				mode <= '1';
		end case;
	end process;
end;
