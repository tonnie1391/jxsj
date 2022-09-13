-------------------------------------------------------
-- 文件名　：wldh_battle_player.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-08-26 05:19:37
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbPlayerBase	= Wldh.Battle.tbPlayerBase or {};
Wldh.Battle.tbPlayerBase	= tbPlayerBase;

-- 结构初始化
function tbPlayerBase:init(pPlayer, tbCamp)
	self.nSeriesKillNum		= 0;			-- 连斩数 
	self.nMaxSeriesKillNum	= 0;			-- 最大连斩数
	self.nSeriesKill		= 0;			-- 当前有效连斩数
	self.nMaxSeriesKill		= 0;			-- 最大有效连斩数
	self.nTriSeriesNum		= 0;			-- 三连斩个数
	self.nRank				= 1;			-- 官衔, 1表示士兵
	self.nBouns				= 0;			-- 战局积分
	self.nKillPlayerNum		= 0;			-- 杀死玩家个数
	self.nKillPlayerBouns	= 0;			-- 杀敌玩家积分
	self.nListRank			= 0;			-- 排行榜排名
	self.nBackTime			= 0;			-- 最后一次回后营的时间
	self.nBeenKilledNum		= 0;			-- 被杀数
	self.szFacName			= Player:GetFactionRouteName(pPlayer.nFaction, pPlayer.nRouteId);	-- 玩家门派名称

	self.pPlayer		= pPlayer;			-- 玩家
	self.tbMission		= tbCamp.tbMission;	-- 所属Mission
	self.tbCamp			= tbCamp;			-- 所属阵营
end

-- 增加当前积分，同时增加本阵营的
function tbPlayerBase:AddBounsWithCamp(nBouns)
	local nResult = self:AddBounsWithoutCamp(nBouns);
	self.tbCamp.nBouns = self.tbCamp.nBouns + nBouns;
	return nResult;
end

-- 增加自身当前积分 ** 去掉积分限制
function tbPlayerBase:AddBounsWithoutCamp(nBouns)
	
	local nNewBouns	= self.nBouns + nBouns;
	local nResult = nNewBouns - self.nBouns;
	
	self.nBouns = nNewBouns;
	self:ProcessRank();
	self:ShowRightBattleInfo();
	
	return nResult;
end

-- 处理官衔相关信息
function tbPlayerBase:ProcessRank()
	
	local nRank = 0;
	
	if self.nRank >= 10 then
		return;
	end
	
	for i = #Wldh.Battle.RANKBOUNS, 1, -1 do
		if self.nBouns >= Wldh.Battle.RANKBOUNS[i] and -1 ~= Wldh.Battle.RANKBOUNS[i] then
			nRank = i;
			break;
		end
	end
	
	if self.nRank == nRank then
		return;
	end

	assert(self.nRank < nRank);
	
	self.pPlayer.AddTitle(2, self.tbCamp.nCampId, nRank, 0);
	self.nRank= nRank;
	
	return nRank;
end

-- 右边战斗信息
function tbPlayerBase:SetRightBattleInfo(nRemainFrame)
	local szMsgFormat = "<color=green>Thời gian còn lại: <color> <color=white>%s<color>";
	Dialog:SetBattleTimer(self.pPlayer, szMsgFormat, nRemainFrame);
	self:ShowRightBattleInfo();
end

function tbPlayerBase:ShowRightBattleInfo()
	
	local szMsg	= string.format("<color=green>当前排名：<color> <color=0xa0ff>%d<color>\n<color=green>个人积分：<color> <color=yellow>%d<color>\n<color=green>伤敌玩家： <color><color=red>%d<color>", 
		self.nListRank, self.nBouns, self.nKillPlayerNum);

	Dialog:SendBattleMsg(self.pPlayer, szMsg);
	Dialog:ShowBattleMsg(self.pPlayer, 1, 0);
end

function tbPlayerBase:DeleteRightBattleInfo()
	Dialog:ShowBattleMsg(self.pPlayer, 0, 3 * 18);
end
