`timescale 1ns / 1ps
//-------------------------------------------------------------------------
//      调用Quartus FFT IP核进行傅里叶变换
//-------------------------------------------------------------------------
module altera_fft
(
        input clk,                     //时钟
        input rst_n,                   //低电平有效复位
        output signed [11:0] data_in,   //AD采集数据输入
        output signed [24:0] amp       //FFT计算结果
);


    /********** 定义FFT IP核使用端口 **********/
    wire inverse;         // 输入，为1时进行IFFT，为0时进行FFT
    wire sink_ready;      // 输出，FFT引擎准备好接收数据时该信号置位
    wire source_ready;    // 输入，下传流模块在可以接收数据时将该信号置位
    reg sink_valid;       // 输入，有效标记信号，sink_valid和sink_ready都置位时开始数据传输
    reg sink_sop;         // 输入，高电平表示1帧数据载入开始
    reg sink_eop;         // 输入，高电平表示1帧数据载入结束
    wire signed [11:0]sink_imag;  // 输入，输入数据的虚部，二进制补码数据
    wire [1:0] sink_error;        // 输入，表示载入数据状态，一般置0
    wire [1:0] source_error;      // 输出，表示FFT转换出现的错误
    wire source_sop;              // 输出，高电平表示一帧数据转换开始
    wire source_eop;              // 输出，高电平表示一帧数据转换结束
    wire [5:0]source_exp;
    wire source_valid;
    wire signed [11:0] xkre;      // 输出，输出数据的实部，二进制补码数据
    wire signed [11:0] xkim;      // 输出，输出数据的虚部

    assign sink_error = 2'b00;
    assign source_ready = 1'b1;   // 该信号置1表示永远准备好接收FFT数据
    assign inverse = 1'b0;        // 进行FFT正变换
    assign sink_imag = 12'd0;     // 输入数据虚部接地

    /********** 控制FFT数据的载入 **********/

    //在sink_valid为高电平期间，通过sink_sop、sink_eop控制载入数据
    //设置FFT变换起始脉冲，sink_eop/sink_sop高电平后开始载入数据
    //由于Burst模式下，FFT变换时延不超过2048个时钟周期，因此每2048个周期进行一次FFT变换
    reg [11:0] count;        

    always @ (posedge clk or negedge rst_n)
        if (!rst_n) begin
            sink_eop <= 'b0;
            sink_sop <= 'b0;
            sink_valid <= 'b0;
            count <= 'b0;
        end
        else begin
            count <= count + 1'd1;
            if (count == 1) sink_sop <= 1'b1;   //计数1，置位sop，开始载入AD数据
            else  sink_sop <= 1'b0;

            if (count == 4095) sink_eop <= 1'b1; //计数512，置位eop，结束载入AD数据，进行512点FFT
            else  sink_eop <= 1'b0;

            if (count>=1 & count<=4095) sink_valid <= 1'b1;  //载入数据期间，置位sink_valid
            else  sink_valid <= 1'b0;
        end
    rom	rom_inst (
	.address ( count ),
	.clock ( clk ),
	.rden ( sink_valid ),
	.q ( data_in )
	);

    /********** 调用IP核进行FFT变换，Burst模式 **********/
    //FFT核，实现512点的FFT正变换,在sink_valid\sink_sop\sink_eop的控制下，每2048个数据进行一次正变换
    unnamed u0 (
        .clk          (clk),              
        .reset_n      (rst_n),            
        .sink_valid   (sink_valid),       
        .sink_ready   (sink_ready),      
        .sink_error   (sink_error),      
        .sink_sop     (sink_sop),         
        .sink_eop     (sink_eop),         
        .sink_real    (data_in),          
        .sink_imag    (sink_imag),    

        .inverse      (inverse),      
        .source_valid (source_valid), 
        .source_ready (source_ready), 
        .source_error (source_error), 
        .source_sop   (source_sop),   
        .source_eop   (source_eop),  
        .source_exp   (source_exp),
        .source_real  (xkre),  
        .source_imag  (xkim)   
    );  

    /********** 计算频谱的幅值信号 **********/
    wire signed [23:0] xkre_square, xkim_square;
    assign xkre_square = xkre * xkre;               //对实部平方
    assign xkim_square = xkim * xkim;               //对虚部平方
    assign amp = xkre_square + xkim_square;         //平方和，再发数据进行开根实现取模
//1. 如果对结果不做处理，直接取复数的模，得到幅度谱（Magnitude）；
//2. 把第一个和最后一个对应直流分量的点的模值除以N，其余点的模值除N/2，得到幅值谱（Amplitude）；
//             -> Magnitude/N
//Amplitude = | 
//             -> Magnitude/2/N
//3. 工程中通常取对数坐标，转化为dB单位。dB = 20log10(Amplitude)







endmodule 