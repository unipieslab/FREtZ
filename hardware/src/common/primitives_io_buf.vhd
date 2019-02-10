---------------------------------- VHDL Code ----------------------------------
-- File         = primitives_io_buf.vhd
-- 
-- Purpose      = Triplication of the BSCAN and FRAME ECC Output Signals
-- 
-- Library      = work
-- 
-- Dependencies = none
-- 
-- Author       = University of Piraeus
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.tmr_types_pkg.all;

library unisim;
use unisim.vcomponents.all;


entity primitives_io_buf is
  port 
    (
    -- BSCAN A Signals
    bscan_tck_a              : in  std_logic;
    bscan_capture_a          : in  std_logic;
    bscan_sel_a              : in  std_logic;
    bscan_shift_a            : in  std_logic;
    bscan_tdi_a              : in  std_logic;
    bscan_update_a           : in  std_logic;
    bscan_tck_a_buf          : out std_logic_vector(2 downto 0);
    bscan_capture_a_buf      : out std_logic_vector(2 downto 0);
    bscan_sel_a_buf          : out std_logic_vector(2 downto 0);
    bscan_shift_a_buf        : out std_logic_vector(2 downto 0);
    bscan_tdi_a_buf          : out std_logic_vector(2 downto 0);
    bscan_update_a_buf       : out std_logic_vector(2 downto 0);

    -- BSCAN B Signals
    bscan_tck_b              : in  std_logic;
    bscan_capture_b          : in  std_logic;
    bscan_sel_b              : in  std_logic;
    bscan_update_b           : in  std_logic;
    bscan_tck_b_buf          : out std_logic_vector(2 downto 0);
    bscan_capture_b_buf      : out std_logic_vector(2 downto 0);
    bscan_sel_b_buf          : out std_logic_vector(2 downto 0);
    bscan_update_b_buf       : out std_logic_vector(2 downto 0);

    -- FRAME ECC Signals
    cfgclk                   : in  std_logic;
    crc_error                : in  std_logic;
    ecc_error                : in  std_logic;
    frame_address            : in  std_logic_vector(25 downto 0);
    syndrome                 : in  std_logic_vector(12 downto 0);
    syndrome_valid           : in  std_logic;
    cfgclk_buf               : out std_logic_vector(2 downto 0);
    crc_error_buf            : out std_logic_vector(2 downto 0);
    ecc_error_buf            : out std_logic_vector(2 downto 0);
    frame_address_buf        : out array3x26b;
    syndrome_buf             : out array3x13b;
    syndrome_valid_buf       : out std_logic_vector(2 downto 0)
    );
end primitives_io_buf;

architecture behavioral of primitives_io_buf is


begin

bscan_a_buf_gen:
  for i in 0 to 2 generate

    lut_bscan_tck_a_buf: lut1
      generic map (init => x"2")
      port map (i0 => bscan_tck_a, o => bscan_tck_a_buf(i));

    lut_bscan_capture_a_buf: lut1
      generic map (init => x"2")
      port map (i0 => bscan_capture_a, o => bscan_capture_a_buf(i));

    lut_bscan_sel_a_buf: lut1
      generic map (init => x"2")
      port map (i0 => bscan_sel_a, o => bscan_sel_a_buf(i));

    lut_bscan_shift_a_buf: lut1
      generic map (init => x"2")
      port map (i0 => bscan_shift_a, o => bscan_shift_a_buf(i));

    lut_bscan_tdi_a_buf: lut1
      generic map (init => x"2")
      port map (i0 => bscan_tdi_a, o => bscan_tdi_a_buf(i));

    lut_bscan_update_a_buf: lut1
      generic map (init => x"2")
      port map (i0 => bscan_update_a, o => bscan_update_a_buf(i));

end generate;


bscan_b_buf_gen:
  for i in 0 to 2 generate

    lut_bscan_tck_b_buf: lut1
      generic map (init => x"2")
      port map (i0 => bscan_tck_b, o => bscan_tck_b_buf(i));

    lut_bscan_capture_b_buf: lut1
      generic map (init => x"2")
      port map (i0 => bscan_capture_b, o => bscan_capture_b_buf(i));

    lut_bscan_sel_b_buf: lut1
      generic map (init => x"2")
      port map (i0 => bscan_sel_b, o => bscan_sel_b_buf(i));

    lut_bscan_update_b_buf: lut1
      generic map (init => x"2")
      port map (i0 => bscan_update_b, o => bscan_update_b_buf(i));

end generate;


frame_ecc_buf_gen:
  for i in 0 to 2 generate

    lut_cfgclk_buf: lut1
      generic map (init => x"2")
      port map (i0 => cfgclk, o => cfgclk_buf(i));
          
    lut_crc_error_buf: lut1
      generic map (init => x"2")
      port map (i0 => crc_error, o => crc_error_buf(i));

    lut_ecc_error_buf: lut1
      generic map (init => x"2")
      port map (i0 => ecc_error, o => ecc_error_buf(i));

    vector_gen_26b: for j in 0 to 25 generate

      lut_frame_address_buf: lut1
        generic map (init => x"2")
        port map (i0 => frame_address(j), o => frame_address_buf(i)(j));

    end generate;

    vector_gen_13b: for j in 0 to 12 generate

      lut_syndrome_buf: lut1
        generic map (init => x"2")
        port map (i0 => syndrome(j), o => syndrome_buf(i)(j));

    end generate;

    lut_syndrome_valid_buf: lut1
      generic map (init => x"2")
      port map (i0 => syndrome_valid, o => syndrome_valid_buf(i));
        
end generate;
  

end behavioral;

