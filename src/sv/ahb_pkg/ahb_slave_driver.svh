/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_slave_driver.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-12-07
 ********************************************************************/

`ifndef AHB_SLAVE_DRIVER_SVH
`define AHB_SLAVE_DRIVER_SVH

class ahb_slave_driver extends uvm_driver #(ahb_xaction);
    virtual ahb_slave_if   ahb_port;

    protected ahb_wdata_t   m_mem[ahb_addr_t];
    protected ahb_addr_t    m_low_boundary;
    protected ahb_addr_t    m_high_boundary;

    protected int   m_id;
    int             m_drop;
    protected int   m_xaction_cnt;

    protected semaphore     m_sem;

    uvm_analysis_port   #(ahb_xaction)  out_driver_ap;
    
    ahb_agent_config    cfg;
    uvm_event_pool      events;

    `uvm_component_utils_begin(ahb_slave_driver)
    `uvm_component_utils_end

    extern                   function      new              (string name = "ahb_slave_driver", uvm_component parent);
    extern           virtual function void build_phase      (uvm_phase phase);
    extern           virtual task          run_phase        (uvm_phase phase);
    extern           virtual function void set_id           (int id);
    extern           virtual function int  get_id           ();
    extern protected virtual task          reset_signal     ();
    extern protected virtual function void init_mem         ();
    extern protected virtual task          get_and_drive    ();
    extern protected virtual task          drive_bus        ();
    extern protected virtual task          pre_drive_bus    ();
    extern protected virtual task          post_drive_bus   ();
    extern protected virtual function int  set_delay        (ahb_direction_e direction);
    extern protected virtual task          drop_xaction     ();
endclass : ahb_slave_driver

function ahb_slave_driver::new(string name = "ahb_slave_driver", uvm_component parent);
    super.new(name, parent);
endfunction : new

function void ahb_slave_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    out_driver_ap  = new("out_driver_ap", this);
    m_drop  = 0;
    m_sem   = new(1);
    if (!uvm_config_db #(ahb_agent_config)::get(this, "", "ahb_agent_config", cfg)) begin
        `uvm_fatal("CONFIG", "Cannot get ahb_agent_config.");
    end
endfunction : build_phase

task ahb_slave_driver::run_phase(uvm_phase phase);
    init_mem();
    reset_signal();
    get_and_drive();
endtask : run_phase

function void ahb_slave_driver::set_id (int id);
    m_id = id;
endfunction : set_id

function int ahb_slave_driver::get_id ();
    return m_id;
endfunction : get_id

task ahb_slave_driver::reset_signal();
    ahb_port.DUT.HRESP      <= OKAY;
    ahb_port.DUT.HREADY_O   <= 1'b0;
    ahb_port.DUT.HRDATA     <= `w_HRDATA'h0;
    repeat(10) @ ahb_port.cb;
endtask : reset_signal

function void ahb_slave_driver::init_mem ();
    bit[`w_HWDATA-1:0]  init_value = `w_HWDATA'h0;

    m_low_boundary  = cfg.addr_db.low_addr[m_id];
    m_high_boundary = cfg.addr_db.high_addr[m_id];

    for (int addr=m_low_boundary; addr<=m_high_boundary; addr++) begin
        m_mem[addr]   = ~init_value;
    end
endfunction : init_mem

task ahb_slave_driver::get_and_drive();
    repeat(10) @ ahb_port.cb;
    forever begin
        fork
            begin
                pre_drive_bus();
                drive_bus();
                post_drive_bus();
            end
            begin
                pre_drive_bus();
                drive_bus();
                post_drive_bus();
            end
        join
    end
endtask : get_and_drive

task ahb_slave_driver::drive_bus ();
    // TODO...
endtask : drive_bus

task ahb_slave_driver::pre_drive_bus ();
    return;
endtask : pre_drive_bus

task ahb_slave_driver::post_drive_bus ();
    return;
endtask : post_drive_bus

function int ahb_slave_driver::set_delay (ahb_direction_e direction);
    int delay;

    if (cfg.has_slave_delay) begin
        if (cfg.has_slave_random_delay) begin
            if (cfg.slave_delay_min != -1 && cfg.slave_delay_max != -1) begin
                delay   = $urandom() % cfg.slave_delay_max;
                while (delay >= cfg.slave_delay_max) begin
                    delay   += cfg.slave_delay_min;
                end
            end
            else begin
                delay   = $urandom;
            end
        end
        else begin
            if (direction == WRITE) begin
                delay   = cfg.slave_write_delay;
            end
            else begin
                delay   = cfg.slave_read_delay;
            end
        end
    end
    else begin
        delay   = 0;
    end

    return delay;
endfunction : set_delay

task ahb_slave_driver::drop_xaction ();
    m_drop ++;
endtask : drop_xaction

`endif
