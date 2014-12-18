/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_sequence_lib.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-11-09
 ********************************************************************/

`ifndef AHB_SEQUENCE_LIB_SVH
`define AHB_SEQUENCE_LIB_SVH

class ahb_sequence_base extends uvm_sequence #(ahb_xaction);
    protected ahb_xaction   req;
    
    protected int m_n_repeat = 0;
    protected int m_id;

    ahb_agent_config    cfg;
    uvm_event_pool      events;

    `uvm_object_utils_begin(ahb_sequence_base)
    `uvm_object_utils_end

    function new (string name = "ahb_sequence_base");
        super.new(name);
    endfunction : new

    function void set_id (int id);
        m_id    = id;
    endfunction : set_id

    function int get_id ();
        return m_id;
    endfunction : get_id

    virtual task pre_body ();
        if (!uvm_config_db #(ahb_agent_config)::get(null, get_full_name(), $sformatf("master_agent_config_%0d", m_id), cfg)) begin
            `uvm_fatal("CFGDB", "Cannot get ahb_agent_config.")
        end
        if (!uvm_config_db #(uvm_event_pool)::get(null, get_full_name(),  "uvm_event_pool", events)) begin
            `uvm_fatal("CFGDB", "Cannot get events.")
        end
    endtask : pre_body

    virtual task body();
        return;
    endtask : body

    virtual function bit check_address ();
        foreach (cfg.addr_db.id[i]) begin
            if ((req.first_address>=cfg.addr_db.low_addr[i]) && (req.first_address<=cfg.addr_db.high_addr[i])) begin
                return 1;
            end
        end

        return 0;
    endfunction : check_address

    virtual function void rand_address_timeout ();
        if (m_n_repeat >= 1000) begin
            `uvm_fatal("TIMEOUT", "Randomize ahb address timeout")
        end
    endfunction : rand_address_timeout
endclass : ahb_sequence_base

class ahb_write_sequence extends ahb_sequence_base;
    `uvm_object_utils(ahb_write_sequence)

    function new (string name = "ahb_write_sequence");
        super.new(name);
    endfunction : new

    virtual task body ();
        bit busy_end = 1'b0;
        super.body();

        repeat (cfg.n_xaction) begin
            ahb_addr_t  low_boundary;
            ahb_addr_t  high_boundary;

            cfg.addr_db.get_boundary(low_boundary, high_boundary);

            `uvm_create(req);
            while (!check_address()) begin
                if (!req.randomize() with { req.direction   == WRITE;
                                            req.size inside {SIZE8, SIZE16, SIZE32};
                                            req.first_address inside {[low_boundary:high_boundary]};}) begin
                    `uvm_fatal("RAND", "ahb_xaction randomize error.")
                end
                m_n_repeat ++;
                rand_address_timeout();
            end
            while (busy_end && req.transfers[0].burst == SINGLE) begin
                while (!check_address()) begin
                    if (!req.randomize() with { req.direction   == WRITE;
                                                req.size inside {SIZE8, SIZE16, SIZE32};
                                                req.first_address inside {[low_boundary:high_boundary]};}) begin
                        `uvm_fatal("RAND", "ahb_xaction randomize error.")
                    end
                    m_n_repeat ++;
                    rand_address_timeout();
                end
            end
            busy_end    = 1'b0;
            if (req.transfers[$].trans == BUSY) begin
                busy_end    = 1'b1;
            end
            `uvm_send(req);
        end
    endtask : body
endclass : ahb_write_sequence

class ahb_read_sequence extends ahb_sequence_base;
    `uvm_object_utils(ahb_read_sequence)

    function new (string name = "ahb_read_sequence");
        super.new(name);
    endfunction : new

    virtual task body ();
        super.body();

        repeat (cfg.n_xaction) begin
            ahb_addr_t  low_boundary;
            ahb_addr_t  high_boundary;

            cfg.addr_db.get_boundary(low_boundary, high_boundary);

            `uvm_create(req);
            while (!check_address()) begin
                if (!req.randomize() with { req.direction == READ;
                                            req.size inside {SIZE8, SIZE16, SIZE32};
                                            req.only_okay == 1;
                                            req.first_address inside {[low_boundary:high_boundary]};}) begin
                    `uvm_fatal("RAND", "ahb_xaction randomize error.")
                end
                m_n_repeat ++;
                rand_address_timeout();
            end
            `uvm_send(req);
        end
    endtask : body
endclass : ahb_read_sequence

`endif
