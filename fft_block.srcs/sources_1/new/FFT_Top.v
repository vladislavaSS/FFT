`timescale 1ns / 1ps

module FFT_Top(
    input  wire i_rst_n,
	input  wire i_clk,
	
	input  wire        s_tvalid,
	input  wire [31:0] s_tdata,
	input  wire        s_tlast,

	
	output wire        m_tvalid,
	output wire        m_tlast ,
	output wire [63:0] m_tdata 
);
    
FFT#()
    FFT(
    .i_clk    (i_clk),
    .i_rst_n  (i_rst_n),
    
    .s_tdata  (s_tdata),
    .s_tvalid (s_tvalid),
    .s_tlast  (s_tlast),
    
    .m_tvalid (m_tvalid),
    .m_tlast  (m_tlast),
    .m_tdata  (m_tdata)
  );
  
endmodule
