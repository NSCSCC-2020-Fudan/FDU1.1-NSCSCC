void MonthData(struct Date_Time *Date_and_Time, struct Data *Lcd_data);
void Flash_Read_Info();
void Flash_Write_Test();
extern _u32 Last_month_num; 

#define CHRWRITE 0
#define BLKWRITE 1
struct Record_0{
  _u32 Date;  /*����������Ϣ��Date = Year*1000 + Month*10, ����2011.10,��Date = 20110100 */
  _u32 TotalHeat;  //xxxxxx.xx, plus 100 
  _u32 TotalFlow;  //xxxxxx.xx, plus 100 
};

struct Record_1{
  _u32 Date;  /*������������Ϣ��Date = Year*10000 + Month*100 + Day, ����2011.10.12,��Date = 20111012 */
  _u32 Time;   /*����ʱ����Ϣ��Time = Hour*100 + Minute, ����9��30����Time = 930 */
  _fp32 TotalHeat;
  _fp32 TotalFlow;  
  _u32 WorkTime;
  _u32 ErrTime;
};
extern struct Record_1 Latest_Record;

