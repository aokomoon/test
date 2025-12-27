`timescale 1ns/1ns 
module tb_FFT_TEST();
reg     sys_clk     ;
reg     sys_rst     ;
reg     data_flag   ;



initial     
    begin   
        sys_clk     <=      1'b0;
        sys_rst     <=      1'b0;
        data_flag   <=      1'b0;
        #20     
        sys_rst     <=      1'b1;
        #500
        data_flag   <=      1'b1;
        #20
        data_flag   <=      1'b0;

    
    end 



always #10  sys_clk <=  ~sys_clk    ;



 FFT_TEST   FFT_TEST_inst
(
    .sys_clk   (sys_clk)  ,
    .sys_rst   (sys_rst)  ,
    .data_flag (data_flag)  
);





endmodule 


