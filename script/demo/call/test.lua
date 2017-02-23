module(...,package.seeall)

--[[
��������
1����������������룬�Զ��ܽ�
2����ż����������룬�Զ�������������10���ӣ����ͨ����Ȼ���ڣ��������Ҷ�
3������1���Ӻ���������10086����ͨ��10���ӣ����ͨ����Ȼ���ڣ��������Ҷ�
]]


local incomingIdx = 1

local function print(...)
	_G.print("test",...)
end

local function connected(id)
	print("connected:"..(id or "nil"))
	sys.timer_start(cc.hangup,10000,"AUTO_DISCONNECT")
end

local function disconnected(id)
	print("disconnected:"..(id or "nil"))
	sys.timer_stop(cc.hangup,"AUTO_DISCONNECT")
end

local function incoming(id)
	print("incoming:"..(id or "nil"))
	if incomingIdx%2==0 then
		cc.accept()
	else
		cc.hangup()
	end	
	incomingIdx = incomingIdx+1
end

local procer =
{
	CALL_INCOMING = incoming, --����ʱ��lib�е�cc.lua�����sys.dispatch�ӿ��׳�CALL_INCOMING��Ϣ
	CALL_DISCONNECTED = disconnected,	--ͨ��������lib�е�cc.lua�����sys.dispatch�ӿ��׳�CALL_DISCONNECTED��Ϣ
}

--�������д�����ע����Ϣ�����������ַ�ʽ
--���ߵ���������Ϣ���������յ��Ĳ�����ͬ
--��һ�ַ�ʽ�ĵ�һ����������ϢID
--�ڶ��ַ�ʽ�ĵ�һ����������ϢID����Զ������
--��ο�incoming��connected��disconnected�еĴ�ӡ
sys.regapp(connected,"CALL_CONNECTED") --����ͨ����lib�е�cc.lua�����sys.dispatch�ӿ��׳�CALL_CONNECTED��Ϣ
sys.regapp(procer)

--����mic����
audio.setmicrophonegain(7)

--1���Ӻ����10086
sys.timer_start(cc.dial,60000,"10086")

