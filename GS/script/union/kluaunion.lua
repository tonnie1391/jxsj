-------------------------------------------------------------------
--File: kluaunion.lua
--Author: zhengyuhua
--Date: 2009-6-6 15:17
--Describe: KLuaUnion扩展脚本指令
-------------------------------------------------------------------
if MODULE_GAMECLIENT then
	return
end

if not _KLuaUnion then --调试需要
	_KLuaUnion = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
end

local self	--作为第一个Up Value

Union.aUnionTaskDesc2Id = {}
Union.aUnionTmpTaskDesc2Id = {}
Union.aUnionBufTaskDesc2Id = {}

--用于生成帮会任务变量对应的指令
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
	rawset(_KLuaUnion, "Get"..szDesc, funGet)
	rawset(_KLuaUnion, "Set"..szDesc, funSet)
	rawset(_KLuaUnion, "Add"..szDesc, funAdd)
	Union.aUnionTaskDesc2Id[szDesc] = nTaskId
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
	rawset(_KLuaUnion, "Get"..szDesc, funGet)
	rawset(_KLuaUnion, "Set"..szDesc, funSet)
	rawset(_KLuaUnion, "Add"..szDesc, funAdd)
	Union.aUnionTaskDesc2Id[szDesc] = nTaskId
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
	rawset(_KLuaUnion, "Get"..szDesc, funGet)
	rawset(_KLuaUnion, "Set"..szDesc, funSet)
	Union.aUnionBufTaskDesc2Id[szDesc] = nTaskId
end

local function _GEN_TMP_TASK_FUN(szDesc, nTaskId)
	local funGet = 
		function ()
			return self.GetTmpTask(nTaskId)
		end
	local funSet = 
		function (nValue)
			return self.SetTmpTask(nTaskId, nValue)
		end
	local funAdd = 
		function (nValue)
			return self.AddTmpTask(nTaskId, nValue)
		end
	rawset(_KLuaUnion, "Get"..szDesc, funGet)
	rawset(_KLuaUnion, "Set"..szDesc, funSet)
	rawset(_KLuaUnion, "Add"..szDesc, funAdd)
end



--不要改变任务变量的编号！
_GEN_TASK_FUN("CreateTime", 1)				--创建时间
_GEN_TASK_FUN_U("UnionMaster", 2)			--盟主帮会ID
_GEN_TASK_FUN("DomainColor", 3)				-- 领土颜色
_GEN_BUF_TASK_FUN("Name", 1)				-- 联盟名称

if not MODULE_GAMECLIENT then
	_GEN_TMP_TASK_FUN("UnionDataVer", 1)	-- 当前数据版本号，用于与客户端的数据对比
end



