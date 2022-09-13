-------------------------------------------------------------------
--File: globaltask.lua
--Author: lbh
--Date: 2007-7-12 10:30
--Describe: 通用脚本全局任务变量
--任务变量ID定义请看misc/globaltaskdef.lua
-------------------------------------------------------------------

Require("\\script\\misc\\globaltaskdef.lua");

if (MODULE_GAMECLIENT) then	------- 客户端模拟部分
	function KGblTask.SCGetDbTaskInt(key)
		return GblTask.tbSyncClientTaskData[key] or 0;
	end
	function KGblTask.SCGetDbTaskStr(key)
		return GblTask.tbSyncClientTaskData[key] or "";
	end
	
	return;	-- 客户端没有真正的全局变量相关函数
end

--加SC前缀区别基本的KGblTask GM指令
--key可以为整型和字符串型，字符串型key长度小于120字符

------------------------------存储并同步的全局任务变量----------------------------------
function KGblTask.SCGetDbTaskInt(key)
	if not key then
		print(debug.traceback("KGblTask Error"));
	end
	return KGblTask.GetGblInt(65, key)
end

function KGblTask.SCSetDbTaskInt(key, nValue)	--在Gameserver端不会立即设上
	if not key or not nValue then
		print(debug.traceback("KGblTask Error"));
	end
	return KGblTask.SetGblInt(65, key, nValue)
end

function KGblTask.SCAddDbTaskInt(key, nAdd)
	return KGblTask.AddGblInt(65, key, nAdd)
end

function KGblTask.SCGetDbTaskStr(key)
	if not key then
		print(debug.traceback("KGblTask Error"));
	end
	return KGblTask.GetGblStr(65, key)
end

function KGblTask.SCSetDbTaskStr(key, szValue)	--szValue小于120字符
	if not key or not szValue then
		print(debug.traceback("KGblTask Error"));
	end
	return KGblTask.SetGblStr(65, key, szValue)
end

function KGblTask.SCDelDbTaskStr(key)
	return KGblTask.DelGblStr(65, key)
end

------------------------------不存储但同步的全局任务变量----------------------------------
function KGblTask.SCGetTmpTaskInt(key)
	return KGblTask.GetGblIntTmp(65, key)
end

function KGblTask.SCSetTmpTaskInt(key, nValue)
	return KGblTask.SetGblIntTmp(65, key, nValue)
end

function KGblTask.SCAddTmpTaskInt(key, nAdd)
	return KGblTask.AddGblIntTmp(65, key, nAdd)
end

function KGblTask.SCGetTmpTaskStr(key)
	return KGblTask.GetGblStrTmp(65, key)
end

function KGblTask.SCSetTmpTaskStr(key, szValue) --szValue小于120字符
	return KGblTask.SetGblStrTmp(65, key, szValue)
end

function KGblTask.SCDelTmpTaskStr(key)
	return KGblTask.DelGblStrTmp(65, key)
end
------------------------------不同步也不存储的任务变量----------------------------------
function KGblTask.SCGetLocalTaskInt(key)
	return KGblTask.GetLocalInt(65, key)
end

function KGblTask.SCSetLocalTaskInt(key, nValue)
	return KGblTask.SetLocalInt(65, key, nValue)
end

function KGblTask.SCAddLocalTaskInt(key, nAdd)
	return KGblTask.AddLocalInt(65, key, nAdd)
end

function KGblTask.SCGetLocalTaskStr(key)
	return KGblTask.GetLocalStr(65, key)
end

function KGblTask.SCSetLocalTaskStr(key, szValue) --szValue小于120字符
	return KGblTask.SetLocalStr(65, key, szValue)
end

function KGblTask.SCDelLocalTaskStr(key) --szValue小于120字符
	return KGblTask.DelLocalStr(65, key)
end
