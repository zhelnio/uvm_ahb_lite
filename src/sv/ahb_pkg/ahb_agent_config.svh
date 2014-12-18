/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_agent_config.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-09
 ********************************************************************/

`ifndef AHB_AGENT_CONFIG_SVH
`define AHB_AGENT_CONFIG_SVH

class ahb_agent_config extends uvm_object;
    virtual ahb_master_if   ahb_master_port;
    virtual ahb_slave_if    ahb_slave_port;
    
    uvm_active_passive_enum active = UVM_ACTIVE;

    // Protocal & Timing
    bit has_busy        = 1'b1;
    bit has_slave_delay = 1'b0;
    bit has_slave_random_delay  = 1'b0;

    int slave_write_delay   = -1;
    int slave_read_delay    = -1;
    int slave_delay_min     = -1;
    int slave_delay_max     = -1;

    // Run-time control
    int n_xaction;

    ahb_addr_database addr_db;

    // Struct control
    bit analysis_enable = 1'b0;
    bit coverage_enable = 1'b0;

    `uvm_object_utils_begin(ahb_agent_config)
    `uvm_object_utils_end 

    function new (string name = "ahb_agent_config");
        super.new(name);

        addr_db = ahb_addr_database::type_id::create("addr_db");
    endfunction : new

endclass : ahb_agent_config

`endif
