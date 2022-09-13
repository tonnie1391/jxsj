-- 文件名  : fightafter_gs.lua
-- 创建者  : zounan
-- 创建时间: 2010-07-21 17:58:51
-- 描述    : 战后系统 GS

if (MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\fightafter\\fightafter_def.lua");
FightAfter.tbRoom = FightAfter.tbRoom or {};
local RoomMgr = FightAfter.tbRoom;
--[[
tbInstance; --结构
tbInstance.nType;
tbInstance.nKillNpc;
tbInstance.nKillBoss;
tbInstance.nUseTime;
tbInstance.nLevel; 
tbInstance.nScore;   --分数
tbInstance.nGrade;   --评价等级
tbInstance.tbTeamer; --队伍
tbInstance.szName;
-- 一个记录玩家名称的LIST？
tbTeamer[1] =  szName = szPlayerName, nWeak =  -- 衰减百分比 tbPlayerRelation = {};
				tbFavor = {}; tbAward = { tbItem = {}, nCount = }
				bNewWorld --是否需要传送
--tbInstance.nMapId;	 -- 不需要吧？
--]]


--完成了一项活动
function FightAfter:FinishInstance(tbInstance)	
	--创建一个szInstanceId
	local szInstanceId  = "|";
	local nNoAwardCount = 0; --未领奖的人数 当人数为0时可以将该BUFF清除
	tbInstance.tbNoAwardPlayer = {};
	local tbTeamer = {};
	--用队员名字 当前时间 组一个唯一的标识
	for _, tbPlayerInfo in ipairs(tbInstance.tbTeamer) do
		local szPlayerName = tbPlayerInfo.szName;
		szInstanceId= szInstanceId..szPlayerName.."|";
		nNoAwardCount = nNoAwardCount + 1;
		tbInstance.tbNoAwardPlayer[szPlayerName] = 1;
		local bNewWorld = tbPlayerInfo.bNewWorld or 1;
		table.insert(tbTeamer, {szPlayerName, bNewWorld});
	end
	
--	tbInstance.nCompleteTime = GetTime(); --完成时间
	tbInstance.nNoAwardCount = nNoAwardCount;
	
	szInstanceId = szInstanceId..tbInstance.nEndTime;
	tbInstance.szInstanceId = szInstanceId;
	GlobalExcute({"FightAfter:AddInstance", tbInstance});
	GCExcute({"FightAfter:AddInstance",  tbInstance});	
	
	self:ApplyFreeRoomForOneTeam(tbTeamer);
end


function FightAfter:ApplyFreeRoomForMe()
--	local tbInstanceList = self:GetExpiryInstanceList(me);
--	if #tbInstanceList == 0 then
--		Dialog:Say("您没有奖励记录，不能进入评价地图。");
--		return;
--	end	
	self:ApplyFreeRoomForOnePlayer(me,1);
end

function FightAfter:EnterRoomForMeReady()
	local szMsg = "你没有奖励记录，是否确定要进入得悦舫参观？";
	local tbInstanceList = self:GetExpiryInstanceList(me);
	if #tbInstanceList > 0 then
		szMsg = string.format("你有<color=yellow>%s条<color>评价奖励记录，是否确定要进入得悦舫领取奖励？", #tbInstanceList);
	end
	Dialog:Say(szMsg, {{"进入得悦舫", self.ApplyFreeRoomForMe, self},{"Để ta suy nghĩ lại"}});
end

function FightAfter:ApplyFreeRoomForOnePlayer(pPlayer, bFailNoNewWorld)
	if not pPlayer then
		return;
	end
	
--	Check 检查是否让进
--	local tbInsList =  self:GetExpiryInstanceList(pPlayer);
--	if #tbInsList == 0 then
--		return;
--	end
	
	local tbTeamer = {};
	tbTeamer[1] = {pPlayer.szName,1};
	self:ApplyFreeRoomForOneTeam(tbTeamer, bFailNoNewWorld);
end

-- tbTeamer 格式[1] = szPlayerName
function FightAfter:ApplyFreeRoomForOneTeam(tbTeamer, bFailNoNewWorld)	
	local bNoPlayer = 1;
	for  _, tbData  in ipairs(tbTeamer) do
		local pPlayer = GetPlayerObjFormRoleName(tbData[1]);
		if (tbData[2] == 1) and pPlayer then
			bNoPlayer = 0;
			break;
		end
	end		
	
	if bNoPlayer == 1 then  -- 没人就不申请了
		return;
	end	

	local nRoomId = RoomMgr:ApplyFreeRoom();
	self:OnApplyRoom(nRoomId, tbTeamer, bFailNoNewWorld);
end


--申请的回调 nApplyMapId == 0  表示申请失败
-- bFailNoNewWorld表示 申请失败不传送 默认传送
function FightAfter:OnApplyRoom(nApplyRoomId, tbTeamer, bFailNoNewWorld)
	local pPlayer   = nil;
	for  _, tbData  in ipairs(tbTeamer) do
		pPlayer = GetPlayerObjFormRoleName(tbData[1]);
		if pPlayer and (tbData[2] == 1) then
			if nApplyRoomId and nApplyRoomId ~= 0 then				
				RoomMgr:NewWorld(pPlayer,nApplyRoomId);
			else 
				pPlayer.Msg("申请房间失败");
				if not bFailNoNewWorld or bFailNoNewWorld == 0 then
					FightAfter:Fly2City(pPlayer);
				end
			end
		end
	end	
	
end


--检查这个副本对玩家是否有效 GS
function FightAfter:CheckInstanceExpiry_player(pPlayer, szInstanceId)
	if self:CheckInstanceExpiry_base(szInstanceId) == 0 then
		return 0;
	end
	
	local tbInstance = self.tbInstanceBuffer[szInstanceId];
	if not tbInstance.tbNoAwardPlayer[pPlayer.szName] then
		return 0;
	end	
	
	return 1;
end


local function OnSort(tbInsA, tbInsB)
	return tbInsB.nEndTime > tbInsA.nEndTime;
end

function FightAfter:GetExpiryInstanceList(pPlayer)
	if not pPlayer then
		return;
	end
	local tbPlayerInstanceList = self.tbPlayerInstanceList[pPlayer.szName];
	if not tbPlayerInstanceList then
		return {};
	end
	
	local tbExpiryPlayerInstanceList = {};
	
	for szInstanceId in pairs(tbPlayerInstanceList) do
		--print(">>>>>>>",szInstanceId);
		if self:CheckInstanceExpiry_player(pPlayer, szInstanceId) == 1 then
			tbExpiryPlayerInstanceList[#tbExpiryPlayerInstanceList + 1] = self.tbInstanceBuffer[szInstanceId];			
		end	
	end	  
	table.sort(tbExpiryPlayerInstanceList,OnSort);
	return tbExpiryPlayerInstanceList;
end

function FightAfter:ShowInstanceDesc(pPlayer, szInstanceId)	
	if self:CheckInstanceExpiry_player(pPlayer, szInstanceId) == 0 then
		return 0;
	end
	local tbInstance    = self.tbInstanceBuffer[szInstanceId];
	local tbPlayerAward = self:RefreshAward(pPlayer, tbInstance);
	pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_FIGHTAFTER",tbInstance,tbPlayerAward});
	return 1;
end

function FightAfter:Award(pPlayer,szInstanceId)	
	if self:CheckInstanceExpiry_player(pPlayer,szInstanceId) == 0 then
		return;
	end

	local tbInstance    = self.tbInstanceBuffer[szInstanceId];
	local tbPlayerAward = self:RefreshAward(pPlayer, tbInstance);	
	
	local nNeedCount = 0;	
	for nIndex, tbItemInfo in ipairs(tbPlayerAward.tbItemList) do
		nNeedCount = nNeedCount + KItem.GetNeedFreeBag(tbItemInfo.tbItemId[1],tbItemInfo.tbItemId[2],tbItemInfo.tbItemId[3],
			tbItemInfo.tbItemId[4],	nil,tbItemInfo.nItemCount);	
	end		

	local nFreeCell = me.CountFreeBagCell();
	if nFreeCell < nNeedCount then
		Dialog:Say(string.format("请把背包清理出<color=yellow> %s 格或以上的空间<color>！",nNeedCount));
		return;
	end;	
	
	--先删再领奖
	FightAfter:DelPlayerAward(pPlayer.szName, szInstanceId);
	GlobalExcute({"FightAfter:DelPlayerAward", pPlayer.szName, szInstanceId});
	GCExcute({"FightAfter:DelPlayerAward",  pPlayer.szName, szInstanceId});
	
	--AWARD--	
	local szItemName = "";
	local nAddCount = 0;
	for nIndex, tbItemInfo in ipairs(tbPlayerAward.tbItemList) do
		nAddCount,szItemName = pPlayer.AddStackItem(tbItemInfo.tbItemId[1], tbItemInfo.tbItemId[2], tbItemInfo.tbItemId[3],
			 tbItemInfo.tbItemId[4], {bForceBind = 1}, tbItemInfo.nItemCount);
			 	
		self:AwardLog(tbInstance,pPlayer.szName,szItemName,nAddCount);
	end	
end

function FightAfter:RefreshPlayerRelation(pPlayer, tbInstance,tbPlayerAward)
	local tbBufferList = {};  --玩家奖励加成列表
	local nRelationType, nFavorLevel = 0, 0;
	
	local tbFavor = {};
	for nIndex, tbPlayerInfo in ipairs(tbInstance.tbTeamer) do
		local szRelationPlayerName = tbPlayerInfo.szName;
		if szRelationPlayerName == pPlayer.szName then
			tbFavor = tbPlayerInfo.tbFavor;
			break;
		end
	end	
	
	for nIndex, tbPlayerInfo in ipairs(tbInstance.tbTeamer) do
		local szRelationPlayerName = tbPlayerInfo.szName;
		if szRelationPlayerName ~= pPlayer.szName then
			nRelationType, nFavorLevel = self:GetRelationTypeAndFavorlevel(pPlayer, szRelationPlayerName);
			tbBufferList[#tbBufferList + 1] = {};
			tbBufferList[#tbBufferList].nIndex = nIndex;
			tbBufferList[#tbBufferList].nRelationType = nRelationType;
			tbBufferList[#tbBufferList].nFavorLevel   = nFavorLevel;	
			tbBufferList[#tbBufferList].nBufferPercent = self.RALATION_BUFFER[nRelationType][nFavorLevel] or 0;
			tbBufferList[#tbBufferList].nFavorAdd	  =  tbFavor[szRelationPlayerName] or 0;
			tbPlayerAward.nTotalBuffer = tbPlayerAward.nTotalBuffer + tbBufferList[#tbBufferList].nBufferPercent;
		end
	end
	return tbBufferList;
end

--刷新领奖
function FightAfter:RefreshAward(pPlayer, tbInstance)	
	local tbPlayerAward = {};
	tbPlayerAward.nTotalBuffer = 0;
	tbPlayerAward.tbBufferList = self:RefreshPlayerRelation(pPlayer, tbInstance, tbPlayerAward);
	if tbPlayerAward.nTotalBuffer > self.BUFFER_MAX then
		tbPlayerAward.nTotalBuffer = self.BUFFER_MAX;
	end
	
	tbPlayerAward.tbItemList = {}; --防止以后多给奖励 所以写成一个TABLE TODO
	tbPlayerAward.tbItemList[1] = {};	
--	tbPlayerAward.tbItemList[1].tbItemId   = {18,1,1,1};
--	tbPlayerAward.tbItemList[1].nItemCount =  0;	
	tbPlayerAward.nTotalCount = 0;
	
	for _, tbInfo in ipairs(tbInstance.tbTeamer) do
		if tbInfo.szName == pPlayer.szName then
			tbPlayerAward.tbItemList[1] = {};
			tbPlayerAward.tbItemList[1].tbItemId = tbInfo.tbAward.tbItem;
			tbPlayerAward.tbItemList[1].nItemCount = self.BOX_TIMES * math.floor(tbInfo.tbAward.nCount *( 1 + tbPlayerAward.nTotalBuffer/100));	
		end
		
	end

	return tbPlayerAward;
end

function FightAfter:OnPlayerRefresh(szInstanceId)	
	if self:CheckInstanceExpiry_player(me,szInstanceId) == 0 then
		return;
	end

	local tbInstance    = self.tbInstanceBuffer[szInstanceId];
	local tbPlayerAward = self:RefreshAward(me, tbInstance);
	me.CallClientScript({"Ui:ServerCall","UI_FIGHTAFTER", "OnAwardRefresh",szInstanceId, tbPlayerAward});
end


function FightAfter:Fly2City(pPlayer)
	for nMapId, tbLeavePos in pairs(self.TB_NEW_WORLD) do
		if IsMapLoaded(nMapId) == 1 then
			pPlayer.NewWorld(unpack(tbLeavePos));
			return;
		end
	end
end


function FightAfter:AwardLog(tbInstance,szPlayerName,szItemName,nItemCount)
	if tbInstance.nType == self.emTYPE_TREASURE then
		TreasureMap2:AwardLog(tbInstance.nTreasureId,tbInstance.nLevel,szPlayerName,szItemName,nItemCount);		
	end
end



--GC数据同步给GS
function FightAfter:OnRecConnectMsg(tbInstance)
	self:AddInstance(tbInstance);
end
