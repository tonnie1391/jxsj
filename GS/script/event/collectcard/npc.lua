Require("\\script\\event\\collectcard\\define.lua")

local CollectCard = SpecialEvent.CollectCard;

--按江湖威望领取盛夏活动卡
function CollectCard:OnAward_EventCard()
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
	
	if nData < self.TIME_STATE[1] then
		Dialog:Say("从9月21日到10月10日，江湖威望达到一定值就可以来领取民族大团圆卡。");
		return 1;
	end	
	
	if nData >= self.TIME_STATE[2] then
		Dialog:Say("民族大团圆卡领取已经结束");
		return 1;
	end		
	local nKinId, nKinMemId = me.GetKinMember();
	local szFailDesc = "";
	if nKinId == nil or nKinId <= 0 then
		szFailDesc = "您没有加入家族，没有江湖威望，不能领取民族大团圆卡。";
		Dialog:Say(szFailDesc);
		return 1;
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		szFailDesc = "您没有加入家族，没有江湖威望，不能领取民族大团圆卡。";
		Dialog:Say(szFailDesc);
		return 1;
	end
	local cMember = cKin.GetMember(nKinMemId);
	if not cMember then
		szFailDesc = "您没有加入家族，没有江湖威望，不能领取民族大团圆卡。";
		Dialog:Say(szFailDesc);
		return 1;
	end	
	if me.GetTask(self.TASK_GROUP_ID, self.TASK_WEIWANG_AWARD) == tonumber(GetLocalDate("%Y%m%d")) then
		szFailDesc = "你今天已经领过卡片了，不要来欺骗老人家啊。";
		Dialog:Say(szFailDesc);
		return 1;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("领取卡片需要背包空间1格，去整理下再来。")
		return 1;
	end
	local nPlayerId = cMember.GetPlayerId();
	local nRepute = KGCPlayer.GetPlayerPrestige(nPlayerId);
	if nRepute < self.AWARD_WEIWANG[#self.AWARD_WEIWANG][1] then
		Dialog:Say("您的江湖威望不足30，不能在这里领取盛夏活动卡");
		return 1;
	end
	--for _, tbParam in ipairs(self.AWARD_WEIWANG) do
	--	if nRepute >= tbParam[1] then
			self:GetAward_EventCard(me, 1);
			me.SetTask(self.TASK_GROUP_ID, self.TASK_WEIWANG_AWARD, tonumber(GetLocalDate("%Y%m%d")));
			--Dialog:Say("成功领取了1张民族大团圆卡。");
			return 1;
	--	end
	--end
	--Dialog:Say("您的江湖威望不足，没有奖励可领取。");
end

--卡册换取奖励
function CollectCard:OnAward_Card_Bag(nFlag, __debug_rank, __debug_card_num)
	
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
	
	if nData < self.TIME_STATE[2] then
		Dialog:Say("活动卡收集奖励领取会在<color=yellow>10月11日<color>到<color=yellow>10月17日<color>开放，在这之前，要努力收集民族大团圆卡啊！");
		return 1;
	end
	
	if me.GetTask(self.TASK_GROUP_ID, self.TASK_CARD_BAG_AWARD_FINISH) ~= 0 then
		Dialog:Say("你已经领取过奖励了，还想要？");
		return 1;	
	end
	
	local tbFind1 = me.FindItemInBags(unpack(CollectCard.CARD_BAG));
	if not tbFind1 or #tbFind1 <= 0 then
		Dialog:Say("你的收集册在哪？快给我看看？");
		return 1;
	end
	
	local nType = Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_ACTION, Ladder.LADDER_TYPE_LADDER_ACTION_SPRING);
	local nClass = PlayerHonor.HONOR_CLASS_SPRING;
	local nRank = __debug_rank or PlayerHonor:GetPlayerHonorRank(me.nId, nClass, nType);
	local nAwardId, szDesc, nCollect, __nOpenMaxCard = CollectCard:GetAward_CardBag_InFor();
	local nOpenMaxCard = __debug_card_num or __nOpenMaxCard;

	local szDetail;
    if nRank <= 3000 then
    	szDetail = string.format("获得了%s名", nRank);
    else
    	szDetail = string.format("共鉴定了%s张卡片", nOpenMaxCard);
    end	
	
	local szMsg = string.format("你在这次的民族卡收集中表现不错，<color=gold>%s<color>。这是你的奖励，你需要拿你的收集册来换，现在要换取吗？",
		szDetail);
	if nFlag ~= 1 then
		local tbOpt = {
			{"Nhận", self.OnAward_Card_Bag, self, 1, __debug_rank, __debug_card_num},
			{"Kết thúc đối thoại"}
		}
		szMsg = szMsg .. "你是否现在领取呢？";
		Dialog:Say(szMsg, tbOpt)
		return 1;
	end
	
	local nType, tbGDPL, nItemNum = self:GetFinalAwardNationalDay09(nRank, nOpenMaxCard, me);
	if nType == 0 then
		Dialog:Say("你收集的卡片似乎少了些，下次努力吧！");
		CollectCard:WriteLog(string.format("国庆卡片收集获得 %s等奖", nRank), me.nId)
		me.ConsumeItemInBags(#tbFind1,unpack(CollectCard.CARD_BAG)); -- 删背包
		me.SetTask(self.TASK_GROUP_ID, self.TASK_CARD_BAG_AWARD_FINISH, 1)
		return 1;
	end
	
	if me.CountFreeBagCell() < nItemNum then
		Dialog:Say(string.format("领取奖励需要%s格背包空间，去整理下再来。", nItemNum));
		return 1;
	end
		
	
	local nError = 0
	
	if nType == 1 then
		me.AddRepute(unpack(tbGDPL));
	end
	if nType == 2 then
		for i = 1, nItemNum do
			local pItem = me.AddItem(unpack(tbGDPL));
			if pItem then
				me.SetItemTimeout(pItem, 43200 , 0);
			end
		end
	end
	CollectCard:WriteLog(string.format("国庆卡片收集获得 %s等奖", nRank), me.nId)
	me.ConsumeItemInBags(#tbFind1,unpack(CollectCard.CARD_BAG)); -- 删背包
	me.SetTask(self.TASK_GROUP_ID, self.TASK_CARD_BAG_AWARD_FINISH, 1)
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("国庆卡片收集获得 %s等奖", nRank));	
	Dialog:Say(string.format("你成功领取国庆卡片收集%s名的奖励。",nRank));
end

--火炬领取奖励
function CollectCard:OnAwardHuoJu(nFlag)
	
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
	
	if nData < self.TIME_STATE[4] then
		Dialog:Say("火炬手评选奖励领取会在<color=yellow>8月31日22点<color>到<color=yellow>9月14日24点<color>之间开放");
		return 1;
	end
	
	if nData > self.TIME_STATE[5] then
		Dialog:Say("火炬手评选奖励领取已经关闭");
		return 1;
	end		
	
	local nRank = 0;
	local nMeRank = 0;
	for ni = DBTASD_EVENT_COLLECTCARD_RANK01, DBTASD_EVENT_COLLECTCARD_RANK10 do
		local nPoint = KGblTask.SCGetDbTaskInt(ni);
		local szName = KGblTask.SCGetDbTaskStr(ni);
		nRank = nRank + 1;
		if me.szName == szName then
			nMeRank = nRank;
			break;
		end
	end
	
	if me.GetTask(self.TASK_GROUP_ID, self.TASK_HUOJU_FINISH) == 1 then
		Dialog:Say("您已领取了火炬积分奖励。")
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("您背包空间不足。")
		return 0;
	end
	local nPoint = me.GetTask(self.TASK_GROUP_ID, self.TASK_HUOJU_POINT);
	if nPoint <= 0 then
		Dialog:Say("您的火炬手积分为0，可以通过使用盛夏活动火炬获得火炬手积分")
		return 1;
	end	
	if nFlag ~= 1 then
		local tbOpt = 
		{
			{"Nhận", self.OnAwardHuoJu, self, 1},
			{"Kết thúc đối thoại"},
		}
		Dialog:Say("人人争当火炬手，参加火炬手竞选有机会获得丰厚的奖励，您确定要领取奖励吗？", tbOpt);
		return 1;
	end
	local nPoint = me.GetTask(self.TASK_GROUP_ID, self.TASK_HUOJU_POINT);
	if nMeRank == 1 then
		local pItem = me.AddItem(unpack(self.ITEM_GOLDTOKEN));
		if pItem then
			pItem.Bind(1);
			me.SetItemTimeout(pItem, 43200);
			me.SetTask(self.TASK_GROUP_ID, self.TASK_HUOJU_FINISH, 1);
			CollectCard:WriteLog(string.format("第%s名火炬手领取奖励，获得了%s, 积分:%s", nMeRank, pItem.szName, nPoint), me.nId)
		end
		Dialog:Say("您成功领取了火炬积分奖励");		
		return 1;
	end
	if nMeRank == 2 or nMeRank == 3 then
		if nPoint >= self.HUOJU_AWARD_STEP[1] then
			local pItem = me.AddItem(unpack(self.ITEM_GOLDTOKEN));
			if pItem then
				pItem.Bind(1);
				local szData = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 43200 * 60 )
				me.SetItemTimeout(pItem, szData);
				me.SetTask(self.TASK_GROUP_ID, self.TASK_HUOJU_FINISH, 1);
				CollectCard:WriteLog(string.format("第%s名火炬手领取奖励，获得了%s, 积分:%s", nMeRank, pItem.szName, nPoint), me.nId)			
			end
		else
			local pItem = me.AddItem(unpack(self.ITEM_WHITETOKEN));
			if pItem then
				pItem.Bind(1);
				local szData = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 43200 * 60 )
				me.SetItemTimeout(pItem, szData);
				me.SetTask(self.TASK_GROUP_ID, self.TASK_HUOJU_FINISH, 1);
				CollectCard:WriteLog(string.format("第%s名火炬手领取奖励，获得了%s, 积分:%s", nMeRank, pItem.szName, nPoint), me.nId)			
			end
		end
		Dialog:Say("您成功领取了火炬积分奖励");		
		return 1;
	end
	
	if nPoint < 20 then
		Dialog:Say("您的火炬手积分不足20，可以通过使用盛夏活动火炬获得火炬手积分")
		return 1;
	end
	for ni, nPointTemp in ipairs(self.HUOJU_AWARD_STEP) do
		if nPoint >= nPointTemp then
			local pItem = me.AddItem(unpack(self.HUOJU_AWARD[ni].tbItem));
			if pItem then
				if self.HUOJU_AWARD[ni].nTimeLimit and self.HUOJU_AWARD[ni].nTimeLimit > 0 then
					local szData = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + self.HUOJU_AWARD[ni].nTimeLimit * 60 )
					me.SetItemTimeout(pItem, szData);
				end
				if self.HUOJU_AWARD[ni].nBind == 1 then
					pItem.Bind(1);
				end
				me.SetTask(self.TASK_GROUP_ID, self.TASK_HUOJU_FINISH, 1);
				CollectCard:WriteLog(string.format("火炬手领取奖励，火炬手积分:%s, 获得了%s", nPoint, pItem.szName), me.nId);
			end	
			break;	
		end
	end
	Dialog:Say("您成功领取了火炬积分奖励");
end

