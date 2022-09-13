-------------------------------------------------------
-- 文件名　：kinbattle_map.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-07 14:23:16
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\mission\\kinbattle\\kinbattle_def.lua");

local tbMap = KinBattle.Map or {};
KinBattle.Map = tbMap;

function tbMap:OnEnter(szParam)
	local nKinId, nMemberId = me.GetKinMember();
	local nMapIndex, nCampIndex = KinBattle:FindMissionId(nKinId);
	if nMapIndex <=0 or nCampIndex <= 0 then
		me.NewWorld(unpack(KinBattle.DEFAULT_POS));
		return 0;
	end
	local tbMission = KinBattle.tbMissionList[nMapIndex].tbMission;
	if tbMission and tbMission:IsOpen() ~= 0 and tbMission:CheckOver() == 0 then
		if KinBattle.tbMissionList[nMapIndex].tbMission:GetPlayerGroupId(me) == -1 then
			KinBattle.tbMissionList[nMapIndex].tbMission:JoinPlayer(me, nCampIndex);
			me.SetLogoutRV(1);
			return 0;
		end
	else
		local nCityId = KinBattle.MAP_LIST[nMapIndex][4];
		me.NewWorld(nCityId, unpack(KinBattle.LEAVE_POS[nCityId]));
		return 0;
	end	
end

function KinBattle:LinkMap()
	for _, tbMapId in pairs(KinBattle.MAP_LIST) do
		local tbMap1 = Map:GetClass(tbMapId[1]);
		local tbMap2 = Map:GetClass(tbMapId[2]);
		local tbMap3 = Map:GetClass(tbMapId[3]);
		for szFunMap, _ in pairs(self.Map) do
			tbMap1[szFunMap] = self.Map[szFunMap];
			tbMap2[szFunMap] = self.Map[szFunMap];
			tbMap3[szFunMap] = self.Map[szFunMap];
		end
	end
end

KinBattle:LinkMap();
