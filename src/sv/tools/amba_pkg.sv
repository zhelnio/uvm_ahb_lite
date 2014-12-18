/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    amba_pkg.sv
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-12-18
 ********************************************************************/
 
`ifndef AMBA_PKG_SV
`define AMBA_PKG_SV

    package amba_pkg;
        import uvm_pkg::*;
        `include "uvm_macros.svh"

        `include "amba_define.svh"
        `include "amba_type.svh"
        `include "amba_xaction.svh"
        `include "amba_common_tools.svh"

    endpackage

`endif
