module rw_fifo_ctrl
(
    input wire                         rstn                    ,//ϵͳ��λ
    input wire                         ddr_clk                 ,//д���ڴ��ʱ�ӣ��ڴ�axi4�ӿ�ʱ�ӣ�

    //дfifo                                                    
    input wire                         wfifo_wr_clk            ,//wfifoдʱ��
    input wire                         wfifo_wr_en             /* synthesis PAP_MARK_DEBUG="1" */,//wfifo����ʹ��
    input wire     [31 : 0]            wfifo_wr_data32_in      /* synthesis PAP_MARK_DEBUG="1" */,//wfifo��������,16bits
    input wire                         wfifo_rd_req            /* synthesis PAP_MARK_DEBUG="1" */,//wfifo�����󣬵���������ͻ������ʱ����
    //input wire                         wfifo_pre_rd_req        /* synthesis PAP_MARK_DEBUG="1" */,
    output wire    [10 : 0]            wfifo_rd_water_level    /* synthesis PAP_MARK_DEBUG="1" */,//wfifo��ˮλ������������ͻ������ʱ��ʼ����
    output wire    [255 : 0]           wfifo_rd_data256_out    /* synthesis PAP_MARK_DEBUG="1" */,//wfifo�����ݣ�256bits      
    //��fifo
    input wire                         rfifo_rd_clk            ,//rfifo��ʱ��
    input wire                         rfifo_rd_en             /* synthesis PAP_MARK_DEBUG="1" */,//rfifo����ʹ��
    output wire    [31 : 0]            rfifo_rd_data32_out     /* synthesis PAP_MARK_DEBUG="1" */,//rfifo��������,16bits
    input wire                         rfifo_wr_req            /* synthesis PAP_MARK_DEBUG="1" */,//rfifoд���󣬵���������ͻ������ʱ����
    output wire    [10: 0]             rfifo_wr_water_level    /* synthesis PAP_MARK_DEBUG="1" */,//rfifoдˮλ��������С��ͻ������ʱ��ʼ����
    input wire     [255 : 0]           rfifo_wr_data256_in     /* synthesis PAP_MARK_DEBUG="1" */ //rfifoд���ݣ�256bits
                           
       );

//inst fifo
write_ddr_fifo user_write_ddr_fifo 
(
  .wr_clk            (wfifo_wr_clk        ),// input         
  .wr_rst            (~rstn               ),// input         
  .wr_en             (wfifo_wr_en         ),// input         
  .wr_data           (wfifo_wr_data32_in  ),// input [31:0]  
  .wr_full           (                    ),// output        
  .wr_water_level    (                    ),// output [13:0]     
  .almost_full       (                    ),// output        
  .rd_clk            (ddr_clk             ),// input         
  .rd_rst            (~rstn               ),// input         
  .rd_en             (wfifo_rd_req        ),// input         
  .rd_data           (wfifo_rd_data256_out),// output [255:0]
  .rd_empty          (                    ),// output        
  .rd_water_level    (wfifo_rd_water_level),// output [10:0]       
  .almost_empty      (                    ) // output        
);

read_ddr_fifo user_read_ddr_fifo 
(
  .wr_clk            (ddr_clk             ),// input        
  .wr_rst            (~rstn               ),// input        
  .wr_en             (rfifo_wr_req        ),// input        
  .wr_data           (rfifo_wr_data256_in ),// input [255:0]
  .wr_full           (                    ),// output       
  .wr_water_level    (rfifo_wr_water_level),// output [10:0] 
  .almost_full       (                    ),// output       
  .rd_clk            (rfifo_rd_clk        ),// input        
  .rd_rst            (~rstn               ),// input        
  .rd_en             (rfifo_rd_en         ),// input        
  .rd_data           (rfifo_rd_data32_out ),// output [31:0]
  .rd_empty          (                    ),// output       
  .rd_water_level    (                    ),// output [13:0]
  .almost_empty      (                    ) // output       
);

endmodule