-------------------------------------------------------------------
--File: kluadomain.lua
--Author: lbh
--Date: 2008-10-16 10:12
--Describe: KLuaDomain扩展脚本指令
-------------------------------------------------------------------
if (MODULE_GAMECLIENT) then
	return
end

if not _KLuaDomain then --调试需要
	_KLuaDomain = {}
	print(GetLocalDate("%Y/%m/%d/%H/%M/%S").." build ok ..")
end

local self	--作为第一个Up Value

--建立szDesc到TaskId的映射
Domain.aDomainTaskDesc2Id = {}
Domain.aDomainBufTaskDesc2Id = {}

--用于生成区域任务变量对应的指令
local function _GEN_TASK_FUN(szDesc, nTaskId)
	local funGet = 
		function ()
			return self.GetTask(nTaskId)
		end
	local funSet = 
		function (nValue)
			return self.SetTask(nTaskId, nValue)
		end
	local funAdd = 
		function (nValue)
			return self.AddTask(nTaskId, nValue)
		end
	rawset(_KLuaDomain, "Get"..szDesc, funGet)
	rawset(_KLuaDomain, "Set"..szDesc, funSet)
	rawset(_KLuaDomain, "Add"..szDesc, funAdd)
	Domain.aDomainTaskDesc2Id[szDesc] = nTaskId
end

--无符号整型任务变量
local function _GEN_TASK_FUN_U(szDesc, nTaskId)
	local funGet = 
		function ()
			return self.GetTaskU(nTaskId)
		end
	local funSet = 
		function (nValue)
			return self.SetTask(nTaskId, nValue)
		end
	local funAdd = 
		function (nValue)
			return self.AddTask(nTaskId, nValue)
		end
	rawset(_KLuaDomain, "Get"..szDesc, funGet)
	rawset(_KLuaDomain, "Set"..szDesc, funSet)
	rawset(_KLuaDomain, "Add"..szDesc, funAdd)
	Domain.aDomainTaskDesc2Id[szDesc] = nTaskId
end

local function _GEN_BUF_TASK_FUN(szDesc, nTaskId)
	local funGet = 
		function ()
			return self.GetBufTask(nTaskId)
		end
	local funSet = 
		function (szValue)
			return self.SetBufTask(nTaskId, szValue)
		end
	rawset(_KLuaDomain, "Get"..szDesc, funGet)
	rawset(_KLuaDomain, "Set"..szDesc, funSet)
	Domain.aDomainBufTaskDesc2Id[szDesc] = nTaskId
end

_GEN_TASK_FUN_U("OccupyTime", 1)	--占领时间

