-------------------------------------------------------
-- 文件名　：kinbattle_gs.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-7 10:15:46
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\mission\\kinbattle\\kinbattle_def.lua");

-- 检查玩家是否是家族族长
function KinBattle:CheckKinCaptain(pPlayer)
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId == 0 or nMemberId == 0 then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return 0;
	end
	if Kin:CheckSelfRight(nKinId, nMemberId, Kin.FIGURE_CAPTAIN) ~= 1 then
		return 0;
	end
	return 1, nKinId, nMemberId;
end

function KinBattle:StartMission_GS2(nKinId, nKinIdMate, nMapIndex, nTimeIndex, nCurMoney, nCurMoneyMate, nMapType, nLookMode)
	local cKin = KKin.GetKin(nKinId);
	local cKinMate = KKin.GetKin(nKinIdMate);
	if not cKin or not cKinMate then
		return 0;
	end
	cKin.SetMoneyFund(nCurMoney);
	cKinMate.SetMoneyFund(nCurMoneyMate);
	self:OccupyBattle(nMapIndex, nKinId, nKinIdMate, nTimeIndex, nLookMode);
	local nMapId = KinBattle.MAP_LIST[nMapIndex][1];
	local szKinName = cKin.GetName();
	local szKinNameMate = cKinMate.GetName();
	if SubWorldID2Idx(nMapId) >= 0 then
		local tbMissionGame = Lib:NewClass(KinBattle.Mission);
		self.tbMissionList[nMapIndex].tbMission = tbMissionGame;
		self.tbMissionList[nMapIndex].tbMission:StartGame(nKinId, nKinIdMate, szKinName, szKinNameMate, nMapIndex, nTimeIndex, nMapType, nLookMode);
	end
	KKin.Msg2Kin(nKinId, string.format("本家族与[%s]家族的家族战预定成功，消耗家族资金20万两。家族战将于10分钟后开始，请家族成员火速去各大城市公平子处报名参战，捍卫家族荣誉！", szKinNameMate));
	KKin.Msg2Kin(nKinIdMate, string.format("本家族与[%s]家族的家族战预定成功，消耗家族资金20万两。家族战将于10分钟后开始，请家族成员火速去各大城市公平子处报名参战，捍卫家族荣誉！", szKinName));
end

function KinBattle:GetCampIndex(pPlayer)
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId == 0 or nMemberId == 0 then
		return 0;
	end
	local nMapIndex = self:FindMissionId(nKinId);
	if nMapIndex == -1 then
		return 0;
	end
	if self.tbMissionList[nMapIndex].nKinId == nKinId then
		return 1;
	end
	if self.tbMissionList[nMapIndex].nKinIdMate == nKinId then
		return 2;
	end
	return 0;
end

function KinBattle:FreeBattle_GS(nIndex)
	GCExcute{"KinBattle:FreeBattle_GC", nIndex};
end

-- 获取玩家所在的mission的地图索引
function KinBattle:GetTargetBattleMapId(pPlayer)
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId == 0 or nMemberId == 0 then
		return 0;
	end
	local nMapIndex = self:FindMissionId(nKinId);
	if nMapIndex <= 0 then
		return 0;
	end
	return KinBattle.MAP_LIST[nMapIndex][1];
end

--获取玩家临时table
function KinBattle:GetPlayerInfo(pPlayer)
	local tbPlayerData	= pPlayer.GetTempTable("Mission");	--获取mission中玩家的数据
	if not tbPlayerData then
		return nil;
	end
	local tbPlayerInfo 	= tbPlayerData.tbKinBattlePlayerInfo;
	return tbPlayerInfo;
end

--使用九转计数
function KinBattle:OnUseJiuZhuan(pPlayer)
	local tbPlayerInfo = self:GetPlayerInfo(pPlayer);
	if not tbPlayerInfo then
		return 0
	end
	tbPlayerInfo:IncreaseJiuZhuanCount();
end

-- 检测是否是家族战使用九转
function KinBattle:CheckUseJiuZhuan(pPlayer)
	local nResult = self:CheckIsBattleMap(pPlayer.nMapId);
	return nResult;
end

