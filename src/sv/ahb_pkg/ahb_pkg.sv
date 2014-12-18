/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_pkg.sv
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-09
 ********************************************************************/

`ifndef AHB_PKG_SV
`define AHB_PKG_SV

package ahb_pkg;
    `define UVM_11
    `define UVM
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import amba_pkg::*;
    import common_pkg::*;

    `include "ahb_define.svh"
    `include "ahb_type.svh"
    
    `include "ahb_xaction.svh"
    `include "ahb_agent_config.svh"
    `include "ahb_env_config.svh"
    `include "ahb_sequence_lib.svh"
    `include "ahb_master_driver.svh"
    `include "ahb_slave_driver.svh"
    `include "ahb_monitor.svh"
    `include "ahb_analyzer.svh"
    `include "ahb_collector.svh"
    `include "ahb_master_agent.svh"
    `include "ahb_slave_agent.svh"
    `include "ahb_comparator.svh"
    `include "ahb_env.svh"
endpackage : ahb_pkg

`endif
