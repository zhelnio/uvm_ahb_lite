/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_analyzer.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-09
 ********************************************************************/

`ifndef AHB_ANALYZER_SVH
`define AHB_ANALYZER_SVH

class ahb_analyzer extends uvm_subscriber #(ahb_xaction);
    ahb_env_config  cfg;
    uvm_event_pool  events;

    local time  m_start;
    local time  m_end;
    local time  m_period;
    local bit   m_first;
    local bit   m_xaction_num;

    `uvm_component_utils(ahb_analyzer)

    extern               function      new              (string name = "ahb_analyzer", uvm_component parent);
    extern       virtual function void build_phase      (uvm_phase phase);
    extern       virtual task          run_phase        (uvm_phase phase);
    extern       virtual function void write            (ahb_xaction t);
    extern local         task          measure_period   ();
endclass : ahb_analyzer

function ahb_analyzer::new (string name = "ahb_analyzer", uvm_component parent);
    super.new(name, parent);
endfunction : new

function void ahb_analyzer::build_phase (uvm_phase phase);
    super.build_phase(phase);

    m_first = 1'b0;
endfunction : build_phase

task ahb_analyzer::run_phase (uvm_phase phase);
    measure_period();
endtask : run_phase

function void ahb_analyzer::write (ahb_xaction t);
    if (!m_first) begin
        m_first = 1'b1;
        m_start = $time();
    end
    m_xaction_num ++;
endfunction : write

task ahb_analyzer::measure_period ();
    time start_time;
    time end_time;

    uvm_event   e = events.get("AHB_CLK_RAISE");
    e.wait_on();
    e.reset();
    start_time  = $time();
    #1;
    e.wait_on();
    e.reset();
    end_time    = $time();
    m_period    = end_time - start_time;
endtask : measure_period

`endif
