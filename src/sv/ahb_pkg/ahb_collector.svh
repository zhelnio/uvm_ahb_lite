/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_collector.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-10-29
 ********************************************************************/

`ifndef AHB_COLLECTOR_SVH
`define AHB_COLLECTOR_SVH

class ahb_transfer_coverage extends common_coverage_base #(ahb_transfer);
    `uvm_object_utils(ahb_transfer_coverage)

    covergroup cg_ahb_transfer;
        option.per_instance = 1;

        trans:      coverpoint cov_xaction.trans;
        response:   coverpoint cov_xaction.response;
    endgroup : cg_ahb_transfer

    function new (string name = "ahb_transfer_coverage");
        super.new(name);

        cg_ahb_transfer = new();
    endfunction : new

    function void sample (ahb_transfer t);
        super.sample(t);

        cg_ahb_transfer.sample();
    endfunction : sample
endclass : ahb_transfer_coverage



class ahb_transaction_coverage extends common_coverage_base #(ahb_xaction);
    ahb_transfer_coverage   coverage;
    `uvm_object_utils(ahb_transaction_coverage)

    covergroup cg_ahb_xaction;
        option.per_instance = 1;

        direction:  coverpoint cov_xaction.direction;
        size:       coverpoint cov_xaction.size;
        burst:      coverpoint cov_xaction.burst;
        
        direction_x_size_x_burst: cross direction, size, burst;
    endgroup : cg_ahb_xaction

    function new (string name = "ahb_transaction_coverage");
        super.new(name);

        coverage    = ahb_transfer_coverage::type_id::create("coverage");
        cg_ahb_xaction  = new();
    endfunction : new

    function void sample (ahb_xaction t);
        super.sample(t);

        foreach (cov_xaction.transfers[i]) begin
            coverage.sample(cov_xaction.transfers[i]);
        end
        cg_ahb_xaction.sample();
    endfunction : sample
endclass : ahb_transaction_coverage



class ahb_master_collector extends common_collector_base #(ahb_xaction, ahb_transaction_coverage);
    `uvm_component_utils(ahb_master_collector)

    extern         function      new   (string name = "ahb_master_collector", uvm_component parent);
    extern virtual function void write (ahb_xaction t);
endclass : ahb_master_collector

function ahb_master_collector::new (string name = "ahb_master_collector", uvm_component parent);
    super.new(name, parent);
endfunction : new

function void ahb_master_collector::write (ahb_xaction t);
    coverage.sample(t);
endfunction : write

`endif
