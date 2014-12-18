/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    amba_xaction.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-12-18
 ********************************************************************
 */
`ifndef AMBA_UVM_XACTION_SVH
`define AMBA_UVM_XACTION_SVH

    class amba_uvm_xaction extends uvm_sequence_item;
        rand int unsigned       len;
        rand amba_size_e        amba_size;
        rand amba_addr_t        first_address;
        rand amba_burst_type_e  burst_type;
    
        constraint c_valid_len {
            len < 5;
        }

        constraint c_align {
            (amba_size == AMBA_BYTE_2)      -> (first_address[0:0]  == 0);
            (amba_size == AMBA_BYTE_4)      -> (first_address[1:0]  == 0);
            (amba_size == AMBA_BYTE_8)      -> (first_address[2:0]  == 0);
            (amba_size == AMBA_BYTE_16)     -> (first_address[3:0]  == 0);
            (amba_size == AMBA_BYTE_32)     -> (first_address[4:0]  == 0);
            (amba_size == AMBA_BYTE_64)     -> (first_address[5:0]  == 0);
            (amba_size == AMBA_BYTE_128)    -> (first_address[6:0]  == 0);
        }

        `uvm_object_utils(amba_uvm_xaction)
    
        extern function new(string name = "amba_uvm_xaction");
    endclass : amba_uvm_xaction
    
        function amba_uvm_xaction::new (string name = "amba_uvm_xaction");
            super.new(name);
        endfunction : new

`endif
