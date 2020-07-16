/**************************************************************************
***************************************************************************
	Notice: Some variable of Lcd_data = real_value * LCD_MULTIPLE
***************************************************************************
**************************************************************************/
struct Data{
    _fp32 total_heat;  //�ۼ�����, plus LCD_MULTIPLE
    _fp32 heat;        //�ȹ���, plus LCD_MULTIPLE  
    _fp32 temp1;       //��ˮ�¶�, plus LCD_MULTIPLE 
    _fp32 temp2;       //��ˮ�¶�, plus LCD_MULTIPLE 
    _fp32 temp0;      //�²�, plus LCD_MULTIPLE 
    _fp32 total_flow; //�ۼ�����, plus LCD_MULTIPLE 
    _fp32 flow;       //˲ʱ����, plus LCD_MULTIPLE 
    _u32 total_time;  //����ʱ��
    _u32 alarm_time;  //����ʱ��
    _u32 date;        //������
    _u32 time;        //ʱ����
    _u32 usercode;
    _fp32 version;
    _u32 history;
    _u32 lcdmode;  //A1_1;
    _u32 auto_caculate;
};
void LcdDisplay(struct Date_Time *Date_and_Time, struct Data *Lcd_data);

//---------------A1�˵�-------------
#define A1 1
#define A1_0 10   //��ʾA1

#define A1_1 11 
#define A1_1_0 (0x08+0x04) //'�ۻ����� '
#define A1_1_1 (0x10+0x20) //'KW*h'

#define A1_2 12      //һλС��
#define A1_2_0 (0x10) //'���� ' 
#define A1_2_1 (0x00) //

#define A1_3 13            //'T�� T��' һλС��
#define A1_3_0 (0x20) //'T��'
#define A1_3_1 (0x04) //'`C'

#define A1_4 14        //��λС��
#define A1_4_0 (0x02) //'�²� '
#define A1_4_1 (0x04) //'`C'

#define A1_5 15        //��λС��
#define A1_5_0 (0x08+0x01) //'�ۻ�����' 
#define A1_5_1 (0x02) //'m3' 

#define A1_6 16        //��λС��
#define A1_6_0 (0x01) //'˲ʱ���� '
#define A1_6_1 (0x02+0x01+0x80) //'m3/h'

#define A1_7 17
#define A1_7_0 (0x08+0x80) //'�ۻ�����ʱ��' 
#define A1_7_1 (0x80) //'h' 

#define A1_8 18
#define A1_8_0 (0x40) //'����ʱ��' 
#define A1_8_1 (0x80) //'h' 

//--------------A2�˵�-------------
#define A2 2
#define A2_0 20   //��ʾA2

#define A2_1 21 //������
#define A2_1_0 (0x80) //'ʱ��'
#define A2_1_1 (0x00) 

#define A2_2 22 //ʱ����
#define A2_2_0 (0x80) //'ʱ��'
#define A2_2_1 (0x00)

#define A2_3 23 //�û����
#define A2_3_0 (0x00) //
#define A2_3_1 (0x00)

#define A2_4 24 //�汾��
#define A2_4_0 (0x00) //
#define A2_4_1 (0x00)

#define A2_5 25 //�͵�ѹ'P6'
#define A2_5_0 (0x00) //
#define A2_5_1 (0x00)

#define A2_6 26 //��ȫ��

//--------------A3�˵�--------------
#define A3 3
#define A3_0 30   //��ʾA3

#define A3_1 31 //����
#define A3_1_0 (0x80) //'ʱ��'
#define A3_1_1 (0x00)

#define A3_2 32
#define A3_2_0 (0x08+0x01) //'�ۻ�����' 
#define A3_2_1 (0x02) //'m3' 

#define A3_3 33 
#define A3_3_0 (0x08+0x04) //'�ۼ����� '
#define A3_3_1 (0x10+0x20) //'KW*h'

//--------------A4�˵�--------------
#define A4 4
#define A4_0 40   //��ʾA4

#define A4_1 41        //��λС��
#define A4_1_0 (0x01) //'˲ʱ���� '
#define A4_1_1 (0x02+0x01+0x80+0x08) //'m3/h'+'�춨'

#define A4_2 42          //��λС��
#define A4_2_0 (0x08+0x01) //'�ۻ�����' 
#define A4_2_1 (0x02+0x08) //'m3'+'�춨'

#define A4_3 43 
#define A4_3_0 (0x10) //'���� '
#define A4_3_1 (0x00+0x08) // +'�춨'

#define A4_4 44             //��λС��
#define A4_4_0 (0x08+0x04) //'�ۻ����� '
#define A4_4_1 (0x10+0x20+0x08) //'KW*h'+'�춨'

#define A4_5 45            //'T�� T��' ��λС��
#define A4_5_0 (0x20) //'T��'
#define A4_5_1 (0x04+0x08) //'`C'+'�춨'

#define A4_6 46 
#define A4_6_0 (0x02) //'�²� '
#define A4_6_1 (0x04+0x08) //'`C'+'�춨'


