module(...,package.seeall)
require"lbsloc"

--[[
��һ��ʹ�û�վ��ȡ��γ�ȵĹ��ܣ����밴�����²��������
1����Luat������ƽ̨ǰ��ҳ�棺https://iot.openluat.com/
2��ע���û�
3��ע���û�֮�󣬴���һ������Ŀ
4����������Ŀ֮�󣬽�����Ŀ
5��������Ŀ�󣬵����ߵ���Ŀ��Ϣ���ұ߻������Ϣ���ݣ��ҵ�ProductKey����ProductKey�����ݣ���ֵ�����ļ��е�ProductKey����
6����ѯһ���豸��IMEI������ǿ�����trace������CGSN��CGSN����������豸��IMEI
7���ڵ�5����ҳ�棬�����ߵ��豸����Ȼ���ٵ���ұߵ�����豸���ڵ������У��豸��������䣬�豸IMEI�������6����õ�IMEI
�Ժ�������豸��ʹ�ô˹���ʱ���ظ�����ĵ�6���͵�7������
]]

--�û���������Լ�����Ŀ��Ϣ���޸����������ֵ
local ProductKey = "v32xEAKsGTIEQxtqgwCldp5aPlcnPs3K"

--[[
��������print
����  ����ӡ�ӿڣ����ļ��е����д�ӡ�������testǰ׺
����  ����
����ֵ����
]]
local function print(...)
	_G.print("test",...)
end

--��γ�ȸ�ʽΪ031.2425864	121.4736522
local function getgps(result,lat,lng)
	print("getgps",result,lat,lng)
	--��ȡ��γ�ȳɹ�
	if result==0 then
	--ʧ��
	else
	end
	sys.timer_start(lbsloc.request,20000,getgps)
end

lbsloc.setup(ProductKey)
--20���ȥ��ѯ��γ�ȣ���ѯ���ͨ���ص�����getgps����
sys.timer_start(lbsloc.request,20000,getgps)
