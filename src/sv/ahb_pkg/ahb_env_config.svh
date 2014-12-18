/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_env_config.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-09
 ********************************************************************/

`ifndef AHB_ENV_CONFIG_SV
`define AHB_ENV_CONFIG_SV

class ahb_env_config extends uvm_object;
    ahb_agent_config    master_config[$];
    ahb_agent_config    slave_config[$];

    int n_masters       = 1;
    int n_slaves        = 1;

    bit has_scoreboard  = 1'b0;
    bit has_checker     = 1'b0;
    bit coverage_enable = 1'b0;
    bit analysis_enable = 1'b0;

    ahb_addr_database   addr_db;

    `uvm_object_utils_begin(ahb_env_config)
    `uvm_object_utils_end 

    function new (string name = "ahb_env_config");
        super.new(name);

        addr_db = ahb_addr_database::type_id::create("addr_db");
    endfunction : new

    function void set_addr_info (input    int id, 
                                          ahb_addr_t low_addr,
                                          ahb_addr_t high_addr
                                          );  
        addr_db.id.push_back(id);
        addr_db.low_addr.push_back(low_addr);
        addr_db.high_addr.push_back(high_addr);
        if (!addr_db.check_addr_range()) begin
            return;
        end 
    endfunction : set_addr_info

endclass : ahb_env_config

`endif
