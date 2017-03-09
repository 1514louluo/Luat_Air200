--[[
ģ�����ƣ�Ӳ�����Ź�
ģ�鹦�ܣ�֧��153BоƬӲ�����Ź�����
ģ������޸�ʱ�䣺2017.02.16
����ĵ��ο� doc\С��GPS��λ������ĵ�\Watchdog descritption.doc
]]

module(...,package.seeall)

local scm_active,get_scm_cnt = true,20

local function getscm()
	get_scm_cnt = get_scm_cnt - 1
	if get_scm_cnt > 0 then
		sys.timer_start(getscm,100)
	else
		get_scm_cnt = 20
	end

	if pins.get(pins.WATCHDOG) then
		scm_active = true
		print("wdt scm_active = true")
	end
end

local function feedend()
	pins.setdir(pio.INPUT,pins.WATCHDOG)
	print("wdt feedend")
	sys.timer_start(getscm,100)
end

local function feed()
	if scm_active then
		scm_active = false
	else
		pins.set(false,pins.RST_SCMWD)
		sys.timer_start(pins.set,100,true,pins.RST_SCMWD)
		print("wdt reset 153b")
	end

	pins.setdir(pio.OUTPUT,pins.WATCHDOG)
	pins.set(true,pins.WATCHDOG)
	print("wdt feed")

	sys.timer_start(feed,120000)
	sys.timer_start(feedend,2000)
end

local function open()
	sys.timer_start(feed,120000)
	pins.set(false,pins.WATCHDOG)
end

sys.timer_start(open,200)
