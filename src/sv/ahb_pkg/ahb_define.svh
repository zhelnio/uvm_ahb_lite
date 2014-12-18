/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_define.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-09
 ********************************************************************/

`ifndef AHB_DEFINE_SVH
`define AHB_DEFINE_SVH

    `ifndef w_HADDR
        `define     w_HADDR     32
    `endif
    `ifndef w_HWDATA
        `define     w_HWDATA    32
    `endif
    `ifndef w_HRDATA
        `define     w_HRDATA    32
    `endif

    `define     w_HTRANS        2
    `define     w_HBURST        3
    `define     w_HSIZE         3
    `define     w_HSEL          1
    `define     w_HREADY_I      1
    `define     w_HREADY_O      1
    `define     w_HRESP         2

`endif
