`timescale 1ns / 1ps

module FFT_Top(
    input  wire i_rst_n,
	input  wire i_clk,
	
	input  wire        s_tvalid,
	input  wire [31:0] s_tdata,
	
	output reg         m_tvalid,
	output reg         m_tlast ,
	output reg  [63:0] m_tdata 
);
    
FFT#()
    FFT(
    .i_clk    (i_clk),
    .i_rst_n  (i_rst_n),
    
    .s_tdata  (s_tdata),
    .s_tvalid (s_tvalid),
    
    .m_tvalid (m_tvalid),
    .m_tlast  (m_tlast),
    .m_tdata  (m_tdata)
  );
  
endmodule
