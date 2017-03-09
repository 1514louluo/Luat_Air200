--[[
ģ�����ƣ���GPSӦ�á�����
ģ�鹦�ܣ�����GPS��������������GPSӦ�á��Ĵ򿪺͹ر�
ģ������޸�ʱ�䣺2017.02.16
]]

module(...,package.seeall)
require"gps"
require"agps"

--��GPSӦ�á���ָ����ʹ��GPS���ܵ�һ��Ӧ��
--���磬����������3������Ҫ��GPS����һ����3����GPSӦ�á���
--��GPSӦ��1����ÿ��1���Ӵ�һ��GPS
--��GPSӦ��2�����豸������ʱ��GPS
--��GPSӦ��3�����յ�һ���������ʱ��GPS
--ֻ�����С�GPSӦ�á����ر��ˣ��Ż�ȥ�����ر�GPS

--[[
ÿ����GPSӦ�á��򿪻��߹ر�GPSʱ�������4������������ GPS����ģʽ�͡�GPSӦ�á���� ��ͬ������һ��Ψһ�ġ�GPSӦ�á���
1��GPS����ģʽ(��ѡ)
2����GPSӦ�á����(��ѡ)
3��GPS�������ʱ��[��ѡ]
4���ص�����[��ѡ]
����gpsapp.open(gpsapp.TIMERORSUC,{cause="TEST",val=120,cb=testgpscb})
gpsapp.TIMERORSUCΪGPS����ģʽ��"TEST"Ϊ��GPSӦ�á���ǣ�120��ΪGPS�������ʱ����testgpscbΪ�ص�����
]]


--[[
GPS����ģʽ����������3��
1��DEFAULT
   (1)���򿪺�GPS��λ�ɹ�ʱ������лص�����������ûص�����
   (2)��ʹ�ô˹���ģʽ����gpsapp.open�򿪵ġ�GPSӦ�á����������gpsapp.close���ܹر�
2��TIMERORSUC
   (1)���򿪺������GPS�������ʱ������ʱ��û�ж�λ�ɹ�������лص�����������ûص�������Ȼ���Զ��رմˡ�GPSӦ�á�
   (2)���򿪺������GPS�������ʱ���ڣ���λ�ɹ�������лص�����������ûص�������Ȼ���Զ��رմˡ�GPSӦ�á�
   (3)���򿪺����Զ��رմˡ�GPSӦ�á�ǰ�����Ե���gpsapp.close�����رմˡ�GPSӦ�á��������ر�ʱ����ʹ�лص�������Ҳ������ûص�����
3��TIMER
   (1)���򿪺���GPS�������ʱ��ʱ�䵽��ʱ�������Ƿ�λ�ɹ�������лص�����������ûص�������Ȼ���Զ��رմˡ�GPSӦ�á�
   (2)���򿪺����Զ��رմˡ�GPSӦ�á�ǰ�����Ե���gpsapp.close�����رմˡ�GPSӦ�á��������ر�ʱ����ʹ�лص�������Ҳ������ûص�����
]]
DEFAULT,TIMERORSUC,TIMER = 0,1,2

--��GPSӦ�á���
local tlist = {}

--[[
��������print
����  ����ӡ�ӿڣ����ļ��е����д�ӡ�������gpsappǰ׺
����  ����
����ֵ����
]]
local function print(...)
	_G.print("gpsapp",...)
end

--[[
��������delitem
����  ���ӡ�GPSӦ�á�����ɾ��һ�GPSӦ�á���������������ɾ����ֻ������һ����Ч��־
����  ��
		mode��GPS����ģʽ
		para��
			para.cause����GPSӦ�á����
			para.val��GPS�������ʱ��
			para.cb���ص�����
����ֵ����
]]
local function delitem(mode,para)
	local i
	for i=1,#tlist do
		--��־��Ч ���� GPS����ģʽ��ͬ ���� ��GPSӦ�á������ͬ
		if tlist[i].flag and tlist[i].mode == mode and tlist[i].para.cause == para.cause then
			--������Ч��־
			tlist[i].flag,tlist[i].delay = false
			break
		end
	end
end

--[[
��������additem
����  ������һ�GPSӦ�á�����GPSӦ�á���
����  ��
		mode��GPS����ģʽ
		para��
			para.cause����GPSӦ�á����
			para.val��GPS�������ʱ��
			para.cb���ص�����
����ֵ����
]]
local function additem(mode,para)
	--ɾ����ͬ�ġ�GPSӦ�á�
	delitem(mode,para)
	local item,i,fnd = {flag = true, mode = mode, para = para}
	--�����TIMERORSUC����TIMERģʽ����ʼ��GPS����ʣ��ʱ��
	if mode == TIMERORSUC or mode == TIMER then item.para.remain = para.val end
	for i=1,#tlist do
		--���������Ч�ġ�GPSӦ�á��ֱ��ʹ�ô�λ��
		if not tlist[i].flag then
			tlist[i] = item
			fnd = true
			break
		end
	end
	--����һ��
	if not fnd then table.insert(tlist,item) end
end

local function isexisttimeritem()
	local i
	for i=1,#tlist do
		if tlist[i].flag and (tlist[i].mode == TIMERORSUC or tlist[i].mode == TIMER or tlist[i].para.delay) then return true end
	end
end

local function timerfunc()
	local i
	for i=1,#tlist do
		print("timerfunc@"..i,tlist[i].flag,tlist[i].mode,tlist[i].para.cause,tlist[i].para.val,tlist[i].para.remain,tlist[i].para.delay,tlist[i].para.cb)
		if tlist[i].flag then
			local rmn,dly,md,cb = tlist[i].para.remain,tlist[i].para.delay,tlist[i].mode,tlist[i].para.cb
			if rmn and rmn > 0 then
				tlist[i].para.remain = rmn - 1
			end
			if dly and dly > 0 then
				tlist[i].para.delay = dly - 1
			end
			
			rmn = tlist[i].para.remain
			if gps.isfix() and md == TIMER and rmn == 0 and not tlist[i].para.delay then
				tlist[i].para.delay = 1
			end
			
			dly = tlist[i].para.delay
			if gps.isfix() then
				if dly and dly == 0 then
					if cb then cb(tlist[i].para.cause) end
					if md == DEFAULT then
						tlist[i].para.delay = nil
					else
						close(md,tlist[i].para)
					end
				end
			else
				if rmn and rmn == 0 then
					if cb then cb(tlist[i].para.cause) end
					close(md,tlist[i].para)
				end
			end			
		end
	end
	if isexisttimeritem() then sys.timer_start(timerfunc,1000) end
end

--[[
��������gpsstatind
����  ������GPS��λ�ɹ�����Ϣ
����  ��
		id��GPS��Ϣid
		evt��GPS��Ϣ����
����ֵ����
]]
local function gpsstatind(id,evt)
	--��λ�ɹ�����Ϣ
	if evt == gps.GPS_LOCATION_SUC_EVT then
		local i
		for i=1,#tlist do
			print("gpsstatind@"..i,tlist[i].flag,tlist[i].mode,tlist[i].para.cause,tlist[i].para.val,tlist[i].para.remain,tlist[i].para.delay,tlist[i].para.cb)
			if tlist[i].flag then
				if tlist[i].mode ~= TIMER then
					tlist[i].para.delay = 1
					if tlist[i].mode == DEFAULT then
						if isexisttimeritem() then sys.timer_start(timerfunc,1000) end
					end
				end				
			end			
		end
	end
	return true
end

--[[
��������forceclose
����  ��ǿ�ƹر����С�GPSӦ�á�
����  ����
����ֵ����
]]
function forceclose()
	local i
	for i=1,#tlist do
		if tlist[i].flag and tlist[i].para.cb then tlist[i].para.cb(tlist[i].para.cause) end
		close(tlist[i].mode,tlist[i].para)
	end
end

--[[
��������close
����  ���ر�һ����GPSӦ�á�
����  ��
		mode��GPS����ģʽ
		para��
			para.cause����GPSӦ�á����
			para.val��GPS�������ʱ��
			para.cb���ص�����
����ֵ����
]]
function close(mode,para)
	assert((para and type(para) == "table" and para.cause and type(para.cause) == "string"),"gpsapp.close para invalid")
	print("ctl close",mode,para.cause,para.val,para.cb)
	--ɾ���ˡ�GPSӦ�á�
	delitem(mode,para)
	local valid,i
	for i=1,#tlist do
		if tlist[i].flag then
			valid = true
		end		
	end
	--���û��һ����GPSӦ�á���Ч����ر�GPS
	if not valid then gps.closegps("gpsapp") end
end

--[[
��������open
����  ����һ����GPSӦ�á�
����  ��
		mode��GPS����ģʽ
		para��
			para.cause����GPSӦ�á����
			para.val��GPS�������ʱ��
			para.cb���ص�����
����ֵ����
]]
function open(mode,para)
	assert((para and type(para) == "table" and para.cause and type(para.cause) == "string"),"gpsapp.open para invalid")
	print("ctl open",mode,para.cause,para.val,para.cb)
	--���GPS��λ�ɹ�
	if gps.isfix() then
		if mode ~= TIMER then
			--ִ�лص�����
			if para.cb then para.cb(para.cause) end
			if mode == TIMERORSUC then return end			
		end
	end
	additem(mode,para)
	--����ȥ��GPS
	gps.opengps("gpsapp")
	--����1��Ķ�ʱ��
	if isexisttimeritem() and not sys.timer_is_active(timerfunc) then
		sys.timer_start(timerfunc,1000)
	end
end

--[[
��������isactive
����  ���ж�һ����GPSӦ�á��Ƿ��ڼ���״̬
����  ��
		mode��GPS����ģʽ
		para��
			para.cause����GPSӦ�á����
			para.val��GPS�������ʱ��
			para.cb���ص�����
����ֵ�������true�����򷵻�nil
]]
function isactive(mode,para)
	assert((para and type(para) == "table" and para.cause and type(para.cause) == "string"),"gpsapp.isactive para invalid")
	local i
	for i=1,#tlist do
		if tlist[i].flag and tlist[i].mode == mode and tlist[i].para.cause == para.cause then
			return true
		end
	end
end

--UART2���UBLOX GPSģ��
gps.initgps(nil,nil,true,1000,2,9600,8,uart.PAR_NONE,uart.STOP_1)
sys.regapp(gpsstatind,gps.GPS_STATE_IND)
