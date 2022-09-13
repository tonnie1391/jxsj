-- 文件名　：missionlevel20_trap.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-22 20:21:57
-- 描述：一些讨厌的trap


Require("\\script\\task\\primer\\missionlevel20\\missionlevel20_def.lua")

Task.PrimerLv20 = Task.PrimerLv20 or {};

local PrimerLv20 = Task.PrimerLv20;

local tbMap = {};

--初始化地图trap，没有特殊的trap点，通用处理
function PrimerLv20:InitTrap(nMapId)
	local tbMapTrap = Map:GetClass(nMapId);
	for szTrapName, tbBackPos in pairs(PrimerLv20.tbTrapBackPos) do
		local tbTrap	= tbMapTrap:GetTrapClass(szTrapName);
		tbTrap.szName = szTrapName;
		tbTrap.nPosX = tbBackPos[1];
		tbTrap.nPosY = tbBackPos[2];
		for szFnc in pairs(tbMap) do		-- 复制函数
			tbTrap[szFnc] = tbMap[szFnc];
		end
	end
end

-- 定义玩家Trap事件
function tbMap:OnPlayer()
	local pGame = PrimerLv20:GetGameObjByPlayerId(me.nId) --获得对象
	if pGame == nil then
		return 0;
	end
	if self.szName == "trap_step1" then
		if pGame.tbIsTrapOpen[1] ~= 1 then
			Dialog:SendBlackBoardMsg(me, "前方貌似有什么可怕的屏障将你阻挡了");
			me.NewWorld(me.nMapId, self.nPosX, self.nPosY);
			return 0;
		end
	elseif self.szName == "trap_step2" then
		if pGame.tbIsTrapOpen[2] ~= 1 then
			Dialog:SendBlackBoardMsg(me, "前方貌似有什么可怕的屏障将你阻挡了");
			me.NewWorld(me.nMapId, self.nPosX, self.nPosY);
			return 0;
		end
	end
	return 0;
end

PrimerLv20:InitTrap(PrimerLv20.nMapTemplateId);