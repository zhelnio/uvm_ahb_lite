/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_type.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-10-29
 ********************************************************************/

`ifndef AHB_TYPE_SVH
`define AHB_TYPE_SVH

typedef class ahb_xaction;
typedef uvm_sequencer #(ahb_xaction)    ahb_sequencer;

typedef bit [`w_HADDR-1:0]  ahb_addr_t;
typedef bit [`w_HWDATA-1:0] ahb_wdata_t;
typedef bit [`w_HRDATA-1:0] ahb_rdata_t;    

typedef enum {
    READ,
    WRITE
    }   ahb_direction_e;

typedef enum {
    SIZE8,
    SIZE16,
    SIZE32,
    SIZE64,
    SIZE128,
    SIZE256,
    SIZE512,
    SIZE1024
    }   ahb_size_e;

typedef enum {
    SINGLE,
    INCR,
    WRAP4,
    INCR4,
    WRAP8,
    INCR8,
    WRAP16,
    INCR16
    }   ahb_burst_e;

typedef enum {
    IDLE,
    BUSY,
    NONSEQ,
    SEQ
    }   ahb_trans_e;

typedef enum {
    OKAY = 0, 
    ERROR = 1, 
    RETRY = 2, 
    SPLIT = 3 
    }   ahb_response_e;

typedef enum {
    FIRST,
    MIDDLE,
    LAST
    }   ahb_location_e;

typedef enum {
    MASTER,
    SLAVE,
    ARBITER,
    DECODER
    }   ahb_agent_type_e;

function string ahb_direction_to_string (ahb_direction_e ahb_direction);
    string s;
    case (ahb_direction)
        READ:   s = "READ";
        WRITE:  s = "WRITE";
        default:  $display("Invalid ahb_direction type");
    endcase

    return s;
endfunction : ahb_direction_to_string

function string ahb_size_to_string (ahb_size_e ahb_size);
    string s;

    case (ahb_size)
        SIZE8:      s = "SIZE8";
        SIZE16:     s = "SIZE16";
        SIZE32:     s = "SIZE32"; 
        SIZE64:     s = "SIZE64";
        SIZE128:    s = "SIZE128";
        SIZE256:    s = "SIZE256";
        SIZE512:    s = "SIZE512";
        SIZE1024:   s = "SIZE1024"; 
        default:    $display("Invalid ahb_size type");
    endcase

    return s;
endfunction : ahb_size_to_string

function string ahb_burst_to_string (ahb_burst_e ahb_burst);
    string s;
    case (ahb_burst)
        SINGLE: s = "SINGLE";     
        INCR:   s = "INCR";   
        WRAP4:  s = "WRAP4";
        INCR4:  s = "INCR4";
        WRAP8:  s = "WRAP8";
        INCR8:  s = "INCR8";
        WRAP16: s = "WRAP16";
        INCR16: s = "INCR16";
        default:  $display("Invalid ahb_burst type");
    endcase
    return s;
endfunction : ahb_burst_to_string

function string ahb_trans_to_string (ahb_trans_e ahb_trans);
    string s;

    case (ahb_trans)
        IDLE:   s = "IDLE";
        BUSY:   s = "BUSY";
        NONSEQ: s = "NONSEQ";
        SEQ:    s = "SEQ";
        default:  $display("Invalid ahb_trans type");
    endcase

    return s;
endfunction : ahb_trans_to_string

function string ahb_response_to_string (ahb_response_e ahb_response);
    string s;

    case (ahb_response)
        OKAY:   s = "OKAY";
        ERROR:  s = "ERROR";
        RETRY:  s = "RETRY";
        SPLIT:  s = "SPLIT";
        default:  $display("Invalid ahb_response type");
    endcase

    return s;
endfunction : ahb_response_to_string

function string ahb_location_to_string (ahb_location_e ahb_location);
    string s;

    case (ahb_location)
        FIRST:      s = "FIRST";
        MIDDLE:     s = "MIDDLE";
        LAST:       s = "LAST";
        default:  $display("Invalid ahb_location type");
    endcase

    return s;
endfunction : ahb_location_to_string
    
function string ahb_agent_type_to_string (ahb_agent_type_e ahb_agent_type);
    string s;

    case (ahb_agent_type)
        MASTER: s = "MASTER";
        SLAVE:  s = "SLAVE";
        ARBITER:s = "ARBITER";
        DECODER:s = "DECODER";
        default:  $display("Invalid ahb_agent type");
    endcase

    return s;
endfunction : ahb_agent_type_to_string

`endif
