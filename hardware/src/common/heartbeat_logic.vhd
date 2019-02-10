---------------------------------- VHDL Code ----------------------------------
-- File         = heartbeat_logic.vhd
-- 
-- Purpose      = Logic which retains the heartbeat of the Readback CRC 
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


entity heartbeat_logic is
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
end heartbeat_logic;




architecture rtl of heartbeat_logic is


signal heartbeat_reg         : std_logic;



begin



heartbeat_bscan_p:
  process(bscan_tck)
    begin
      if bscan_tck'event and bscan_tck = '1' then

        if bscan_capture = '1' then
          bscan_tdo          <= heartbeat_reg;
        end if;

        
      end if;
    end process heartbeat_bscan_p;




heartbeat_reg_p:
  process(cfgclk, bscan_sel, bscan_update)
    begin
      -- The heartbeat signal is asynchronously reset in case of BSCAN access
      -- It is asserted when the last configuration frame is read 
      -- by the Readback CRC/Frame Ecc logic
      if bscan_sel = '1' and bscan_update = '1' then
        heartbeat_reg        <= '0';
      elsif cfgclk'event and cfgclk = '1' then

        if last_conf_frame = '1' then
          heartbeat_reg      <= '1';
        end if;

      end if;
    end process heartbeat_reg_p;



end;
