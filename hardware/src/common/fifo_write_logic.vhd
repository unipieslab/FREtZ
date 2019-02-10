---------------------------------- VHDL Code ----------------------------------
-- File         = fifo_write_logic.vhd
-- 
-- Purpose      = FIFO write logic using FRAME_ECC output
-- 
-- Library      = work
-- 
-- Dependencies = none
-- 
-- Author       = University of Piraeus
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;


entity fifo_write_logic is
  port 
    (
    -- FRAME ECC Signals
    cfgclk                   : in  std_logic;
    crc_error                : in  std_logic;
    ecc_error                : in  std_logic;
    syndrome_valid           : in  std_logic;
    syndrome                 : in  std_logic_vector(12 downto 0);
    frame_address            : in  std_logic_vector(25 downto 0);
    single_ecc_error         : in  std_logic;
    syn_bit                  : in  std_logic_vector(4 downto 0);
    syn_word                 : in  std_logic_vector(6 downto 0);
    -- FIFO Signals
    fifo_din                 : out std_logic_vector(63 downto 0);
    fifo_write               : out std_logic
    );
end fifo_write_logic;




architecture rtl of fifo_write_logic is

signal crc_error_d           : std_logic;
signal frame_address_d       : std_logic_vector(25 downto 0);
signal frame_address_err     : std_logic_vector(25 downto 0);



begin

fifo_write                   <= (crc_error and (not crc_error_d)) or (syndrome_valid and ecc_error);
fifo_din(63 downto 55)       <= (others => '0');
fifo_din(54 downto 42)       <= (others => '0'); --syn_bit & syn_word & single_ecc_error;
fifo_din(41 downto 16)       <= frame_address_err; 
fifo_din(15 downto 3)        <= syndrome; 
fifo_din(2 downto 0)         <= crc_error & ecc_error & syndrome_valid;



fifo_write_logic_p:
  process(cfgclk)
    begin
      if cfgclk'event and cfgclk = '1' then

        crc_error_d          <= crc_error;

--        if syndrome_valid = '1' then
--          frame_address_d    <= frame_address;
--          frame_address_err  <= frame_address_d;
--        end if;

      end if;
    end process fifo_write_logic_p;


far_err_g: for i in 0 to 25 generate
    far_shift_reg : SRLC32E
      generic map
        (
        INIT => X"00000000"
        )
      port map
        (
        Q    => frame_address_err(i),
        Q31  => open,
        A    => "00001",   -- 2 bit shift reg depth
        CE   => syndrome_valid,
        CLK  => cfgclk,
        D    => frame_address(i)
        );
  end generate far_err_g;


end;
