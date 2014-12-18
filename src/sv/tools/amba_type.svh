/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    amba_type.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-12-18
 ********************************************************************/

`ifndef AMBA_TYPE_SVH
`define AMBA_TYPE_SVH
    
    typedef bit [`AMBA_BUS_ADDR_WIDTH-1:0]  amba_addr_t;
    typedef bit [`AMBA_BUS_DATA_WIDTH-1:0]  amba_data_t;

    typedef int unsigned    uint;

    typedef enum int {
        AMBA_BYTE_1,
        AMBA_BYTE_2,
        AMBA_BYTE_4,
        AMBA_BYTE_8,
        AMBA_BYTE_16,
        AMBA_BYTE_32,
        AMBA_BYTE_64,
        AMBA_BYTE_128
    }   amba_size_e;
    
    typedef enum int {
        READ,
        WRITE
    }   amba_direction_e;
    
    typedef enum int {
        FIXED,
        INCR,
        WRAP
    }   amba_burst_type_e;
    
    function string amba_size_to_string (amba_size_e amba_size);
        case (amba_size)
            AMBA_BYTE_1:    amba_size_to_string = "AMBA_BYTE_1";
            AMBA_BYTE_2:    amba_size_to_string = "AMBA_BYTE_2";
            AMBA_BYTE_4:    amba_size_to_string = "AMBA_BYTE_4";
            AMBA_BYTE_8:    amba_size_to_string = "AMBA_BYTE_8";
            AMBA_BYTE_16:   amba_size_to_string = "AMBA_BYTE_16";
            AMBA_BYTE_32:   amba_size_to_string = "AMBA_BYTE_32";
            AMBA_BYTE_64:   amba_size_to_string = "AMBA_BYTE_64";
            AMBA_BYTE_128:  amba_size_to_string = "AMBA_BYTE_128";
            default:`uvm_error("IVLCFG", "Invalid AMBA size")
        endcase
    endfunction : amba_size_to_string
    
    function string amba_direction_to_string (amba_direction_e amba_direction);
        case (amba_direction)
            READ:   amba_direction_to_string = "READ";
            WRITE:  amba_direction_to_string = "WRITE";
            default:`uvm_error("IVLCFG", "Invalid AMBA op_type")
        endcase
    endfunction : amba_direction_to_string
    
    function string amba_burst_type_to_string (amba_burst_type_e amba_burst_type);
        case (amba_burst_type)
            FIXED:  amba_burst_type_to_string = "FIXED";
            INCR:   amba_burst_type_to_string = "INCR";
            WRAP:   amba_burst_type_to_string = "WRAP";
            default:`uvm_error("IVLCFG", "Invalid AMBA burst_type")
        endcase
    endfunction : amba_burst_type_to_string

`endif
