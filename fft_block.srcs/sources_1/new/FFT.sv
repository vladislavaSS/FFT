`timescale 1ns / 1ps

module FFT #(
  parameter G_COUNT_OF_MODS = 4 
    )(
	input  wire i_rst_n,
	input  wire i_clk,
	
	input  wire        s_tvalid,
	input  wire [31:0] s_tdata ,
	
	output reg         m_tvalid = '0,
	output reg         m_tlast  = '0,
	output reg  [63:0] m_tdata  = '0
);


// FIFOs input array of AXIS interfaces
wire [3:0]  s_fft_tvalid;
wire [3:0]  s_fft_tready;
wire [3:0]  s_fft_tlast;
wire [63:0] s_fft_tdata [3:0];

// FIFOs output array of AXIS interfaces
wire [3:0]  m_fft_tvalid;
wire [3:0]  m_fft_tlast;
wire [63:0] m_fft_tdata [3:0];

reg [1:0] q_cnt_i = '0; // input channel counter
reg [1:0] q_cnt_o = '0; // output channel counter

always_ff @(posedge i_clk)
	q_cnt_o <= q_cnt_o + 1; 

always_ff @(posedge i_clk)
	if (s_tvalid)
		q_cnt_i <= q_cnt_i + 1;




always_ff @(posedge i_clk) begin
	m_tvalid <= |m_fft_tvalid; 
	m_tlast  <= m_fft_tlast[3] & m_fft_tvalid[3] & q_cnt_o == 3; 
	for (int k = 0; k < 4; k++) begin
		if (m_fft_tvalid[k] & q_cnt_o == k) 
			m_tdata <= m_fft_tdata[k];
  end
end


genvar i;
(* keep_hierarchy="yes" *) 
generate 
  for (i = 0; i < G_COUNT_OF_MODS; i += 1) begin : fft 
    xfft_0 FFT_block 
    (
        .s_axis_data_tdata      (s_tdata), 
        .s_axis_data_tvalid     (s_tvalid & q_cnt_i == i), 
        .s_axis_data_tready     (),
        .s_axis_data_tlast      (s_tlast),

        .s_axis_config_tdata    ('0), 
        .s_axis_config_tvalid   ('0), 
        .s_axis_config_tready   (  ), 

        .m_axis_data_tready          (s_fft_tready[i]),
		.m_axis_data_tvalid          (s_fft_tvalid[i]),
		.m_axis_data_tlast           (s_fft_tlast[i] ),
		.m_axis_data_tdata           (s_fft_tdata[i] ),

        .aclk                        (i_clk       )

    );

    axis_fifo_w #(
    .PACKET_MODE ("False"), // Packet mode, when true the FIFO outputs data only when a tlast is received or the FIFO has filled
	.MEM_STYLE   ("Block"), // Memory style: "Distributed" or "Block"
	.DUAL_CLOCK  ("False"), // Dual clock fifo: "True" or "False"
	.RESET_SYNC  ("False"), // Asynchronous reset synchronization: "True" or "False"
	.FEATURES    ('0     ),  // Advanced features: [ reserved, read count, prog. empty flag, almost empty, reserved, write count, prog. full flag, almost full flag ]    
    .TDATA_W     (8      ), // AXI4-Stream TDATA width in bytes
    .DEPTH       (16     )   
    ) AXIS_FIFO (
      .i_fifo_a_rst_n     ('1   ),

      .s_axis_a_clk_p     (i_clk  ),
      .s_axis_a_rst_n     (i_rst_n),

      .m_axis_a_clk_p     (i_clk  ),
      .m_axis_a_rst_n     (i_rst_n),
      
      .s_axis_tready  (s_fft_tready[i]),
      .s_axis_tvalid  (s_fft_tvalid[i]),
      .s_axis_tlast   (s_fft_tlast[i]),
      .s_axis_tdata   (s_fft_tdata[i]),
    
      .m_axis_tready  (q_cnt_o == i), // output channel separation (read one at a time)
      .m_axis_tvalid  (m_fft_tvalid[i]),
      .m_axis_tlast   (m_fft_tlast[i]),
      .m_axis_tdata   (m_fft_tdata[i])
    );

  end : fft

endgenerate


endmodule
































/* `timescale 1ns / 1ps

module fft(
	input  wire i_rst_n,
	input  wire i_clk,
	
	input  wire        s_tvalid,
	input  wire [31:0] s_tdata ,
	
	output reg         m_tvalid = '0,
	output reg         m_tlast  = '0,
	output reg  [63:0] m_tdata  = '0
);

// FIFOs input array of AXIS interfaces
wire [ 3:0] s0_tready;
wire [ 3:0] s0_tvalid;
wire [ 3:0] s0_tlast;
wire [63:0] s0_tdata [3:0];

// FIFOs output array of AXIS interfaces
wire [ 3:0] m0_tvalid;
wire [ 3:0] m0_tlast;
wire [63:0] m0_tdata [3:0];


(* keep_hierarchy="yes" *) 
generate 
  for (i = 0; i < G_COUNT_OF_MODS; i += 1) begin : fft 
    xfft_0 FFT_block 
    (
        .s_axis_data_tdata      (s_tdata), 
        .s_axis_data_tvalid     (s_tvalid && q_cnt_i == i), 
        .s_axis_data_tready     (),
        .s_axis_data_tlast           (s_tlast),

        .s_axis_config_tdata    ('0), 
        .s_axis_config_tvalid   ('0), 
        .s_axis_config_tready   (  ), 

        // .m_axis_data_tdata      (m_fft_axis.tdata  ), 
        // .m_axis_data_tvalid     (m_fft_axis.tvalid ), 
        // .m_axis_data_tready     (m_fft_axis.tready ), 

        .m_axis_data_tready          (s0_tready[i]),
			  .m_axis_data_tvalid          (s0_tvalid[i]),
			  .m_axis_data_tlast           (s0_tlast[i] ),
			  .m_axis_data_tdata           (s0_tdata[i] ),

        .aclk                        (i_clk       )
        // .aresetn                (i_rst_n           )

    );

    axis_fifo #(
    .PACKET_MODE ("False"), // Packet mode, when true the FIFO outputs data only when a tlast is received or the FIFO has filled
		.MEM_STYLE   ("Block"), // Memory style: "Distributed" or "Block"
		.DUAL_CLOCK  ("False"), // Dual clock fifo: "True" or "False"
		.RESET_SYNC  ("False"), // Asynchronous reset synchronization: "True" or "False"
		.FEATURES    ('0     ),  // Advanced features: [ reserved, read count, prog. empty flag, almost empty, reserved, write count, prog. full flag, almost full flag ]    
    .TDATA_W     (8      ), // AXI4-Stream TDATA width in bytes
    .DEPTH       (16     )   
    ) AXIS_FIFO (
      .i_fifo_a_rst_n     ('1   ),

      .s_axis_a_clk_p     (i_clk  ),
      .s_axis_a_rst_n     (i_rst_n),

      .m_axis_a_clk_p     (i_clk  ),
      .m_axis_a_rst_n     (i_rst_n),
      
			.s_axis_tready  (s0_tready[i]),
			.s_axis_tvalid  (s0_tvalid[i]),
			.s_axis_tlast   (s0_tlast[i]),
			.s_axis_tdata   (s0_tdata[i]),
  
			.m_axis_tready  (q_cnt_o == i), // output channel separation (read one at a time)
			.m_axis_tvalid  (m0_tvalid[i]),
			.m_axis_tlast   (m0_tlast[i]),
			.m_axis_tdata   (m0_tdata[i])
    );

  end : fft
endgenerate


endmodule : fft
 */