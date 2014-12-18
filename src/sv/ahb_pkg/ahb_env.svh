/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_env.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-09
 ********************************************************************/

`ifndef AHB_ENV_SVH
`define AHB_ENV_SVH

class ahb_env extends uvm_env;
    ahb_master_agent    masters[];
    ahb_slave_agent     slaves[];
    ahb_comparator      master_scoreboard[];
    ahb_comparator      slave_scoreboard[];

    ahb_env_config      cfg;
    uvm_event_pool      events;

    uvm_analysis_export #(ahb_xaction) master_before_export[]; 
    uvm_analysis_export #(ahb_xaction) slave_before_export[]; 
    uvm_analysis_port   #(ahb_xaction) master_out_monitor_ap[];
    uvm_analysis_port   #(ahb_xaction) slave_out_monitor_ap[];

    `uvm_component_utils(ahb_env)

    extern         function      new            (string name, uvm_component parent);
    extern         function void build_phase    (uvm_phase phase);
    extern         function void connect_phase  (uvm_phase phase);
    extern         task          run_phase      (uvm_phase phase);
endclass : ahb_env

function ahb_env::new (string name, uvm_component parent);
    super.new(name, parent);
endfunction : new

function void ahb_env::build_phase (uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(ahb_env_config)::get(this, "", "ahb_env_config", cfg)) begin
        `uvm_fatal("CONFIG", "Cannot get ahb_env_config.");
    end

    masters = new[cfg.n_masters];
    foreach (masters[i]) begin
        masters[i]  = ahb_master_agent::type_id::create($sformatf("masters_%0d", i), this);
        masters[i].set_id(i);
    end
    slaves  = new[cfg.n_slaves];
    foreach (slaves[i]) begin
        slaves[i]   = ahb_slave_agent::type_id::create($sformatf("slaves_%0d", i), this);
        slaves[i].set_id(i);
    end
    if (cfg.has_scoreboard) begin
        master_scoreboard       = new[cfg.n_masters];
        master_before_export    = new[cfg.n_masters];
        foreach (masters[i]) begin
            master_scoreboard[i]= ahb_comparator::type_id::create($sformatf("master_scoreboard_%0d", i), this);
        end
        slave_scoreboard        = new[cfg.n_slaves];
        slave_before_export     = new[cfg.n_slaves];
        foreach (slaves[i]) begin
            slave_scoreboard[i] = ahb_comparator::type_id::create($sformatf("slave_scoreboard_%0d", i), this);
        end
    end

    foreach (masters[i]) begin
        master_out_monitor_ap   = new[cfg.n_masters];
        cfg.master_config[i].addr_db= cfg.addr_db;
        uvm_config_db #(ahb_agent_config)::set(this, "*", $sformatf("master_agent_config_%0d", i), cfg.master_config[i]);
    end
    foreach (slaves[i]) begin
        slave_out_monitor_ap    = new[cfg.n_slaves];
        cfg.slave_config[i].addr_db = cfg.addr_db;
        uvm_config_db #(ahb_agent_config)::set(this, "*", $sformatf("slave_agent_config_%0d", i), cfg.slave_config[i]);
    end
endfunction : build_phase

function void ahb_env::connect_phase (uvm_phase phase);
    foreach (masters[i]) begin
        master_out_monitor_ap[i]    = masters[i].out_monitor_ap;
        if (cfg.has_scoreboard) begin
            master_before_export[i] = master_scoreboard[i].before_export;
        end
    end
    foreach (slaves[i]) begin
        slave_out_monitor_ap[i]     = slaves[i].out_monitor_ap;
        if (cfg.has_scoreboard) begin
            slave_before_export[i]  = slave_scoreboard[i].before_export;
        end
    end
endfunction : connect_phase
    
task ahb_env::run_phase (uvm_phase phase);
    ahb_sequence_base  seq[];

    if (get_parent() == null) begin
        seq = new[cfg.n_masters];
        foreach (seq[i]) begin
            seq[i] = ahb_sequence_base::type_id::create($sformatf("seq[%0d]", i), this);
        end
        phase.raise_objection(this, "start simulation");
        foreach (seq[i]) begin
            // DO NOT use 'i' directly, owing to each thread will share the same
            // variable 'i'.
            int j = i;
            fork
                seq[j].start(masters[j].sequencer);
                seq[j].set_id(j);
            join_none
        end
        // Avoid phase drop at once. Maybe replaced later.
        wait fork;
        phase.drop_objection(this, "finish simulation");
    end
endtask : run_phase

`endif
