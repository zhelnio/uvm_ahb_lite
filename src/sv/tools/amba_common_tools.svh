/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    amba_common_tools.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-12-18
 ********************************************************************/
 
`ifndef AMBA_COMMON_TOOLS_SVH
`define AMBA_COMMON_TOOLS_SVH

    class amba_common_tools; 
        static local amba_common_tools  m_inst;
    
        // Data member
        local amba_addr_t   m_start_addr;
        local uint          m_num_bytes;
        local uint          m_burst_len;
        local amba_addr_t   m_aligned_addr;
        local amba_addr_t   m_wrap_boundary;
        local uint          m_data_size;
        local uint          m_data_bus_bytes;
        local amba_addr_t   m_addrs[$];
        local int           m_lower_byte_lane[$];
        local int           m_upper_byte_lane[$];
    
        // Methord
        extern local  function                   new                ();
        extern static function amba_common_tools get_inst           (); 
        extern local  function void              set_start_addr     (amba_uvm_xaction tr);
        extern local  function void              set_num_bytes      (amba_uvm_xaction tr);
        extern local  function void              set_burst_len      (amba_uvm_xaction tr);
        extern local  function void              set_aligned_addr   ();
        extern local  function void              set_wrap_boundary  ();
        extern local  function void              set_data_size      ();
        extern local  function void              set_data_bus_bytes ();
        extern local  function void              set_addr           (amba_uvm_xaction tr);
        extern        function void              process_xaction    (amba_uvm_xaction tr);
        extern        function void              get_addr           (output amba_addr_t addrs[]);
        extern        function void              get_byte_lane      (output int upper_byte_lane[], 
                                                                            int lower_byte_lane[]);
        extern        function void              clean              ();
    endclass : amba_common_tools 
    
    function amba_common_tools::new ();
    endfunction : new
    
    function amba_common_tools amba_common_tools::get_inst ();
        if (m_inst == null) begin
            m_inst  = new();
        end
        return m_inst;
    endfunction : get_inst
    
    function void amba_common_tools::set_start_addr (amba_uvm_xaction tr);
        m_start_addr  = tr.first_address;
    endfunction : set_start_addr
    
    function void amba_common_tools::set_num_bytes (amba_uvm_xaction tr);
        case (tr.amba_size)
            AMBA_BYTE_1:    m_num_bytes   = 1;
            AMBA_BYTE_2:    m_num_bytes   = 2;
            AMBA_BYTE_4:    m_num_bytes   = 4;
            AMBA_BYTE_8:    m_num_bytes   = 8;
            AMBA_BYTE_16:   m_num_bytes   = 16;
            AMBA_BYTE_32:   m_num_bytes   = 32;
            AMBA_BYTE_64:   m_num_bytes   = 64;
            AMBA_BYTE_128:  m_num_bytes   = 128;
            default:    `uvm_error("CFG", "Invalid amba byte type.")
        endcase
    endfunction : set_num_bytes
    
    function void amba_common_tools::set_burst_len (amba_uvm_xaction tr);
        m_burst_len = tr.len + 1;
    endfunction : set_burst_len
    
    function void amba_common_tools::set_data_size ();
        m_data_size   = m_num_bytes * m_burst_len;
    endfunction : set_data_size
    
    function void amba_common_tools::set_aligned_addr ();
        m_aligned_addr    = (m_start_addr/m_num_bytes) * m_num_bytes;
    endfunction : set_aligned_addr
    
    function void amba_common_tools::set_wrap_boundary ();
        m_wrap_boundary   = (m_start_addr/m_data_size) * m_data_size;
    endfunction : set_wrap_boundary
    
    function void amba_common_tools::set_data_bus_bytes ();
        m_data_bus_bytes  = `AMBA_BUS_DATA_WIDTH / 8;
    endfunction : set_data_bus_bytes
    
    function void amba_common_tools::set_addr (amba_uvm_xaction tr);
        bit         aligned;
        amba_addr_t addr = m_start_addr;
        amba_addr_t lower_wrap_boundary;
        amba_addr_t upper_wrap_boundary;
        amba_addr_t lower_byte_lane;
        amba_addr_t upper_byte_lane; 
    
        aligned = (m_aligned_addr == m_start_addr);
    
        if (tr.get_type_name() == "ahb_xaction") begin
            if (!aligned) begin
                `uvm_fatal("CFG", "HADDR must be aligned.")
            end
        end
    
        if (tr.burst_type == WRAP) begin
            lower_wrap_boundary = addr/m_data_size * m_data_size;
            // addr must be aligned for a wrapping burst
            upper_wrap_boundary = lower_wrap_boundary + m_data_size;
//            $display("low:%0h, upper:%0h", lower_wrap_boundary, upper_wrap_boundary);
        end
    
        for (int n = 0; n < m_burst_len; n++) begin
            lower_byte_lane = addr - (addr / m_data_bus_bytes) * m_data_bus_bytes;
            if(aligned) begin
                upper_byte_lane = lower_byte_lane + m_num_bytes - 1;
            end
            else begin
                upper_byte_lane = m_aligned_addr + m_num_bytes - 1 - (addr/m_data_bus_bytes) * m_data_bus_bytes; 
            end
    
            m_addrs.push_back(addr);
            m_upper_byte_lane.push_back(upper_byte_lane);
            m_lower_byte_lane.push_back(lower_byte_lane);
            if (tr.burst_type != FIXED) begin
            // Increment address if necessary
                if (aligned) begin
                    addr += m_num_bytes;
                    if (tr.burst_type == WRAP) begin 
                        // WRAP mode is always aligned
                        if (addr >= upper_wrap_boundary) begin
                            addr = lower_wrap_boundary;
                        end
                    end
                end
                else begin
                    addr = m_aligned_addr + m_num_bytes;
                    aligned = 1; 
                    // All transfers after the first are aligned
                end
            end
            else begin
                addr    = m_start_addr;
            end
        end
    endfunction : set_addr
    
    function void amba_common_tools::process_xaction (amba_uvm_xaction tr);
        amba_uvm_xaction    t;

        clean();

        if (!$cast(t, tr)) begin
            `uvm_fatal("CAST", "amba_uvm_xaction cast failed.")
        end
        set_start_addr(t);
        set_num_bytes(t);
        set_burst_len(t);
        set_aligned_addr();
        set_wrap_boundary();
        set_data_size();
        set_data_bus_bytes();
        set_addr(t);
    endfunction : process_xaction

    function void amba_common_tools::get_addr (output amba_addr_t addrs[]);
        int size = m_addrs.size();

        addrs   = new[size];
        for(int i=0; i<size; i++) begin
            addrs[i]    = m_addrs.pop_front();
        end
    endfunction : get_addr

    function void amba_common_tools::get_byte_lane (output int upper_byte_lane[], 
                                                           int lower_byte_lane[]
                                                           );
        int size = m_upper_byte_lane.size();
        
        upper_byte_lane = new[size];
        lower_byte_lane = new[size];

        for(int i=0; i<size; i++) begin
            upper_byte_lane[i]  = m_upper_byte_lane.pop_front();
            lower_byte_lane[i]  = m_lower_byte_lane.pop_front();
        end
    endfunction : get_byte_lane
    
    function void amba_common_tools::clean ();
        m_start_addr    = 0;
        m_num_bytes     = 0;
        m_burst_len     = 0;
        m_aligned_addr  = 0;
        m_wrap_boundary = 0;
        m_data_size     = 0;
        m_data_bus_bytes= 0;
        m_addrs.delete();
        m_upper_byte_lane.delete();
        m_lower_byte_lane.delete();
    endfunction : clean
    
    const amba_common_tools   amba_tools    = amba_common_tools::get_inst();

`endif
