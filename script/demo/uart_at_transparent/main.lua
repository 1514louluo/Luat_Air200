PROJECT = "UART_AT_TRANSPARENT"
VERSION = "1.0.0"
require"sys"
require"ril"
require"uartat"

--��������ATC���ڹ���ģʽΪ͸��ģʽ
--����ATC�����յ����ݣ���ֱ�ӵ���uartat.write�ӿ�
--uartat.write�ӿڣ��������ATC�����յ�������ͨ������uartת��������
ril.setransparentmode(uartat.write)
sys.init(0,0)
sys.run()
