---------------------------------- VHDL Code ----------------------------------
-- File         = user_logic_monitoring.vhd
-- 
-- Purpose      = Logic which retains the status of the User Logic
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


entity user_logic_monitoring is
  port 
    (
    -- BSCAN Signals
    bscan_tck                : in  std_logic;
    bscan_sel                : in  std_logic;
    bscan_shift              : in  std_logic;
    bscan_capture            : in  std_logic;
    bscan_update             : in  std_logic;
    bscan_tdo                : out std_logic;
    -- User Logic Monitoring Signals
    clk                      : in  std_logic;
    output                   : in  std_logic
    );
end user_logic_monitoring;




architecture rtl of user_logic_monitoring is


signal output_d              : std_logic;
signal output_status_reg     : std_logic;
signal status_reg            : std_logic_vector(3 downto 0);

begin

bscan_tdo                    <= status_reg(0);

bscan_p:
  process(bscan_tck)
    begin
      if bscan_tck'event and bscan_tck = '1' then

        -- The Shift Register Output is loaded when the BSCAN CAPTURE signal is asserted.
        -- The status reg bits 1 to 3 are reserved for future use.
        if bscan_capture = '1' then 
          status_reg(0)      <= output_status_reg;
          status_reg(1)      <= '0';
          status_reg(2)      <= '1';
          status_reg(3)      <= '0';
        end if;


        -- The Status Register is shifted out to the TDO pin 
        if bscan_sel = '1' and bscan_shift = '1' then
          for i in 0 to 2 loop
            status_reg(i)    <= status_reg(i+1);
          end loop;
        end if;
        
      end if;
    end process bscan_p;



output_p:
  process(clk)
    begin
      if clk'event and clk = '1' then

        output_d             <= output;

      end if;
    end process output_p;



status_reg_p:
  process(clk, bscan_sel, bscan_update)
    begin
      -- The status signal is asynchronously reset in case of BSCAN access
      if bscan_sel = '1' and bscan_update = '1' then
        output_status_reg    <= '0';

      -- It is asserted in case that the output toggles
      elsif clk'event and clk = '1' then

        if (output xor output_d) = '1' then
          output_status_reg  <= '1';
        end if;

      end if;
    end process status_reg_p;




end;
