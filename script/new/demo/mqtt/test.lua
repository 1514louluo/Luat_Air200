require"misc"
require"mqtt"
module(...,package.seeall)

local ssub,schar,smatch,sbyte,slen = string.sub,string.char,string.match,string.byte,string.len
--测试时请搭建自己的服务器
local PROT,ADDR,PORT = "TCP","lbsmqtt.airm2m.com",1884
local mqttclient


--[[
函数名：print
功能  ：打印接口，此文件中的所有打印都会加上test前缀
参数  ：无
返回值：无
]]
local function print(...)
	_G.print("test",...)
end

local qos0cnt,qos1cnt = 1,1

--[[
函数名：pubqos0testsndcb
功能  ：“发布1条qos为0的消息”发送结果的回调函数
参数  ：
		usertag：调用mqttclient:publish时传入的usertag
		result：true表示发送成功，false或者nil发送失败
返回值：无
]]
local function pubqos0testsndcb(usertag,result)
	print("pubqos0testsndcb",usertag,result)
	sys.timer_start(pubqos0test,10000)
	qos0cnt = qos0cnt+1
end

--[[
函数名：pubqos0test
功能  ：发布1条qos为0的消息
参数  ：无
返回值：无
]]
function pubqos0test()
	mqttclient:publish("/qos0topic","qos0data",0,pubqos0testsndcb,"publish0test_"..qos0cnt)
end

--[[
函数名：pubqos1testackcb
功能  ：发布1条qos为1的消息后收到PUBACK的回调函数
参数  ：
		usertag：调用mqttclient:publish时传入的usertag
		result：true表示发布成功，false或者nil表示失败
返回值：无
]]
local function pubqos1testackcb(usertag,result)
	print("pubqos1testackcb",usertag,result)
	sys.timer_start(pubqos1test,20000)
	qos1cnt = qos1cnt+1
end

--[[
函数名：pubqos1test
功能  ：发布1条qos为1的消息
参数  ：无
返回值：无
]]
function pubqos1test()
	mqttclient:publish("/qos1topic","qos1data",1,pubqos1testackcb,"publish1test_"..qos1cnt)
end

--[[
函数名：subackcb
功能  ：MQTT SUBSCRIBE之后收到SUBACK的回调函数
参数  ：
		usertag：调用mqttclient:subscribe时传入的usertag
		result：true表示订阅成功，false或者nil表示失败
返回值：无
]]
local function subackcb(usertag,result)
	print("subackcb",usertag,result)
end

--[[
函数名：rcvmessage
功能  ：收到PUBLISH消息时的回调函数
参数  ：
		topic：消息主题
		payload：消息负载
		qos：消息质量等级
返回值：无
]]
local function rcvmessagecb(topic,payload,qos)
	print("rcvmessagecb",topic,payload,qos)
end

--[[
函数名：connectedcb
功能  ：MQTT CONNECT成功回调函数
参数  ：无		
返回值：无
]]
local function connectedcb()
	print("connectedcb")
	--订阅主题
	mqttclient:subscribe({{topic="/event0",qos=0}, {topic="/event1",qos=1}}, subackcb, "subscribetest")
	--注册事件的回调函数，MESSAGE事件表示收到了PUBLISH消息
	mqttclient:regevtcb({MESSAGE=rcvmessagecb})
	--发布一条qos为0的消息
	pubqos0test()
	--发布一条qos为1的消息
	pubqos1test()
end

--[[
函数名：connecterrcb
功能  ：MQTT CONNECT失败回调函数
参数  ：
		r：失败原因值
			1：Connection Refused: unacceptable protocol version
			2：Connection Refused: identifier rejected
			3：Connection Refused: server unavailable
			4：Connection Refused: bad user name or password
			5：Connection Refused: not authorized
返回值：无
]]
local function connecterrcb(r)
	print("connecterrcb",r)
end

--[[
函数名：imeirdy
功能  ：IMEI读取成功，成功后，才去创建mqtt client，连接服务器，因为用到了IMEI号
参数  ：无		
返回值：无
]]
local function imeirdy()
	--创建一个mqtt client
	mqttclient = mqtt.create(PROT,ADDR,PORT)
	--连接mqtt服务器
	mqttclient:connect(misc.getimei(),600,"user","password",connectedcb,connecterrcb)
end

local procer =
{
	IMEI_READY = imeirdy,
}
--注册消息的处理函数
sys.regapp(procer)
