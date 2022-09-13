-- 文件名　：lottery_gs.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-09-18 19:12:38
-- 描  述  ：

function NewLottery:GSSynStart()
	self.nInSyn = 1;
end

function NewLottery:GSSynEnd()
	self.nInSyn = 0;
end

function NewLottery:GSDataIsValid()
	if not self.nInSyn or self.nInSyn == 1 then
		return 0;
	else
		return 1;
	end
end

function NewLottery.__sort_dialog_cmp(tb1, tb2)
	return tb1[4] < tb2[4];
end

function NewLottery:OnDialog()
	local nRes, var = NewLottery:GetPlayerAwardList(me);
	if nRes == 0 then
		Dialog:Say(var);
		return;
	end
	
	local tbOpt = {};
	for nDate, tbAwardInDate in pairs(var) do
		local nTime = Lib:GetDate2Time(nDate);
		local hasAward = 0;
		local szMsg = string.format("领取%d月%d日的奖励", tonumber(os.date("%m", nTime)), tonumber(os.date("%d", nTime)));
		local tbAward = {}
		for nAward, nAwardNum in pairs(tbAwardInDate) do
			if nAwardNum > 0 then
				hasAward = 1;
				tbAward[nAward] = nAwardNum;
			end
		end
		
		if hasAward == 1 then
			table.insert(tbOpt, {szMsg, NewLottery.OnDialog2, NewLottery, nDate, tbAward});
		end
	end
	
	table.sort(tbOpt, self.__sort_dialog_cmp);
	table.insert(tbOpt, {"Ta chỉ đến xem thôi"});
	Dialog:Say("你运气不错呀，中了大奖，下面是你可以领取的奖励。恭喜恭喜啊，哈哈~~~~！", tbOpt);
end

function NewLottery:OnDialog2(nDate, tbAward)
	local tbOpt = {}
	for nAward, szAwardName in ipairs(self.tbAwardName) do
		local nAwardNum = tbAward[nAward];
		if nAwardNum then
			local szMsg = string.format("%s %d次", szAwardName, nAwardNum);
			table.insert(tbOpt, {szMsg, NewLottery.GetAward, NewLottery, me, nDate, nAward, nAwardNum});		
		end
	end
	
	table.insert(tbOpt, "Ta chỉ đến xem thôi");
	local nTime = Lib:GetDate2Time(nDate);
	local szMsg = string.format("领取%d月%d日的奖励", tonumber(os.date("%m", nTime)), tonumber(os.date("%d", nTime)));
	Dialog:Say(szMsg, tbOpt);
end

function NewLottery:SyncAwardInfo()
	local tbPlayerList	= KPlayer.GetAllPlayer();
	for _, pPlayer in ipairs(tbPlayerList) do
		NewLottery:SendMyAwardInfo(pPlayer);
	end
end

function NewLottery:SendMyAwardInfo(pPlayer)
	local nRes, var = NewLottery:GetPlayerAwardList(pPlayer);
	if nRes == 0 then
		var = {};
	end
	pPlayer.CallClientScript({"Task.tbHelp:OnUpdateLottroyData", var});
	return 1;
end

function NewLottery:OnLogin_ProcessAward(bExchangeServerComing)
	if (bExchangeServerComing == 1) then
		return 0;
	end

	local nFlag = EventManager.tbChongZhiEvent:CheckLottoryOpen();
	if (nFlag ~= 1) then
		return 0;
	end
	
	self:SendMyAwardInfo(me);
end

PlayerEvent:RegisterGlobal("OnLogin", NewLottery.OnLogin_ProcessAward, NewLottery);

--?pl DoScript("\\script\\event\\lottery\\lottery_gs.lua")
