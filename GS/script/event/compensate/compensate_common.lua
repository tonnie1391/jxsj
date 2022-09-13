--回档补偿，普通物品金钱补偿
--孙多良
--2008.08.20
--现在为第33批普通补偿
local Compensate = {};
SpecialEvent.CompensateCommon = Compensate;

Compensate.OPEN        = 1;  		--开启标志
Compensate.TASK_GROUP  = 2027;	 	--补偿任务组
Compensate.TASK_FINISH = 10;	 	--补偿任务变量

--批次---
Compensate.BATCH 	   	= 33;	 	--批次，每次补偿批次赠1(每换一个奖励表赠1)
Compensate.TIME_START 	= 0;	 		--开始时间
Compensate.TIME_END   	= 200909010000;	--结束时间

Compensate.FILE_PATH  = "\\setting\\event\\compensate\\compensate_common.txt";
function Compensate:OnDialog()
	local tbOpt = {
		{"我要领取",self.GetAward, self},
		{"我没丢什么物品，没什么可领的"},
	}
	local szMsg = string.format("您好，在我这里可以领回您丢失的物品。因物品丢失给大家带来的不便，我们深表歉意。\n<color=red>领取截止时间：%s年%s月%s日%s时<color>",math.mod(math.floor(self.TIME_END/10^8), 10^4),math.mod(math.floor(self.TIME_END/10^6), 10^2),math.mod(math.floor(self.TIME_END/10^4), 10^2),math.mod(math.floor(self.TIME_END/10^2), 10^2));
	Dialog:Say(szMsg, tbOpt)
end

function Compensate:CheckState()
	if self.OPEN ~= 1 then
		return 0;
	end
	local nServer = tonumber(string.sub(GetGatewayName(), 5, 6));
	local nDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nDate >= self.TIME_START and nDate < self.TIME_END and self.tbTxt[nServer] ~= nil then
		return 1;
	end
	return 0;
end

function Compensate:GetAward()
	if self:CheckState() == 0 then
		Dialog:Say("补偿活动已经截至。");
		return 0;
	end
	local nServer = tonumber(string.sub(GetGatewayName(), 5, 6));
	if self.tbTxt[nServer][string.upper(me.szAccount)] == nil or self.tbTxt[nServer][string.upper(me.szAccount)][me.szName] == nil then
		Dialog:Say("对不起，您没有丢失的记录，没有可领取的物品。");
		return 0;
	end
	if me.GetTask(self.TASK_GROUP, self.TASK_FINISH) == self.BATCH then
		Dialog:Say("对不起，您已经领取完物品，不能再领取了。");
		return 0;
	end
	local tbItem = self.tbTxt[nServer][string.upper(me.szAccount)][me.szName]

	if me.CountFreeBagCell() < tbItem.nNeedFreeBag then
		Dialog:Say(string.format("对不起，您的背包空间不够，请整理一下背包再来领取。您需要%s格背包空间。", tbItem.nNeedFreeBag));
		return 0;
	end
	if tbItem.nMaxBindMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
		Dialog:Say(string.format("对不起，领取后，您身上的绑定银两将会达到上限，请整理后再来领取。"));
		return 0;		
	end
	if tbItem.nMaxMoney + me.nCashMoney > me.GetMaxCarryMoney() then
		Dialog:Say(string.format("对不起，领取后，您身上的银两将会达到上限，请整理后再来领取。"));
		return 0;
	end
	for _, tbAward in pairs(tbItem.tbAward) do
		local nMoney 		= tbAward.nMoney;
		local nBindMoney 	= tbAward.nBindMoney;
		local nBindCoin		= tbAward.nBindCoin;
		local nBind 		= tbAward.nBind;
		local nNum 			= tbAward.nNum;
		local nTimeLimit 	= tbAward.nTimeLimit;
		local tbAwardItem 	= tbAward.tbItem;
	
		if nMoney > 0 then
			me.Earn(nMoney, Player.emKEARN_ERROR_REAWARD)
			Compensate:WriteLog(me,"领取银两："..nMoney);
		end
		
		if nBindMoney > 0 then
			me.AddBindMoney(nBindMoney, Player.emKBINDMONEY_ADD_ERROR_REAWARD);
			Compensate:WriteLog(me,"领取绑定银两："..nBindMoney);
		end
		
		if nBindCoin > 0 then
			me.AddBindCoin(nBindCoin, Player.emKBINDCOIN_ADD_ERROR_REAWARD);
			Compensate:WriteLog(me,string.format("领取绑定%s：%s",IVER_g_szCoinName, nBindCoin));			
		end
		
		if tbAwardItem[1] > 0 and tbAwardItem[2] > 0 and tbAwardItem[3] > 0 then
			local nG, nD, nP, nL = unpack(tbAwardItem)
			for i=1, nNum do
				local pItem = me.AddItemEx(nG, nD, nP, nL, {bForceBind=nBind});
				if pItem then
					if nTimeLimit >= 0 then
						if nTimeLimit > 0 then
							me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 60 * nTimeLimit));
						else
							--默认有效期30天
							me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 60 * 43200));
						end
						pItem.Sync();
					end
					local szItem = string.format("%s,%s,%s,%s",unpack(tbAwardItem));
					Compensate:WriteLog(me,"领取物品成功 物品ID："..szItem);
				end
			end
		end
		if (tbAward.szDoScript and tbAward.szDoScript ~= "") then
			local fnCmd, szMsg	= loadstring(tbAward.szDoScript,  "[Award]");
			local szResult = "";
			if (not fnCmd) then
				error("Do Award Script CMD failed:"..szMsg);
				szResult = "failed";
			else
				fnCmd();
				szResult = "success";
			end
			Compensate:WriteLog(me ," Compensate:GetAward Do Script CMD "..tbAward.szDoScript .. " execut result:"..szResult);
		end
		me.SetTask(self.TASK_GROUP, self.TASK_FINISH, self.BATCH);
	end


	local szMsg = "您成功领取所有了补偿物品，请查看您的背包。";
	Dialog:Say(szMsg);
end

function Compensate:WriteLog(pPlayer, szMsg)
	Dbg:WriteLog("SpecialEvent.CompensateCommon", "补偿", pPlayer.szAccount, pPlayer.szName, szMsg);
end

function Compensate:ClearBlank(szStr)
	local nSafe = 0; 	--安全。防止死循环，最多只执行50次。
	repeat
		nSafe = nSafe + 1;
		local ni = string.find(szStr, " ") or 0
		if ni and ni > 0 then
			szStr = string.sub(szStr,1, ni-1) .. string.sub(szStr,ni+1);
		end
	until(ni <= 0 or nSafe > 50)
	return szStr;
end

function Compensate:LoadFile()
	self.tbTxt = {};
	local tbFile = Lib:LoadTabFile(self.FILE_PATH);
	if not tbFile then
		return
	end
	for nId=2, #tbFile do
		local tbParam = tbFile[nId];
		local szGateWay = tonumber(tbParam.GATEWAY_NAME);
		if self.tbTxt[szGateWay] == nil then
			self.tbTxt[szGateWay] = {}
		end
		local szAccount = self:ClearBlank(string.upper(tbParam.ACCOUNT));
		if self.tbTxt[szGateWay][szAccount] == nil then
			self.tbTxt[szGateWay][szAccount] = {};
		end
		local szPlayerName = self:ClearBlank(tbParam.PLAYERNAME);
		if self.tbTxt[szGateWay][szAccount][szPlayerName] == nil then
			self.tbTxt[szGateWay][szAccount][szPlayerName] = {};
			self.tbTxt[szGateWay][szAccount][szPlayerName].tbAward = {};
			self.tbTxt[szGateWay][szAccount][szPlayerName].nNeedFreeBag = 0;
			self.tbTxt[szGateWay][szAccount][szPlayerName].nMaxMoney = 0;
			self.tbTxt[szGateWay][szAccount][szPlayerName].nMaxBindMoney = 0;
		end
		local nMoney 		= tonumber(tbParam.MONEY) or 0;
		local nBindMoney 	= tonumber(tbParam.BINDMONEY) or 0;
		local nBindCoin		= tonumber(tbParam.BINDCOIN) or 0;
		local nGenre 		= tonumber(tbParam.GENRE) or 0;
		local nDetailType 	= tonumber(tbParam.DETAILTYPE) or 0;
		local nParticularType = tonumber(tbParam.PARTICULARTYPE) or 0;
		local nLevel 		= tonumber(tbParam.LEVEL) or 1;
		local nBind 		= tonumber(tbParam.BIND) or 0;
		local nNum 			= tonumber(tbParam.NUM) or 1;
		local nTimeLimit 	= tonumber(tbParam.LIMITTIME) or 0;
		local szDoScript	= Lib:ClearStrQuote(tbParam.DOSCRIPT);
		
		local tbTemp = {
				tbItem = {nGenre,nDetailType,nParticularType,nLevel},
				nTimeLimit = nTimeLimit,
				nMoney = nMoney,
				nBindMoney = nBindMoney,
				nBindCoin = nBindCoin,
				nBind = nBind,
				nNum = nNum,
				szDoScript = szDoScript;
		}
		table.insert(self.tbTxt[szGateWay][szAccount][szPlayerName].tbAward, tbTemp);
		if nGenre > 0 and nDetailType > 0 and nParticularType > 0 then
			self.tbTxt[szGateWay][szAccount][szPlayerName].nNeedFreeBag = self.tbTxt[szGateWay][szAccount][szPlayerName].nNeedFreeBag + nNum;
		end
		if nMoney > 0 then
			self.tbTxt[szGateWay][szAccount][szPlayerName].nMaxMoney = self.tbTxt[szGateWay][szAccount][szPlayerName].nMaxMoney + nMoney;
		end
		if nBindMoney > 0 then
			self.tbTxt[szGateWay][szAccount][szPlayerName].nMaxBindMoney = self.tbTxt[szGateWay][szAccount][szPlayerName].nMaxBindMoney + nBindMoney;
		end
	end
	return self.tbTxt;
end

Compensate:LoadFile()