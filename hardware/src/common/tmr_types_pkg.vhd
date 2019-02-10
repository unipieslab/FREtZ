---------------------------------- VHDL Code ----------------------------------
-- File         = tmr_types_pkg.vhd
-- 
-- Purpose      = Types used by TMR design
-- 
-- Library      = work
-- 
-- Dependencies = none
-- 
-- Author       = University of Piraeus
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package tmr_types_pkg is

-- Types
type array3x5b  is array (0 to 2) of std_logic_vector(4 downto 0);
type array3x7b  is array (0 to 2) of std_logic_vector(6 downto 0);
type array3x13b is array (0 to 2) of std_logic_vector(12 downto 0);
type array3x26b is array (0 to 2) of std_logic_vector(25 downto 0);
type array3x64b is array (0 to 2) of std_logic_vector(63 downto 0);

end tmr_types_pkg;

