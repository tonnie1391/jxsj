-- 文件名　：console_global.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-04-23 17:59:30
-- 描  述  ：

--申请新的类
function Console:New(nDegree)
	Console:NewBase(nDegree);
	return Console:GetBase(nDegree);
end

function Console:NewBase(nDegree)
	Console.tbConsole = Console.tbConsole or {};
	Console.tbConsole[nDegree] = Lib:NewClass(self.Base);
	Console.tbConsole[nDegree].nDegree 	= nDegree;
end

function Console:GetBase(nDegree)
	return Console.tbConsole[nDegree];
end

function Console:GetConsoleCfg(nDegree)
	local tbConsole = self:GetBase(nDegree);
	if (not tbConsole) then
		return;
	end
	return tbConsole.tbCfg;
end

--是否满人
function Console:IsFull(nDegree, nPlayerCount)
	local tbBase = self:GetBase(nDegree);
	return tbBase:IsFull(nPlayerCount)
end

--进入准备场加入名单
function Console:JoinGroupList(nDegree, nMapId, tbPlayerList)
	local tbBase = self:GetBase(nDegree);
	tbBase:JoinGroupList(nMapId, tbPlayerList);
end

--离开准备场
function Console:LeaveGroupList(nDegree, nMapId, nId)
	local tbBase = self:GetBase(nDegree);
	tbBase:LeaveGroupList(nMapId, nId);
end

-- 返回地图人数
function Console:GetPlayerNumInMap(nDegree, nMapId)
	local tbBase = self:GetBase(nDegree);
	return tbBase:GetPlayerNumInMap(nMapId);
end

-- 返回地图玩家id列表
function Console:GetPlayerIdList(nDegree, nMapId)
	local tbBase = self:GetBase(nDegree);
	return tbBase:GetPlayerIdList(nMapId);
end

-- 返回当前控制状态
function Console:GetConsoleState(nDegree)
	local tbBase = self:GetBase(nDegree);
	return tbBase:GetConsoleState();
end