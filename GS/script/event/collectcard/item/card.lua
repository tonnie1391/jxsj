Require("\\script\\event\\collectcard\\define.lua")

local tbItem = Item:GetClass("guoqing_card");
local CollectCard = SpecialEvent.CollectCard;
tbItem.nCastSkillId 	=  307;

function tbItem:OnUse()
	local nTaskId = CollectCard.TASK_CARD_ID[it.nParticular][1];
	if not nTaskId then
		return 0;
	end
	
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M%S"));	
	if nData < CollectCard.TIME_STATE[1] or 
		KGblTask.SCGetDbTaskInt(DBTASK_NATIONAL_DAY_CLEAR_DATE) == 0 --未清数据
	then
		me.Msg("活动还未开启，请稍后再进行鉴定。")
		return 0;
	end
	if nData >= CollectCard.TIME_STATE[2] then
		me.Msg("卡片已过期，自动销毁。")
		return 1;
	end
	
	local tbFind1 = me.FindItemInBags(unpack(CollectCard.CARD_BAG));
	local tbFind2 = me.FindItemInRepository(unpack(CollectCard.CARD_BAG));
	if #tbFind1 <= 0 and #tbFind2 <= 0 then
		if me.CountFreeBagCell() >= 3 then
			local pItem = me.AddItem(unpack(CollectCard.CARD_BAG));
			if pItem then
				local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 43200*60 )
				me.SetItemTimeout(pItem, szDate);
			end
		else
			me.Msg("使用民族大团圆卡需要3格背包空间，去整理下再来吧");
			return 0;
		end
	end
	
	if me.CountFreeBagCell() < 2 then
		me.Msg("使用民族大团圆卡需要2格背包空间，去整理下再来吧");
		return 0;
	end
	
	if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COLLECTCARD_RANDOM) == it.nParticular then
		--获得幸运奖;
		self:OnUseSpecial(it.dwId);
	else
		--获得安慰奖;
		Item:GetClass("randomitem"):SureOnUse(43);	
		CollectCard:WriteLog("使用卡片，获得了鼓励奖", me.nId);
		self:PutCardIntoCardBag(it);
	end
end

function tbItem:PutCardIntoCardBag(pItem)
	local nTaskId = CollectCard.TASK_CARD_ID[pItem.nParticular][1];
	if me.GetTask(CollectCard.TASK_GROUP_ID, nTaskId) == 0 then
		me.SetTask(CollectCard.TASK_GROUP_ID, nTaskId, 1);
		me.Msg(string.format("您成功将“%s”放入了收藏册",pItem.szName));
		local nAwarId, szDesc, nCollect, nOpenMaxCard = CollectCard:GetAward_CardBag_InFor();
		local nAddHonor = PlayerHonor:GetPlayerHonorByName(me.szName, PlayerHonor.HONOR_CLASS_SPRING, 0) + 1;
		if nCollect < nAddHonor then
			nCollect = nAddHonor;
		end
		PlayerHonor:SetPlayerHonorByName(me.szName, PlayerHonor.HONOR_CLASS_SPRING, 0, nCollect);
	end
	
	--收集到所有卡片,做记录
	if me.GetTask(CollectCard.TASK_GROUP_ID, CollectCard.TASK_COLLECT_FINISH) == 0 then
		local nCollectCount = 0;
		for _, tbTask in pairs(CollectCard.TASK_CARD_ID) do
			if me.GetTask(CollectCard.TASK_GROUP_ID, tbTask[1]) == 1 then
				nCollectCount = nCollectCount + 1;
			end
		end
		if nCollectCount == 56 then
			Dialog:SendBlackBoardMsg(me, "您已经搜集到所有民族大团圆卡，共56张，恭喜恭喜！")
			me.SetTask(CollectCard.TASK_GROUP_ID, CollectCard.TASK_COLLECT_FINISH, 1);
			me.CastSkill(self.nCastSkillId, 1, -1, me.GetNpc().nIndex);
			--GCExcute{"SpecialEvent.CollectCard:AddCollectCount"};
		end
	end
	
	pItem.Delete(me);
end

-- 今日幸运卡
function tbItem:OnUseSpecial(dwId, nAwardType)
	local pItem = KItem.GetObjById(dwId);
	if (not pItem) then
		return;
	end
	
	if not nAwardType then
		local szMsg = "这张是今天的幸运民族大团圆卡！你要选择哪种奖励？";
		local tbOpt = {
			{"1500绑定" .. IVER_g_szCoinName, self.OnUseSpecial, self, dwId, 1},
			{"摇奖获得奇珍阁不绑定道具", self.OnUseSpecial, self, dwId, 2},
			{"Để ta suy nghĩ thêm"},
			};
		Dialog:Say(szMsg, tbOpt);
	else
		if nAwardType == 1 then
			Item:GetClass("randomitem"):SureOnUse(43);
			me.AddBindCoin(1500, Player.emKBINDCOIN_ADD_GUOQING_CARD);
			CollectCard:WriteLog("使用幸运卡，获得1500绑定" .. IVER_g_szCoinName, me.nId);
		elseif nAwardType == 2 then
			Item:GetClass("randomitem"):SureOnUse(43);
			Item:GetClass("randomitem"):SureOnUse(44);
			CollectCard:WriteLog("使用幸运卡，获得奇珍阁不绑定道具", me.nId);
		end
		self:PutCardIntoCardBag(pItem);
	end
end

function tbItem:InitGenInfo()
	local nTime = tonumber(os.date("%Y%m%d", GetTime()));
	nTime = Lib:GetDate2Time(nTime);
	nTime = nTime + 86400
	it.SetTimeOut(0, nTime);
	return {};
end