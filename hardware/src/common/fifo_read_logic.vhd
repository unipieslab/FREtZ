---------------------------------- VHDL Code ----------------------------------
-- File         = fifo_write_logic.vhd
-- 
-- Purpose      = FIFO read logic through BSCAN primitive
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


entity fifo_read_logic is
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
end fifo_read_logic;




architecture rtl of fifo_read_logic is


constant shift_reg_out_width : integer := 48;
signal shift_reg_out         : std_logic_vector(shift_reg_out_width-1 downto 0);
signal shift_reg_in          : std_logic_vector(3 downto 0);
signal read_command          : std_logic;
signal reset_command         : std_logic;




begin


bscan_tdo                    <= shift_reg_out(0);
fifo_read                    <= bscan_sel and bscan_capture and read_command;
fifo_reset                   <= reset_command;


fifo_read_logic_p:
  process(bscan_tck)
    begin
      if bscan_tck'event and bscan_tck = '1' then

        -- The Shift Register Output is loaded when the BSCAN CAPTURE signal is asserted. 
        -- In this clock cycle, the FWFT FIFO read signal is also asserted in case that
        -- the FIFO READ COMMAND has already been programmed through the BSCAN.
        if bscan_capture = '1' then 
          --shift_reg_out      <= x"0" & "00" & fifo_dout(54 downto 42) & fifo_full & fifo_almostfull & fifo_empty & fifo_dout(41 downto 0);
          shift_reg_out      <= "000" & fifo_full & fifo_almostfull & fifo_empty & fifo_dout(41 downto 0);
        end if;


        -- The Shift Register Output is shifted out to the TDO pin 
        if bscan_sel = '1' and bscan_shift = '1' then
          for i in 0 to shift_reg_out_width-2 loop
            shift_reg_out(i) <= shift_reg_out(i+1);
          end loop;
        end if;


        -- The data available on the TDI pin is shifted in to the Shift Register Input. 
        if bscan_sel = '1' and bscan_shift = '1' then
          shift_reg_in(3)    <= bscan_tdi;
          for i in 0 to 2 loop
            shift_reg_in(i)  <= shift_reg_in(i+1);
          end loop;
        end if;

        
        -- The FIFO READ COMMAND is programmed through BSCAN.
        -- It is valid until the next BSCAN UPDATE.
        if bscan_update = '1' then
          if shift_reg_in = x"6" then
            read_command       <= '1';
          else
            read_command       <= '0';
          end if;
        end if;
        

        -- The FIFO RESET COMMAND is programmed through BSCAN.
        -- It is valid until the next BSCAN UPDATE.
        if bscan_update = '1' then
          if shift_reg_in = x"9" then
            reset_command      <= '1';
          else
            reset_command      <= '0';
          end if;
        end if;
        

      end if;
    end process fifo_read_logic_p;


end;
