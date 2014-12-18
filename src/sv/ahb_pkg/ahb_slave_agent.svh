/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_slave_agent.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-09
 ********************************************************************/

`ifndef AHB_SLAVE_AGENT_SVH
`define AHB_SLAVE_AGENT_SVH

class ahb_slave_agent extends uvm_agent;
    local int m_id;
    local bit m_call_set_id = 1'b0;

    ahb_slave_driver    driver;
    ahb_sequencer       sequencer;
    ahb_slave_monitor   monitor;

    uvm_event_pool      events;
    ahb_agent_config    cfg;

    uvm_analysis_port   #(ahb_xaction)  out_driver_ap;
    uvm_analysis_port   #(ahb_xaction)  out_monitor_ap;

    `uvm_component_utils_begin(ahb_slave_agent)
    `uvm_component_utils_end

    extern         function      new            (string name = "ahb_slave_agent", uvm_component parent);
    extern virtual function void build_phase    (uvm_phase phase);
    extern virtual function void connect_phase  (uvm_phase phase);
    extern virtual function void set_id         (int id);
    extern virtual function int  get_id         ();
    extern virtual function void set_config     ();
    extern virtual function void set_event      ();
endclass : ahb_slave_agent

function ahb_slave_agent::new (string name = "ahb_slave_agent", uvm_component parent);
    super.new(name, parent);
endfunction : new

function void ahb_slave_agent::build_phase (uvm_phase phase);
    super.build_phase(phase);

    if (!m_call_set_id) begin
        `uvm_warning("FUNCCALL", "Haven't call set_id() yet, will use default value 0 as id.")
    end
    if (!uvm_config_db #(ahb_agent_config)::get(this, "", $sformatf("slave_agent_config_%0d", m_id), cfg)) begin
        `uvm_fatal("CFGDB", "Cannot get ahb_agent_config.");
    end
    if (!uvm_config_db #(uvm_event_pool)::get(this, "", "uvm_event_pool", events)) begin
        `uvm_fatal("CFGDB", "Cannot get uvm events.");
    end
    monitor         = ahb_slave_monitor::type_id::create("monitor", this);
    if (cfg.active == UVM_ACTIVE) begin
        sequencer   = ahb_sequencer::type_id::create("sequencer", this);
        driver      = ahb_slave_driver::type_id::create("driver", this);
    end
endfunction : build_phase

function void ahb_slave_agent::connect_phase (uvm_phase phase);
    monitor.ahb_slave_port  = cfg.ahb_slave_port; 
    out_monitor_ap          = monitor.out_monitor_ap;

    if (cfg.active == UVM_ACTIVE) begin
        driver.seq_item_port.connect(sequencer.seq_item_export);
        driver.ahb_port    = cfg.ahb_slave_port;
        out_driver_ap      = driver.out_driver_ap;
    end
    set_config();
    set_event();
endfunction : connect_phase

function void ahb_slave_agent::set_id (int id);
    m_id    = id;

    m_call_set_id   = 1'b1;
endfunction : set_id

function int ahb_slave_agent::get_id ();
    return m_id;
endfunction : get_id

function void ahb_slave_agent::set_config ();
    driver.cfg  = cfg;
    monitor.cfg = cfg;
endfunction : set_config

function void ahb_slave_agent::set_event ();
    driver.events  = events;
    monitor.events = events;
endfunction : set_event

`endif
