library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_pkg.all;

entity main_memory is
    port(
        clk : in std_logic;
        rst : in std_logic;
        address : in std_logic_vector(15 downto 0);
        data_dram_in : in std_logic_vector(31 downto 0);
        data_dram_out : out std_logic_vector(31 downto 0);
        rd_dram : in std_logic;
        wr_dram : in std_logic;
        ready_dram : out std_logic
    );
end entity;


architecture main_memory of main_memory is
    signal memory_storage : main_memory_type := (
        0 => x"00",
        1 => x"01",
        2 => x"02",
        3 => x"03",
        others => x"FF"
    );
begin   
    process(clk, rst)
        variable clk_counter : integer := 0;
        variable aux_memory_storage : main_memory_type := memory_storage;
        variable aux_ready_dram : std_logic := '0';
        variable aux_data_dram_out : std_logic_vector(31 downto 0);
    begin
        aux_memory_storage := memory_storage;

        if falling_edge(rst) then
            aux_memory_storage := (others => x"00");
        elsif rising_edge(clk) then
            aux_ready_dram := '0';

            if wr_dram = '1' then
                aux_memory_storage(to_integer(unsigned(address(15 downto 2))) * 4 + 0) := data_dram_in(7 downto 0);
                aux_memory_storage(to_integer(unsigned(address(15 downto 2))) * 4 + 1) := data_dram_in(15 downto 8);
                aux_memory_storage(to_integer(unsigned(address(15 downto 2))) * 4 + 2) := data_dram_in(23 downto 16);
                aux_memory_storage(to_integer(unsigned(address(15 downto 2))) * 4 + 3) := data_dram_in(31 downto 24);
            elsif rd_dram = '1' and clk_counter = 0 then
                clk_counter := 5;
            end if;

            if clk_counter > 0 then
                clk_counter := clk_counter - 1;
                if clk_counter = 0 then
                    aux_ready_dram := '1';
                end if;
            end if;
            
            if aux_ready_dram = '1' then
                aux_data_dram_out(7 downto 0) := memory_storage(to_integer(unsigned(address(15 downto 2))) * 4 + 0);
                aux_data_dram_out(15 downto 8) := memory_storage(to_integer(unsigned(address(15 downto 2))) * 4 + 1);
                aux_data_dram_out(23 downto 16) := memory_storage(to_integer(unsigned(address(15 downto 2))) * 4 + 2);
                aux_data_dram_out(31 downto 24) := memory_storage(to_integer(unsigned(address(15 downto 2))) * 4 + 3);
            else
                aux_data_dram_out := (others => 'Z');
            end if;
        end if;

        ready_dram <= aux_ready_dram;
        data_dram_out <= aux_data_dram_out;
        memory_storage <= aux_memory_storage;
    end process;
end architecture;

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_pkg.all;

entity tb_main_memory is
end entity;

architecture tb_main_memory of tb_main_memory is
    component main_memory is
        port(
            clk : in std_logic;
            rst : in std_logic;
            address : in std_logic_vector(15 downto 0);
            data_dram_in : in std_logic_vector(31 downto 0);
            data_dram_out : out std_logic_vector(31 downto 0);
            rd_dram : in std_logic;
            wr_dram : in std_logic;
            ready_dram : out std_logic
        );
    end component;

    signal tb_clk : std_logic := '0';
    signal tb_rst : std_logic;
    signal tb_address : std_logic_vector(15 downto 0);
    signal tb_data_dram_in : std_logic_vector(31 downto 0);
    signal tb_data_dram_out : std_logic_vector(31 downto 0);
    signal tb_rd_dram : std_logic;
    signal tb_wr_dram : std_logic;
    signal tb_ready_dram : std_logic;
begin
    tb_clk <= not tb_clk after 5ns;
    tb_rst <= '1', '0' after 105ns, '1' after 115ns;
    tb_address <= (others => '0'), x"0004" after 100ns;
    tb_data_dram_in <= (others => 'Z'), x"11223344" after 125ns, (others => 'Z') after 135ns;
    tb_rd_dram <= '0', '1' after 25ns, '0' after 35ns; 
    tb_wr_dram <= '0', '1' after 125ns, '0' after 135ns;
    TB_MM : main_memory port map(tb_clk, tb_rst, tb_address, tb_data_dram_in, tb_data_dram_out, tb_rd_dram, tb_wr_dram, tb_ready_dram);
end architecture;