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

`endif
