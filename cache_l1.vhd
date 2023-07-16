library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_pkg.all;

entity cache_l1 is
    port(
        -- cpu
        address : in std_logic_vector(15 downto 0);
        clk : in std_logic;
        rst : in std_logic;
        rd_cpu : in std_logic;
        wr_cpu : in std_logic;
        data_cpu_in : out std_logic_vector(7 downto 0);
        data_cpu_out : in std_logic_vector(7 downto 0);
        cachel1_hit : out std_logic;
        cachel1_miss : out std_logic;
        -- main_memory
        data_dram_in : out std_logic_vector(31 downto 0);
        data_dram_out : in std_logic_vector(31 downto 0);
        rd_dram : out std_logic;
        wr_dram : out std_logic;
        ready_dram : in std_logic
    );
end entity;

architecture cache_l1 of cache_l1 is
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

    component cache_controller is
        port(
            -- cpu
            address : in std_logic_vector(15 downto 0);
            clk : in std_logic;
            rst : in std_logic;
            rd_cpu : in std_logic;
            wr_cpu : in std_logic;
            data_cpu_in : out std_logic_vector(7 downto 0);
            data_cpu_out : in std_logic_vector(7 downto 0);
            cachel1_hit : out std_logic;
            cachel1_miss : out std_logic;
            -- sram
            sram_cache_line : in std_logic_vector(31 downto 0);
            rd_sram : out std_logic;
            wr_sram : out std_logic;
            wr_data_sram : out std_logic_vector(31 downto 0);
            -- tag_sram
            tag_sram_valid_bit : in std_logic;
            tag_sram_tag : in std_logic_vector(10 downto 0);
            wr_tag : out std_logic;
            rd_tag : out std_logic;
            wr_data_tag_sram : out std_logic_vector(10 downto 0);
            -- main_memory
            data_dram_in : out std_logic_vector(31 downto 0);
            data_dram_out : in std_logic_vector(31 downto 0);
            rd_dram : out std_logic;
            wr_dram : out std_logic;
            ready_dram : in std_logic
        );
    end component;

    signal sig_sram_cache_line : std_logic_vector(31 downto 0);
    signal sig_rd_sram : std_logic;
    signal sig_wr_sram : std_logic;
    signal sig_wr_data_sram : std_logic_vector(31 downto 0);
    signal sig_tag_sram_valid_bit : std_logic;
    signal sig_tag_sram_tag : std_logic_vector(10 downto 0);
    signal sig_wr_tag : std_logic;
    signal sig_rd_tag : std_logic;
    signal sig_wr_data_tag_sram : std_logic_vector(10 downto 0);
begin
    C_SRAM : sram port map(
        address => address,
        rst => rst,
        sram_cache_line => sig_sram_cache_line,
        rd_sram => sig_rd_sram,
        wr_sram => sig_wr_sram,
        wr_data_sram => sig_wr_data_sram
    );

    C_TAG_SRAM : tag_sram port map(
        address => address,
        rst => rst,
        tag_sram_valid_bit => sig_tag_sram_valid_bit,
        tag_sram_tag => sig_tag_sram_tag,
        wr_tag => sig_wr_tag,
        rd_tag => sig_rd_tag,
        wr_data_tag_sram => sig_wr_data_tag_sram
    );

    C_CACHE_CTRL : cache_controller port map(
        -- cpu
        address => address,
        clk => clk,
        rst => rst,
        rd_cpu => rd_cpu,
        wr_cpu => wr_cpu,
        data_cpu_in => data_cpu_in,
        data_cpu_out => data_cpu_out,
        cachel1_hit => cachel1_hit,
        cachel1_miss => cachel1_miss,
        -- sram
        sram_cache_line => sig_sram_cache_line,
        rd_sram => sig_rd_sram,
        wr_sram => sig_wr_sram,
        wr_data_sram => sig_wr_data_sram,
        -- tag_sram
        tag_sram_valid_bit => sig_tag_sram_valid_bit,
        tag_sram_tag => sig_tag_sram_tag,
        wr_tag => sig_wr_tag,
        rd_tag => sig_rd_tag,
        wr_data_tag_sram => sig_wr_data_tag_sram,
        -- main_memory
        data_dram_in => data_dram_in,
        data_dram_out => data_dram_out,
        rd_dram => rd_dram,
        wr_dram => wr_dram,
        ready_dram => ready_dram
    );
end architecture;

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_pkg.all;

entity tb_cache_l1 is
end entity;

architecture tb_cache_l1 of tb_cache_l1 is
    component cache_l1 is
        port(
            -- cpu
            address : in std_logic_vector(15 downto 0);
            clk : in std_logic;
            rst : in std_logic;
            rd_cpu : in std_logic;
            wr_cpu : in std_logic;
            data_cpu_in : out std_logic_vector(7 downto 0);
            data_cpu_out : in std_logic_vector(7 downto 0);
            cachel1_hit : out std_logic;
            cachel1_miss : out std_logic;
            -- main_memory
            data_dram_in : out std_logic_vector(31 downto 0);
            data_dram_out : in std_logic_vector(31 downto 0);
            rd_dram : out std_logic;
            wr_dram : out std_logic;
            ready_dram : in std_logic
        );
    end component;

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

    -- cpu
    signal tb_address : std_logic_vector(15 downto 0);
    signal tb_clk : std_logic := '0';
    signal tb_rst : std_logic;
    signal tb_rd_cpu : std_logic;
    signal tb_wr_cpu : std_logic;
    signal tb_data_cpu_in : std_logic_vector(7 downto 0);
    signal tb_data_cpu_out : std_logic_vector(7 downto 0);
    signal tb_cachel1_hit : std_logic;
    signal tb_cachel1_miss : std_logic;

    -- main_memory
    signal tb_data_dram_in : std_logic_vector(31 downto 0);
    signal tb_data_dram_out : std_logic_vector(31 downto 0);
    signal tb_rd_dram : std_logic;
    signal tb_wr_dram : std_logic;
    signal tb_ready_dram : std_logic;
begin
    tb_clk <= not tb_clk after 5ns;
    tb_rst <= '1', '0' after 525ns, '1' after 535ns;

    tb_address <= x"0000", x"0003" after 95ns, x"4004" after 115ns, 
                           x"0003" after 245ns, x"0001" after 315ns,
                           x"0082" after 385ns, x"0081" after 455ns;

    tb_rd_cpu <= '0', '1' after 15ns, '0' after 25ns, 
                      '1' after 95ns, '0' after 105ns,
                      '1' after 115ns, '0' after 125ns,
                      '1' after 205ns, '0' after 215ns;

    tb_wr_cpu <= '0', '1' after 245ns, '0' after 305ns,
                      '1' after 315ns, '0' after 375ns,
                      '1' after 385ns, '0' after 445ns,
                      '1' after 455ns, '0' after 515ns;

    tb_data_cpu_out <= (others => 'Z'), x"11" after 245ns, (others => 'Z') after 305ns,
                                        x"22" after 315ns, (others => 'Z') after 375ns,
                                        x"33" after 385ns, (others => 'Z') after 445ns,
                                        x"44" after 455ns, (others => 'Z') after 515ns;

    C_CACHE_L1 : cache_l1 port map(
         -- cpu
         address => tb_address,
         clk => tb_clk,
         rst => tb_rst,
         rd_cpu => tb_rd_cpu,
         wr_cpu => tb_wr_cpu,
         data_cpu_in => tb_data_cpu_in,
         data_cpu_out => tb_data_cpu_out,
         cachel1_hit => tb_cachel1_hit,
         cachel1_miss => tb_cachel1_miss,
         -- main_memory
         data_dram_in => tb_data_dram_in,
         data_dram_out => tb_data_dram_out,
         rd_dram => tb_rd_dram,
         wr_dram => tb_wr_dram,
         ready_dram => tb_ready_dram
    );

    C_MAIN_MEMORY : main_memory port map(
        clk => tb_clk,
        rst => tb_rst,
        address => tb_address,
        data_dram_in => tb_data_dram_in,
        data_dram_out => tb_data_dram_out,
        rd_dram => tb_rd_dram,
        wr_dram => tb_wr_dram,
        ready_dram => tb_ready_dram
    ); 
end architecture;