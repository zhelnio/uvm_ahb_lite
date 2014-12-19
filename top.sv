/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *       
 * \file    ahb_sequence_lib.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-29
 ********************************************************************/
         
`ifndef TOP_SV                                                                                                                                                         
`define TOP_SV
         
import uvm_pkg::*;
import ahb_pkg::*;
import ahb_case_pkg::*;
         
`include "uvm_macros.svh"
         
`include "ahb_if.svi"
`include "ahb_decoder.svh"
         
module top;
         
    reg HCLK;
    reg HRESET_N;
    wire hready;
         
    ahb_master_if   master_port(HCLK);
    ahb_decoder_if  decoder_port(HCLK);
         
    ahb_dummy   DUT(
        .HCLK       (HCLK),
        .HRESET_N   (HRESET_N),
        .HADDR      (decoder_port.HADDR_O),
        .HTRANS     (master_port.HTRANS),
        .HBURST     (master_port.HBURST),
        .HWRITE     (master_port.HWRITE),
        .HSIZE      (master_port.HSIZE),
        .HSEL       (decoder_port.HSEL[0]),
        .HWDATA     (master_port.HWDATA),
        .HREADY_I   (hready),
        .HRDATA     (decoder_port.HRDATA_I[0]),
        .HREADY_O   (hready),
        .HRESP      (decoder_port.HRESP_I[0])
    );   
         
    ahb_decoder     decoder(decoder_port);
    assign decoder_port.HADDR_I     = master_port.HADDR;
    assign master_port.HRESP        = decoder_port.HRESP_O;
    assign master_port.HRDATA       = decoder_port.HRDATA_O;
    assign master_port.HREADY       = decoder_port.HREADY_O;
    assign decoder_port.HRESET_N    = master_port.HRESET_N;
         
    assign decoder_port.HREADY_I[0]    = hready;                                                                                                                       
         
    initial begin
        uvm_config_db #(virtual ahb_master_if)::set(uvm_root::get(), "*", "ahb_master_if", master_port);
        run_test();
    end  
         
    initial begin
        HCLK            = 1'b0;
        HRESET_N        = 1'b0;
        #11 HRESET_N    = 1'b1;
    end  
        
    always #4   HCLK = ~HCLK;
endmodule : top

