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
        
`ifndef AHB_CASE_BASE_SVH
`define AHB_CASE_BASE_SVH
        
class ahb_case_base extends uvm_test;
    ahb_env             env;
        
    ahb_env_config      ahb_env_cfg;
    ahb_agent_config    ahb_agent_cfg;
        
    uvm_event_pool      events;
    `uvm_component_utils(ahb_case_base)
        
    extern         function      new                        (string name = "ahb_case_base", uvm_component parent = null);
    extern         function void build_phase                (uvm_phase phase);
    extern virtual function void end_of_elaboration_phase   (uvm_phase phase);
    extern         task          run_phase                  (uvm_phase phase);
        
    extern virtual function void config_ahb_agent           (ahb_agent_config       cfg);
    extern virtual function void config_ahb_env             (ahb_env_config         cfg);
endclass : ahb_case_base
        
function ahb_case_base::new (string name = "ahb_case_base", uvm_component parent = null);
    super.new(name, parent);
endfunction : new 
     
function void ahb_case_base::build_phase (uvm_phase phase);
    super.build_phase(phase);
     
    // Create and configure agent UVC
    ahb_env_cfg         = ahb_env_config::type_id::create("ahb_env_cfg", this);
    config_ahb_env(ahb_env_cfg);
     
    ahb_agent_cfg       = ahb_agent_config::type_id::create("ahb_agent_config", this); 
    config_ahb_agent(ahb_agent_cfg);
    ahb_env_cfg.master_config.push_back(ahb_agent_cfg);
     
    // Get virtual interface from test top
    if (!uvm_config_db #(virtual ahb_master_if)::get(this, "", "ahb_master_if", ahb_agent_cfg.ahb_master_port)) begin
       `uvm_fatal("NOVIF", "Cannot get interface ahb_master_if")
    end
     
    events = new("events");
     
    // Set agent UVC configuration
    uvm_config_db #(ahb_env_config)::set(this, "env", "ahb_env_config", ahb_env_cfg);
    uvm_config_db #(ahb_env_config)::set(this, "decoder", "ahb_env_config", ahb_env_cfg);
    uvm_config_db #(uvm_event_pool)::set(this, "*", "uvm_event_pool", events);
     
    // Create ahb environment
    env = ahb_env::type_id::create("env", this);
endfunction : build_phase
     
function void ahb_case_base::end_of_elaboration_phase (uvm_phase phase);
    super.end_of_elaboration_phase(phase);
     
    uvm_top.print_topology();
endfunction : end_of_elaboration_phase                                                                                                                                 
     
task ahb_case_base::run_phase (uvm_phase phase);
    ahb_write_sequence  write_sequence;
     
    write_sequence  = ahb_write_sequence::type_id::create("write_sequence");
     
    phase.raise_objection(this, "start simulation");
    `uvm_info("NORMAL", $sformatf("Case %0s running", get_type_name()), UVM_NONE);
    write_sequence.start(env.masters[0].sequencer);
    phase.drop_objection(this, "finish simulation");
endtask : run_phase
     
function void ahb_case_base::config_ahb_agent (ahb_agent_config cfg);
    cfg.active      = UVM_ACTIVE;
    cfg.has_busy    = 0;
    cfg.n_xaction   =10;
endfunction : config_ahb_agent
     
function void ahb_case_base::config_ahb_env (ahb_env_config cfg);
    cfg.n_masters       = 1;
    cfg.n_slaves        = 0;
    cfg.has_scoreboard  = 0;
    cfg.set_addr_info(0, 'h9000_0000, 'h9000_ffff);
endfunction : config_ahb_env
     
`endif 
