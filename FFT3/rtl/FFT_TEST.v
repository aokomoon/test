module FFT_TEST
(
    input       wire        sys_clk     ,
    input       wire        sys_rst     ,
    input       wire        data_flag   ,
    
    output      wire  signed  [24:0]     ans2,
    output      wire  signed  [24:0]     ans           //平方和，实际还需要开根    
    
);


//FFT     
    wire inverse;         // 输入，为1时进行IFFT，为0时进行FFT
    wire sink_ready;      // 输出，FFT引擎准备好接收数据时该信号置位
    reg source_ready;     // 输入，下传流模块在可以接收数据时将该信号置位
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
   // assign source_ready = 1'b1;   // 该信号置1表示永远准备好接收FFT数据
    assign inverse = 1'b0;        // 进行FFT正变换
    assign sink_imag = 12'd0;     // 输入数据虚部无数据，仅限于FFT正变换
    
   
    

//ROM
   reg      [11:0]      address       ;
   wire     signed[11:0]  data_in     ;
 


//测试读数据
   reg   [11:0]           rd_adder    ; 
   reg                    rden        ;
//reRAM
   reg   signed[11:0]     re_data     ;
   reg   [11:0]           re_adder    ;
   reg                    re_wren     ;
   wire  signed[11:0]     re_out      ;
//imRAM
   reg   signed[11:0]     im_data     ;
   reg   [11:0]           im_adder    ;
   reg                    im_wren     ;   
   wire  signed[11:0]     im_out      ; 
   
 
   
   



//状态表
reg      [4:0]        FFT_state      ;
parameter    DATA_IN_START   =  5'b000;      
parameter    DATA_IN_Vaild   =  5'b001;      //输入数据start
parameter    DATA_IN_END     =  5'b010;      //输入数据END
parameter    DATA_OUT_GUODU  =  5'b011;      //输出数据写状态的过渡态
parameter    DATA_OUT_START  =  5'b100;      //输出数据写RAM
parameter    RAM_OUT_TEST    =  5'b101;      //写入数据输出测试
parameter    RAM_OUT_TEST2   =  5'b110;      //写入数据输出测试



reg      signed[11:0]       data_re_reg    ;
reg      signed[11:0]       data_im_reg    ;



//状态机
always@(posedge sys_clk or negedge sys_rst)
    if(!sys_rst)
        begin 
            FFT_state   <=    DATA_IN_START ;     //状态 
            source_ready<=    1'b0          ;
            sink_valid  <=    1'b0          ;     //输入数据有效准备信号
            sink_sop    <=    1'b0          ;     //一包数据开始输入信号
            sink_eop    <=    1'b0          ;     //一包数据结束输入信号
            address     <=    12'd0         ;     //DDS信号源地址
            data_re_reg <=    12'd0         ;
            data_im_reg <=    12'd0         ;
            re_wren     <=    1'b0          ;     //RAM写使能
            im_wren     <=    1'b0          ;
            re_adder    <=    1'b0          ;     //RAM写地址
            im_adder    <=    1'b0          ;
            rd_adder    <=    12'd0         ;     //测试读地址
            rden        <=    1'b0          ;     //测试读使能
        end   
    else 
        begin
           case(FFT_state)
                
                    DATA_IN_START:  
                        begin
                            if(data_flag == 1'b1)
                                begin
                                    source_ready <= 1'b1            ;//首先是开始准备使能
                                    sink_valid   <= 1'b1            ;//高电平时期读一个数据，此时高电平期间已经读了首位地址位的数据
                                    sink_sop     <= 1'b1            ;
                                    FFT_state    <= DATA_IN_Vaild   ;//跳转状态，还有一个开始数据使能
                                end     
                            else
                                    FFT_state    <= DATA_IN_START   ;//保持当前状态
                        end 
                    DATA_IN_Vaild:
                        begin
                                    sink_sop     <= 1'b0            ;
                            if(address < 12'd4094)
                                begin
                                    address      <= address +   1'b1;
                                end 
                            else   if(address == 12'd4094)   
                                begin
                                    address      <= 12'd4095        ;
                                    sink_eop     <= 1'b1            ;
                                    
                                end 
                            else   if(address == 12'd4095)   
                                begin
                                    address      <= 12'd0           ;
                                    sink_eop     <= 1'b0            ;
                                    sink_valid   <= 1'b0            ;
                                    FFT_state    <= DATA_IN_END     ;
                                end 
                            else    
                                    address      <= 12'd0           ;
                        end 
                    DATA_IN_END:
                        begin
                                    sink_eop     <= 1'b0            ;
                                    address      <= 12'd0           ;
                            if((source_sop == 1'b1)&&(source_valid == 1'b1))
                                begin
                                    data_re_reg  <= xkre            ;       //由于当开始输出使能为高电平时的数据已经是有效数据了，所以这个要加一个缓存
                                    data_im_reg  <= xkim            ;       //防止数据丢失
                                    re_wren      <= 1'b1            ;
                                    im_wren      <= 1'b1            ;       //RAM写使能
                                    FFT_state    <= DATA_OUT_GUODU  ;       //输出写数据开始
                                end 

                            
                        end 
                    DATA_OUT_GUODU:                                         //写数据的地址过渡态，防止0地址未写入          
                        begin
                            if(((source_eop == 1'b0)&&(source_valid == 1'b1))||((source_eop == 1'b1)&&(source_valid == 1'b1)))
                                begin
                                    re_data      <= data_re_reg     ;
                                    im_data      <= data_im_reg     ;
                                    data_re_reg  <= xkre            ;
                                    data_im_reg  <= xkim            ;
                                    FFT_state    <= DATA_OUT_START  ;
                                end 
                        end 
                    DATA_OUT_START:
                        begin
                            if(((source_eop == 1'b0)&&(source_valid == 1'b1))||((source_eop == 1'b1)&&(source_valid == 1'b1)))
                                begin
                                    re_data      <= data_re_reg     ;
                                    im_data      <= data_im_reg     ;
                                    data_re_reg  <= xkre            ;
                                    data_im_reg  <= xkim            ;
                                    re_adder     <= re_adder +1'b1  ; 
                                    im_adder     <= im_adder +1'b1  ;
                                end     
                            else    
                                begin
                                    re_data      <= data_re_reg     ;
                                    im_data      <= data_im_reg     ;
                                    re_adder     <= 12'd0           ; 
                                    im_adder     <= 12'd0           ;
                                    FFT_state    <= RAM_OUT_TEST    ;
                                end     
                        end 
                    RAM_OUT_TEST:
                        begin
                            rden         <=      1'b1       ;
                            FFT_state    <= RAM_OUT_TEST2   ;
                        end 
                    RAM_OUT_TEST2:
                        begin
                            if(rd_adder <4095)
                                rd_adder     <= rd_adder+1'b1   ;
                            else    
                                begin
                                    rd_adder     <= 1'b0            ;
                                    rden         <= 1'b0            ;
                                    FFT_state    <= DATA_IN_START   ;
                                end 
                            
                        end    
            endcase
        end 
        
        

wire signed [23:0] xkre_square, xkim_square;
assign xkre_square = re_data * re_data;               //对实部平方
assign xkim_square = im_data * im_data;               //对虚部平方
assign ans   =  ((source_valid==1'b1))?xkre_square+xkim_square:'d0;



//这个输出有两个周期的延时，所以实际坐标是当前地址位-2
wire signed [23:0] xkre_square2, xkim_square2;
assign xkre_square2 = re_out * re_out;               //对实部平方
assign xkim_square2 = im_out * im_out;               //对虚部平方
assign ans2   =  ((rden==1'b1))?xkre_square2+xkim_square2:'d0;

//有符号数转无符号数
wire    [24:0]  ans_us;
assign ans_us   =   (ans2[24]==1'b1)?{1'b0,(~ans2[23:0]-1'b1)}:{1'b0,(ans2[23:0])};


wire  	[12:0] q2;
//平方根计算，输出的是幅值/2
sqrt	sqrt_inst (
	.clk ( sys_clk ),
	.ena ( rden ),
	.radical ( ans_us ),
	.q (q2  ),
	.remainder (  )
	);




wire signed 	[12:0] q;
wire  	[12:0] q_mag;  
//cordic计算atan2
cordic cordic_inst 
(
	.areset (1'd0)    ,
	.clk    (sys_clk)    ,   
	.en     (rden)    ,
	.q      (q)    ,        //角度结果
	.x      (re_out)    ,
	.y      (im_out)
);


//角度转换  定点数，后十位是小数位，第一位是符号位，乘的K是180/PI  
parameter signed    toAngle = 57;    
wire signed [20:0]  q_mul_out; 

//有符号数的扩展
wire signed [20:0]  q_ext;     
assign q_ext = {{7{q[12]}}, q}; 

assign q_mul_out = q * toAngle;      





//FFT例化

  unnamed u0 (
        .clk          (sys_clk),              
        .reset_n      (sys_rst),            
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

//波形发生器
   rom	rom_inst (
	.address ( address ),
	.clock ( sys_clk ),
	.rden ( source_ready ),
	.q ( data_in )
	);


//实部数据存储器
RANre	RANre_inst (
	.clock ( sys_clk ),
	.data ( re_data ),
	.rdaddress ('d20  ),
	.rden ( rden ),
	.wraddress ( re_adder ),
	.wren ( re_wren ),
	.q ( re_out )
	);

//虚部数据存储器
RANre	RANim_inst (
	.clock ( sys_clk ),
	.data ( im_data ),
	.rdaddress ( 'd20 ),
	.rden ( rden ),
	.wraddress ( im_adder ),
	.wren ( im_wren ),
	.q ( im_out )
	);

endmodule 
