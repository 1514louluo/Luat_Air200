--[[
ģ�����ƣ���GPSӦ�á�����
ģ�鹦�ܣ�����gpsapp.lua�Ľӿ�
ģ������޸�ʱ�䣺2017.02.16
]]

module(...,package.seeall)

--[[
��������print
����  ����ӡ�ӿڣ����ļ��е����д�ӡ�������gpsappǰ׺
����  ����
����ֵ����
]]
local function print(...)
	_G.print("testgps",...)
end

local function test1cb(cause)
	--gps.isfix()���Ƿ�λ�ɹ�
	--gps.getgpslocation()����γ����Ϣ
	print("test1cb",cause,gps.isfix(),gps.getgpslocation())
end

local function test2cb(cause)
	--gps.isfix()���Ƿ�λ�ɹ�
	--gps.getgpslocation()����γ����Ϣ
	print("test2cb",cause,gps.isfix(),gps.getgpslocation())
end

local function test3cb(cause)
	--gps.isfix()���Ƿ�λ�ɹ�
	--gps.getgpslocation()����γ����Ϣ
	print("test3cb",cause,gps.isfix(),gps.getgpslocation())
end

--���Դ��뿪�أ�ȡֵ1,2
local testidx = 1

--��1�ֲ��Դ���
if testidx==1 then
	--ִ�����������д����GPS�ͻ�һֱ��������Զ����ر�
	--��Ϊgpsapp.open(gpsapp.DEFAULT,{cause="TEST1",cb=test1cb})�����������û�е���gpsapp.close�ر�
	gpsapp.open(gpsapp.DEFAULT,{cause="TEST1",cb=test1cb})
	
	--10���ڣ����gps��λ�ɹ�������������test2cb��Ȼ���Զ��ر������GPSӦ�á�
	--10��ʱ�䵽��û�ж�λ�ɹ�������������test2cb��Ȼ���Զ��ر������GPSӦ�á�
	gpsapp.open(gpsapp.TIMERORSUC,{cause="TEST2",val=10,cb=test2cb})
	
	--300��ʱ�䵽������������test3cb��Ȼ���Զ��ر������GPSӦ�á�
	gpsapp.open(gpsapp.TIMER,{cause="TEST3",val=300,cb=test3cb})
--��2�ֲ��Դ���
elseif testidx==2 then
	gpsapp.open(gpsapp.DEFAULT,{cause="TEST1",cb=test1cb})
	sys.timer_start(gpsapp.close,30000,gpsapp.DEFAULT,{cause="TEST1"})
	gpsapp.open(gpsapp.TIMERORSUC,{cause="TEST2",val=10,cb=test2cb})
	gpsapp.open(gpsapp.TIMER,{cause="TEST3",val=60,cb=test3cb})	
end
