module(...,package.seeall)
require"config"

package.path = "/?.lua;"..package.path

--Ĭ�ϲ������ô洢��config.lua��
--ʵʱ�������ô洢��para.lua��
local configname,paraname,para = "/lua/config.lua","/para.lua"

local function print(...)
	_G.print("nvm",...)
end

--�ָ���������
--��config.lua�ļ����ݸ��Ƶ�para.lua��
function restore()
	local fpara,fconfig = io.open(paraname,"wb"),io.open(configname,"rb")
	fpara:write(fconfig:read("*a"))
	fpara:close()
	fconfig:close()
	para = config
end

local function serialize(pout,o)
	if type(o) == "number" then
		pout:write(o)
	elseif type(o) == "string" then
		pout:write(string.format("%q", o))
	elseif type(o) == "boolean" then
		pout:write(tostring(o))
	elseif type(o) == "table" then
		pout:write("{\n")
		for k,v in pairs(o) do
			if type(k) == "number" then
				pout:write(" [", k, "] = ")
			elseif type(k) == "string" then
				pout:write(" [\"", k,"\"] = ")
			else
				error("cannot serialize table key " .. type(o))
			end
			serialize(pout,v)
			pout:write(",\n")
		end
		pout:write("}\n")
	else
		error("cannot serialize a " .. type(o))
	end
end

local function upd()
	for k,v in pairs(config) do
		if k ~= "_M" and k ~= "_NAME" and k ~= "_PACKAGE" then
			if para[k] == nil then
				para[k] = v
			end			
		end
	end
end

local function load()
	local f = io.open(paraname,"rb")
	if not f or f:read("*a") == "" then
		if f then f:close() end
		restore()
		return
	end
	f:close()
	
	f,para = pcall(require,"para")
	if not f then
		restore()
		return
	end
	upd()
end

local function save(s)
	if not s then return end
	local f = io.open(paraname,"wb")

	f:write("module(...)\n")

	for k,v in pairs(para) do
		if k ~= "_M" and k ~= "_NAME" and k ~= "_PACKAGE" then
			f:write(k, " = ")
			serialize(f,v)
			f:write("\n")
		end
	end

	f:close()
end

--����ĳ��������ֵ
--k��������
--v����Ҫ���õ���ֵ
--r������ԭ��ֻ�д�������Ч����������v����ֵ�;�ֵ�����˸ı䣬�Ż��׳�TPARA_CHANGED_IND��Ϣ
--s���Ƿ���Ҫд�뵽�ļ�ϵͳ�У�false��д�룬����Ķ�д��
function set(k,v,r,s)
	local bchg
	if type(v) == "table" then
		for kk,vv in pairs(para[k]) do
			if vv ~= v[kk] then bchg = true break end
		end
	else
		bchg = (para[k] ~= v)
	end
	print("set",bchg,k,v,r,s)
	if bchg then		
		para[k] = v
		save(s or s==nil)
		if r then sys.dispatch("PARA_CHANGED_IND",k,v,r) end
	end
	return true
end

--����table���͵Ĳ����е�ĳһ���ֵ
--k��table������
--kk��table�����еļ�ֵ
--v����Ҫ���õ���ֵ
--r������ԭ��ֻ�д�������Ч����������v����ֵ�;�ֵ�����˸ı䣬�Ż��׳�TPARA_CHANGED_IND��Ϣ
--s���Ƿ���Ҫд�뵽�ļ�ϵͳ�У�false��д�룬����Ķ�д��
function sett(k,kk,v,r,s)
	if para[k][kk] ~= v then
		para[k][kk] = v
		save(s or s==nil)
		if r then sys.dispatch("TPARA_CHANGED_IND",k,kk,v,r) end
	end
	return true
end

--�Ѳ������ڴ�д���ļ���
function flush()
	save(true)
end

--��ȡ����ֵ
--k��������
function get(k)
	if type(para[k]) == "table" then
		local tmp = {}
		for kk,v in pairs(para[k]) do
			tmp[kk] = v
		end
		return tmp
	else
		return para[k]
	end
end

--��ȡtable���͵Ĳ����е�ĳһ���ֵ
--k��table������
--kk��table�����еļ�ֵ
function gett(k,kk)
	return para[k][kk]
end

--��ʼ�������ļ������ļ��аѲ�����ȡ���ڴ���
load()
