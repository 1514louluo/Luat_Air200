module(...,package.seeall)

--[[
此例子为短连接，发送数据后，进入飞行模式，然后定时退出飞行模式再发送数据，如此循环
功能需求：
1、连接后台发送位置包"loc data\r\n"到后台，超时时间为2分钟，2分钟内如果失败，会一直重试，发送成功或者超时后都进入飞行模式；
2、进入飞行模式5分钟后，退出飞行模式，然后继续第1步
循环以上2个步骤
2、收到后台的数据时，在rcv函数中打印出来
测试时请搭建自己的服务器，并且修改下面的PROT，ADDR，PORT 
]]

local ssub,schar,smatch,sbyte = string.sub,string.char,string.match,string.byte
--测试时请搭建自己的服务器
local SCK_IDX,PROT,ADDR,PORT = 1,"TCP","www.test.com",6500
--每次连接后台，会有如下异常处理
--一个连接周期内的动作：如果连接后台失败，会尝试重连，重连间隔为RECONN_PERIOD秒，最多重连RECONN_MAX_CNT次
--如果一个连接周期内都没有连接成功，则等待RECONN_CYCLE_PERIOD秒后，重新发起一个连接周期
--如果连续RECONN_CYCLE_MAX_CNT次的连接周期都没有连接成功，则重启软件
local RECONN_MAX_CNT,RECONN_PERIOD,RECONN_CYCLE_MAX_CNT,RECONN_CYCLE_PERIOD = 3,5,1,20
--reconncnt:当前连接周期内，已经重连的次数
--reconncyclecnt:连续多少个连接周期，都没有连接成功
--一旦连接成功，都会复位这两个标记
--reconning:是否在尝试连接中
local reconncnt,reconncyclecnt,conning = 0,0

--[[
函数名：print
功能  ：打印接口，此文件中的所有打印都会加上test前缀
参数  ：无
返回值：无
]]
local function print(...)
	_G.print("test",...)
end

--[[
函数名：snd
功能  ：调用发送接口发送数据
参数  ：
        data：发送的数据，在发送结果事件处理函数ntfy中，会赋值到item.data中
		para：发送的参数，在发送结果事件处理函数ntfy中，会赋值到item.para中 
返回值：调用发送接口的结果（并不是数据发送是否成功的结果，数据发送是否成功的结果在ntfy中的SEND事件中通知），true为成功，其他为失败
]]
function snd(data,para)
	return linkapp.scksnd(SCK_IDX,data,para)
end


--[[
函数名：locrptimeout
功能  ：位置包数据发送超时处理，直接进入飞行模式
参数  ：无  
返回值：无
]]
local function locrptimeout()
	print("locrptimeout")
	locrptcb(true)
end

--[[
函数名：locrpt
功能  ：发送位置包数据到后台
参数  ：无 
返回值：无
]]
function locrpt()
	print("locrpt")	
	--调用发送接口成功，并不是数据发送成功，数据发送是否成功，在ntfy中的SEND事件中通知
	if snd("loc data\r\n","LOCRPT")	then
		--设置2分钟定时器，如果超时2分钟数据都没有发送成功，则直接进入飞行模式
		sys.timer_start(locrptimeout,120000)
	--调用发送接口失败，做重连处理
	else
		locrptcb()
	end	
end

--[[
函数名：locrptcb
功能  ：位置包发送结果处理，发送成功或者超时，都会进入飞行模式，启动5分钟的“退出飞行模式，连接后台”定时器
参数  ：  
        result： bool类型，发送结果或者是否超时，true为成功或者超时，其他为失败
		item：table类型，{data=,para=}，消息回传的参数和数据，例如调用linkapp.scksnd时传入的第2个和第3个参数分别为dat和par，则item={data=dat,para=par}
返回值：无
]]
function locrptcb(result,item)
	print("locrptcb",result)
	if result then
		linkapp.sckdisc(SCK_IDX)
		link.shut()
		misc.setflymode(true)
		sys.timer_start(connect,300000)
		sys.timer_stop(locrptimeout)
	else
		sys.timer_start(reconn,RECONN_PERIOD*1000)
	end
end

--[[
函数名：sndcb
功能  ：发送数据结果事件的处理
参数  ：  
        result： bool类型，消息事件结果，true为成功，其他为失败
		item：table类型，{data=,para=}，消息回传的参数和数据，例如调用linkapp.scksnd时传入的第2个和第3个参数分别为dat和par，则item={data=dat,para=par}
返回值：无
]]
local function sndcb(item,result)
	print("sndcb",item.para,result)
	if not item.para then return end
	if item.para=="LOCRPT" then
		locrptcb(result,item)
	end	
end

--[[
函数名：reconn
功能  ：重连后台处理
        一个连接周期内的动作：如果连接后台失败，会尝试重连，重连间隔为RECONN_PERIOD秒，最多重连RECONN_MAX_CNT次
        如果一个连接周期内都没有连接成功，则等待RECONN_CYCLE_PERIOD秒后，重新发起一个连接周期
        如果连续RECONN_CYCLE_MAX_CNT次的连接周期都没有连接成功，则重启软件
参数  ：无
返回值：无
]]
function reconn()
	print("reconn",reconncnt,conning,reconncyclecnt)
	--conning表示正在尝试连接后台，一定要判断此变量，否则有可能发起不必要的重连，导致reconncnt增加，实际的重连次数减少
	if conning then return end
	--一个连接周期内的重连
	if reconncnt < RECONN_MAX_CNT then		
		reconncnt = reconncnt+1
		link.shut()
		connect()
	--一个连接周期的重连都失败
	else
		reconncnt,reconncyclecnt = 0,reconncyclecnt+1
		if reconncyclecnt >= RECONN_CYCLE_MAX_CNT then
			dbg.restart("connect fail")
		end
		sys.timer_start(reconn,RECONN_CYCLE_PERIOD*1000)
	end
end

--[[
函数名：ntfy
功能  ：socket状态的处理函数
参数  ：
        idx：number类型，linkapp中维护的socket idx，跟调用linkapp.sckconn时传入的第一个参数相同，程序可以忽略不处理
        evt：string类型，消息事件类型
		result： bool类型，消息事件结果，true为成功，其他为失败
		item：table类型，{data=,para=}，消息回传的参数和数据，目前只是在SEND类型的事件中用到了此参数，例如调用linkapp.scksnd时传入的第2个和第3个参数分别为dat和par，则item={data=dat,para=par}
返回值：无
]]
function ntfy(idx,evt,result,item)
	print("ntfy",evt,result,item)
	--连接结果
	if evt == "CONNECT" then
		conning = false
		--连接成功
		if result then
			reconncnt,reconncyclecnt = 0,0
			--停止重连定时器
			sys.timer_stop(reconn)			
			--发送位置包到后台
			locrpt()
		--连接失败
		else
			--RECONN_PERIOD秒后重连
			sys.timer_start(reconn,RECONN_PERIOD*1000)
		end	
	--数据发送结果
	elseif evt == "SEND" then
		if item then
			sndcb(item,result)
		end
	--连接被动断开或者调用link.shut后
	elseif evt == "STATE" and result == "CLOSED" then

	--连接主动断开
	elseif evt == "DISCONNECT" then
			
	end
	--其他错误处理
	if smatch((type(result)=="string") and result or "","ERROR") then
		--RECONN_PERIOD秒后重连
		sys.timer_start(reconn,RECONN_PERIOD*1000)
	end
end

--[[
函数名：rcv
功能  ：socket接收数据的处理函数
参数  ：
        idx ：linkapp中维护的socket idx，跟调用linkapp.sckconn时传入的第一个参数相同，程序可以忽略不处理
        data：接收到的数据
返回值：无
]]
function rcv(idx,data)
	print("rcv",data)
end

--[[
函数名：connect
功能  ：创建到后台服务器的连接；
        如果数据网络已经准备好，会理解连接后台；否则，连接请求会被挂起，等数据网络准备就绪后，自动去连接后台
		ntfy：socket状态的处理函数
		rcv：socket接收数据的处理函数
参数  ：无
返回值：无
]]
function connect()
	misc.setflymode(false)
	linkapp.sckconn(SCK_IDX,linkapp.NORMAL,PROT,ADDR,PORT,ntfy,rcv)
	conning = true
end

connect()
