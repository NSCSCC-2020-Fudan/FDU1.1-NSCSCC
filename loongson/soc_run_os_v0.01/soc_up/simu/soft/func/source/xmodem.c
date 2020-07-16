/**********************************************************************************************************************************************************************
	This file uses xmodem to download code, then writes it into flash. 
**********************************************************************************************************************************************************************/

#include "../config.h"

static _u16 _crc_xmodem_update (_u16 crc, _u8 data)
{
    int i;
    crc = crc ^ ((_u16)data << 8);
    for (i=0; i<8; i++)
    {
        if (crc & 0x8000)
            crc = (crc << 1) ^ 0x1021;
        else
            crc <<= 1;
    }
    return crc;
}

//����Xmoden�����ַ�
#define XMODEM_NUL          0x00
#define XMODEM_SOH          0x01
#define XMODEM_STX          0x02
#define XMODEM_EOT          0x04
#define XMODEM_ACK          0x06
#define XMODEM_NAK          0x15
#define XMODEM_CAN          0x18
#define XMODEM_EOF          0x1A
#define XMODEM_WAIT_CHAR    'C'


#define ST_WAIT_START	0x00         //�ȴ�����
#define ST_BLOCK_OK	0x01         //����һ�����ݿ�ɹ�
#define ST_BLOCK_FAIL	0x02         //����һ�����ݿ�ʧ��
#define ST_OK		0x03         //���

#if LS1D_FPGA
static int testchar(unsigned int timeout)
{
	int total, start;
	start = now();

	while(1)
	{
		if(tgt_testchar()) return 100;
		if( (now()-start) > timeout ) break;  
	}

	return 0;
}
#else
static int testchar(unsigned int timeout)
{
	int total, start;
	//start = now();

	_u32 i,j;
	for(i=1000;i>0;i--)
		for(j=500;j>0;j--)
	//while(1)
	{
		if(tgt_testchar()) return 100;
		//if( ((now()-start)%COUNT_COMPARE) > timeout ) break;  
	}

	return 0;
}
#endif
static int get_data(unsigned char *ptr,unsigned int len,unsigned int timeout)
{
	int i=0;
	while(i<len)
	{
		if(testchar(timeout)>0)
			ptr[i++] = tgt_getchar();
		else break;   //It doesn't receive data in 1 second.
	}

	return i;
}
//����CRC16
static unsigned int calcrc(unsigned char *ptr, unsigned int count, _u8 crc_mode)
{
	_u16 crc = 0;
	while (count--)
	{
		if(crc_mode)
			crc = _crc_xmodem_update(crc,*ptr++);
		else
		{
			crc += *ptr++ ;
			crc &= 0xff;
		}
	}

	return crc;
}

static int xmodem_transfer(_u32 base)
{
	unsigned int i;
	_u16 crc;
	unsigned int filesize=0;
	unsigned char BlockCount=1;               //���ݿ��ۼ�(��8λ�����뿼�����)
	_u8 crc_mode = 1;
	_u8 chr;
#if LS1D_FPGA
	_u32 addr_w = base;
	_u32 length = 128;
#endif
	unsigned char STATUS;                  //����״̬
        STATUS = ST_WAIT_START;               //��������='d'��'D',����XMODEM
	while(1)
	{	
		chr = crc_mode?XMODEM_WAIT_CHAR:XMODEM_NAK ;
		tgt_putchar(chr);
		if(testchar(80)>0)break;   //5 seconds timeout
		crc_mode += 1;
		crc_mode %= 2;
	}   //send 'c' first, if there is no respond, then send NAK.

	struct str_XMODEM strXMODEM;      //XMODEM�Ľ������ݽṹ
	while(STATUS!=ST_OK)                  //ѭ�����գ�ֱ��ȫ������
	{
/**********************************************************************************************************************************************************************************************************************************************************************************************************************************************/
		i = get_data(&strXMODEM.SOH, BLOCKSIZE+5, 1);   // 1/16 second timeout, it'll affect the total time of download.

/**********************************************************************************************************************************************************************************************************************************************************************************************************************************************/
		if(i)
		{
			//�������ݰ��ĵ�һ������ SOH/EOT/CAN
			switch(strXMODEM.SOH)
			{
				case XMODEM_SOH:			   //�յ���ʼ��SOH
					if (i>=(crc_mode?(BLOCKSIZE+5):(BLOCKSIZE+4)))
					{
						STATUS=ST_BLOCK_OK;
					}
					else
					{
						STATUS=ST_BLOCK_FAIL;	  //������ݲ��㣬Ҫ���ط���ǰ���ݿ�
						tgt_putchar(XMODEM_NAK);
					}
					break;
				case XMODEM_EOT:			   //�յ�������EOT
					tgt_putchar(XMODEM_ACK);			//֪ͨPC��ȫ���յ�
					STATUS=ST_OK;
					break;
				case XMODEM_CAN:			   //�յ�ȡ����CAN
					tgt_putchar(XMODEM_ACK);			//��ӦPC��
					STATUS=ST_OK;
					break;
				default:					 //��ʼ�ֽڴ���
					tgt_putchar(XMODEM_NAK);			//Ҫ���ط���ǰ���ݿ�
					STATUS=ST_BLOCK_FAIL;
					break;
			}
		}
		else 
		{
			break;
			//tgt_putchar(XMODEM_NAK);			//���ݿ��Ŵ���Ҫ���ط���ǰ���ݿ�
			//continue;
		}

		if (STATUS==ST_BLOCK_OK)			//����133�ֽ�OK������ʼ�ֽ���ȷ
		{
			if (BlockCount != strXMODEM.BlockNo)//�˶����ݿ�����ȷ
			{
				tgt_putchar(XMODEM_NAK);			//���ݿ��Ŵ���Ҫ���ط���ǰ���ݿ�
				continue;
			}
			if (BlockCount !=(unsigned char)(~strXMODEM.nBlockNo))
			{
				tgt_putchar(XMODEM_NAK);			//���ݿ��ŷ������Ҫ���ط���ǰ���ݿ�
				continue;
			}

			if(crc_mode)
			{
				crc = strXMODEM.CRC16hi<<8;
				crc += strXMODEM.CRC16lo;
			}
			else
			{
				crc = strXMODEM.CRC16hi;
			}

			if(calcrc(&strXMODEM.Xdata[0], BLOCKSIZE, crc_mode)!=crc)
			{
				tgt_putchar(XMODEM_NAK);			  //CRC����Ҫ���ط���ǰ���ݿ�
				continue;
			}

#if LS1D_FPGA
			_u32 addr_r = (_u32)&strXMODEM.Xdata[0];
			spiflash_write(addr_w, addr_r, length);
			addr_w += length;
#else
			//Flash_Write(base+filesize, &buf[0],32) ;
#endif

			filesize += 128;
			tgt_putchar(XMODEM_ACK);				 //��Ӧ����ȷ�յ�һ�����ݿ�
			BlockCount++;					   //���ݿ��ۼƼ�1
		}
	}

	//printf("xmodem finished\n");

	return filesize;
}


_u32 xmodem()
{
	_u32 base = FLASH_ERASE_START;
	int file_size;

	//printf("Waiting for serial transmitting datas...\n");
#if LS1D_FPGA
	_u32 addr_start = FLASH_ERASE_START;
	_u32 addr_end = FLASH_ERASE_END;
	spiflash_erase(addr_start, addr_end);
#endif
	file_size = xmodem_transfer(base);
	//printf("Load successfully! Start at 0x%x, size 0x%x\n", base, file_size);

	return 0; 
}


