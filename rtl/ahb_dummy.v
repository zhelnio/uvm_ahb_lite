module ahb_dummy (
    input  wire                     HCLK,
    input  wire                     HRESET_N,
    input  wire [`w_HADDR-1:0]      HADDR,
    input  wire [`w_HTRANS-1:0]     HTRANS,
    input  wire [`w_HBURST-1:0]     HBURST,
    input  wire                     HWRITE,
    input  wire [`w_HSIZE-1:0]      HSIZE,
    input  wire                     HSEL,
    input  wire [`w_HWDATA-1:0]     HWDATA,
    input  wire                     HREADY_I,                                                                                                                          
    output reg  [`w_HRDATA-1:0]     HRDATA,
    output reg                      HREADY_O,
    output wire [1:0]               HRESP
    );  
        
    assign HRESP    = 2'h0;
        
    always @(posedge HCLK) begin
        if (!HRESET_N) begin
            HRDATA      <= `w_HRDATA'h0;
            HREADY_O    <= 1'b0;
        end 
        else begin
            HRDATA      <= `w_HRDATA'h5A;
            HREADY_O    <= $urandom();
        end 
    end 
        
endmodule
