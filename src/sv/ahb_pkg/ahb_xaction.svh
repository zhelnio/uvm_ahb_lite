/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_xaction.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-10-29
 ********************************************************************/

`ifndef AHB_XACTION_SVH
`define AHB_XACTION_SVH

// The ahb_addr_database is used to determine the possible range of
// first_address. Each slave should have a address range with it's id. All of
// slaves's address infomation is stored in an ahb_addr_database object which
// often included in a configure object.
 
class ahb_addr_database extends uvm_object;
    int         id[$];
    ahb_addr_t  low_addr[$];
    ahb_addr_t  high_addr[$];

    `uvm_object_utils(ahb_addr_database)

    function new (string name = "ahb_addr_database");
        super.new(name);
    endfunction : new

    function void get_boundary (output ahb_addr_t low_boundary, 
                                       ahb_addr_t high_boundary
                                       );
        ahb_addr_t  low[$];
        ahb_addr_t  high[$];

        low     = low_addr.min;
        high    = high_addr.max;

        low_boundary    = low[0];
        high_boundary   = high[0];
    endfunction : get_boundary

    function bit check_addr_range ();
        ahb_addr_t  addr_ass[int];

        foreach (low_addr[i]) begin
            addr_ass[2*i]   = low_addr[i];
            addr_ass[2*i+1] = high_addr[i];
        end

        begin
            ahb_addr_t q0[$];
            ahb_addr_t q1[$];

            q0 = addr_ass.unique();
            if (q0.size() != low_addr.size() + high_addr.size()) begin
                `uvm_error("IPARA", "There is(are) low address equal high address")
                return 0;
            end
            q1 = q0;
            q0.sort();
            if (q0 != q1) begin
                `uvm_error("IPARA", "This address range is overlaping")
                return 0;
            end
        end

        return 1;
    endfunction : check_addr_range
endclass : ahb_addr_database


// AHB transfer for each burst, include 'address', 'size', 'burst', 'trans',
// 'direction', 'response' and 'location' information.

class ahb_transfer extends uvm_sequence_item;
    rand ahb_addr_t         address;
    rand ahb_size_e         size;
    rand ahb_burst_e        burst;
    rand ahb_trans_e        trans;
    rand ahb_direction_e    direction;
         ahb_location_e     location;
    rand ahb_response_e     response;

    rand int unsigned       busy_delay;
         bit                data_valid;
         bit                has_header = 1'b1;

         ahb_agent_type_e agent_type;

    constraint c_busy_delay {
        busy_delay inside {[1:5]};
    }

    `uvm_object_utils(ahb_transfer)

    function new (string name = "ahb_transfer");
        super.new(name);
    endfunction : new

    virtual function void set_header (bit has_header);
        this.has_header = has_header;
    endfunction : set_header

    virtual function void do_copy (uvm_object rhs);
        ahb_transfer rhs_;

        if(!$cast(rhs_, rhs)) begin
            uvm_report_error("do_copy:", "Cast failed");
            return;
        end
        super.do_copy(rhs); // Chain the copy with parent classes

        address     = rhs_.address;
        size        = rhs_.size;
        burst       = rhs_.burst;
        trans       = rhs_.trans;
        direction   = rhs_.direction;
        location    = rhs_.location;
        response    = rhs_.response;

        busy_delay  = rhs_.busy_delay;
        data_valid  = rhs_.data_valid;
        has_header  = rhs_.has_header;
        agent_type  = rhs_.agent_type;
    endfunction : do_copy

    virtual function bit do_compare (uvm_object rhs, uvm_comparer comparer);
        ahb_transfer rhs_;

        do_compare = super.do_compare(rhs, comparer);
        if (!$cast(rhs_, rhs)) begin
            uvm_report_error("CAST", "cast failed, check type compatability");
            return 0;
        end

        do_compare  &= (address     == rhs_.address);
        do_compare  &= (size        == rhs_.size);
        do_compare  &= (burst       == rhs_.burst);
        do_compare  &= (trans       == rhs_.trans);
        do_compare  &= (direction   == rhs_.direction);
        do_compare  &= (response    == rhs_.response);
    endfunction : do_compare

    function void do_print (uvm_printer printer);
        if(printer.knobs.sprint == 0) begin
            $display(convert2string());
        end
        else begin
            printer.m_string = convert2string();
        end 
    endfunction: do_print

    virtual function string convert2string ();
        if (has_header) begin
            $sformat(convert2string, "\n-------------------------------------------------------");
            $sformat(convert2string, "%s\n(Type:%s) %s", convert2string, get_type_name(), get_name());
            $sformat(convert2string, "%s\n @ %0t", convert2string, $time());
            $sformat(convert2string, "%s\n-------------------------------------------------------", convert2string);
        end
        $sformat(convert2string, "%s\n HWRITE\t\t%s\n", convert2string, ahb_direction_to_string(direction));
        $sformat(convert2string, "%s HADDR\t\t'%hh\n", convert2string, address);
        $sformat(convert2string, "%s HSIZE\t\t%s\n", convert2string, ahb_size_to_string(size));
        $sformat(convert2string, "%s HBURST\t\t%s\n", convert2string, ahb_burst_to_string(burst));
        $sformat(convert2string, "%s HTRANS\t\t%s\n", convert2string, ahb_trans_to_string(trans));
        $sformat(convert2string, "%s HRESP\t\t%s\n", convert2string, ahb_response_to_string(response));
        $sformat(convert2string, "%s location\t%s\n", convert2string, ahb_location_to_string(location));
        $sformat(convert2string, "%s-------------------------------------------------------", convert2string);
    endfunction : convert2string
endclass : ahb_transfer


// The base ahb transaction, include all of information of a burst on ahb. Any
// other ahb transaction should be derived from this class.

class ahb_xaction extends amba_uvm_xaction;
// data member 
    rand ahb_wdata_t        hwdata[$];
         ahb_rdata_t        hrdata[$];
    rand ahb_transfer       transfers[$];
    rand ahb_direction_e    direction;
    rand ahb_size_e         size;
    rand ahb_burst_e        burst;
         int                upper_byte_lane[];
         int                lower_byte_lane[];

// parameter
         bit                only_okay  = 1'b1;
    rand int unsigned       delay;
    rand int unsigned       busy_num;
    // Early burst termination continue
         bit                ebt_continue    = 1'b0;
         bit                use_busy_end    = 1'b0;
         ahb_agent_type_e   agent_type;
         string             name;

    `uvm_object_utils(ahb_xaction)

    // The protocol does not permit a master to end a burst with a BUSY
    // transfer for fixed length bursts of type
    constraint c_delay {
        delay <= 10;
    }

    constraint c_busy_num {
        busy_num <= len;
        (len == 1-1)    -> (busy_num == 0);
    }
    
    constraint c_burst {
        (len == 1-1)    -> (burst inside {ahb_pkg::SINGLE, ahb_pkg::INCR});
        (len == 4-1)    -> (burst inside {ahb_pkg::INCR, ahb_pkg::INCR4, ahb_pkg::WRAP4});
        (len == 8-1)    -> (burst inside {ahb_pkg::INCR, ahb_pkg::INCR8, ahb_pkg::WRAP8});
        (len == 16-1)   -> (burst inside {ahb_pkg::INCR, ahb_pkg::INCR16, ahb_pkg::WRAP16});
        (len != 1-1 && len != 4-1 && len != 8-1 && len != 16-1) -> (burst   == ahb_pkg::INCR);
        (burst inside {ahb_pkg::SINGLE})                -> (len == 1-1);
        (burst inside {ahb_pkg::INCR4, ahb_pkg::WRAP4}) -> (len == 4-1);
        (burst inside {ahb_pkg::INCR8, ahb_pkg::WRAP8}) -> (len == 8-1);
        (burst inside {ahb_pkg::INCR16, ahb_pkg::WRAP16}) -> (len == 16-1);
    }

    constraint c_size {
        len + busy_num + 1 == hwdata.size();
        len + busy_num + 2 == transfers.size();
    }

    constraint c_1k_boundary {
        (first_address[9:0] + ((len + 1) << size)) <= 1024;
    }

    extern               function             new               (string name = "ahb_xaction");
    extern       virtual function void        do_copy           (uvm_object rhs);
    extern       virtual function void        do_print          (uvm_printer printer);
    extern       virtual function bit         do_compare        (uvm_object rhs, 
                                                                 uvm_comparer comparer);
    extern       virtual function string      convert2string    ();
    extern               function void        post_randomize    ();
    extern local         function void        command_process   ();
    extern local         function void        data_process      ();
    extern local         function void        set_agent_type    ();
    extern local         function void        set_direction     ();
    extern local         function void        set_hsize         ();
    extern local         function void        set_htrans        ();
    extern local         function void        set_hburst        ();
    extern               function void        set_location      ();
    extern local         function void        set_address       ();
    extern local         function void        set_byte_lane     ();
    extern local         function void        set_response      ();
    extern       virtual function ahb_wdata_t get_mask          (ahb_wdata_t upper_byte_lane,
                                                                 ahb_wdata_t lower_byte_lane);
endclass : ahb_xaction

function ahb_xaction::new (string name = "ahb_xaction");
    super.new(name);
endfunction : new

function void ahb_xaction::do_copy (uvm_object rhs);
    ahb_xaction rhs_;

    if(!$cast(rhs_, rhs)) begin
        uvm_report_error("do_copy:", "Cast failed");
        return;
    end
    super.do_copy(rhs); // Chain the copy with parent classes

    delay       = rhs_.delay;
    len         = rhs_.len;
    only_okay   = rhs_.only_okay;
    busy_num    = rhs_.busy_num;
    agent_type  = rhs_.agent_type;
    name        = rhs_.name;

    hwdata  = rhs_.hwdata;
    hrdata  = rhs_.hrdata;
    size    = rhs_.size;
    burst   = rhs_.burst;

    transfers   = rhs_.transfers;
    direction   = rhs_.direction;

    upper_byte_lane = rhs_.upper_byte_lane;
    lower_byte_lane = rhs_.lower_byte_lane;

endfunction : do_copy

function void ahb_xaction::do_print (uvm_printer printer);
    if(printer.knobs.sprint == 0) begin
        $display(convert2string());
    end
    else begin
        printer.m_string = convert2string();
    end 
endfunction: do_print

function bit ahb_xaction::do_compare (uvm_object rhs, 
                                      uvm_comparer comparer
                                      );
    ahb_xaction rhs_;

    do_compare = super.do_compare(rhs, comparer);
    if (!$cast(rhs_, rhs)) begin
        uvm_report_error("do_compare", "cast failed, check type compatability");
        return 0;
    end
    
    // -- size -- 
    do_compare &= (transfers.size() == rhs_.transfers.size());
    foreach (transfers[i]) begin
        do_compare &= transfers[i].compare(rhs_.transfers[i]);
    end

    // -- data --
    foreach(hrdata[i]) begin
        ahb_wdata_t mask = get_mask(upper_byte_lane[i], lower_byte_lane[i]);
 
        do_compare &= ((hrdata[i] & mask) == (rhs_.hrdata[i] & mask));
    end
    foreach(hwdata[i]) begin
        ahb_wdata_t mask = get_mask(upper_byte_lane[i], lower_byte_lane[i]);
 
        do_compare &= ((hwdata[i] & mask) == (rhs_.hwdata[i] & mask));
    end
endfunction : do_compare

function string ahb_xaction::convert2string ();
    $sformat(convert2string, "\n-------------------------------------------------------");
    $sformat(convert2string, "%s\n(Type:%s) %s", convert2string, get_type_name(), get_name());
    $sformat(convert2string, "%s\n-------------------------------------------------------\n", convert2string);
    foreach (hwdata[i]) begin
        $sformat(convert2string, "%s HWDATA[%0d]\t%0d'h%0h\n", convert2string, i, `w_HWDATA, hwdata[i]);
    end 
    foreach (hrdata[i]) begin
        $sformat(convert2string, "%s HRDATA[%0d]\t%0d'h%0h\n", convert2string, i, `w_HRDATA, hrdata[i]);
    end 
    foreach (transfers[i]) begin
        transfers[i].set_header(0);
        $sformat(convert2string, "%s\n transfers[%0d]: %s\n", convert2string, i, transfers[i].convert2string());
    end 
endfunction : convert2string

function void ahb_xaction::post_randomize ();
    command_process();
    data_process();
endfunction : post_randomize

function void ahb_xaction::set_agent_type ();
    foreach (transfers[i]) begin
        transfers[i].agent_type = agent_type;
    end
endfunction : set_agent_type

function void ahb_xaction::set_direction ();
    foreach (transfers[i]) begin
        transfers[i].direction  = direction;
    end
    transfers[$].direction = READ;
endfunction : set_direction

function void ahb_xaction::set_hsize ();
    foreach (transfers[i]) begin
        transfers[i].size   = size;
    end
    transfers[$].size  = SIZE8;
    case (size)
        SIZE8:      amba_size = AMBA_BYTE_1;  
        SIZE16:     amba_size = AMBA_BYTE_2;  
        SIZE32:     amba_size = AMBA_BYTE_4;  
        SIZE64:     amba_size = AMBA_BYTE_8;  
        SIZE128:    amba_size = AMBA_BYTE_16; 
        SIZE256:    amba_size = AMBA_BYTE_32; 
        SIZE512:    amba_size = AMBA_BYTE_64; 
        SIZE1024:   amba_size = AMBA_BYTE_128;
    endcase
endfunction : set_hsize

function void ahb_xaction::set_htrans ();
    int busy_idx;
    int bq[$];
    int busy_queue[$];
    int busy_difference;

    // Randomize busy index, last valid HTRANS cannot be busy.
    for (int i=0; i<busy_num; i++) begin
        busy_idx    = $urandom % (len + busy_num);
        if (busy_idx != 0) begin
           bq.push_back(busy_idx);
        end
    end
    busy_queue  = bq.unique();
    busy_queue.sort();

    // Remove continuous busy index, index arrange bellow is not allowed:
    // +-----+-----+-----+-----+-----+
    // | NON | SEQ | BSY | BSY | SEQ |
    // +-----+-----+-----+-----+-----+
    //    0     1     2     3     4
    // 
    // and this one is acceptable.
    // +-----+-----+-----+-----+-----+
    // | NON | BSY | SEQ | BSY | SEQ |
    // +-----+-----+-----+-----+-----+
    //    0     1     2     3     4
      
    foreach (busy_queue[i]) begin
        if (i != 0) begin
            if (busy_queue[i] == busy_queue[i-1] + 1) begin
                busy_queue.delete(i);
            end
        end
    end

    busy_difference = busy_num - busy_queue.size();
    busy_num        = busy_queue.size();

    begin
        ahb_wdata_t tmp_wdata[$];
        int data_after_size = len + busy_num + 1;

        repeat (busy_difference) transfers.delete(0);

        tmp_wdata = hwdata;
        hwdata.delete();
        for (int i=0; i<data_after_size; i++) begin
            hwdata.push_back(tmp_wdata[i]);
        end
    end

    foreach(transfers[i]) begin
        int q[$];
        q   = busy_queue.find_index with (item == i);
        if (q.size() == 0) begin
            transfers[i].trans   = SEQ;
        end
        else begin
            transfers[i].trans   = BUSY;
        end
    end
    // For safety, set the last transfers to SEQ, althrough busy_idx can't
    // be last number.
    transfers[0].trans  = NONSEQ;
    if (!use_busy_end && transfers[$-1].trans != BUSY) begin
        transfers[$].trans = IDLE;
    end
    else if (!use_busy_end && transfers[$-1].trans == BUSY) begin
        transfers[$-1].trans    = SEQ;
        busy_num --;
    end
    else begin
        transfers[$].trans = BUSY;
        busy_num ++;
    end
endfunction : set_htrans

function void ahb_xaction::set_hburst ();
    foreach (transfers[i]) begin
        transfers[i].burst   = burst;
    end
    transfers[$].burst = SINGLE;
    
    if (burst inside {ahb_pkg::INCR, ahb_pkg::INCR4, ahb_pkg::INCR8, ahb_pkg::INCR16}) begin
        burst_type  = amba_pkg::INCR;
    end
    else if (burst inside {ahb_pkg::WRAP4, ahb_pkg::WRAP8, ahb_pkg::WRAP16}) begin
        burst_type  = amba_pkg::WRAP;
    end
endfunction : set_hburst

function void ahb_xaction::set_location ();
    // FIRST is the highest priority, second is LAST, last is MIDDLE.
    foreach (transfers[i]) begin
        transfers[i].location   = MIDDLE;
    end
    transfers[$].location   = LAST;
    transfers[0].location   = FIRST;
endfunction : set_location

function void ahb_xaction::set_response ();
    if (only_okay) begin
        foreach (transfers[i]) begin
            transfers[i].response   = OKAY;
        end
    end
endfunction : set_response

function void ahb_xaction::set_address ();
    bit busy_flag   = 1'b0;
    int addr_idx    = 0;
    amba_addr_t  addrs[];

    amba_tools.process_xaction(this);
    amba_tools.get_addr(addrs);

    foreach (transfers[i]) begin
        if (transfers[i].trans == BUSY) begin
            busy_flag   = 1'b1;
            transfers[i].data_valid = 1'b1;
        end
        // If privious transfers is "BUSY", the address should be hold on
        // untile HTRANS = SEQ
        if (transfers[i].trans == SEQ && busy_flag) begin
            transfers[i].address    = addrs[addr_idx];
            busy_flag   = 1'b0;
            transfers[i].data_valid = 1'b0;
            addr_idx ++;
        end
        else begin
            transfers[i].address    = addrs[addr_idx];
            transfers[i].data_valid = 1'b1;
            if (!busy_flag) addr_idx ++;
        end
    end
    if (transfers[$].trans != BUSY) begin
        transfers[$].address     = 'h0;
        transfers[$].data_valid  = 1'b1;
    end
    else begin
        transfers[$].address     = transfers[$-1].address;
        transfers[$].data_valid  = 1'b0;
    end
endfunction : set_address

function void ahb_xaction::set_byte_lane ();
    int  valid_upper_lane[];
    int  valid_lower_lane[];

    int lane_idx = 0;

    amba_tools.get_byte_lane(valid_upper_lane, valid_lower_lane);

    upper_byte_lane = new[len + busy_num + 1];
    lower_byte_lane = new[len + busy_num + 1];

    foreach (upper_byte_lane[i]) begin
        if (transfers[i].trans == BUSY) begin
            lane_idx --;

            upper_byte_lane[i]  = valid_upper_lane[lane_idx];
            lower_byte_lane[i]  = valid_lower_lane[lane_idx];

            lane_idx ++;
        end
        else begin
            upper_byte_lane[i]  = valid_upper_lane[lane_idx];
            lower_byte_lane[i]  = valid_lower_lane[lane_idx];

            lane_idx ++;
        end
    end
endfunction : set_byte_lane

function void ahb_xaction::command_process ();
    foreach (transfers[i]) begin
        transfers[i] = new();
        if (!transfers[i].randomize()) begin
            `uvm_fatal("RAND", "ahb transfers randomize error.")
        end
    end
    set_agent_type();
    if (agent_type == MASTER) begin
        set_direction();
        set_hsize();
        set_htrans();
        set_hburst();
        set_location();
        set_address();
        set_byte_lane();
    end
    if (agent_type == SLAVE) begin
        set_response();
    end
endfunction : command_process

function void ahb_xaction::data_process ();
    bit busy_flag   = 1'b0;
    int data_idx    = 0;

    ahb_wdata_t valid_data[$];

    for (int i=0; i<len+1; i++) begin
        valid_data.push_back(hwdata[i]);
    end

    if (direction == READ) begin
        hwdata.delete();
    end
    else begin
        if (busy_num != 0) begin
            foreach (hwdata[i]) begin
                if (transfers[i].trans == BUSY) begin
                    data_idx --;

                    hwdata[i]    = valid_data[data_idx];

                    data_idx ++;
                end
                else begin
                    hwdata[i]    = valid_data[data_idx];

                    data_idx ++;
                end
            end
        end
    end

    foreach (hwdata[i]) begin
        ahb_wdata_t mask = `w_HWDATA'h0;
        ahb_wdata_t data = hwdata[i];

        hwdata[i] &= get_mask(upper_byte_lane[i], lower_byte_lane[i]);
    end
endfunction : data_process

function ahb_wdata_t ahb_xaction::get_mask (ahb_wdata_t upper_byte_lane, 
                                            ahb_wdata_t lower_byte_lane
                                            );
    ahb_wdata_t mask = 0;

    mask    = ~mask;
    mask    >>= lower_byte_lane*8;
    mask    <<= lower_byte_lane*8;
    mask    <<= (`w_HWDATA - (upper_byte_lane+1)*8);
    mask    >>= (`w_HWDATA - (upper_byte_lane+1)*8);

    return mask;
endfunction : get_mask
`endif
