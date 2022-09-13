-------------------------------------------------------------------
--File: 	fudai.lua
--Author: 	sunduoliang
--Date: 	2008-3-4 19:30:24
--Describe:	黄金福袋

local tbFuDaiItem = Item:GetClass("fudai");
tbFuDaiItem.AWARD_FILE 			= "\\setting\\event\\tianjianghongfu\\fudaiitem.txt";
tbFuDaiItem.AWARD_FILE_MONEY 	= "\\setting\\event\\tianjianghongfu\\fudaiitem_money.txt";
tbFuDaiItem.AWARD_FILE_EXP 		= "\\setting\\event\\tianjianghongfu\\fudaiitem_exp.txt";
tbFuDaiItem.BASE_EXP_FILE = "\\setting\\player\\attrib_level.txt"        --基准奖励文件
tbFuDaiItem.TASK_GROUP_ID = 2013;
tbFuDaiItem.TASK_COUNT_ID = 1; --记录使用次数
tbFuDaiItem.TASK_DATE_ID = 2;  --记录日期
tbFuDaiItem.TASK_COUNT_LIMIT = 3; -- 记录最大开福袋上限
tbFuDaiItem.TASK_COUNT_EX 	 = 4; -- 额外次数
tbFuDaiItem.TASK_GETEXTRACOUNT_FLAG = 5;	-- 合服之后子服务器玩家是否领取过额外开启福袋的机会
tbFuDaiItem.TASK_COUNT_SUBPLAYER_EXTRA = 6;	-- 合服之后给子服务器玩家获得的额外福袋开启机会次数
tbFuDaiItem.TASK_COUNT_TODAY_CANOPEN = 7;	-- 合服之后子服务器玩家当天可以额外开启的福袋次数
tbFuDaiItem.VIP = IVER_g_nPayLevel1;  --充值15元可开启20次

tbFuDaiItem.DEF_COZONE_COMPOSE_MINDAY = 7;

tbFuDaiItem.ITEM_USE_COUNT_MAX = 
{
	nCommon = 10,
	nVip	= 20,
};	--一天最大使用次数

tbFuDaiItem.AWARD_LEVEL = 
{
	[1] 	= 1,	--超凡 金钱福袋
	[2] 	= 1,	--出尘 金钱福袋
	[3] 	= 1,	--凌绝 金钱福袋
	[4] 	= 1,	--惊世 金钱福袋
	[5] 	= 1,	--御空 金钱福袋
	[6] 	= 1,	--混天 金钱福袋
	[7] 	= 1,	--雏凤 金钱福袋
	[8] 	= 1,	--潜龙 金钱福袋
	[9] 	= 1,	--至尊 金钱福袋
	[10] 	= 2,	--无双 经验福袋
};

tbFuDaiItem.tbItemList = {};

function tbFuDaiItem:OnUse()
	self:SureUse(it.dwId);
	return 0;
end

function tbFuDaiItem:SureUse(nItemId, nFlag)
	local pPlayer = me;
	local pItem = KItem.GetObjById(nItemId);	
	if not pItem then
		return 1;
	end	
	local nDate = tonumber(GetLocalDate("%y%m%d"))
	if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_DATE_ID) ~= nDate then
		local nExtraTime = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_SUBPLAYER_EXTRA);
		if (nExtraTime < 0) then
			nExtraTime = 0;
		end
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_TODAY_CANOPEN, nExtraTime);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_DATE_ID, nDate);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID, 0);
	end
	local nMaxUse =  self.ITEM_USE_COUNT_MAX.nCommon;
	local nVip = 0;

	if pPlayer.GetExtMonthPay() >= self.VIP then
		nMaxUse = self.ITEM_USE_COUNT_MAX.nVip;
		nVip = 1;
	end
	
	local nNowTime		= GetTime();
	
	-- *******合服优惠，合服7天后过期*******
	local bCoZoneAdd = 0;
	local nCoZoneTime	= KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);
	if nNowTime < nCoZoneTime + 7 * 24 * 60 * 60 and pPlayer.nLevel >= 50 then
		nMaxUse = nMaxUse + 5;
		bCoZoneAdd = 1;
		--print("并服期间福袋nMaxUse为"..nMaxUse);
	end
	-- *************************************
	
	-- *******合服优惠，给子服务器玩家额外的福袋开启机会*******
	if (pPlayer.nLevel >= 50) then
		if (pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_GETEXTRACOUNT_FLAG) < nCoZoneTime and 
			nCoZoneTime + 10 * 24 * 60 * 60 > nNowTime) then
			local nExtraTime = self.DEF_COZONE_COMPOSE_MINDAY * 10;
			
			if (pPlayer.IsSubPlayer() == 1) then
				nExtraTime = math.max(nExtraTime, math.floor(KGblTask.SCGetDbTaskInt(DBTASK_SERVER_STARTTIME_DISTANCE) / (24 * 3600)) * 10);
			end
			
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_GETEXTRACOUNT_FLAG, GetTime());
			if (nExtraTime > 0) then
				pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_SUBPLAYER_EXTRA, nExtraTime);
				pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_TODAY_CANOPEN, nExtraTime);
			end
		end
		if (pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_SUBPLAYER_EXTRA) > 0) then
			local nHaveUse = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID);
			if (nHaveUse >= nMaxUse) then
				local nCountSubPlayer = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_SUBPLAYER_EXTRA) - 1;
				if (nCountSubPlayer < 0) then
					nCountSubPlayer = 0;
				end
				pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_SUBPLAYER_EXTRA, nCountSubPlayer);
			end
			nMaxUse = nMaxUse + pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_TODAY_CANOPEN);
		end
	end
	-- ********************************************************
	
	local nUseCount = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID);
	local nExCount 	= pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_EX);

	if nUseCount >= nMaxUse then		
		if pPlayer.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1 then
			return 1;
		end
		pPlayer.AddBindMoney(100, Player.emKBINDMONEY_ADD_FUDAI2);
		KStatLog.ModifyAdd("bindjxb", "[产出]黄金福袋开出", "总量", 100);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID, nUseCount + 1);
		pPlayer.Msg(string.format("Hôm nay bạn đã mở <color=yellow>%s<color> Túi Phúc, xin chúc mừng bạn đã nhận được <color=yellow>100<color> bạc khóa. Mở <color=yellow>%s<color> túi phúc đầu tiên mỗi ngày sẽ nhận được phần thưởng phong phú, chúc bạn vui vẻ.", nUseCount + 1, nMaxUse));
		SpecialEvent.ActiveGift:AddCounts(pPlayer, 4);		--开启福袋活跃度
		SpecialEvent.tbGoldBar:AddTask(pPlayer, 1);		--金牌联赛开启福袋
		return 1;
	end
	local nMaxProbability = 1000000;
	local nRate = Random(nMaxProbability) + 1;
	local nRateSum = 0;
	local nLevel = pPlayer.GetHonorLevel();
	local tbItemList = self.tbItemList;
	if self.AWARD_LEVEL[nLevel] then
		if self.AWARD_LEVEL[nLevel] == 1 then
			tbItemList = self.tbItemList_Money;
		elseif self.AWARD_LEVEL[nLevel] == 2 then
			tbItemList = self.tbItemList_Exp;
		end
	end
	
	for _, tbItem in pairs(tbItemList) do
		nRateSum = nRateSum + tbItem.nProbability;
		if nRate <= nRateSum then
			if pPlayer.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1 then
				return 1;
			end
			if self:GetItem(pPlayer, tbItem, nFlag) == 0 then
				return 0;
			end
			SpecialEvent.ActiveGift:AddCounts(pPlayer, 4);		--开启福袋活跃度
			SpecialEvent.tbGoldBar:AddTask(pPlayer, 1);		--金牌联赛开启福袋
			--2012春节活动额外福袋奖励
			if SpecialEvent.SpringFestival2012 and SpecialEvent.SpringFestival2012:IsEventOpen() == 1 then
				SpecialEvent.SpringFestival2012:GiveSpringFestivalPrizeBag(pPlayer);
			end
			return 1;
		end
	end
	return 1;
end

function tbFuDaiItem:GetItem(pPlayer, tbitem, nFlag)
	if pPlayer == nil then
		return 0;
	end
	local szFriendMsg = "";
	local szMsg = "Bạn mở Túi Phúc Hoàng Kim nhận được ";
	if tbitem.nAnnouce == 1 then
		szMsg = string.format("%s mở Túi Phúc Hoàng Kim nhận được ",pPlayer.szName);
	end
	if tbitem.nBaseExp ~= 0 then
		local nAddExp = pPlayer.GetBaseAwardExp() * tbitem.nBaseExp;
		szMsg = string.format("%s<color=yellow>%s<color> điểm kinh nghiệm, ",szMsg, nAddExp);
		pPlayer.AddExp(nAddExp);
	end
	
	if tbitem.nMoney ~= 0 then
		szMsg = string.format("%s<color=yellow>%s<color>bạc, ",szMsg,tbitem.nMoney);
		szFriendMsg = string.format("<color=yellow>%s<color> bạc", tbitem.nMoney);
		pPlayer.Earn(tbitem.nMoney, Player.emKEARN_FUDAI);
		KStatLog.ModifyAdd("jxb", "[产出]黄金福袋开出", "总量", tbitem.nMoney);
	end
	if tbitem.nBindMoney ~= 0 then
		szMsg = string.format("%s<color=yellow>%s<color> bạc khóa, ",szMsg,tbitem.nBindMoney);
		szFriendMsg = string.format("<color=yellow>%s<color> bạc khóa", tbitem.nBindMoney);
		if me.GetBindMoney() + tbitem.nBindMoney > me.GetMaxCarryMoney() then			
			local pItemEx = me.AddItem(18,1,527,3);
			if pItemEx then
				pItemEx.Bind(1);
				pItemEx.SetGenInfo(1, tbitem.nBindMoney);
				me.SetItemTimeout(pItemEx, 7*24*60, 0);
				pItemEx.Sync();
			end
		else
			pPlayer.AddBindMoney(tbitem.nBindMoney, Player.emKBINDMONEY_ADD_FUDAI);
			KStatLog.ModifyAdd("bindjxb", "[产出]黄金福袋开出", "总量", tbitem.nBindMoney);
		end
	end
	
	if tbitem.nCoin ~= 0 then
		pPlayer.AddBindCoin(tbitem.nCoin, Player.emKBINDCOIN_ADD_FUDAI)
		szMsg = string.format("%s<color=yellow>%s<color> %s khóa, ",szMsg,tbitem.nCoin, IVER_g_szCoinName);
		szFriendMsg = string.format("<color=yellow>%s<color> %s khóa", tbitem.nCoin, IVER_g_szCoinName);
		KStatLog.ModifyAdd("bindcoin", "[产出]黄金福袋开出", "总量", tbitem.nCoin);
	end
	if tbitem.nAnnouce == 1 then
		szMsg = string.format("%s thật sự may mắn!",szMsg);
	else
		szMsg = string.format("%s thật may mắn!",szMsg);
	end	
	if tbitem.nAnnouce == 1 then
		KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
		--公告
		if (szFriendMsg ~= "") then
			pPlayer.SendMsgToFriend("Hảo hữu của bạn ["..pPlayer.szName.."] mở Túi Phúc Hoàng Kim "..szFriendMsg..".");
			Player:SendMsgToKinOrTong(pPlayer, " mở Túi Phúc Hoàng Kim "..szFriendMsg..".", 1);
		end
	end
	
	if nFlag == 2 then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_EX, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_EX) - 1);
		pPlayer.Msg(string.format("Bạn đã sử dụng lần mở thêm, bạn còn <color=yellow>%s<color> cơ hội mở thêm Túi Phúc.", pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_EX)));
	end
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID) + 1);
	local nCount = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID);
	local szMsgPay	= "";
	local nMsgFlag	= 0;
	local nTotalCount = self.ITEM_USE_COUNT_MAX.nCommon;
	if pPlayer.GetExtMonthPay() >= self.VIP then
		nMsgFlag = nMsgFlag + 1;
		szMsgPay = string.format("由于您正在享受本月的充值优惠，");
		nTotalCount = self.ITEM_USE_COUNT_MAX.nVip;
	end
	if EventManager.IVER_bOpenFuFaiVip == 0 then
		szMsgPay = "";
	end
	
	-- *******合服优惠，合服7天后过期*******
	if GetTime() < KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME) + 7 * 24 * 60 * 60 and pPlayer.nLevel >= 50 then
		if (nMsgFlag <= 0) then
			szMsgPay = "由于您正享受着合服7天优惠，"
		else
			szMsgPay = szMsgPay .. "、合服7天优惠，"
		end
		nTotalCount = nTotalCount + 5;
	end
	-- *************************************
	
	local szMsg2 = string.format("<color=yellow>%s<color> Hôm nay đã mở <color=yellow>%s túi<color>, <color=yellow>%s túi đầu tiên<color> sẽ nhận được phần thưởng phong phú!", szMsg, nCount, nTotalCount);
	
	local szMsg3 = "";
	if (pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_SUBPLAYER_EXTRA) > 0 and pPlayer.nLevel >= 50) then
		local nExtraTime = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_SUBPLAYER_EXTRA);
		if (nExtraTime > 0) then
			szMsg3 = szMsg3 .. "作为合服的补偿，您今天还有<color=yellow>" .. nExtraTime .. "<color>次额外开启福袋的机会。";
			pPlayer.Msg(szMsg3);
		end
	end
	pPlayer.Msg(szMsg2);
	return 1;
end

function tbFuDaiItem:LoadItemList()
	self.tbItemList = self:LoadList(self.AWARD_FILE);
	self.tbItemList_Money 	= self:LoadList(self.AWARD_FILE_MONEY);
	self.tbItemList_Exp 	= self:LoadList(self.AWARD_FILE_EXP);
end

function tbFuDaiItem:LoadList(szFile)
	local tbItemList = {};
	local tbFile = Lib:LoadTabFile(szFile);
	if tbFile == nil then
		return 0;
	end
	for ni, tbItem in pairs(tbFile) do
		local nProbability = tonumber(tbItem.PROB) or 0;
		local nBaseExp = tonumber(tbItem.BASE_EXP) or 0;
		local nMoney = tonumber(tbItem.MONEY)or 0;
		local nBindMoney = tonumber(tbItem.BINDMONEY)or 0;
		local nCoin = tonumber(tbItem.COIN) or 0;
		local nAnnouce = tonumber(tbItem.ANNOUNCE)or 0;
		local nCount = #tbItemList + 1;
		tbItemList[nCount] = {};
		tbItemList[nCount].nProbability = nProbability;
		tbItemList[nCount].nBaseExp = nBaseExp;
		tbItemList[nCount].nMoney = nMoney;
		tbItemList[nCount].nBindMoney = nBindMoney;
		tbItemList[nCount].nCoin = nCoin;
		tbItemList[nCount].nAnnouce = nAnnouce;	
	end
	return tbItemList;
end

-- 直接打开充值界面
function tbFuDaiItem:OnOpenOnlinePay()
	if IVER_g_nSdoVersion == 1 then
		me.CallClientScript({"OpenSDOWidget"});
		return;
	end
	local szZoneName = GetZoneName();
	me.CallClientScript({"Ui:ServerCall", "UI_PAYONLINE", "OnRecvZoneOpen", szZoneName});	
end

if tbFuDaiItem.tbItemList == nil or #tbFuDaiItem.tbItemList == 0 then
	tbFuDaiItem:LoadItemList()
end

