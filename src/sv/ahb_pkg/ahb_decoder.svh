/********************************************************************
 * Copyright (c) 2014
 * All rights reserved.
 *
 * \file    ahb_decoder.svh
 * \brief   
 * \version 1.0
 * \author  seabeam
 * \Email   seabeam@sina.com
 * \date    2014-12-07
 ********************************************************************/

`ifndef AHB_DECODER_SVH
`define AHB_DECODER_SVH

module ahb_decoder (ahb_decoder_if ahb_port);
    ahb_env_config  cfg;
    
    wire [31:0] slave_id;
    reg         in_range = 1'b0;
    reg [31:0]  slave_num;
    reg [31:0]  id;

    initial begin
        cfg = new("cfg");
        uvm_config_db #(ahb_env_config)::wait_modified(null, "uvm_test_top.decoder", "ahb_env_config");
        if (!uvm_config_db #(ahb_env_config)::get(null, "uvm_test_top.decoder", "ahb_env_config", cfg)) begin
            `uvm_fatal("CFGDB", "Cannot get ahb_env_config")
        end
        slave_num   = cfg.n_slaves + 1;
    end

    reg [3:0] idx0;

    always @(ahb_port.DUT.HADDR_I) begin
        idx0 = 0;
        in_range    = 1'b0;
        repeat (16) begin
            if ((cfg.addr_db.low_addr[idx0] <= ahb_port.DUT.HADDR_I) && (cfg.addr_db.high_addr[idx0] >= ahb_port.DUT.HADDR_I) && (idx0<slave_num)) begin
                id      = idx0;
                in_range= 1'b1;
            end
            idx0 ++;
        end
    end

    assign slave_id = in_range ? id : 15;

    reg [3:0] idx1;
    always @(slave_id) begin
        idx1 = 0;
        repeat(16) begin
            if (idx1 == slave_id) begin
                ahb_port.DUT.HSEL[idx1]    = 1'b1;
            end
            else begin
                ahb_port.DUT.HSEL[idx1]    = 1'b0;
            end  
            idx1 ++;
        end
    end

    always @(ahb_port.DUT.HADDR_I) begin
        ahb_port.DUT.HADDR_O    = ahb_port.DUT.HADDR_I;
    end

    assign ahb_port.DUT.HRESP_O     = ahb_port.DUT.HRESP_I[slave_id];
    assign ahb_port.DUT.HREADY_O    = ahb_port.DUT.HREADY_I[slave_id];
    assign ahb_port.DUT.HRDATA_O    = ahb_port.DUT.HRDATA_I[slave_id];

    assign ahb_port.DUT.HRESP_I[15]     = OKAY;
    assign ahb_port.DUT.HREADY_I[15]    = 1'b1;
    assign ahb_port.DUT.HRDATA_I[15]    = 'h0;
endmodule : ahb_decoder

`endif
