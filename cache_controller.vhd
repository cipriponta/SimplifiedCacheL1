library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_pkg.all;

entity cache_controller is
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
end cache_controller;

architecture cache_controller of cache_controller is
begin
    process(clk, rst)
        variable current_state : cache_controller_state_machine_type := cache_idle;
        variable aux_rd_internal : std_logic := '0';
        variable aux_rd_external : std_logic := '0';
        variable block_offset : integer;
        variable aux_cachel1_hit : std_logic := '0';
        variable aux_cachel1_miss : std_logic := '0';
        variable aux_data_cpu_in : std_logic_vector(7 downto 0) := (others => 'Z');
        variable aux_wr_internal : std_logic := '0';
        variable aux_wr_external : std_logic := '0';
        variable aux_wr_data_sram  : std_logic_vector(31 downto 0) := (others => 'Z');
        variable aux_wr_data_tag_sram : std_logic_vector(10 downto 0) := (others => 'Z');
        variable aux_wr_data_dram : std_logic_vector(31 downto 0) := (others => 'Z');
    begin
        if rising_edge(clk) then
            aux_rd_internal := '0';

            if current_state = cache_idle then
                if rd_cpu = '1' then
                    aux_rd_internal := '1';
                    current_state := cache_read;
                elsif wr_cpu = '1' then
                    aux_rd_internal := '1';
                    current_state := cache_write;
                end if;
            end if;
        elsif falling_edge(clk) then
            aux_rd_external := '0';
            aux_data_cpu_in := (others => 'Z');
            aux_cachel1_hit := '0';
            aux_cachel1_miss := '0';

            aux_wr_internal := '0';
            aux_wr_external := '0';

            aux_wr_data_sram := (others => 'Z');
            aux_wr_data_tag_sram := (others => 'Z');
            aux_wr_data_dram := (others => 'Z');

            if current_state = cache_read then
                block_offset := to_integer(unsigned(address(1 downto 0)));

                if block_offset = 0 then
                    aux_data_cpu_in := sram_cache_line(7 downto 0);
                elsif block_offset = 1 then
                    aux_data_cpu_in := sram_cache_line(15 downto 8);
                elsif block_offset = 2 then
                    aux_data_cpu_in := sram_cache_line(23 downto 16);
                elsif block_offset = 3 then
                    aux_data_cpu_in := sram_cache_line(31 downto 24);
                end if;  
                
                if tag_sram_tag = address(15 downto 5) and tag_sram_valid_bit = '1' then
                    current_state := cache_read_hit;
                else
                    current_state := cache_read_miss;
                end if;

                if current_state = cache_read_hit then
                    aux_cachel1_hit := '1';
                    current_state := cache_idle;
                elsif current_state = cache_read_miss then
                    aux_cachel1_miss := '1';
                    aux_rd_external := '1';
                    current_state := cache_read_wait_dram;
                end if;
            elsif current_state = cache_read_wait_dram then
                if ready_dram = '1' then
                    aux_wr_internal := '1';
                    aux_wr_data_sram := data_dram_out;
                    aux_wr_data_tag_sram := address(15 downto 5);
                    current_state := cache_idle;
                end if;
            elsif current_state = cache_write then
                if tag_sram_tag = address(15 downto 5) and tag_sram_valid_bit = '1' then
                    current_state := cache_write_hit;
                else
                    current_state := cache_write_miss;
                end if;
                
                if current_state = cache_write_hit then
                    aux_cachel1_hit := '1';

                    aux_wr_internal := '1';
                    aux_wr_data_sram := sram_cache_line;
                    block_offset := to_integer(unsigned(address(1 downto 0)));
                    if block_offset = 0 then
                        aux_wr_data_sram(7 downto 0) := data_cpu_out;
                    elsif block_offset = 1 then
                        aux_wr_data_sram(15 downto 8) := data_cpu_out;
                    elsif block_offset = 2 then
                        aux_wr_data_sram(23 downto 16) := data_cpu_out;
                    elsif block_offset = 3 then
                        aux_wr_data_sram(31 downto 24) := data_cpu_out;
                    end if;  
                    aux_wr_data_tag_sram := address(15 downto 5);

                    aux_rd_external := '1';
                    current_state := cache_write_wait_dram;
                elsif current_state = cache_write_miss then
                    aux_cachel1_miss := '1';

                    aux_rd_external := '1';
                    current_state := cache_write_wait_dram;
                end if;
            elsif current_state = cache_write_wait_dram then
                if ready_dram = '1' then
                    aux_wr_external := '1';
                    
                    aux_wr_data_dram := data_dram_out;
                    block_offset := to_integer(unsigned(address(1 downto 0)));
                    if block_offset = 0 then
                        aux_wr_data_dram(7 downto 0) := data_cpu_out;
                    elsif block_offset = 1 then
                        aux_wr_data_dram(15 downto 8) := data_cpu_out;
                    elsif block_offset = 2 then
                        aux_wr_data_dram(23 downto 16) := data_cpu_out;
                    elsif block_offset = 3 then
                        aux_wr_data_dram(31 downto 24) := data_cpu_out;
                    end if;  

                    current_state := cache_idle;
                end if;
            end if;
        end if;

        rd_sram <= aux_rd_internal;
        rd_tag <= aux_rd_internal;
        rd_dram <= aux_rd_external;

        cachel1_hit <= aux_cachel1_hit;
        cachel1_miss <= aux_cachel1_miss;

        data_cpu_in <= aux_data_cpu_in;

        wr_sram <= aux_wr_internal;
        wr_tag <= aux_wr_internal;
        wr_dram <= aux_wr_external;

        wr_data_sram <= aux_wr_data_sram;
        wr_data_tag_sram <= aux_wr_data_tag_sram;
        data_dram_in <= aux_wr_data_dram;
    end process;
end architecture;