/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_monitor.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-12-05
 ********************************************************************/

`ifndef AHB_MONITOR_SVH
`define AHB_MONITOR_SVH

// AHB base monitor, the monitor of master and slave is derived from this
// class. The class implements <run_phase> and <clk_event> task, the children
// should not overwrite the <run_phase> task. The <collect> and <send> task
// should be overwrite, and <event_process> can be overwrite.
virtual class ahb_monitor extends common_monitor_base #(ahb_xaction, ahb_agent_config);
    virtual ahb_master_if   ahb_master_port;
    virtual ahb_slave_if    ahb_slave_port;

    protected ahb_xaction   m_monitor_xaction;
    protected ahb_transfer  m_transfers[$];
    protected ahb_rdata_t   m_hrdata[$];
    protected ahb_wdata_t   m_hwdata[$];
    protected int           m_index;

    protected semaphore     m_sem;

    extern                   function      new          (string name = "ahb_monitor", uvm_component parent);
    extern           virtual function void build_phase  (uvm_phase phase);
    extern           virtual task          run_phase    (uvm_phase phase);
    extern local             task          clk_event    ();

    pure virtual protected   task          collect      ();
    pure virtual protected   function void send         (ahb_xaction t);
endclass : ahb_monitor

function ahb_monitor::new (string name = "ahb_monitor", uvm_component parent);
    super.new(name, parent);
endfunction : new

function void ahb_monitor::build_phase (uvm_phase phase);
    super.build_phase(phase);

    m_sem   = new(1);
endfunction : build_phase

task ahb_monitor::run_phase (uvm_phase phase);
    wait (ahb_master_port.MON.HRESET_N);
    fork
        clk_event();
        collect();
        collect();
        event_process();
    join
endtask : run_phase

task ahb_monitor::clk_event ();
    uvm_event   e = events.get("AHB_CLK_RAISE");
    @ (ahb_master_port.cb);
    e.trigger();
    @ (ahb_master_port.cb);
    e.trigger();
endtask : clk_event



class ahb_master_monitor extends ahb_monitor;
    `uvm_component_utils(ahb_master_monitor)

    extern                   function      new              (string name = "ahb_master_monitor", uvm_component parent);
    extern protected virtual task          collect          ();
    extern protected virtual function void send             (ahb_xaction t);
    extern protected virtual task          event_process    ();
    extern protected virtual task          detect_burst_end ();
    extern protected virtual function void keep_one_busy    (ref ahb_xaction t);
endclass : ahb_master_monitor

function ahb_master_monitor::new (string name = "ahb_master_monitor", uvm_component parent);
    super.new(name, parent);
endfunction : new

task ahb_master_monitor::collect ();
    m_monitor_xaction = ahb_xaction::type_id::create("m_monitor_xaction");
    forever begin
        ahb_transfer    transfer = new("ahb_transfer");
        // commond phase
        while (ahb_master_port.MON.HRESET_N !== 1'b1 || ahb_master_port.MON.HREADY !== 1'b1) begin
            @ ahb_master_port.cb;
        end
        m_sem.get();
        transfer.address    = ahb_addr_t'(ahb_master_port.MON.HADDR);
        transfer.direction  = ahb_direction_e'(ahb_master_port.MON.HWRITE);
        transfer.size       = ahb_size_e'(ahb_master_port.MON.HSIZE);
        transfer.trans      = ahb_trans_e'(ahb_master_port.MON.HTRANS);
        transfer.burst      = ahb_burst_e'(ahb_master_port.MON.HBURST);

        m_monitor_xaction.direction  = ahb_direction_e'(ahb_master_port.MON.HWRITE);
        m_monitor_xaction.size       = ahb_size_e'(ahb_master_port.MON.HSIZE);
        m_monitor_xaction.burst      = ahb_burst_e'(ahb_master_port.MON.HBURST);
        
        m_monitor_xaction.transfers.push_back(transfer);
        @ ahb_master_port.cb;
        m_sem.put();

        // data phase
        while (ahb_master_port.MON.HRESET_N !== 1'b1 || ahb_master_port.MON.HREADY !== 1'b1) begin
            @ ahb_master_port.cb;
        end
        m_monitor_xaction.hwdata.push_back(ahb_wdata_t'(ahb_master_port.MON.HWDATA));
        m_monitor_xaction.hrdata.push_back(ahb_rdata_t'(ahb_master_port.MON.HRDATA));
        @ ahb_master_port.cb;
    end
endtask : collect

function void ahb_master_monitor::send (ahb_xaction t);
    t.copy(m_monitor_xaction);
    keep_one_busy(t);
    t.set_location();
    t.direction = t.transfers[0].direction;
    t.size      = t.transfers[0].size;
    t.burst     = t.transfers[0].burst;
    out_monitor_ap.write(t);
    m_monitor_xaction = ahb_xaction::type_id::create("m_monitor_xaction");
endfunction : send

task ahb_master_monitor::event_process ();
    detect_burst_end();
endtask : event_process

task ahb_master_monitor::detect_burst_end ();
    bit init = 1;
    bit burst_start = 1'b0;
    bit burst_end   = 1'b0;
    bit first_tr    = 1'b1;

    forever begin
        ahb_trans_e     trans;

        while (ahb_master_port.MON.HRESET_N !== 1'b1 || ahb_master_port.MON.HREADY !== 1'b1) begin
            @ ahb_master_port.cb;
        end
        trans   = ahb_trans_e'(ahb_master_port.MON.HTRANS);
        // When the first burst start, the monitor transaction should not be send at this moment.
        if (trans == NONSEQ && !init) begin
            // IDLE -> NONSEQ
            if (burst_start == 1'b0) begin
                init = 0;

                burst_start = 1'b1;
                burst_end   = 1'b0;
            end
            // SEQ -> NONSEQ
            else begin
                ahb_xaction monitor_xaction = ahb_xaction::type_id::create("monitor_xaction");
                burst_end   = 1'b1;

                // When outstanding transfer, the data phase has not been
                // execute yet, so data and response should be pushed into
                // m_monitor_xaction.
                if (!first_tr) begin
                    void'(m_monitor_xaction.hwdata.pop_front());
                    void'(m_monitor_xaction.hrdata.pop_front());
                end
                #0 send(monitor_xaction);
                first_tr    = 1'b0;
            end
        end
        // SEQ -> IDLE
        if (burst_start == 1'b1 && trans == IDLE) begin
            ahb_xaction monitor_xaction = ahb_xaction::type_id::create("monitor_xaction");
            
            burst_start = 1'b0;
            burst_end   = 1'b1;
            if (!first_tr) begin
                void'(m_monitor_xaction.hwdata.pop_front());
                void'(m_monitor_xaction.hrdata.pop_front());
            end
            #0 send(monitor_xaction);
            first_tr    = 1'b0;
        end
        if (trans == NONSEQ && init) begin
            init        = 1'b0;
            burst_start = 1'b1;
        end
        @ ahb_master_port.cb;
    end
endtask : detect_burst_end

function void ahb_master_monitor::keep_one_busy (ref ahb_xaction t);
    int idx_queue[$];

    for (int i=1; i<t.transfers.size(); i++) begin
        if (t.transfers[i].trans == BUSY && t.transfers[i-1].trans == BUSY) begin
            idx_queue.push_back(i);
        end
    end

    foreach (idx_queue[i]) begin
        t.transfers.delete(idx_queue[i]-i);
        t.hwdata.delete(idx_queue[i]-i);
        t.hrdata.delete(idx_queue[i]-i);
    end
endfunction : keep_one_busy



class ahb_slave_monitor extends ahb_master_monitor;
    `uvm_component_utils(ahb_slave_monitor)

    extern                   function new     (string name = "ahb_slave_monitor", uvm_component parent);
    extern protected virtual task     collect ();
endclass : ahb_slave_monitor

function ahb_slave_monitor::new (string name = "ahb_slave_monitor", uvm_component parent); 
    super.new(name, parent);
endfunction : new

task ahb_slave_monitor::collect ();
    m_monitor_xaction = ahb_xaction::type_id::create("m_monitor_xaction");

    forever begin
        ahb_transfer    transfer = new("ahb_transfer");
        // commond phase
        while (ahb_slave_port.MON.HRESET_N !== 1'b1 || ahb_slave_port.MON.HSEL !== 1'b1 || ahb_slave_port.MON.HREADY_O !== 1'b1) begin
            @ ahb_slave_port.cb;
        end
        m_sem.get();
        transfer.address    = ahb_addr_t'(ahb_slave_port.MON.HADDR);
        transfer.direction  = ahb_direction_e'(ahb_slave_port.MON.HWRITE);
        transfer.size       = ahb_size_e'(ahb_slave_port.MON.HSIZE);
        transfer.trans      = ahb_trans_e'(ahb_slave_port.MON.HTRANS);
        transfer.burst      = ahb_burst_e'(ahb_slave_port.MON.HBURST);
        
        m_monitor_xaction.transfers.push_back(transfer);
        @ ahb_slave_port.cb;
        m_sem.put();

        // data phase
        while (ahb_slave_port.MON.HRESET_N !== 1'b1 || ahb_slave_port.MON.HSEL !== 1'b1 || ahb_slave_port.MON.HREADY_O !== 1'b1) begin
            @ ahb_slave_port.cb;
        end
        m_monitor_xaction.hwdata.push_back(ahb_wdata_t'(ahb_slave_port.MON.HWDATA));
        m_monitor_xaction.hrdata.push_back(ahb_rdata_t'(ahb_slave_port.MON.HRDATA));
        @ ahb_slave_port.cb;
    end
endtask : collect

`endif
