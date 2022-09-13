-------------------------------------------------------
-- 文件名　：newland_map.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-09-03 15:23:16
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\Newland\\Newland_def.lua");

-- map
local tbMap = Newland.Map or {};
Newland.Map = tbMap;

function tbMap:OnEnter(szParam)
	if Newland:GM_EnterMap() == 1 then
		if Newland.tbMissionGame and Newland.tbMissionGame:IsOpen() ~= 0 then
			local nRemainTime = Newland.tbMissionGame:GetRemainTime();
			Newland.tbMissionGame:OpenRightUI(me, Newland.tbMissionGame.szRightTitle, nRemainTime);
		end
		return 0;
	end
	local nIndex = Newland:GetPlayerGroupIndex(me);
	if nIndex <= 0 then
		Transfer:NewWorld2GlobalMap(me);
		me.SetLogoutRV(1);
		return 0;
	end
	if Newland.tbMissionGame and Newland.tbMissionGame:IsOpen() ~= 0 then
		Newland.tbMissionGame:JoinPlayer(me, nIndex);
		Newland:AddMapPlayerCount_GS(me.nMapId, 1);
		me.SetLogoutRV(1);
	else
		Transfer:NewWorld2GlobalMap(me);
	end
end

function tbMap:OnLeave(szParam)
	if Newland:GM_LeaveMap() == 1 then
		Dialog:ShowBattleMsg(me, 0, 0);
		return 0;
	end
	local nIndex = Newland:GetPlayerGroupIndex(me);
	if Newland.tbMissionGame and Newland.tbMissionGame:IsOpen() ~= 0 then
		Newland.tbMissionGame:KickPlayer(me, nIndex);
		Newland:AddMapPlayerCount_GS(me.nMapId, -1);
		me.SetLogoutRV(0);
	end
end

function Newland:LinkMap(nMapId)
	local tbMap = Map:GetClass(nMapId);
	for szFunMap, _ in pairs(self.Map) do
		tbMap[szFunMap] = self.Map[szFunMap];
	end
end
-- end

-- map npc
local tbMapNpc = Newland.MapNpc or {};
Newland.MapNpc = tbMapNpc;

function Newland:LinkNpc(nLevel)
	for szNpcClass, tbInfo in pairs(Newland.NPC_CLASS) do
		if tbInfo.MapLevel == nLevel then
			local tbNpc = Npc:GetClass(szNpcClass);
			tbNpc.szNpcClass = szNpcClass;
			tbNpc.nFightState = tbInfo.FightState;
			tbNpc.nSuperTime = tbInfo.SuperTime;
			tbNpc.nStepMap = tbInfo.StepMap;
			tbNpc.tbTransPos = tbInfo.TransPos;
			tbNpc.nMapLevel = tbInfo.MapLevel;
			tbNpc.FnCheck = function(tbBase)
				return self.MapNpc[tbInfo.Check](self.MapNpc, szNpcClass, tbBase);
			end
			for szFunNpc, _ in pairs(self.MapNpc) do
				tbNpc[szFunNpc] = self.MapNpc[szFunNpc];
			end
		end
	end
end

function tbMapNpc:OnDialog()
	
	-- gm跳过判断
	if me.GetCamp() == 6 then
		local nGroupIndex = Newland:GetPlayerGroupIndex(me);
		if not nGroupIndex or nGroupIndex <= 0 then
			Dialog:Say("请使用GM卡选择观战的帮会。");
			return 0;
		end
		local nMapId = (self.nStepMap == 0) and me.nMapId or Newland:GetStepMapId(me.nMapId, self.nStepMap, nGroupIndex);
		local nOk, szError = Map:CheckTagServerPlayerCount(nMapId);
		if nOk ~= 1 then
			Dialog:Say(szError);
			return 0;
		end
		local tbTree = Newland:GetMapTreeByIndex(nGroupIndex);
		local nMapLevel = Newland:GetMapLevel(nMapId);
		local nIndex = (self.nStepMap == 0) and 1 or tbTree[nMapLevel - 1];
		local nMapX, nMapY = unpack(self.tbTransPos[nIndex]);
		me.NewWorld(nMapId, nMapX, nMapY);
		return 0;
	end
	
	-- 判断条件
	if self.FnCheck(self) ~= 1 then
		return 0;
	end
	
	-- 完成传送
	self:OnTransPos();
end

function tbMapNpc:OnTransPos()

	-- 玩家分组
	local nGroupIndex = Newland:GetPlayerGroupIndex(me);
	
	-- 判断地图人数
	local nMapId = (self.nStepMap == 0) and me.nMapId or Newland:GetStepMapId(me.nMapId, self.nStepMap, nGroupIndex);
	if me.nMapId ~= nMapId and Newland:GetMapPlayerCount(nMapId) > Newland.MAX_MAP_PLAYER then
		Dialog:Say("对不起，前往地图人数已满，请稍后再试。");
		return 0;
	end
	
	-- 地图是否异常
	local nOk, szError = Map:CheckTagServerPlayerCount(nMapId);
	if nOk ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	
	-- 支持随机坐标
	local tbTree = Newland:GetMapTreeByIndex(nGroupIndex);
	local nMapLevel = Newland:GetMapLevel(nMapId);
	local nIndex = (self.nStepMap == 0) and 1 or tbTree[nMapLevel - 1];
	local nMapX, nMapY = unpack(self.tbTransPos[nIndex]);
	
	-- 保护时间、战斗状态
	Player:AddProtectedState(me, self.nSuperTime);
	me.SetFightState(self.nFightState);
	me.NewWorld(nMapId, nMapX, nMapY);
end

-- 复活点出去检测
function tbMapNpc:Check_RevivalOut(szNpcClass, tbBase)
	
	-- 判断披风
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem or pItem.nLevel < Newland.MANTLE_LEVEL then
		Dialog:Say(string.format("只有佩戴%s或以上披风的侠士才能进入战场。", Newland.MIN_MANTLE_LEVEL_NAME));
		return 0;		
	end
	
	-- 等待期
	if Newland:GetWarState() ~= Newland.WAR_START then
		Dialog:Say("铁浮城之战尚未打响，请在复活点准备。");
		return 0;
	end
	
	return 1;
end

-- 复活点进入检测
function tbMapNpc:Check_RevivalIn(szNpcClass, tbBase)
	
	local nGroupIndex = Newland:GetPlayerGroupIndex(me);
	if nGroupIndex <= 0 then
		return 0;
	end
	
	local nMapId = Newland:GetLevelMapIdByIndex(nGroupIndex, 1);
	local tbTree = Newland:GetMapTreeByIndex(nGroupIndex);
	local tbDestPos = Newland.REVIVAL_LIST[tbTree[0]];
	local tbTransPos = Newland.NPC_CLASS[szNpcClass].TransPos[1];
	
	-- 地图和复活点索引匹配
	if nMapId == me.nMapId and Lib:Val2Str(tbTransPos) == Lib:Val2Str(tbDestPos) then
		return 1;
	end
	
	return 0;
end

-- 进入下一层检测
function tbMapNpc:Check_Next(szNpcClass)
	
	local nGroupIndex = Newland:GetPlayerGroupIndex(me);
	if nGroupIndex <= 0 then
		return 0;
	end
	
	if Newland._TestPlayer[me.szName] then
		return 1;
	end
	
	local nPole = Newland:GetMapPoleCount(nGroupIndex, me.nMapId);
	if nPole < Newland.MIN_POLE then
		me.Msg(string.format("本帮在本层占领了<color=yellow>%s根龙柱<color>，还未达到<color=yellow>%s根龙柱<color>，无法进入下一层！", nPole, Newland.MIN_POLE));
		return 0;
	end
	
	return 1;
end

-- 返回检测
function tbMapNpc:Check_Back(szNpcClass)
	return 1;
end

function Newland:LinkMapNpc()
	for nLevel, tbMapId in pairs(self.MAP_LIST) do
		for _, nMapId in pairs(tbMapId) do
			self:LinkNpc(nLevel);
			self:LinkMap(nMapId);
		end
	end	
end

Newland:LinkMapNpc();
