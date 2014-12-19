/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    amba_xaction.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-28
 ********************************************************************/
 
`ifndef COMMON_COMPONENT_SVH
`define COMMON_COMPONENT_SVH
 
virtual class common_monitor_base #(type T = int, type CONFIG = uvm_object) extends uvm_monitor;
 
    typedef common_monitor_base #(T, CONFIG) this_type;
    uvm_analysis_port #(T)  out_monitor_ap;
 
    CONFIG          cfg;
    uvm_event_pool  events;
 
    const static string type_name = "common_monitor_base #(T, CONFIG)";
 
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
                                                                                                                                                                       
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
 
        out_monitor_ap  = new("out_monitor_ap", this);
    endfunction : build_phase
 
    pure virtual protected function void send (T t); 
    pure virtual protected task          collect (); 
 
    virtual protected task event_process (); 
        return;
    endtask : event_process
 
    function string get_type_name (); 
        return type_name;
    endfunction : get_type_name
 
endclass : common_monitor_base
 
 
// Common comparator, <process_report> function should be implemented by
// children, or scoreboard will print nothing.
virtual class common_comparator_base #(type BEFORE=int, type AFTER=BEFORE, type CONFIG = uvm_object) extends uvm_component;
 
    typedef common_comparator_base #(BEFORE, AFTER, CONFIG) this_type;
 
    uvm_analysis_export #(BEFORE)               before_export;
    uvm_analysis_export #(AFTER)                after_export;
    protected uvm_tlm_analysis_fifo #(BEFORE)   m_before_fifo;
    protected uvm_tlm_analysis_fifo #(AFTER)    m_after_fifo;
     
    protected int unsigned  m_mismatches;
    protected int unsigned  m_matches;
    protected int unsigned  m_total;
    protected string        m_status;
    protected bit           m_print_summary = 1'b1; 
 
    CONFIG          cfg;
    uvm_event_pool  events;
 
    const static string type_name = "common_comparator_base #(BEFORE, AFTER, CONFIG)";
 
    function new (string name = "common_comparator_base", uvm_component parent);
        super.new(name, parent);
        before_export   = new("before_export", this);
        after_export    = new("after_export", this);
         
        m_before_fifo   = new("m_before_fifo", this);
        m_after_fifo    = new("m_after_fifo", this);
         
        m_matches       = 0;
        m_mismatches    = 0;
        m_total         = 0;
        m_status        = "PASS";
    endfunction : new
 
    function void connect_phase (uvm_phase phase);
        before_export.connect(m_before_fifo.analysis_export);
        after_export.connect(m_after_fifo.analysis_export);
    endfunction : connect_phase 
 
    function void report_phase (uvm_phase phase);
        if (m_print_summary) begin
            process_report();
        end
    endfunction : report_phase
 
    function void pre_abort ();
        if (m_print_summary) begin
            process_report();
        end
    endfunction : pre_abort
 
    virtual function string get_type_name ();
        return type_name;
    endfunction : get_type_name
 
    function void use_print_summary (bit print_summary);
        m_print_summary = print_summary;
    endfunction : use_print_summary
 
    pure virtual function void process_report ();
endclass : common_comparator_base
 
 
// Coverage wrapper based on transaction. The subclass's <sample> function
// should call 'super.sample()' methord.
virtual class common_coverage_base #(type T = uvm_object) extends uvm_object;
    typedef common_coverage_base #(T) this_type;
 
    T cov_xaction;
 
    const static string type_name = "common_coverage_base #(T)";
 
    function new (string name = "common_coverage_base");
        super.new(name);
    endfunction : new
 
    function string get_type_name ();
        return type_name;
    endfunction : get_type_name
 
    virtual function void sample (T t);
        T xaction;
        if (!$cast(xaction, t)) begin
            `uvm_fatal("CAST", $sformatf("Invalid type, transaction is not type '%0s'", t.get_type_name()))
        end
        cov_xaction = T::type_id::create("cov_xaction");
        cov_xaction.copy(xaction);
    endfunction : sample
 
endclass : common_coverage_base
 
 
 
// Coverage based on interface. 
virtual class common_if_coverage_base #(type IF = int, type T = uvm_object) extends uvm_component;
    typedef common_if_coverage_base #(T) this_type;
 
    IF  port;
    T   cov_xaction;
 
    const static string type_name = "common_if_coverage_base #(T)";
 
    function new (string name = "common_if_coverage_base", uvm_component parent);
        super.new(name, parent);
    endfunction : new
 
    function string get_type_name ();
        return type_name;
    endfunction : get_type_name
 
    pure virtual function void sample (T t);
 
endclass : common_if_coverage_base
 
 
 
virtual class common_collector_base #(type T = uvm_object, type COV = uvm_object) extends uvm_subscriber #(T);
    typedef common_collector_base #(T, COV) this_type;
 
    COV             coverage;
    uvm_event_pool  events;
 
    const static string type_name = "common_collector_base #(T, COV)";
 
    function new (string name = "common_collector_base", uvm_component parent);
        super.new(name, parent);
 
        coverage    = COV::type_id::create("coverage");
    endfunction : new
 
    function void write (T t);
        coverage.sample(t);
    endfunction : write
 
    function string get_type_name ();
        return type_name;
    endfunction : get_type_name
 
endclass : common_collector_base
`endif
