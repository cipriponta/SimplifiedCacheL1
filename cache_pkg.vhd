library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cache_pkg is
    type cache_block_type is array(0 to 3) of std_logic_vector(7 downto 0);
    type main_memory_type is array(0 to 65535) of std_logic_vector(7 downto 0);
    type cache_sram_type is array (0 to 31) of std_logic_vector(7 downto 0);
    type tag_sram_valid_bit_type is array(0 to 7) of std_logic;
    type tag_sram_tag_type is array(0 to 7) of std_logic_vector(10 downto 0);
    type cache_controller_state_machine_type is (cache_idle, 
                                                 cache_read, cache_read_hit, cache_read_miss, cache_read_wait_dram,
                                                 cache_write, cache_write_hit, cache_write_miss, cache_write_wait_dram);
end package;