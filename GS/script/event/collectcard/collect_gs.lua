
Require("\\script\\event\\collectcard\\define.lua")
local CollectCard = SpecialEvent.CollectCard;

function CollectCard:GetAward_GS(nPlayerId, nFlag)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if (not pPlayer) then
		return;
	end	
	if nFlag == 1 then
		--获得黄金令牌
		local pItem = pPlayer.AddItem(unpack(self.ITEM_GOLDTOKEN));
		if pItem then
			local szData = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 43200*60 )
			pPlayer.SetItemTimeout(pItem, szData);
			CollectCard:WriteLog("全服唯一黄金令牌获得玩家，获得了黄金令牌", pPlayer.nId)
		end
		pItem = pPlayer.AddItem(unpack(self.ITEM_GOLDHUOJU));
		if pItem then
			pPlayer.SetItemTimeout(pItem, self:CreateStrDate(4));
			CollectCard:WriteLog("全服唯一黄金令牌获得玩家，获得了黄金火炬", pPlayer.nId)
		end
		KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, string.format("%s打开盛夏活动黄金宝箱，获得了盛夏活动黄金令牌，可兑换技能+1腰带！ ", pPlayer.szName));
	elseif nFlag ==  2 then
		--获得白银令牌
		local pItem = pPlayer.AddItem(unpack(CollectCard.ITEM_WHITETOKEN));
		if pItem then
			local szData = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 43200*60 )
			pPlayer.SetItemTimeout(pItem, szData);
			CollectCard:WriteLog("全服唯一白银令牌获得玩家，获得了白银令牌", pPlayer.nId)			
		end
		pItem = pPlayer.AddItem(unpack(CollectCard.ITEM_GOLDHUOJU));
		if pItem then
			pPlayer.SetItemTimeout(pItem, self:CreateStrDate(4));
			CollectCard:WriteLog("全服唯一白银令牌获得玩家，获得了黄金火炬", pPlayer.nId)
		end
	else
		self:GetAward_BaoXiang(pPlayer, 1);
	end
	pPlayer.AddWaitGetItemNum(-1);
	return 0;
end

function CollectCard:XiuLianZhu()
	
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
	
	if nData < self.TIME_STATE[3] then
		Dialog:Say("火炬手评选将会在<color=yellow>8月28日<color>开始，<color=yellow>8月31日22点<color>结束，敬请期待。");
		return 1;
	end
	
	if nData >= self.TIME_STATE[5] then
		Dialog:Say("火炬手评选已经关闭");
		return 1;
	end

	local szMsg = "盛夏活动火炬手评选:\n\n<color=yellow>";
	local nRank = 0;
	for ni = DBTASD_EVENT_COLLECTCARD_RANK01, DBTASD_EVENT_COLLECTCARD_RANK10 do
		local nPoint = KGblTask.SCGetDbTaskInt(ni);
		local szName = KGblTask.SCGetDbTaskStr(ni);
		nRank = nRank + 1;
		if nPoint > 0 and szName ~= "" then
			szMsg = szMsg .. Lib:StrFillL(string.format("第%2s名：%s", nRank, szName), 25).. nPoint .."分\n"
		end
	end
	
	szMsg = szMsg .. "<color>\n评选结束时间：<color=red>8月31日22：00<color>\n";
	szMsg = szMsg .. "\n您目前的积分：\n".. string.format("<color=yellow>%s：%s分<color>", me.szName, me.GetTask(self.TASK_GROUP_ID, self.TASK_HUOJU_POINT));
	Dialog:Say(szMsg);
end


--获取卡册奖励
function CollectCard:GetAward_CardBag_InFor()
	local nCollectCount = 0;
	local szItemName = "";
	local szDesc = "";
	for nPId, tbTask in pairs(self.TASK_CARD_ID) do
		if me.GetTask(self.TASK_GROUP_ID, tbTask[1]) == 1 then
			nCollectCount = nCollectCount + 1;
		end
	end
	local nMaxOpenCard = me.GetTask(self.TASK_GROUP_ID, self.TASK_COLLECT_COUNT);
	if nCollectCount < 4 and nMaxOpenCard < 40 then
		szDesc = "您收集到的活动卡数量太低，不能获得活动奖励";
		return -1, szDesc, nCollectCount, nMaxOpenCard;
	end	
	
	local nType = 0;
	local nAwardId = 0;
	if nMaxOpenCard == 50 then
		nType = 3;
	elseif nMaxOpenCard >= 40 then
		nType = 2;
	else
		nType = 1;
	end
	for ni, nCount in ipairs(CollectCard.CARD_BAG_AWARD_STEP[nType]) do
		if nCollectCount >= nCount then
			szItemName = KItem.GetNameById(unpack(CollectCard.CARD_BAG_AWARD[ni]))
			nAwardId = ni;
			break;
		end
	end
	szDesc = "1个"..szItemName;
	return nAwardId, szDesc, nCollectCount, nMaxOpenCard;
end

--宝箱奖励
function CollectCard:GetAward_BaoXiang(pPlayer, nTypeId)
	local nMaxRate = self.BaoXiangFile[nTypeId].MaxRate;
	local nRandomRate = Random(nMaxRate) + 1;
	local nSum = 0;
	for _, tbItem in pairs(self.BaoXiangFile[nTypeId].RateItem) do
		nSum = nSum + tbItem.nRate;
		if nSum >= nRandomRate then
			if tbItem.nMoney > 0 then
				local nAddMoney = pPlayer.Earn(tbItem.nMoney, Player.emKEARN_COLLECT_CARD);
				if nAddMoney == 1 then
					CollectCard:WriteLog(string.format("开启%s类盛夏箱子，成功获得了%s银两",nTypeId, tbItem.nMoney), pPlayer.nId)
				else
					CollectCard:WriteLog(string.format("开启%s类盛夏箱子，银两达到上限,获得了%s银两失败",nTypeId, tbItem.nMoney), pPlayer.nId)
				end
			end
			if tbItem.nGenre > 0 and tbItem.nDetailType > 0 and tbItem.nParticularType > 0 then
				local pItem = pPlayer.AddItem(tbItem.nGenre, tbItem.nDetailType, tbItem.nParticularType, tbItem.nLevel);
				if pItem then
					CollectCard:WriteLog(string.format("开启%s类盛夏箱子，获得了%s",nTypeId, pItem.szName), pPlayer.nId)
				end
			end
			break;
		end
	end
	for _, tbItem in pairs(self.BaoXiangFile[nTypeId].FixItem) do
		if tbItem.nGenre > 0 and tbItem.nDetailType > 0 and tbItem.nParticularType > 0 then
			local pItem = pPlayer.AddItem(tbItem.nGenre, tbItem.nDetailType, tbItem.nParticularType, tbItem.nLevel);
			if pItem then
				pPlayer.SetItemTimeout(pItem, self:CreateStrDate(4));
				CollectCard:WriteLog(string.format("开启%s类盛夏箱子，获得了%s",nTypeId, pItem.szName), pPlayer.nId)
			end
		end
	end
end

--获得盛夏活动卡（未鉴定）;
function CollectCard:GetAward_EventCard(pPlayer, nNum)
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
	if nData >= self.TIME_STATE[1] and nData < self.TIME_STATE[2] then
		for i=1, nNum do 
			local pItem = pPlayer.AddItem(unpack(self.ITEM_CARD_ORG));
			if pItem then
				local szDate = GetLocalDate(self:CreateStrDate(2))
				pPlayer.SetItemTimeout(pItem, szDate);
			end
		end
	end
end

function CollectCard:CheckEventTime(szClass)
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
	
	if not szClass then
		if nData >= self.TIME_STATE[1] and nData < self.TIME_STATE[5] then
			return 1;
		end
		return 0;
	elseif szClass == "OnAward_EventCard" then
		if nData >= self.TIME_STATE[1] and nData < self.TIME_STATE[2] then
			return 1;
		end
		return 0;		
	elseif szClass == "OnAward_Card_Bag" then
		if nData >= self.TIME_STATE[1] and nData < self.TIME_STATE[3] then
			return 1;
		end
		return 0;		
	end
end

function CollectCard:CreateStrDate(nState)
	local nDate = self.TIME_STATE[nState];
	local nSec = Lib:GetDate2Time(math.floor(nDate/100))
	
	local szDate = os.date("%Y/%m/%d/%H/%M/%S", nSec);
	return szDate;
end

function CollectCard:GetPlayerRankByName(szName)
	local nClass = PlayerHonor.HONOR_CLASS_SPRING;
	local nType = Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_ACTION, Ladder.LADDER_TYPE_LADDER_ACTION_SPRING);
	return PlayerHonor:GetPlayerHonorRankByName(szName, nClass, nType);
end


function CollectCard:ChuxiaoOnLogin()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate >= 20091001 then
		return 0;
	end
	local nReg = EventManager:GetTask(129);
	local nPay = me.GetTask(2093, 13);
	local nCurPay = me.GetExtMonthPay();
	if nReg > 0 then
		if nPay >= 120 then
			return 0;
		end
		if nPay >=60 and nCurPay < 120 then
			return 0;
		end
		if nCurPay < 60 then
			return 0;
		end
		local szPay = 60;
		if nCurPay >= 120 then
			szPay = 120;
		end
		me.SetTask(2093, 13, nCurPay);
		local szMsg = string.format("你成功获得“九月幸运第二波活动”九月累计充值达到%s元的资格", szPay);
		Dialog:SendBlackBoardMsg(me, szMsg);
		me.Msg(string.format("<color=yellow>%s<color>",szMsg));
	end
end
CollectCard.nChuxiaoOnLoginId = PlayerEvent:RegisterOnLoginEvent(CollectCard.ChuxiaoOnLogin, CollectCard);
