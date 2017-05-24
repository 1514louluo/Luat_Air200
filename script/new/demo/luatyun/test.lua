module(...,package.seeall)

require"luatyuniot"

local qos1cnt = 1

--[[
��������print
����  ����ӡ�ӿڣ����ļ��е����д�ӡ�������testǰ׺
����  ����
����ֵ����
]]
local function print(...)
	_G.print("test",...)
end

--[[
��������pubqos1testackcb
����  ������1��qosΪ1����Ϣ���յ�PUBACK�Ļص�����
����  ��
		usertag������mqttclient:publishʱ�����usertag
		result��true��ʾ�����ɹ���false����nil��ʾʧ��
����ֵ����
]]
local function pubqos1testackcb(usertag,result)
	print("pubqos1testackcb",usertag,result)
	sys.timer_start(pubqos1test,20000)
	qos1cnt = qos1cnt+1
end

--[[
��������pubqos1test
����  ������1��qosΪ1����Ϣ
����  ����
����ֵ����
]]
function pubqos1test()
	--ע�⣺�ڴ˴��Լ�ȥ����payload�����ݱ��룬luatyuniot���в����payload���������κα���ת��
	luatyuniot.publish("qos1data",1,pubqos1testackcb,"publish1test_"..qos1cnt)
end

--[[
��������rcvmessage
����  ���յ�PUBLISH��Ϣʱ�Ļص�����
����  ��
		topic����Ϣ���⣨gb2312���룩
		payload����Ϣ���أ�ԭʼ���룬�յ���payload��ʲô���ݣ�����ʲô���ݣ�û�����κα���ת����
		qos����Ϣ�����ȼ�
����ֵ����
]]
local function rcvmessagecb(topic,payload,qos)
	print("rcvmessagecb",topic,payload,qos)
end

--[[
��������connectedcb
����  ��MQTT CONNECT�ɹ��ص�����
����  ����		
����ֵ����
]]
local function connectedcb()
	print("connectedcb")
	--����һ��qosΪ1����Ϣ
	pubqos1test()
end

--ע��MQTT CONNECT�ɹ��ص����յ�PUBLISH��Ϣ�ص�
luatyuniot.regcb(connectedcb,rcvmessagecb)
--[[
local function getbase64bcdimei()
	if not base64bcdimei then
		local imei = "862990013106540"
		local imei1,imei2 = string.sub(imei,1,7),string.sub(imei,8,14)
		imei1,imei2 = string.format("%06X",tonumber(imei1)),string.format("%06X",tonumber(imei2))
		print(imei1..imei2)
		imei = common.hexstobins(imei1..imei2)
		base64bcdimei = crypto.base64_encode(imei,6)
		if string.sub(base64bcdimei,-1,-1)=="=" then base64bcdimei = string.sub(base64bcdimei,1,-2) end
		base64bcdimei = string.gsub(base64bcdimei,"+","-")
		base64bcdimei = string.gsub(base64bcdimei,"/","_")
		base64bcdimei = string.gsub(base64bcdimei,"=","@")
	end
	return base64bcdimei
end

print("862990013106540  �C>  "..getbase64bcdimei())
]]
