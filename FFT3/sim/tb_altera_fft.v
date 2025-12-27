`timescale 1ns / 1ps
module tb_altera_fft();


reg clk;
reg rst_n;
initial 
    begin
        clk <= 1'b1;
        rst_n<= 1'b0;
        #20
        rst_n<= 1'b1;
    end

always #10 clk = ~clk;


altera_fft  altera_fft_inst
(
        .clk    (clk),           
        .rst_n  (rst_n),         
        .data_in(),  
        .amp    ()   
);
















endmodule 



