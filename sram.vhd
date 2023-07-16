library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_pkg.all;

entity sram is
    port(
        address : in std_logic_vector(15 downto 0);
        rst : in std_logic;
        sram_cache_line : out std_logic_vector(31 downto 0);
        rd_sram : in std_logic;
        wr_sram : in std_logic;
        wr_data_sram : in std_logic_vector(31 downto 0)
    );
end entity;

architecture sram of sram is
    signal sram_storage : cache_sram_type := (others => (others => '0'));
begin
    process(rd_sram, wr_sram, rst)
        variable aux_sram_cache_line : std_logic_vector(31 downto 0) := (others => 'Z');
        variable aux_sram_storage : cache_sram_type := sram_storage;
    begin
        aux_sram_cache_line := (others => 'Z');
        aux_sram_storage := sram_storage;

        if rst = '0' then
            aux_sram_storage := (others => (others => '0'));
        elsif rd_sram = '1' then
            aux_sram_cache_line(7 downto 0) := sram_storage(to_integer(unsigned(address(4 downto 2))) * 4 + 0);
            aux_sram_cache_line(15 downto 8) := sram_storage(to_integer(unsigned(address(4 downto 2))) * 4 + 1);
            aux_sram_cache_line(23 downto 16) := sram_storage(to_integer(unsigned(address(4 downto 2))) * 4 + 2);
            aux_sram_cache_line(31 downto 24) := sram_storage(to_integer(unsigned(address(4 downto 2))) * 4 + 3);
        elsif wr_sram = '1' then
            aux_sram_storage(to_integer(unsigned(address(4 downto 2))) * 4 + 0) := wr_data_sram(7 downto 0);
            aux_sram_storage(to_integer(unsigned(address(4 downto 2))) * 4 + 1) := wr_data_sram(15 downto 8);
            aux_sram_storage(to_integer(unsigned(address(4 downto 2))) * 4 + 2) := wr_data_sram(23 downto 16);
            aux_sram_storage(to_integer(unsigned(address(4 downto 2))) * 4 + 3) := wr_data_sram(31 downto 24);
        end if;
        
        sram_storage <= aux_sram_storage;
        sram_cache_line <= aux_sram_cache_line;
    end process;
end architecture;

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_pkg.all;

entity tb_sram is
end entity;

architecture tb_sram of tb_sram is
    component sram is
        port(
            address : in std_logic_vector(15 downto 0);
            rst : in std_logic;
            sram_cache_line : out std_logic_vector(31 downto 0);
            rd_sram : in std_logic;
            wr_sram : in std_logic;
            wr_data_sram : in std_logic_vector(31 downto 0)
        );
    end component;

    signal tb_address : std_logic_vector(15 downto 0);
    signal tb_rst : std_logic;
    signal tb_sram_cache_line : std_logic_vector(31 downto 0);
    signal tb_rd_sram : std_logic;
    signal tb_wr_sram : std_logic;
    signal tb_wr_data_sram : std_logic_vector(31 downto 0);
begin
    tb_address <= x"0000", x"0004" after 55ns, x"0000" after 65ns;
    tb_rst <= '1', '0' after 85ns, '1' after 95ns;
    tb_rd_sram <= '0', '1' after 35ns, '0' after 45ns;
    tb_wr_sram <= '0', '1' after 15ns, '0' after 25ns, '1' after 55ns, '0' after 65ns;
    tb_wr_data_sram <= (others => 'Z'), x"76543210" after 15ns, (others => 'Z') after 25ns, x"ABCDABCD" after 55ns, (others => 'Z') after 65ns;
    TBSRAM : sram port map(tb_address, tb_rst, tb_sram_cache_line, tb_rd_sram, tb_wr_sram, tb_wr_data_sram);
end architecture;
