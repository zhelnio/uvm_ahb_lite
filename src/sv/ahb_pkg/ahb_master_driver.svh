/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_master_driver.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-19
 ********************************************************************/

`ifndef AHB_MASTER_DRIVER_SVH
`define AHB_MASTER_DRIVER_SVH

class ahb_master_driver extends uvm_driver #(ahb_xaction);
    virtual ahb_master_if   ahb_port;

    int                 m_drop;
    local int           m_xaction_cnt;

    uvm_analysis_port   #(ahb_xaction)  out_driver_ap;
    
    ahb_agent_config    cfg;
    uvm_event_pool      events;

    `uvm_component_utils_begin(ahb_master_driver)
    `uvm_component_utils_end

    extern                   function      new              (string name = "ahb_master_driver", uvm_component parent);
    extern           virtual function void build_phase      (uvm_phase phase);
    extern           virtual task          run_phase        (uvm_phase phase);
    extern protected virtual task          reset_signal     ();
    extern protected virtual task          get_and_drive    ();
    extern protected virtual task          drive_bus        ();
    extern protected virtual task          pre_drive_bus    ();
    extern protected virtual task          post_drive_bus   ();
    extern protected virtual task          drop_xaction     ();
endclass : ahb_master_driver

function ahb_master_driver::new (string name = "ahb_master_driver", uvm_component parent);
    super.new(name, parent);
endfunction : new

function void ahb_master_driver::build_phase (uvm_phase phase);
    super.build_phase(phase);
    
    out_driver_ap  = new("out_driver_ap", this);
    m_drop      = 0;
endfunction : build_phase

task ahb_master_driver::run_phase (uvm_phase phase);
    reset_signal();
    get_and_drive();
endtask : run_phase

task ahb_master_driver::reset_signal ();
    ahb_port.DUT.HADDR      <= `w_HADDR     'h0;
    ahb_port.DUT.HTRANS     <= `w_HTRANS    'h0;
    ahb_port.DUT.HBURST     <=              'h0;
    ahb_port.DUT.HWRITE     <= 1            'b0;
    ahb_port.DUT.HSIZE      <=              'h0;
    ahb_port.DUT.HSEL       <= `w_HSEL      'b1;
    ahb_port.DUT.HWDATA     <= `w_HWDATA    'h0;
    @ ahb_port.cb;
endtask : reset_signal

task ahb_master_driver::get_and_drive ();
    repeat(10) @ ahb_port.cb;
    forever begin
        seq_item_port.get_next_item(req);
        m_xaction_cnt ++;
        pre_drive_bus();
        drive_bus();
        post_drive_bus();
        seq_item_port.item_done();
    end
endtask : get_and_drive

task ahb_master_driver::pre_drive_bus ();
    return;
endtask : pre_drive_bus

task ahb_master_driver::post_drive_bus ();
    return;
endtask : post_drive_bus

task ahb_master_driver::drive_bus ();
    for (int i=0; i<req.transfers.size(); i++) begin
        ahb_response_e  response;

        ahb_port.DUT.HADDR  <= req.transfers[i].address;
        ahb_port.DUT.HWRITE <= req.direction;
        ahb_port.DUT.HSIZE  <= req.transfers[i].size;
        ahb_port.DUT.HBURST <= req.transfers[i].burst;
        ahb_port.DUT.HTRANS <= req.transfers[i].trans;
        
        // When write, at the first phase, data is not placed on HWDATA.
        if ((req.direction == WRITE) && (req.transfers[i].location != FIRST)) begin
            ahb_port.DUT.HWDATA         <= req.hwdata[i-1];
            ahb_port.upper_byte_lane    <= req.upper_byte_lane[i-1];
            ahb_port.lower_byte_lane    <= req.lower_byte_lane[i-1];
        end

        // Last phase, if no delay between this transfer and next new
        // transfer, command should be placed on AHB bus at once.
        if ((req.delay != 0) || (req.transfers[i].location != LAST)) begin
            @ ahb_port.cb;
        end
        while (ahb_port.DUT.HREADY !== 1'b1) begin
            @ ahb_port.cb;
        end

        // Response process
        response    = ahb_response_e'(ahb_port.DUT.HRESP);
        if (response == ERROR) begin
            break;
        end

        // Busy wait
        if (req.transfers[i].trans == BUSY) begin
            repeat (req.transfers[i].busy_delay) @ ahb_port.cb;
        end
    end
    ahb_port.DUT.HADDR      <= `w_HADDR 'h0;
    ahb_port.DUT.HTRANS     <= `w_HTRANS'h0;
    ahb_port.DUT.HBURST     <=          'h0;
    ahb_port.DUT.HWRITE     <= 1        'b0;
    ahb_port.DUT.HSIZE      <=          'h0;
//  ahb_port.DUT.HBUSREQ    <= 1        'b0;
    out_driver_ap.write(req);
    repeat (req.delay) @ ahb_port.cb;
endtask : drive_bus

task ahb_master_driver::drop_xaction ();
    m_drop ++;
endtask : drop_xaction

`endif
