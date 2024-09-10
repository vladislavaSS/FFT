`timescale 1ns / 1ps

module tb_fft #(
  real      dt         = 1.0,
  parameter G_DATA_BYT = 4,
  parameter G_CFG_BYT  = 2,
  parameter G_COUNT_OF_MODS = 4 
    ); 

logic i_clk   = '0; 
logic i_rst   = '1; 

always #(dt/2.0) i_clk = ~i_clk;

if_axis #(.N(G_DATA_BYT)) s_fifo_axis ();
if_axis #(.N(G_DATA_BYT)) m_fifo_axis ();
if_axis #(.N(G_DATA_BYT*2)) m_fft_axis ();
if_axis #(.N(1))  s_cfg_axis ();
if_axis #(.N(G_DATA_BYT*2)) q_fft  (); 
if_axis #(.N(G_DATA_BYT)) m_res();

int  test = 0,
     file
  /* freal = 0,
    fimag = 0, */;

localparam int W = 27;

logic signed [63:0] o_data;
reg o_valid = '0;

logic signed [W-1:0] m_fft_tdata_re;
logic signed [W-1:0] m_fft_tdata_im;

assign m_fft_tdata_re = q_fft.tdata[W-1:0];
assign m_fft_tdata_im = q_fft.tdata[32+W-1:32];

reg signed [63:0] q_fft_tdata = '0;

always_ff @(posedge i_clk) begin
	q_fft.tvalid <= m_fft_axis.tready & m_fft_axis.tvalid;
	if (m_fft_axis.tready & m_fft_axis.tvalid) begin
		q_fft.tlast <= m_fft_axis.tlast;
		q_fft.tdata <= m_fft_axis.tdata;
	end
	if (q_fft.tvalid)
		q_fft_tdata <= (m_fft_tdata_re * m_fft_tdata_re) + (m_fft_tdata_im * m_fft_tdata_im);
end

initial begin
  m_fft_axis.tready = '1;
  s_cfg_axis.tvalid = '0;
  s_cfg_axis.tdata  = '0;
end

initial begin
  s_fifo_axis.tvalid = '0;
  s_fifo_axis.tdata  = '0;
  s_fifo_axis.tlast  = '0;

  #199.6;
  while (1) begin
  // open for reading
  test = $fopen("test.dat", "r");

  // reading
  while (!$feof(test)) begin
      $fscanf(test, "%d %d\n", s_fifo_axis.tdata[15:0], s_fifo_axis.tdata[31:16]);
      s_fifo_axis.tvalid = '1;
      s_fifo_axis.tlast  = $feof(test);
      #1;
      s_fifo_axis.tvalid = '0;
       
  end
  end
  
  
  s_fifo_axis.tlast = '1;
      #1;
       s_fifo_axis.tlast = '0;
  
    #199.6;

  // open for reading
  test = $fopen("test.dat", "r");

  // reading
  while (!$feof(test)) begin
      s_fifo_axis.tvalid = '1;
      $fscanf(test, "%d %d\n", s_fifo_axis.tdata[15:0], s_fifo_axis.tdata[31:16]);
      #1;
           
  end  
   s_fifo_axis.tlast = '1;
      #1;
       s_fifo_axis.tlast = '0; 
  #199.6;

  // open for reading
  test = $fopen("test.dat", "r");

  // reading
  while (!$feof(test)) begin
      s_fifo_axis.tvalid = '1;
      $fscanf(test, "%d %d\n", s_fifo_axis.tdata[15:0], s_fifo_axis.tdata[31:16]);
     #1;
       
  end
  s_fifo_axis.tlast = '1;
      #1;
       s_fifo_axis.tlast = '0;
  #199.6;

  // open for reading
  test = $fopen("test.dat", "r");

  // reading
  while (!$feof(test)) begin
      s_fifo_axis.tvalid = '1;
      $fscanf(test, "%d %d\n", s_fifo_axis.tdata[15:0], s_fifo_axis.tdata[31:16]);
     #1;
       
  end
  s_fifo_axis.tlast = '1;
      #1;
       s_fifo_axis.tlast = '0;
       
  #199.6;

  // open for reading
  test = $fopen("test.dat", "r");

  // reading
  while (!$feof(test)) begin
      s_fifo_axis.tvalid = '1;
      $fscanf(test, "%d %d\n", s_fifo_axis.tdata[15:0], s_fifo_axis.tdata[31:16]);
     #1;
       
  end
  s_fifo_axis.tlast = '1;
      #1;
       s_fifo_axis.tlast = '0;
      
end

reg q_vld = '0;
reg unsigned [7:0] q_cnt = '0;

always_ff @(posedge i_clk)
    if (q_cnt > 50)
        q_vld <= '1;

always_ff @(posedge i_clk)
    q_cnt <= q_cnt + 1; 

initial begin
  file = $fopen("output_data.dat", "w");
  #15000; $fclose(file);            //+-20000
  end


always_ff @(posedge i_clk) begin
  if (o_valid)
    $fwrite(file, "%h %h\n", o_data [31:0], o_data [63:32]);
end
  

 FFT#()FFT(
   .i_clk    (i_clk),
   .s_tlast  (s_fifo_axis.tlast),
   .s_tdata  (s_fifo_axis.tdata),
   .s_tvalid (s_fifo_axis.tvalid),
   .m_tdata  (o_data),
   .m_tvalid (o_valid),
   .i_rst_n  (i_rst)
 );
endmodule
