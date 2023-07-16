library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_pkg.all;

entity tag_sram is
    port(
        address : in std_logic_vector(15 downto 0);
        rst : in std_logic;
        tag_sram_valid_bit : out std_logic;
        tag_sram_tag : out std_logic_vector(10 downto 0);
        wr_tag : in std_logic;
        rd_tag : in std_logic;
        wr_data_tag_sram : in std_logic_vector(10 downto 0)
    );
end entity;

architecture tag_sram of tag_sram is 
    signal tag_sram_valid_bit_storage : tag_sram_valid_bit_type := (others => '0');
    signal tag_sram_tag_storage : tag_sram_tag_type := (others => (others => '0'));
begin
    process(rd_tag, wr_tag, rst)
        variable aux_tag_sram_valid_bit : std_logic := 'Z';
        variable aux_tag_sram_tag : std_logic_vector(10 downto 0) := (others => 'Z');
        variable aux_tag_sram_valid_bit_storage : tag_sram_valid_bit_type := tag_sram_valid_bit_storage;
        variable aux_tag_sram_tag_storage : tag_sram_tag_type := tag_sram_tag_storage;
    begin
        aux_tag_sram_valid_bit := 'Z';
        aux_tag_sram_tag := (others => 'Z');
        aux_tag_sram_valid_bit_storage := tag_sram_valid_bit_storage;
        aux_tag_sram_tag_storage := tag_sram_tag_storage;

        if rst = '0' then
            aux_tag_sram_valid_bit_storage := (others => '0');
            aux_tag_sram_tag_storage := (others => (others => '0'));
        elsif rd_tag = '1' then
            aux_tag_sram_valid_bit := tag_sram_valid_bit_storage(to_integer(unsigned(address(4 downto 2))));
            aux_tag_sram_tag := tag_sram_tag_storage(to_integer(unsigned(address(4 downto 2))));
        elsif wr_tag = '1' then
            aux_tag_sram_valid_bit_storage(to_integer(unsigned(address(4 downto 2)))) := '1';
            aux_tag_sram_tag_storage(to_integer(unsigned(address(4 downto 2)))) := wr_data_tag_sram;
        end if;
        
        tag_sram_valid_bit_storage <= aux_tag_sram_valid_bit_storage;
        tag_sram_tag_storage <= aux_tag_sram_tag_storage;
        tag_sram_valid_bit <= aux_tag_sram_valid_bit;
        tag_sram_tag <= aux_tag_sram_tag;
    end process;
end architecture;

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_pkg.all;

entity tb_tag_sram is
end entity;

architecture tb_tag_sram of tb_tag_sram is
    component tag_sram is
        port(
            address : in std_logic_vector(15 downto 0);
            rst : in std_logic;
            tag_sram_valid_bit : out std_logic;
            tag_sram_tag : out std_logic_vector(10 downto 0);
            wr_tag : in std_logic;
            rd_tag : in std_logic;
            wr_data_tag_sram : in std_logic_vector(10 downto 0)
        );
    end component;

    signal tb_address : std_logic_vector(15 downto 0);
    signal tb_rst : std_logic;
    signal tb_tag_sram_valid_bit : std_logic;
    signal tb_tag_sram_tag : std_logic_vector(10 downto 0);
    signal tb_wr_tag : std_logic;
    signal tb_rd_tag : std_logic;
    signal tb_wr_data_tag_sram : std_logic_vector(10 downto 0);
begin
    tb_address <= (others => '0'), x"0004" after 55ns;
    tb_rst <= '1', '0' after 95ns, '1' after 105ns; 
    tb_wr_tag <= '0', '1' after 15ns, '0' after 25ns, '1' after 55ns, '0' after 65ns;
    tb_rd_tag <= '0', '1' after 35ns, '0' after 45ns, '1' after 75ns, '0' after 85ns;
    tb_wr_data_tag_sram <= (others => 'Z'), "00010101010" after 15ns, (others => 'Z') after 25ns, "00011001100" after 55ns, (others => 'Z') after 65ns;

    TBTAGSRAM : tag_sram port map(tb_address, tb_rst, tb_tag_sram_valid_bit, tb_tag_sram_tag, tb_wr_tag, tb_rd_tag, tb_wr_data_tag_sram);
end architecture;