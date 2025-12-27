#ifndef __AD9854_PARALLEL_H
#define __AD9854_PARALLEL_H

#include "headers.h"

#if USE_AD9854

#define AD9854_RST(x)	HAL_GPIO_WritePin(AD9854_RST_GPIO_Port, AD9854_RST_Pin, x? GPIO_PIN_SET: GPIO_PIN_RESET)
#define AD9854_UCLK(x)	HAL_GPIO_WritePin(AD9854_UCLK_GPIO_Port, AD9854_UCLK_Pin, x? GPIO_PIN_SET: GPIO_PIN_RESET)
#define AD9854_WR(x)	HAL_GPIO_WritePin(AD9854_WR_GPIO_Port, AD9854_WR_Pin, x? GPIO_PIN_SET: GPIO_PIN_RESET)
#define AD9854_RD(x)	HAL_GPIO_WritePin(AD9854_RD_GPIO_Port, AD9854_RD_Pin, x? GPIO_PIN_SET: GPIO_PIN_RESET)
#define AD9854_OSK(x)	HAL_GPIO_WritePin(AD9854_OSK_GPIO_Port, AD9854_OSK_Pin, x? GPIO_PIN_SET: GPIO_PIN_RESET)
#define AD9854_FSK(x)	HAL_GPIO_WritePin(AD9854_FSK_GPIO_Port, AD9854_FSK_Pin, x? GPIO_PIN_SET: GPIO_PIN_RESET)

#define AD9854_D0(x)  HAL_GPIO_WritePin(AD9854_D0_GPIO_Port, AD9854_D0_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)
#define AD9854_D1(x)  HAL_GPIO_WritePin(AD9854_D1_GPIO_Port, AD9854_D1_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)
#define AD9854_D2(x)  HAL_GPIO_WritePin(AD9854_D2_GPIO_Port, AD9854_D2_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)
#define AD9854_D3(x)  HAL_GPIO_WritePin(AD9854_D3_GPIO_Port, AD9854_D3_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)
#define AD9854_D4(x)  HAL_GPIO_WritePin(AD9854_D4_GPIO_Port, AD9854_D4_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)
#define AD9854_D5(x)  HAL_GPIO_WritePin(AD9854_D5_GPIO_Port, AD9854_D5_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)
#define AD9854_D6(x)  HAL_GPIO_WritePin(AD9854_D6_GPIO_Port, AD9854_D6_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)
#define AD9854_D7(x)  HAL_GPIO_WritePin(AD9854_D7_GPIO_Port, AD9854_D7_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)

#define AD9854_A0(x)  HAL_GPIO_WritePin(AD9854_A0_GPIO_Port, AD9854_A0_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)
#define AD9854_A1(x)  HAL_GPIO_WritePin(AD9854_A1_GPIO_Port, AD9854_A1_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)
#define AD9854_A2(x)  HAL_GPIO_WritePin(AD9854_A2_GPIO_Port, AD9854_A2_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)
#define AD9854_A3(x)  HAL_GPIO_WritePin(AD9854_A3_GPIO_Port, AD9854_A3_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)
#define AD9854_A4(x)  HAL_GPIO_WritePin(AD9854_A4_GPIO_Port, AD9854_A4_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)
#define AD9854_A5(x)  HAL_GPIO_WritePin(AD9854_A5_GPIO_Port, AD9854_A5_Pin, x ? GPIO_PIN_SET : GPIO_PIN_RESET)


#define AUTO 		1//自动扫频
#define MANUAL	0//FSK控制脚控制扫频

#define uint  unsigned int
#define uchar unsigned char
#define ulong unsigned long

//**************************以下部分为函数定义********************************

void AD9854_IO_Init(void);								//AD9854需要用到的IO口初始化
void AD9854_WR_Byte(uint32_t addr, uint32_t dat);		//AD9854并行口写数据
void Freq_convert(ulong Freq);	 						//正弦信号频率数据转换
void Freq_double_convert(double Freq);					//正弦信号频率数据转换,入口参数为double，可使信号的频率更精确

void AD9854_InitSingle(void);	      	  				//AD9854点频模式初始化
void AD9854_SetSine(ulong Freq,uint Shape);	 			//AD9854正弦波产生程序,频率为整数
void AD9854_SetSine_double(double Freq,uint Shape);		//AD9854正弦波产生程序,频率可为小数

void AD9854_InitFSK(void);								//AD9854的FSK模式初始化
void AD9854_SetFSK(ulong Freq1,ulong Freq2);			//AD9854的FSK参数设置

void AD9854_InitRFSK(uchar autoSweepEn);												//AD9854的RFSK模式初始化 线性调频模式即扫频	 
void AD9854_SetRFSK(ulong Freq_Low,ulong Freq_High,ulong Freq_Up_Down,ulong FreRate);	//AD9854的RFSK扫频参数设置	

void AD9854_InitChirp(void);													//AD9854的Chirp模式初始化
void AD9854_SetChirp(ulong Freq,uint Shape,ulong Freq_Up_Down,ulong FreRate);	//AD9854的Chirp扫频参数设置	

void AD9854_InitBPSK(void);												//AD9854的BPSK模式初始化			  
void AD9854_SetBPSK(ulong Freq,uint Shape,uint Phase1,uint Phase2);		//AD9854的BPSK参数设置

void AD9854_InitOSK(void);					 		//AD9854的OSK模式初始化
void AD9854_SetOSK(ulong Freq,uchar RateShape);		//AD9854的OSK参数设置


#endif	// #if USE_AD9854

#endif	// #ifndef __AD9854_PARALLEL_H

