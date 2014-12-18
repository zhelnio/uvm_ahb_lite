/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_comparator.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-09
 ********************************************************************/

`ifndef AHB_COMPARATOR_SVH
`define AHB_COMPARATOR_SVH

class ahb_comparator extends common_comparator_base #(ahb_xaction);
    `uvm_component_utils(ahb_comparator)

    extern function      new            (string name = "ahb_comparator", uvm_component parent);
    extern task          run_phase      (uvm_phase phase);
    extern function void process_report (); 
endclass : ahb_comparator

function ahb_comparator::new (string name = "ahb_comparator", uvm_component parent);
    super.new(name, parent);
endfunction : new

task ahb_comparator::run_phase (uvm_phase phase);
    ahb_xaction b;
    ahb_xaction a;

    string s;
    super.run_phase(phase);
    forever begin

        m_before_fifo.get(b);
        m_after_fifo.get(a);
    
        if(!b.compare(a)) begin
            $sformat(s, "%s differs from %s", b.convert2string(), a.convert2string());
            uvm_report_error("Comparator Mismatch", s); 
            m_mismatches++;
        end 
        else begin
            m_matches++;
        end 
    end 
endtask : run_phase

function void ahb_comparator::process_report ();
    m_total = m_matches + m_mismatches;

    if (m_mismatches != 0 || m_total == 0) begin
        m_status  = "FAILURE";
    end
    else begin
        m_status  = "PASS";
    end

    uvm_report_info("ahb VS ahb Comparator", $sformatf("Total transaction:  %0d", m_total));
    uvm_report_info("ahb VS ahb Comparator", $sformatf("Matches:            %0d", m_matches));
    uvm_report_info("ahb VS ahb Comparator", $sformatf("Mismatches:         %0d", m_mismatches));
endfunction : process_report

`endif
