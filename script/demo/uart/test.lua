module(...,package.seeall)

--[[
��������
uart����֡�ṹ������Χ�豸�����룬�յ���ȷ��ָ��󣬻ظ�ASCII�ַ���

֡�ṹ���£�
֡ͷ��1�ֽڣ�0x01��ʾɨ��ָ�0x02��ʾ����GPIO���0x03��ʾ���ƶ˿�����
֡�壺�ֽڲ��̶�����֡ͷ�й�
֡β��1�ֽڣ��̶�Ϊ0xC0

�յ���ָ��֡ͷΪ0x01ʱ���ظ�"CMD_SCANNER\r\n"����Χ�豸
�յ���ָ��֡ͷΪ0x02ʱ���ظ�"CMD_GPIO\r\n"����Χ�豸
�յ���ָ��֡ͷΪ0x03ʱ���ظ�"CMD_PORT\r\n"����Χ�豸
�յ���ָ��֡ͷΪ��������ʱ���ظ�"CMD_ERROR\r\n"����Χ�豸
]]



local UART_ID = 1
local CMD_SCANNER,CMD_GPIO,CMD_PORT,FRM_TAIL = 1,2,3,string.char(0xC0)
local rdbuf = ""

local function print(...)
	_G.print("test",...)
end

local function parse(data)
	if not data then return end	
	
	local tail = string.find(data,string.char(0xC0))
	if not tail then return false,data end	
	local cmdtyp = string.byte(data,1)
	local body,result = string.sub(data,2,tail-1)
	
	print("parse",common.binstohexs(data),cmdtyp,common.binstohexs(body))
	
	if cmdtyp == CMD_SCANNER then
		write("CMD_SCANNER")
	elseif cmdtyp == CMD_GPIO then
		write("CMD_GPIO")
	elseif cmdtyp == CMD_PORT then
		write("CMD_PORT")
	else
		write("CMD_ERROR")
	end
	
	return true,string.sub(data,tail+1,-1)	
end

--��ο��������󣬷����˺���
local function proc(data)
	if not data or string.len(data) == 0 then return end
	rdbuf = rdbuf..data	
	
	local result,unproc
	unproc = rdbuf
	while true do
		result,unproc = parse(unproc)
		if not unproc or unproc == "" or not result then
			break
		end
	end

	rdbuf = unproc or ""
end

--�ײ�core�У������յ�����ʱ��
--������ջ�����Ϊ�գ�������жϷ�ʽ֪ͨLua�ű��յ��������ݣ�
--������ջ�������Ϊ�գ��򲻻�֪ͨLua�ű�
--����Lua�ű����յ��ж϶���������ʱ��ÿ�ζ�Ҫ�ѽ��ջ������е�����ȫ���������������ܱ�֤�ײ�core�е��������ж���������read�����е�while����оͱ�֤����һ��
local function read()
	local data = ""
	while true do		
		data = uart.read(UART_ID,"*l",0)
		if not data or string.len(data) == 0 then break end
		print("read",data,common.binstohexs(data))
		proc(data)
	end
end

--ͨ�����ڷ������ݵ���Χ�豸
function write(s)
	print("write",s)
	uart.write(UART_ID,s.."\r\n")	
end

--����ϵͳ���ڻ���״̬���˴�ֻ��Ϊ�˲�����Ҫ�����Դ�ģ��û�еط�����pm.sleep("test")���ߣ��������͹�������״̬
--�ڿ�����Ҫ�󹦺ĵ͡�����Ŀʱ��һ��Ҫ��취��֤pm.wake("test")���ڲ���Ҫ����ʱ����pm.sleep("test")
pm.wake("test")
--ע�ᴮ�ڵ����ݽ��պ����������յ����ݺ󣬻����жϷ�ʽ������read�ӿڶ�ȡ����
sys.reguart(UART_ID,read)
--���ò��Ҵ򿪴���
uart.setup(UART_ID,115200,8,uart.PAR_NONE,uart.STOP_1,2)


