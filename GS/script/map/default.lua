-- Map默认模板（也是基础模板）

local tbMapBase	= Map.tbMapBase;

tbMapBase.tbTraps		= nil;	-- Trap点类库

-- 根据参数，执行检查函数
function tbMapBase:CallParam(tbSwitchExec, bIn)
	for _, fnCallBack in pairs(tbSwitchExec) do
		 Lib:CallBack({fnCallBack, Map.tbSwitchs, bIn});
	end
end

-- 玩家进入地图状态(调用状态表,不建议重载)
function tbMapBase:OnEnterState(tbSwitchExec)
	self:CallParam(tbSwitchExec, 1);	-- 通用开关
end

-- 动态注册进入地图事件
function tbMapBase:RegisterMapEnterFun(szKey, fnExcute, ...)
	if not self.tbEnterMapFun then
		self.tbEnterMapFun = {};	-- 玩家进入地图事件函数表
	end
	self.tbEnterMapFun[szKey] = {fnProcess = fnExcute, tbParam = arg};
end

-- 反注册
function tbMapBase:UnregisterMapEnterFun(szKey)
	if (not self.tbEnterMapFun or not self.tbEnterMapFun[szKey] )then
		return 0;
	end
	self.tbEnterMapFun[szKey] = nil;
end

-- 执行进入地图事件
function tbMapBase:ExcuteEnterFun()
	if not self.tbEnterMapFun then
		return 0;
	end
	for _, tbExcute in pairs(self.tbEnterMapFun) do
		tbExcute.fnProcess(unpack(tbExcute.tbParam));
	end
end

-- 动态注册离开地图事件
function tbMapBase:RegisterMapLeaveFun(szKey, fnExcute, ...)
	if not self.tbLeaveMapFun then
		self.tbLeaveMapFun = {};	-- 玩家进入地图事件函数表
	end
	self.tbLeaveMapFun[szKey] = {fnProcess = fnExcute, tbParam = arg};
end

-- 反注册
function tbMapBase:UnregisterMapLeaveFun(szKey)
	if (not self.tbLeaveMapFun or not self.tbLeaveMapFun[szKey] )then
		return 0;
	end
	self.tbLeaveMapFun[szKey] = nil;
end

-- 执行进入地图事件
function tbMapBase:ExcuteLeaveFun()
	if not self.tbLeaveMapFun then
		return 0;
	end
	for _, tbExcute in pairs(self.tbLeaveMapFun) do
		tbExcute.fnProcess(unpack(tbExcute.tbParam));
	end
end

--定义开关类进入事件
function tbMapBase:OnEnterConsole()
end

-- 定义玩家进入事件Onlogin前调用
function tbMapBase:OnEnter()
end

-- 定义玩家进入事件Onlogin后调用
function tbMapBase:OnEnter2()
end

-- 
function tbMapBase:OnLeaveState(tbSwitchExec)
	self:CallParam(tbSwitchExec, 0);	-- 通用开关
end

function tbMapBase:OnDyLoad(nDynMapId)
end

--定义开关类离开事件
function tbMapBase:OnLeaveConsole()
end

-- 定义玩家离开事件
function tbMapBase:OnLeave()
end

-- 获取当前地图的指定Trap点
function tbMapBase:GetTrapClass(szClassName, bNotCreate)
	if (not self.tbTraps) then
		self.tbTraps	= {};
	end
	local tbTrap	= self.tbTraps[szClassName];
	-- 如果没有bNotCreate，当找不到指定模板时会自动建立新模板
	if (not tbTrap and bNotCreate ~= 1) then
		-- 新模板从基础模板派生
		tbTrap	= Lib:NewClass(Map.tbTrapBase);
		tbTrap.szName	= szClassName;
		tbTrap.tbMap	= self;
		-- 加入到模板库里面
		self.tbTraps[szClassName]	= tbTrap;
	end
	return tbTrap;
end

-- 触发本地图任何Trap点
function tbMapBase:OnPlayerTrap(szClassName)
	self:GetTrapClass(szClassName):OnPlayer();
end
function tbMapBase:OnNpcTrap(szClassName)
	self:GetTrapClass(szClassName):OnNpc();
end

local tbTrapBase	= Map.tbTrapBase;

-- 定义玩家Trap事件
function tbTrapBase:OnPlayer()
	local tbToPos	= self.tbMap.tbTransmit[self.szName];
	Map:DbgOut("OnPlayerTrap:", me.szName, self.tbMap.nMapId, self.szName, tbToPos);
	if (tbToPos) then
		-- 现在的逻辑需要先NewWorld再SetFightState
		tbToPos[1] = Map:DynamicMapChange(tbToPos[1], me.nMapId);
		local nRet, szMsg = Map:CheckTagServerPlayerCount(tbToPos[1]);
		if nRet ~= 1 then
			me.Msg(szMsg);
			return 0;
		end
		me.NewWorld(tbToPos[1], tbToPos[2], tbToPos[3]);
		if (tbToPos[4] ~= "") then
			me.SetFightState(tonumber(tbToPos[4]));
		end
		
		-- 进入某些地图需要保护5秒钟
		if (tbToPos[5] and tbToPos[5] > 0) then
			Player:AddProtectedState(me, 5);
		else
			Player:AddProtectedState(me, 0);
		end
	end
end

-- 定义Npc Trap事件
function tbTrapBase:OnNpc()
	Map:DbgOut("OnNpcTrap:", him.szName, self.tbMap.nMapId, self.szName);
end

