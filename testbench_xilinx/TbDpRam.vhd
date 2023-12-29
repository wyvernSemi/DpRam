--
--  File Name:         TbDpRam.vhd
--  Design Unit Name:  TbDpRam
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Simple DpRam Manager Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    04/2018   2018       Initial revision
--    01/2020   2020.01    Updated license notice
--    12/2020   2020.12    Updated signal and port names
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2018 - 2020 by SynthWorks Design Inc.
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      https://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

library OSVVM_DPRAM ;
  context OSVVM_DpRam.DPRamContext ; 

entity TbDpRam is
end entity TbDpRam ;
architecture TestHarness of TbDpRam is
  constant ADDR_WIDTH : integer := 24 ;
  constant DATA_WIDTH : integer := 16 ;

  constant tperiod_Clk : time := 10 ns ;
  constant tpd         : time := 2 ns ;

  signal Clk         : std_logic := '0' ;
  signal nReset      : std_logic := '0' ;

  signal AddrA      : std_logic_vector(ADDR_WIDTH-1 downto 0) ; 
  signal WriteA     : std_logic ; 
  signal DataInA    : std_logic_vector(DATA_WIDTH-1 downto 0) ; 
  signal DataOutA   : std_logic_vector(DATA_WIDTH-1 downto 0) ; 

  signal AddrB      : std_logic_vector(ADDR_WIDTH-1 downto 0) ; 
  signal WriteB     : std_logic ; 
  signal DataInB    : std_logic_vector(DATA_WIDTH-1 downto 0) ; 
  signal DataOutB   : std_logic_vector(DATA_WIDTH-1 downto 0) ; 

--c  signal Manager1Rec, Manager2Rec  : AddressBusRecType (
--c          Address(ADDR_WIDTH-1 downto 0),
--c          DataToModel(DATA_WIDTH-1 downto 0),
--c          DataFromModel(DATA_WIDTH-1 downto 0)
--c        ) ;
  signal Manager1Rec, Manager2Rec  : AddressBusRecType ;

  component TestCtrl is
    port (
      -- Global Signal Interface
      nReset         : In    std_logic ;

      -- Transaction Interfaces
      Manager1Rec    : inout AddressBusRecType ;
      Manager2Rec    : inout AddressBusRecType
    ) ;
  end component TestCtrl ;

begin

--  Clk <= not Clk after Tperiod_Clk / 2 ; 
--  
--  process 
--  begin
--    wait until rising_edge(Clk) ; 
--    nReset <= '1' after tperiod_Clk * 7 + tpd ; 
--    wait ; 
--  end process ; 
  -- create Clock
  Osvvm.TbUtilPkg.CreateClock (
    Clk        => Clk,
    Period     => Tperiod_Clk
  )  ;

  -- create nReset
  Osvvm.TbUtilPkg.CreateReset (
    Reset       => nReset,
    ResetActive => '0',
    Clk         => Clk,
    Period      => 7 * tperiod_Clk,
    tpd         => tpd
  ) ;

  ------------------------------------------------------------
   DpRam_1 : entity osvvm_DpRam.DpRam
  ------------------------------------------------------------
    generic map ( 
      ADDR_WIDTH   => ADDR_WIDTH,
      DATA_WIDTH   => DATA_WIDTH,
      REGA_OUT     => FALSE, 
      REGB_OUT     => FALSE,
      MEMORY_NAME  => "DpRam_1"
    )
    port map (
      ClkA         => Clk     ,
      AddrA        => AddrA   ,
      WriteA       => WriteA  ,
      DataInA      => DataInA ,
      DataOutA     => DataOutA,
      
      ClkB         => Clk     ,
      AddrB        => AddrB   ,
      WriteB       => WriteB  ,
      DataInB      => DataInB ,
      DataOutB     => DataOutB
    ) ; 


  ------------------------------------------------------------
  DpRamController_1 : entity osvvm_DpRam.DpRamController 
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk         => Clk   ,
    nReset      => nReset,

    -- DpRam Manager Functional Interface
    Address     => AddrA   , 
    Write       => WriteA  , 
    oData       => DataInA , 
    iData       => DataOutA, 

    -- Testbench Transaction Interface
    TransRec    => Manager1Rec 
  ) ;
  
  ------------------------------------------------------------
  DpRamController_2 : entity osvvm_DpRam.DpRamController 
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk         => Clk   ,
    nReset      => nReset,

    -- DpRam Manager Functional Interface
    Address     => AddrB   , 
    Write       => WriteB  , 
    oData       => DataInB , 
    iData       => DataOutB, 

    -- Testbench Transaction Interface
    TransRec    =>  Manager2Rec
  ) ;
  
  
  ------------------------------------------------------------
  TestCtrl_1 : entity work.TestCtrl
  ------------------------------------------------------------
  port map (
    -- Global Signal Interface
    nReset        => nReset,

    -- Transaction Interfaces
    Manager1Rec   => Manager1Rec,
    Manager2Rec   => Manager2Rec
  ) ;

end architecture TestHarness ;