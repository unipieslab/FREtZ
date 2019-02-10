---------------------------------- VHDL Code ----------------------------------
-- File         = fifo_engine.vhd
-- 
-- Purpose      = FIFO instantiation with Write Logic using FRAME_ECC signals
--                and Read Logic using BSCAN signals and Heartbeat Logic 
-- 
-- Library      = work
-- 
-- Dependencies = none
-- 
-- Author       = University of Piraeus
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity fifo_engine is
  port 
    (
    -- BSCAN A Signals
    bscan_tck_a              : in  std_logic;
    bscan_tdi_a              : in  std_logic;
    bscan_sel_a              : in  std_logic;
    bscan_shift_a            : in  std_logic;
    bscan_capture_a          : in  std_logic;
    bscan_update_a           : in  std_logic;
    bscan_tdo_a              : out std_logic;
    -- BSCAN B Signals
    bscan_tck_b              : in  std_logic;
    bscan_sel_b              : in  std_logic;
    bscan_capture_b          : in  std_logic;
    bscan_update_b           : in  std_logic;
    bscan_tdo_b              : out std_logic;
    -- FRAME ECC Signals
    cfgclk                   : in  std_logic;
    crc_error                : in  std_logic;
    ecc_error                : in  std_logic;
    syndrome_valid           : in  std_logic;
    syndrome                 : in  std_logic_vector(12 downto 0);
    frame_address            : in  std_logic_vector(25 downto 0);
    single_ecc_error         : in  std_logic;
    syn_bit                  : in  std_logic_vector(4 downto 0);
    syn_word                 : in  std_logic_vector(6 downto 0)
    );
end FIFO_engine;

architecture behavioral of fifo_engine is

component fifo_write_logic
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
end component;


component fifo_read_logic
  port 
    (
    -- BSCAN Signals
    bscan_tck                : in  std_logic;
    bscan_tdi                : in  std_logic;
    bscan_sel                : in  std_logic;
    bscan_shift              : in  std_logic;
    bscan_capture            : in  std_logic;
    bscan_update             : in  std_logic;
    bscan_tdo                : out std_logic;
    -- FIFO Signals
    fifo_empty               : in  std_logic;
    fifo_full                : in  std_logic;
    fifo_almostfull          : in  std_logic;
    fifo_dout                : in  std_logic_vector(63 downto 0);
    fifo_read                : out std_logic;
    fifo_reset               : out std_logic
    );
end component;

component heartbeat_logic
  port 
    (
    -- BSCAN Signals
    bscan_tck                : in  std_logic;
    bscan_sel                : in  std_logic;
    bscan_capture            : in  std_logic;
    bscan_update             : in  std_logic;
    bscan_tdo                : out std_logic;
    -- FRAME ECC Signals
    cfgclk                   : in  std_logic;
    last_conf_frame          : in  std_logic
    );
end component;


-- FIFO Signals
signal fifo_din              : std_logic_vector(63 downto 0);
signal fifo_write            : std_logic;
signal fifo_empty            : std_logic;
signal fifo_full             : std_logic;
signal fifo_almostfull       : std_logic;
signal fifo_dout             : std_logic_vector(63 downto 0);
signal fifo_read             : std_logic;
signal fifo_reset            : std_logic;

begin


fifo_wr_logic: fifo_write_logic
  port map
    (
    -- FRAME ECC Signals
    cfgclk                   => cfgclk,
    crc_error                => crc_error,
    ecc_error                => ecc_error,
    syndrome_valid           => syndrome_valid,
    syndrome                 => syndrome,
    frame_address            => frame_address,
    single_ecc_error         => single_ecc_error,
    syn_bit                  => syn_bit,
    syn_word                 => syn_word,
    -- FIFO Signals
    fifo_din                 => fifo_din,
    fifo_write               => fifo_write
    );


fifo_rd_logic: fifo_read_logic
  port map
    (
    -- BSCAN Signals
    bscan_tck                => bscan_tck_a,
    bscan_tdi                => bscan_tdi_a,
    bscan_sel                => bscan_sel_a,
    bscan_shift              => bscan_shift_a,
    bscan_capture            => bscan_capture_a,
    bscan_update             => bscan_update_a,
    bscan_tdo                => bscan_tdo_a,
    -- FIFO Signals
    fifo_empty               => fifo_empty,
    fifo_full                => fifo_full,
    fifo_almostfull          => fifo_almostfull,
    fifo_dout                => fifo_dout,
    fifo_read                => fifo_read,
    fifo_reset               => fifo_reset
    );


FIFO: FIFO36E1
  generic map
    (
    ALMOST_EMPTY_OFFSET      => X"0080",               -- Sets the almost empty threshold
    ALMOST_FULL_OFFSET       => X"0180",               -- Sets almost full threshold
    DATA_WIDTH               => 72,                    -- Sets data width to 4, 9, 18, 36, or 72
    DO_REG                   => 1,                     -- Enable output register (0 or 1) Must be 1 if EN_SYN = FALSE
    EN_ECC_READ              => FALSE,                 -- Enable ECC decoder, TRUE or FALSE
    EN_ECC_WRITE             => FALSE,                 -- Enable ECC encoder, TRUE or FALSE
    EN_SYN                   => FALSE,                 -- Specifies FIFO as Asynchronous (FALSE) or Synchronous (TRUE)
    FIFO_MODE                => "FIFO36_72",           -- Sets mode to "FIFO36" or "FIFO36_72"
    FIRST_WORD_FALL_THROUGH  => TRUE,                  -- Sets the FIFO FWFT to TRUE or FALSE
    INIT                     => X"000000000000000000", -- Initial values on output port
    SIM_DEVICE               => "7SERIES",             -- Must be set to "7SERIES" for simulation behavior
    SRVAL                    => X"000000000000000000"  -- Set/Reset value for output port
    )
  port map 
    (
    -- ECC Signals: 1-bit (each) output: Error Correction Circuitry ports
    DBITERR                  => open,            -- 1-bit output: Double bit error status output
    ECCPARITY                => open,            -- 8-bit output: Generated error correction parity output
    SBITERR                  => open,            -- 1-bit output: Single bit error status output
    -- Read Data: 64-bit (each) output: Read output data
    DO                       => fifo_dout,       -- 64-bit output: Data output
    DOP                      => open,            -- 8-bit output: Parity data output
    -- Status: 1-bit (each) output: Flags and other FIFO status outputs
    ALMOSTEMPTY              => open,            -- 1-bit output: Almost empty output flag
    ALMOSTFULL               => fifo_almostfull, -- 1-bit output: Almost full output flag
    EMPTY                    => fifo_empty,      -- 1-bit output: Empty output flag
    FULL                     => fifo_full,       -- 1-bit output: Full output flag
    RDCOUNT                  => open,            -- 13-bit output: Read count output
    RDERR                    => open,            -- 1-bit output: Read error output
    WRCOUNT                  => open,            -- 13-bit output: Write count output
    WRERR                    => open,            -- 1-bit output: Write error output
    -- ECC Signals: 1-bit (each) input: Error Correction Circuitry ports
    INJECTDBITERR            => '0',             -- 1-bit input: Inject a double bit error input
    INJECTSBITERR            => '0',
    -- Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
    RDCLK                    => bscan_tck_a,     -- 1-bit input: Read clock input
    RDEN                     => fifo_read,       -- 1-bit input: Read enable input
    REGCE                    => '1',             -- 1-bit input: Clock enable input
    RST                      => fifo_reset,      -- 1-bit input: Reset input
    RSTREG                   => '0',             -- 1-bit input: Output register set/reset input
    -- Write Control Signals: 1-bit (each) input: Write clock and enable input signals
    WRCLK                    => cfgclk,          -- 1-bit input: Rising edge write clock.
    WREN                     => fifo_write,      -- 1-bit input: Write enable input
    -- Write Data: 64-bit (each) input: Write input data
    DI                       => fifo_din,        -- 64-bit input: Data input
    DIP                      => (others => '0')  -- 8-bit input: Parity input
    );

heart_beat_logic: heartbeat_logic
  port map
    (
    -- BSCAN Signals
    bscan_tck                => bscan_tck_b,
    bscan_sel                => bscan_sel_b,
    bscan_capture            => bscan_capture_b,
    bscan_update             => bscan_update_b,
    bscan_tdo                => bscan_tdo_b,
    -- FRAME ECC Signals
    cfgclk                   => cfgclk,
    last_conf_frame          => frame_address(25)
    );

end behavioral;

