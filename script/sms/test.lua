module(...,package.seeall)

--[[
��������
�յ����ź󣬶�ȡ�������ݺͺ��룬��ӡ����
Ȼ��ظ���ͬ�Ķ������ݸ����ͷ�
���ɾ���յ��Ķ���
]]

local function print(...)
	_G.print("test",...)
end

local function handle(num,data,datetime)
	print("handle",num,data,datetime)
	--�ظ���ͬ���ݵĶ��ŵ����ͷ�
	if num then sms.send(num,common.binstohexs(common.gb2312toucs2be(data))) end
end

local tnewsms = {}

local function readsms()
	if #tnewsms ~= 0 then
		sms.read(tnewsms[1])
	end
end

local function newsms(pos)
	table.insert(tnewsms,pos)
	if #tnewsms == 1 then
		readsms()
	end
end

--result�������bool����
--num�����ͷ����룬ASCII�ַ���
--data���������ݣ�unicode��˱����16�����ַ���
--pos���洢����
--datetime���������ں�ʱ��
--name�����ͷ������Ӧ����ϵ������
local function readcnf(result,num,data,pos,datetime,name)
	local d1,d2 = string.find(num,"^([%+]*86)")
	if d1 and d2 then
		num = string.sub(num,d2+1,-1)
	end
	sms.delete(tnewsms[1])
	table.remove(tnewsms,1)
	if data then
		data = common.ucs2betogb2312(common.hexstobins(data))
		handle(num,data,datetime)
	end
	readsms()
end

local function sendcnf(result)
	print("sendcnf",result)
end

local smsapp =
{
	SMS_NEW_MSG_IND = newsms, --�յ��¶��ţ�sms.lua���׳�SMS_NEW_MSG_IND��Ϣ
	SMS_READ_CNF = readcnf, --����sms.read��ȡ����֮��sms.lua���׳�SMS_READ_CNF��Ϣ
	SMS_SEND_CNF = sendcnf, --����sms.send���Ͷ���֮��sms.lua���׳�SMS_SEND_CNF��Ϣ
}

--ע����Ϣ������
sys.regapp(smsapp)
