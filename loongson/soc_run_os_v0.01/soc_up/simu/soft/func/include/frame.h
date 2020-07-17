
#define ERROR 1
#define DATA_LENGTH 100

extern _u32 RX_IndexW;
void IrSend(_u8 *str);
void uart_tx();
void uart_rx();
void Frame_exe(struct Date_Time *Date_and_Time, struct Data *Lcd_data);

union uint_uchar{
    _u32 i_value;
    _u8 c_value[4];
};

/*-----------------Э���ֶ�-----------------*/
struct FrameFormat{
  _u8 HeadCode;
  _u8 TypeCode;
  _u8 Address[7];
  _u8 CtrlCode;
  _u8 DataLen;
  _u8 DI0,DI1,SER;
  _u8 Data[DATA_LENGTH];
  _u8 CheckSum;
  _u8 TailCode;
};

/****************����д*****************/
struct ModifyData{
    _u8 seg;  //�����κ�
    _u32 flowpoint;   //���������㣬ʹ��ʱҪ����10��xxxxx.x
    _u8 danwei;   //������λ
    _u32 flowdata;   //��׼�������ݣ�ʹ��ʱҪ����1000��xxx.xxx
    _u32 rcode;   //����ȵ�����
    _u32 temp;   //�궨�¶�ֵ
    _u32 rdata;   //�ȵ�����ֵ��ʹ��ʱҪ����100��xxxx.xx
    _u32 tempmodify;   //�¶�����ϵ����ʹ��ʱҪ����100000��x.xxxxx
};




