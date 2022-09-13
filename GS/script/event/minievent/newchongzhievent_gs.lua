-------------------------------------------------------------------
--File: newchongzhievent.lua
--Author: zhouchenfei
--Date: 2012/3/3 11:38:57
--Describe: 新充值活动
-------------------------------------------------------------------

--EventManager.EventManager.tbEvent = {
--		["tbDialog"] = {
--		{
--			[nNpcId] = 
--			{
--				[nNum] = {
--					[1] = {
--							[1] = szName,
--							[2] = self.OnDialog,
--							[3] = self
--						}, -- tbDialog
--					[2] = {
--						
--						}, -- tbPartTime
--				},
--			}
--		}
--	};
--
--Lib:CallBack({tbDi[2],tbDi[3]});
--local tbDi = EventManager.EventManager.tbEvent[100].tbEventPart[1].tbDialog[1].tbDialog;
--Lib:CallBack({tbDi[2],tbDi[3]});


EventManager.tbChongZhiEvent = EventManager.tbChongZhiEvent or {};
local tbChongZhiEvent = EventManager.tbChongZhiEvent;

tbChongZhiEvent.MSG_NOT_OPEN = [[<color=gold>尊敬的玩家朋友：<color>
    本月充值三大强力超值回馈系列活动火热进行中，凡达到活动条件的玩家朋友即可参加。 
<color=green>充值领奖活动<color>
    <color=yellow>领奖时间<color>：本月中下旬开放至月底
    <color=yellow>活动介绍<color>：本活动不仅有丰厚的福利回馈、方便实用的便利道具，更有超值的游戏增值货币以及高端珍品的购买资格。本月还有特色充值神秘礼物赠送，敬请关注！
<color=green>幸运奖券活动<color>
    <color=yellow>抽奖时间<color>：本月中下旬开启至月底，每晚10点开奖
    <color=yellow>活动介绍<color>：活动期间使用幸运奖券即可参加本活动，在抽奖期间内每晚产生金奖（1名，价值5000元）、银奖（5名，价值500元）、铜奖（若干名，价值88元）。白银/黄金装备购买资格等你拿！
<color=green>百万实物抽奖活动<color>
    <color=yellow>抽奖时间<color>：隔月中旬开放抽奖，请关注系统邮件
    <color=yellow>活动介绍<color>：凡本月【奇珍阁消耗】满100元（1万金币）以上和【限时充值】满100元以上的玩家均可参加此强力超值回馈活动，100%中奖。最高5000元京东商城购物资格，百万商品任你选，包邮哦！]];

tbChongZhiEvent.nFreshTime = 10;
tbChongZhiEvent.nEventId_Avtive = 101;
tbChongZhiEvent.nPartId_Avtive = 1;

tbChongZhiEvent.nEventId_ChangeYueGui = 95;
tbChongZhiEvent.nPartId_ChangeYueGui = 2;

tbChongZhiEvent.nEventId_ChangePuTi = 95;
tbChongZhiEvent.nPartId_ChangePuTi = 3;

tbChongZhiEvent.nEventId_ChangeLeitingyin = 95;
tbChongZhiEvent.nPartId_ChangeLeitingyin = 14;

tbChongZhiEvent.nEventId_BindCoinBack = 100;
tbChongZhiEvent.nPartId_BindCoinBack = 5;

tbChongZhiEvent.nEventId_Lottory = 102;

tbChongZhiEvent.nEventId_GetLottoryAward = 102;
tbChongZhiEvent.nPartId_GetLottoryAward = 1;
tbChongZhiEvent.szLastChongZhi = "http://jxsj.xoyo.com/zt/2012/09/10/cz/index.shtml";

tbChongZhiEvent.nAvtiveHighlight = 0;

-- 只有在新手村，城市才能领取奖励

tbChongZhiEvent.tbNeedCheckParam = {
		["CheckTaskEq"] = 1,
	};

tbChongZhiEvent.tbNeedCheckParam_BackCoin = {
		["CheckMonthPay"] = 1,
		["AddExBindCoinByPay"] = 1,
	};

function tbChongZhiEvent:ApplyProcessPayAward(nProt, tbInfo)
	if (nProt == self.PROT_ACTIVE) then
		self:ApplyActive();
	elseif (nProt == self.PROT_UPDATEMONEY) then
		self:GetValue();
	elseif (nProt == self.PROT_UPDATEDATA) then
		self:GetData();
	elseif (nProt == self.PROT_PROCESS_AWARD) then
		self:ApplyGetPayAward(tbInfo);
	elseif (nProt == self.PROT_OPEN_WND) then
		self:ApplyOpenPayAward();
	elseif (nProt == self.PROT_CHANGE_YUEGUI) then
		local tbOpt = {
				{"<color=yellow>菩提果*1<color>兑换<color=yellow>特别的精魄*5<color>", self.ApplyGetPayAward, self, {{self.nEventId_ChangePuTi, self.nPartId_ChangePuTi}}},
				{"<color=yellow>广寒月桂花*1<color>兑换<color=yellow>玄晶宝箱*1<color>", self.ApplyGetPayAward, self, {{self.nEventId_ChangeYueGui, self.nPartId_ChangeYueGui}}},
				{"暂时不兑换"},
			};
		
		if TimeFrame:GetState("OpenLevel150") >= 1 then
			table.insert(tbOpt, 3, {"<color=yellow>雷霆印碎片*10<color>兑换<color=yellow>雷霆印*1<color>", self.ApplyGetPayAward, self, {{self.nEventId_ChangeLeitingyin, self.nPartId_ChangeLeitingyin}}});
		end
		
		Dialog:Say("这位客官，我这里提供礼品兑换操作，你可以选择兑换所需要的物品，祝您游戏愉快！", tbOpt);
	elseif (nProt == self.PROT_BINCOIN_BACK) then
		self:ApplyGetPayAward({{self.nEventId_BindCoinBack, self.nPartId_BindCoinBack}});
	elseif (nProt == self.PROT_LOTTORY) then
		self:ApplyGetPayAward({{self.nEventId_GetLottoryAward, self.nPartId_GetLottoryAward}});
	end
end

function tbChongZhiEvent:OpenUrl_LastWeb()
	me.CallClientScript({"OpenWebSite", self.szLastChongZhi});
end

function tbChongZhiEvent:ApplyActive()
	local nFlag, szMsg = self:CheckPayAward(self.nEventId_Avtive);
	if (0 ~= nFlag) then
		if (1 == nFlag) then
			Dialog:Say(szMsg);
			return 0;	
		end

		local szMsg = self.MSG_NOT_OPEN;

		Dialog:Say(szMsg, {
				{"了解上月充值活动", self.OpenUrl_LastWeb, self},
				{"我已了解活动详情"},
			});
		return 0;
	end	
	
	self:ApplyGetPayAward({{self.nEventId_Avtive, self.nPartId_Avtive}});
end

function tbChongZhiEvent:CheckPayAwardOpen(nEventId)
	local tbParam = {};
	if (not nEventId) then
		nEventId = self.nEventId_Avtive;
	end
	local tbEvent = EventManager:GetEventTableEx(nEventId);
	
	if (not tbEvent or not tbEvent.tbEvent) then
		return 0;
	end
	
	tbParam[1] = string.format("CheckGDate:%s,%s",tbEvent.tbEvent.nStartDate, tbEvent.tbEvent.nEndDate);
	local nFlag, szMsg = EventManager.tbFun:CheckParam(tbParam, 2);
	if not nFlag or nFlag == 0 then
		return 1;
	end
	return 0;
end

function tbChongZhiEvent:CheckLottoryOpen()
	local tbParam = {};
	local tbEvent = EventManager:GetEventTableEx(self.nEventId_Lottory);
	
	if (not tbEvent or not tbEvent.tbEvent) then
		return 0;
	end
	
	tbParam[1] = string.format("CheckGDate:%s,%s",tbEvent.tbEvent.nStartDate, tbEvent.tbEvent.nEndDate);
	local nFlag, szMsg = EventManager.tbFun:CheckParam(tbParam, 2);
	if not nFlag or nFlag == 0 then
		return 1;
	end
	return 0;
end

function tbChongZhiEvent:CheckPayAward(nEventId)
	-- 只在新手村、和城市才能使用
	
	if (self.nOpenFlag == 0) then
		return 1, "活动未开启。";
	end
	
	if (self:CheckPayAwardOpen(nEventId) == 0) then
		return 2, "充值促销活动没开启！";
	end
	
	if me.IsAccountLock() ~= 0 then
		return 1, "你的账号处于锁定状态，无法打开界面。";
	end
	if Account:Account2CheckIsUse(me, 8) == 0 then
		return 1, "你正在使用副密码登陆游戏，设置了权限控制，无法进行该操作！";
	end
	if (GLOBAL_AGENT) then
		return 1, "全局服务器不能打开界面。";
	end
	
	return 0;
end

function tbChongZhiEvent:ApplyOpenPayAward()
	local nFlag, szMsg = self:CheckPayAward();
	if (0 ~= nFlag) then
		if (me.nFightState == 1) then
			me.Msg(szMsg);
			return 0;	
		end
		
		if (1 == nFlag) then
			Dialog:Say(szMsg);
			return 0;	
		end

		local szMsg = self.MSG_NOT_OPEN;

		Dialog:Say(szMsg, {
				{"了解上月充值活动", self.OpenUrl_LastWeb, self},
				{"我已了解活动详情"},
			});
		return 0;
	end
	me.CallClientScript({"UiManager:OpenWindow", "UI_PAYAWARD"});
end

function tbChongZhiEvent:ApplyGetPayAward(tbSendInfo)
	if (not tbSendInfo or #tbSendInfo <= 0) then
		return 0;
	end
	
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		me.Msg("只能在各大新手村和城市才能领取充值优惠奖励！");
		return 0;
	end
	
	for nIndex, tbInfo in pairs(tbSendInfo) do
		local nEventId	= tbInfo[1];
		local nPartId	= tbInfo[2];
		local nFlag, szMsg = self:CheckPayAward(nEventId);
		if (0 ~= nFlag) then
			if (me.nFightState == 1) then
				me.Msg(szMsg);
				return 0;	
			end
			
			if (1 == nFlag) then
				Dialog:Say(szMsg);
				return 0;	
			end
	
			local szMsg = self.MSG_NOT_OPEN;
	
			Dialog:Say(szMsg, {
					{"了解上月充值活动", self.OpenUrl_LastWeb, self},
					{"我已了解活动详情"},
				});
			return 0;
		end
	end
	
	for nIndex, tbInfo in pairs(tbSendInfo) do
		local nEventId	= tbInfo[1];
		local nPartId	= tbInfo[2];
		EventManager:GotoEventPartTable(nEventId, nPartId, 0, 0, 1, 1, 0, 0);
	end

	return 1;
end

function tbChongZhiEvent:GetValue(nDirect)
	local nFlag, szMsg = self:CheckPayAward();
	if (0 ~= nFlag) then
		if (me.nFightState == 1) then
			me.Msg(szMsg);
			return 0;	
		end
		
		if (1 == nFlag) then
			Dialog:Say(szMsg);
			return 0;	
		end

		local szMsg = self.MSG_NOT_OPEN;

		Dialog:Say(szMsg, {
				{"了解上月充值活动", self.OpenUrl_LastWeb, self},
				{"我已了解活动详情"},
			});
		return 0;
	end

	local tbMyTemp		= EventManager:GetTempTable();
	
	if (not tbMyTemp.nPayAwardGetValueFreshTime) then
		tbMyTemp.nPayAwardGetValueFreshTime = 0;
	end
	
	-- 这里做了不及时刷新机制，10秒钟才刷新

	local nNowTime = GetTime();
	if (not nDirect or nDirect ~= 1) then
		if (nNowTime - tbMyTemp.nPayAwardGetValueFreshTime < self.nFreshTime) then
			return 0;
		end
	end
	
	EventManager:GetTempTable().nPayAwardGetValueFreshTime = nNowTime;
	me.CallClientScript({"UiManager:Update", "UI_PAYAWARD", me.GetExtMonthPay(), me.GetPayActionState(1)});
end

function tbChongZhiEvent:GetData(nDirect)
	local nFlag, szMsg = self:CheckPayAward();
	if (0 ~= nFlag) then
		me.Msg(szMsg);
		return 1;
	end

	self:SyncData(nDirect);
	return 0;
end

function tbChongZhiEvent:SyncData(nDirect)

	local tbMyTemp		= EventManager:GetTempTable();
	
	if (not tbMyTemp.nPayAwardFreshTime) then
		tbMyTemp.nPayAwardFreshTime = 0;
	end
	
	-- 这里做了不及时刷新机制，10秒钟才刷新
	if (not nDirect or nDirect ~= 1) then
		local nNowTime = GetTime();
		if (nNowTime - tbMyTemp.nPayAwardFreshTime < self.nFreshTime) then
			return 1;
		end
	end
	local tbClassState = {};
	for nClassId, tbClass in pairs(self.tbChongZhiAward) do		
		if (tbClass.tbAwardList) then
			local tbAwardCount = {};
			for nType, tbType in pairs(tbClass.tbAwardList) do
				for nItem, tbItem in pairs(tbType.tbList) do
					local nEventType = tbItem.nEventType;
					if (not tbAwardCount[nEventType]) then
						tbAwardCount[nEventType] = {};
					end
					if (tbItem.szAwardType == "CoinBuyItem") then
						local nIndex = tonumber(tbItem.szAward);
						local nCount = SpecialEvent.BuyItem:GetCount(nIndex);
						local tbAward = SpecialEvent.BuyItem.tbItemList[nIndex];
						tbAwardCount[nEventType][tbItem.szAward] = nCount;
					elseif (tbItem.szAwardType == "CoinBuyHeShiBi") then
						local nCount = SpecialEvent.BuyHeShiBi:GetCount();
						tbAwardCount[nEventType][tbItem.szAward] = nCount;
					end
				end
				
				for nEventType, tbAward in pairs(tbType.tbAwardEventType) do					
					local nEventId	= tbAward.nEventId;
					local nPartId	= tbAward.nPartId;
					local tbParam	= EventManager:GetEventPartTable(nEventId, nPartId).tbParam;					
					local nFlag, szMsg = EventManager.tbFun:CheckParamEx(tbParam, self.tbNeedCheckParam);
					
					if (5 == nClassId) then
						nFlag, szMsg = EventManager.tbFun:CheckParamEx(tbParam, self.tbNeedCheckParam_BackCoin);
					end
					
					local tbEvent	= { nClassId, nType, nEventType, nFlag };
					if (Lib:CountTB(tbAwardCount[nEventType]) > 0) then
						table.insert(tbEvent, tbAwardCount[nEventType]);
					end
					tbClassState[#tbClassState + 1] = tbEvent;
				end
			end
		end
	end

	EventManager:GetTempTable().nPayAwardFreshTime = nNowTime;
	me.CallClientScript({"Ui:ServerCall", "UI_PAYAWARD", "UpdatePayAwardData" , me.GetPayActionState(1), tbClassState, self.nAvtiveHighlight});
	self.nAvtiveHighlight = 0;
	return 0;

end

function tbChongZhiEvent:GetPayAwardYeliandashi()
	local szMsg = "";
	if (self.nOpenFlag == 0) then
		return szMsg;
	end
	
	if (self:CheckPayAwardOpen(nEventId) == 0) then
		return szMsg;
	end

	if (GLOBAL_AGENT) then
		return szMsg;
	end
	
	szMsg = string.format("\n\n<color=yellow>注：本月充值50元可获得强化优惠符，充值588元可获得强化传承优惠符。<color>");
	
	return szMsg;
end

function tbChongZhiEvent:OnLogin_ProcessPayAward(bExchangeServerComing)
	if (bExchangeServerComing == 1) then
		return 0;
	end

	if (self.nOpenFlag == 0) then
		return 0;
	end
	
	if (self:CheckPayAwardOpen() == 0) then
		return 0;
	end
	
	if (GLOBAL_AGENT) then
		return 0;
	end
	
	local nLastLogoutTime = me.GetLastLogoutTime();
	local nNowDay = tonumber(GetLocalDate("%Y%m%d"));
	local nLastDay	= tonumber(os.date("%Y%m%d", nLastLogoutTime));
	
	if (nNowDay == nLastDay) then
		self.nAvtiveHighlight = 0;
	else
		self.nAvtiveHighlight = 1;
	end

	self:SyncData();
end

PlayerEvent:RegisterGlobal("OnLogin", tbChongZhiEvent.OnLogin_ProcessPayAward, tbChongZhiEvent);
