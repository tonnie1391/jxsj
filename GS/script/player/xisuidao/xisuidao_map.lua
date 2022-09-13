
local tbXiBattleMap 	= Map:GetClass(256); -- 地图id -- TODO 战斗区地图ID

tbXiBattleMap.tbMission = Xisuidao.tbMission;

-- 进入战斗测试区才能加入 Mission
function tbXiBattleMap:OnEnter()
	KGblTask.SCAddTmpTaskInt(Xisuidao.GBLTASKID_NUM, 1);
	assert(self.tbMission);
	self.tbMission:JoinPlayer(me, 1);
end

function tbXiBattleMap:OnLeave()
	KGblTask.SCAddTmpTaskInt(Xisuidao.GBLTASKID_NUM, -1);
	assert(self.tbMission);
	local nGroupId = self.tbMission:GetPlayerGroupId(me);
	if (nGroupId ~= -1) then
		self.tbMission:KickPlayer(me, 1);
	end
end

--local tbXiBattleTrap = tbXiBattleMap:GetTrapClass("-------");  -- TODO

--function tbXiBattleTrap:OnPlayer()
--	local pPlayer = me;
--	pPlayer.NewWorld(181,1654,3314); -- 传送到非战斗区
--	pPlayer.SetFightState(0);
--end

local tbXiXidianMap		= Map:GetClass(255);		-- 地图id 洗点地图

function tbXiXidianMap:OnEnter()
	KGblTask.SCAddTmpTaskInt(Xisuidao.GBLTASKID_NUM, 1);
end

function tbXiXidianMap:OnLeave()
	KGblTask.SCAddTmpTaskInt(Xisuidao.GBLTASKID_NUM, -1);
end

--local tbXiXidianTrap = tbXiXidianMap:GetTrapClass();

--function tbXiXidianTrap:OnPlayer()
--	local pPlayer = me;
--	pPlayer.NewWorld(168,1646,3177); -- 传送到战斗区
--	pPlayer.SetFightState(1);
--end
