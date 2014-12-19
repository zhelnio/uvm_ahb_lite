/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    amba_xaction.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-28
 ********************************************************************/
 
`ifndef COMMAN_PKG_SV
`define COMMAN_PKG_SV
 
package common_pkg;                                                                                                                                                    
    `define UVM 
    `ifdef UVM 
        import uvm_pkg::*;
        `include "uvm_macros.svh"
        `include "common_component.svh"
    `endif
endpackage
 
`endif
