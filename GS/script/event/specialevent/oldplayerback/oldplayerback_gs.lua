-- 文件名  : oldplayerback_gs.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-08-30 17:04:00
-- 描述    :  老玩家回归

if not MODULE_GAMESERVER then
	return;
end

SpecialEvent.tbOldPlayerBack = SpecialEvent.tbOldPlayerBack or {};
local tbOldPlayerBack = SpecialEvent.tbOldPlayerBack or {};

-------------------------------转新服-----------------------------------
--Dialog
function tbOldPlayerBack:OnDialog_New()
	local szMsg = "如果您是江湖前辈转入到本服这里有丰富的奖励等着您。"
	local tbOpt = {{"激活资格", self.ActivatePlayer, self, 1},
		{"领取绑金绑银返还", self.Get2NewGateAward, self},
		{"领取额外奖励", self.Get2NewGateAwardItem, self},
		{"Để ta suy nghĩ thêm"}
		};
		
	Dialog:Say(szMsg, tbOpt);	
end

--转新服玩家领奖
function tbOldPlayerBack:Get2NewGateAward()
	if not self.tbOldPlayerInfo or not self.tbOldPlayerInfo[1] then
		return;
	end
	local bIsActivate = me.GetTask(self.TASK_GID, self.TASK_TASKID_ACTIVATE_NEW);
	if bIsActivate == 0 then
		Dialog:Say("您还没有激活资格呢，快去激活吧。", {"Ta hiểu rồi"});
		return 0;
	end
	
	local szAccount = string.lower(me.szAccount);
	if not self.tbOldPlayerInfo[1][szAccount] then		
		Dialog:Say("您好像没有奖励能领取！", {"Ta hiểu rồi"});
		return 0;
	end
	if GetGatewayName() ~= self.tbOldPlayerInfo[1][szAccount][1] then
		Dialog:Say("您好像没有奖励能领取！", {"Ta hiểu rồi"});
		return 0;
	end
	local nTimes = 10;	
	local nAwardInfoCoin = self.tbOldPlayerInfo[1][szAccount][4];
	local nAwardInfoMoney = self.tbOldPlayerInfo[1][szAccount][5];
	local szMsg = string.format("您是江湖前辈可以在我这里领取很丰富的奖励哦！\n<color=red>注：领奖截止时间：%s", os.date("%Y年%m月%d日", Lib:GetDate2Time(self.nCloseDate[1]))).."24：00点<color>";
	local tbOpt = {{"Để ta suy nghĩ thêm"}};
	local nState = 0;
	local szColor = "white";
	for i = 1, #self.tbLevel do
		nState = 0;
		szColor = "white";
		local nFlagCoin = math.fmod(nAwardInfoCoin, nTimes);
		nAwardInfoCoin = math.floor(nAwardInfoCoin/nTimes);
		local nFlagMoney = math.fmod(nAwardInfoMoney, nTimes);
		nAwardInfoMoney = math.floor(nAwardInfoMoney/nTimes);		
		if (nFlagCoin == 0 and nFlagMoney == 0) or me.nLevel < self.tbLevel[i][1] then
			szColor = "gray";
		end
		table.insert(tbOpt, 1, {string.format("<color=%s>%s级奖励<color>",szColor, self.tbLevel[i][1]), self.Get2NewGateAwardEx, self, i, 0, nFlagCoin, nFlagMoney});
	end
	Dialog:Say(szMsg, tbOpt);
end

--转新服玩家领奖
function tbOldPlayerBack:Get2NewGateAwardEx(nNum, nFlag, nFlagCoin, nFlagMoney, nType)	
	local szAccount = string.lower(me.szAccount);
	local nPayCount = self.tbOldPlayerInfo[1][szAccount][2];
	local szOldAccount = self.tbOldPlayerInfo[1][szAccount][3];
	local nTimecoe = self.tbOldPlayerInfo[1][szAccount][6];
	local nBindCoin = math.floor(nPayCount * nTimecoe * self.nRate2NewPlayer_Coin * self.nRateBindCoin * self.tbLevel[nNum][2] / 100);
	local nBindMoney = math.floor(nPayCount * nTimecoe * self.nRate2NewPlayer_Money * self.nRateBindMoney * self.tbLevel[nNum][2] / 100);
	local szCoinColor = "white";
	local szMoneyColor = "white";
	if nFlagCoin == 0 or me.nLevel < self.tbLevel[nNum][1] then
		szCoinColor = "gray";
	end
	if nFlagMoney == 0 or me.nLevel < self.tbLevel[nNum][1] then
		szMoneyColor = "gray";
	end
	local nGetBindCoin = math.floor(nBindCoin * self.nReBackCoinRate);
	local nConsumeCoin = math.floor(nBindCoin * (1 - self.nReBackCoinRate));
	local nGetBindMoney = math.floor(nBindMoney * self.nReBackCoinRate);
	local nConsumeMoney = math.floor(nBindMoney * (1 - self.nReBackCoinRate));
	if nFlag == 0 then
		local szMsg = string.format("您的老账户为<color=yellow>%s<color>，新账户为<color=yellow>%s<color>，在我这里您可以领取<color=yellow>%s绑金<color>和<color=yellow>%s绑银<color>,以及增加<color=yellow>%s绑金<color>的消耗返还额，<color=yellow>%s绑银<color>的消耗返还额(消费多少返还多少，每次奇珍阁消费后立即返还)，您确定领取吗？\n", szOldAccount, me.szAccount, nGetBindCoin, nGetBindMoney, nConsumeCoin, nConsumeMoney)
		local tbOpt = {{string.format("<color=%s>领取绑定金币<color>",szCoinColor), self.Get2NewGateAwardEx, self, nNum, 1, nFlagCoin, nFlagMoney, 4},
			{string.format("<color=%s>领取绑定银两<color>",szMoneyColor), self.Get2NewGateAwardEx, self, nNum, 1, nFlagCoin, nFlagMoney, 5},
			{"Để ta suy nghĩ thêm"}}
		Dialog:Say(szMsg, tbOpt);
		return;
	end
	if nType then
		if me.nLevel < self.tbLevel[nNum][1] then
			Dialog:Say("提升到对应等级再来领奖吧！",{"Ta hiểu rồi"});
			return;
		end
		if nType == 4 then
			if nFlagCoin == 0 then
				Dialog:Say("您已经领取过了！",{"Ta hiểu rồi"});
				return;
			end
		elseif  nType == 5 then
			if nFlagMoney == 0 then
				Dialog:Say("您已经领取过了！",{"Ta hiểu rồi"});
				return;
			end
			local bCanLoad, szMsg = self:CheckCanLoad(nBindMoney);
			if bCanLoad == 1 then
				Dialog:Say(szMsg,{"Ta hiểu rồi"});
				return;
			end
		end
	end
	if nType and nType == 4 then
		me.AddBindCoin(nGetBindCoin, Player.emKBINDCOIN_ADD_OLD_RETURN);
		me.SetTask(self.TASK_GID, self.TASK_TASKID_BANDCOIN_RETURN, me.GetTask(self.TASK_GID, self.TASK_TASKID_BANDCOIN_RETURN) + nConsumeCoin);
		me.Msg(string.format("恭喜您获得<color=yellow>%s绑金<color>及<color=yellow>%s绑金<color>的消耗返还额度!", nGetBindCoin, nConsumeCoin));
	elseif nType and nType == 5 then
		me.AddBindMoney(nGetBindMoney);
		me.SetTask(2034,11, me.GetTask(2034,11) + nConsumeMoney);
		me.Msg(string.format("恭喜您获得<color=yellow>%s绑银<color>及<color=yellow>%s绑银<color>的消耗返还额度!!", nGetBindMoney, nConsumeMoney));
	end	
	local nAwardInfo = self.tbOldPlayerInfo[1][szAccount][nType];
	nAwardInfo = nAwardInfo - math.pow(10, nNum - 1);
	self:SaveBuffer_GS(1, szAccount, nAwardInfo, nType);
end

--转新服道具装备奖励
function tbOldPlayerBack:Get2NewGateAwardItem(nFlag)	
	local bIsActivate = me.GetTask(self.TASK_GID, self.TASK_TASKID_ACTIVATE_NEW);
	if bIsActivate == 0 then
		Dialog:Say("您还没有激活资格呢，快去激活吧。", {"Ta hiểu rồi"});
		return 0;
	end
	if not nFlag then
		local tbOpt = {
			{"领取特殊背包", self.Get2NewGateAwardItem, self, 1},
			{"领取等级及装备奖励", self.Get2NewGateAwardItem, self, 2},
			{"Để ta suy nghĩ thêm"}
			};
			
		Dialog:Say(" 这里有丰富的奖励等着您来领取呢。", tbOpt);
		return;
	end
	if me.CountFreeBagCell() < 1  then
		Dialog:Say("Hành trang không đủ 1 ô trống.", {"Ta hiểu rồi"});		
		return 0;
	end
	if nFlag == 1 then
		if me.GetTask(self.TASK_GID, self.TASK_TASKID_ITEM_NEW) == 1 then
			Dialog:Say("你已经领取过了。", {"Ta hiểu rồi"});			
			return 0;
		end
		local pItem = me.AddItem(unpack(self.tbItem2NewExBag));
		if pItem then
			pItem.Bind(1);
		end
		me.SetTask(self.TASK_GID, self.TASK_TASKID_ITEM_NEW, 1);
	elseif nFlag == 2 then
		if me.GetTask(self.TASK_GID, self.TASK_TASKID_EQUIT_NEW) == 1 then
			Dialog:Say("你已经领取过了。", {"Ta hiểu rồi"});			
			return 0;
		end
		local szGatewayMe = GetGatewayName();
		local tbAward = self.tbEquit2New[szGatewayMe];
		if not tbAward or type(tbAward) ~= "table"then
			Dialog:Say("没有奖励可以领取", {"Ta hiểu rồi"});
			return 0;
		end
		local pItem = me.AddItem(unpack(tbAward[1]));
		if pItem then
			pItem.Bind(1);
		end
		local nLevel = tbAward[2];
		if nLevel and nLevel - me.nLevel > 0 then
			me.AddLevel(nLevel - me.nLevel);
		end
		me.SetTask(self.TASK_GID, self.TASK_TASKID_EQUIT_NEW, 1);
	end
	return;
end


-----------------------------------老玩家-------------------------------------

--Dialog
function tbOldPlayerBack:OnDialog_Old()
	local szMsg = "如果您是江湖前辈回老服这里有丰富的奖励等着您，当然如果不是您也可以邀请江湖前辈回来，<color=yellow>一起参加活动<color>也同样会有<color=yellow>丰富的奖励<color>。\n<color=red>注意：完成家族任务有效期为自激活起30天内<color>";
	local tbOpt = {		
		{"激活资格", self.ActivatePlayer, self, 2},
		{"领取绑金绑银返还", self.GetOldPlayerBack, self},
		{"领取额外奖励", self.GetOldPlayerBackAwardItem, self},
		{"Để ta suy nghĩ thêm"}
		};
		
	Dialog:Say(szMsg, tbOpt);	
end

--老玩家召回领奖
function tbOldPlayerBack:GetOldPlayerBack()
	if not self.tbOldPlayerInfo or not self.tbOldPlayerInfo[2] or not self.tbOldPlayerInfo2 or not self.tbOldPlayerInfo3 then
		return;
	end
	local bIsActivate = me.GetTask(self.TASK_GID, self.TASK_TASKID_ACTIVATE_OLD);
	if bIsActivate == 0 then
		Dialog:Say("您还没有激活资格呢，先去激活资格吧。", {"Ta hiểu rồi"});
		return 0;
	end
	local szAccount = string.lower(me.szAccount);
	if not self.tbOldPlayerInfo[2][szAccount] and not self.tbOldPlayerInfo2[szAccount] and not self.tbOldPlayerInfo3[szAccount] then
		Dialog:Say("您好像没有奖励能领取！", {"Ta hiểu rồi"});
		return;
	end
	if me.GetRoleCreateDate() >= self.nRoleCreateDate then
		Dialog:Say("您好像没有奖励能领取！",{"Ta hiểu rồi"});
		return;
	end	
	if me.GetTask(self.TASK_GID, self.TASK_TASKID_ITEM_OLD_TIMES) == 1 then
		Dialog:Say("你已经领取过啦。", {"Ta hiểu rồi"});
		return 0;
	end
	local tbOldPlayerInfo = self.tbOldPlayerInfo[2];
	if self.tbOldPlayerInfo2[szAccount] then
		tbOldPlayerInfo = self.tbOldPlayerInfo2;		
	end
	if self.tbOldPlayerInfo3[szAccount] then
		tbOldPlayerInfo = self.tbOldPlayerInfo3;
	end
	local nPayCount = tbOldPlayerInfo[szAccount][1];
	local nTimecoe = tbOldPlayerInfo[szAccount][2];
	--是去年的老玩家	
	local nTimes = 1;
	--if tbOldPlayerInfo[szAccount][6] and tbOldPlayerInfo[szAccount][6] == 1 then
	if me.GetTask(self.TASK_GID, self.TASK_TASKID_ACTIVATE_OLD_LAST) == 1 then
		nTimes = 0.5;
	end
	local nBindCoin = math.floor(nPayCount * self.nRateOldPlayerBack * self.nRateBindCoin * nTimecoe);
	local nBindMoney = math.floor(nPayCount * self.nRateOldPlayerBack * self.nRateBindMoney * nTimecoe);
	local nGetBindCoin = math.floor(nBindCoin * self.nReBackCoinRate * nTimes);
	local nConsumeCoin = math.floor(nBindCoin * (1 - self.nReBackCoinRate) * nTimes);
	local nGetBindMoney = math.floor(nBindMoney * self.nReBackCoinRate * nTimes);
	local nConsumeMoney = math.floor(nBindMoney * (1 - self.nReBackCoinRate) * nTimes);
	local szMsg = string.format("欢迎江湖前辈归来,您的充值额%s，消耗额%s，可以在我这里领取：\n<color=yellow>%s绑金<color>\n<color=yellow>%s绑银<color>\n<color=yellow>%s绑金奇珍阁消耗返还<color>\n<color=yellow>%s绑银奇珍阁消耗返还<color>\n<color=yellow>%s小时<color>4倍修炼时间\n<color=yellow>%s<color>次额外开福袋机会\n<color=yellow>%s<color>次祈福机会\n<color=yellow>%s<color>个游龙修炼符\n强化优惠（1周）!",
		 tbOldPlayerInfo[szAccount][3], tbOldPlayerInfo[szAccount][4], nGetBindCoin, nGetBindMoney, nConsumeCoin, nConsumeMoney, nTimecoe * 30, nTimecoe * 80,  nTimecoe *20,  nTimecoe * 40);
	local tbOpt = {{"领取奖励",self.GetOldPlayerBackEx, self, nBindCoin, nBindMoney, nTimecoe, nTimes},
		{"Để ta suy nghĩ thêm"}};
	Dialog:Say(szMsg, tbOpt);
end

--老玩家召回绑银绑金领奖
function tbOldPlayerBack:GetOldPlayerBackEx(nBindCoin, nBindMoney, nTimecoe, nTimes)	
	local bCanLoad, szMsg = self:CheckCanLoad(nBindMoney);
	if bCanLoad == 1 then
		Dialog:Say(szMsg,{"Ta hiểu rồi"});
		return;
	end	
	if me.CountFreeBagCell() < 2  then
		Dialog:Say("Hành trang không đủ ，需要2格背包空间。",{"Ta hiểu rồi"});
		return 0;
	end
	local nGetBindCoin = math.floor(nBindCoin * self.nReBackCoinRate * nTimes);
	local nConsumeCoin = math.floor(nBindCoin * (1 - self.nReBackCoinRate) * nTimes);
	--绑金绑银
	me.AddBindCoin(nGetBindCoin, Player.emKBINDCOIN_ADD_OLD_RETURN);
	
	local nGetBindMoney = math.floor(nBindMoney * self.nReBackCoinRate * nTimes);
	local nConsumeMoney = math.floor(nBindMoney * (1 - self.nReBackCoinRate) * nTimes);
	me.AddBindMoney(nGetBindMoney);
	--加返还绑金，加item
	me.SetTask(self.TASK_GID, self.TASK_TASKID_BANDCOIN_RETURN, me.GetTask(self.TASK_GID, self.TASK_TASKID_BANDCOIN_RETURN) + nConsumeCoin);
	--加返还绑银
	me.SetTask(2034,11, me.GetTask(2034,11) + nConsumeMoney);

	local pItem = me.AddItem(unpack(self.tbItemReturn));
	if pItem then
		pItem.Bind(1);
		local nActiveTime = me.GetTask(self.TASK_GID, self.TASK_TASKID_ACTIVATE_TIME);
		local nStateTime = 30*24*60 - math.floor((GetTime() - nActiveTime) / 60);
		me.SetItemTimeout(pItem, nStateTime, 0);
	end
	
	me.Msg(string.format("恭喜您获得<color=yellow>%s绑金<color>和<color=yellow>%s绑银<color>及<color=yellow>%s消耗返还绑金%s消耗返还绑银<color>!", nGetBindCoin, nGetBindMoney, nConsumeCoin, nConsumeMoney));	
	--修炼珠时间
	me.SetTask(1023,7,me.GetTask(1023,7) + nTimecoe * 30 * 10);
	--开福袋机会
	me.SetTask(2013,4, me.GetTask(2013,4) + nTimecoe * 80);
	--离线时间
	--Player.tbOffline:AddExOffLineTime(nTimecoe * 40);
	--游龙阁修炼符
	me.AddStackItem(18, 1, 526, 1, nil, nTimecoe * 40);
	--祈福机会
	me.SetTask(2049,4, me.GetTask(2049,4) + nTimecoe * 20);
	--强化领取
	me.AddSkillState(892, 1, 1, 7 * 24 *3600*18, 1, 0, 1);
	
	me.SetTask(self.TASK_GID, self.TASK_TASKID_ITEM_OLD_TIMES, 1);
end

--回老服道具称号奖励
function tbOldPlayerBack:GetOldPlayerBackAwardItem(tbEquit, nNum)
	local szMsg = "这里有丰富的奖励等着您来领取呢。";
	local bIsActivate = me.GetTask(self.TASK_GID, self.TASK_TASKID_ACTIVATE_OLD);
	if bIsActivate == 0 then
		Dialog:Say("您还没有激活资格呢，先去激活资格吧。", {"Ta hiểu rồi"});
		return 0;
	end
	local tbOpt = {};
	if not tbEquit and not nNum then
		for i, tbAward in ipairs(self.tbAward2Old) do
			if type(tbAward[1]) == "table" then
				local szAwardName = "西域龙魂印鉴五选一";
				if i == 4 then
					szAwardName = "装备套装或同伴四选一";
				end
				table.insert(tbOpt, {szAwardName, self.GetOldPlayerBackAwardItem, self, tbAward, i});
			else
				table.insert(tbOpt,  {tbAward[1], self.GetOldPlayerBackAwardItemEx, self, i});
			end
		end
		table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
	elseif tbEquit and nNum then
		if nNum == 4 then
			szMsg = "这里的奖励只能四选一喔~请认真选择自己需要的奖励。";
		else
			szMsg = "这里的奖励只能五选一喔~请认真选择自己需要的印鉴。";
		end
		for j, tbAwardEx in pairs(tbEquit) do
			table.insert(tbOpt, 1, {tbAwardEx[1], self.GetOldPlayerBackAwardItemEx, self, nNum, j});
		end
	end
	Dialog:Say(szMsg, tbOpt);	
end

--回老服道具称号奖励
function tbOldPlayerBack:GetOldPlayerBackAwardItemEx(nGen, nDetal, bOK)
	local tbAward = self.tbAward2Old[nGen];
	if nDetal then
		tbAward = self.tbAward2Old[nGen][nDetal];
		if not bOK then
			Dialog:Say("你确定选择领取<color=yellow>"..tbAward[1].."<color>", {{"Xác nhận",self.GetOldPlayerBackAwardItemEx, self, nGen, nDetal, 1},{"Để ta suy nghĩ thêm"}});	
			return;
		end		
	end
	if not tbAward then
		return;
	end
	if me.GetTask(self.TASK_GID, self.TASK_TASKID_ITEM_OLD_TIMES + nGen) == 1 then
		Dialog:Say("你已经领取过了。",{"Ta hiểu rồi"});
		return 0;
	end
	if tbAward[2] == 2 then
		if me.CountFreeBagCell() < (tbAward[5] or 1)  then
			Dialog:Say(string.format("Hành trang không đủ ，需要%s格背包空间。", tbAward[5] or 1),{"Ta hiểu rồi"});
			return 0;
		end
	end
	if tbAward[2] == 2 then
		local nCount = tbAward[3][5] or 1;
		for i = 1, nCount do
			local pItem = me.AddItem(tbAward[3][1], tbAward[3][2], tbAward[3][3], tbAward[3][4]);
			if pItem then
				pItem.Bind(1);
				if tbAward[4] then
					pItem.SetTimeOut(0, GetTime() + tbAward[4]);
					pItem.Sync();
				end
			end
		end
	else
		me.AddTitle(unpack(tbAward[3]));
		me.SetCurTitle(unpack(tbAward[3]));
	end
	me.SetTask(self.TASK_GID, self.TASK_TASKID_ITEM_OLD_TIMES + nGen, 1);
end

-----------------------------------------------------------------------------

function tbOldPlayerBack:QueryKinTaskFinsh()
	local bIsActivate = me.GetTask(self.TASK_GID, self.TASK_TASKID_ACTIVATE_OLD);
	if bIsActivate == 0 then
		Dialog:Say("您还没有江湖前辈资 ô.", {"Ta hiểu rồi"});
		return 0;
	end
	local szColor = "";
	local szMsg = "参与活动情况：（<color=green>注：江湖前辈需为家族正式成员，激活江湖前辈30天内有效<color>）\n";
	local tbNameGate = {"\n逍遥谷通关：   ", "\n通过白虎堂2层：", "\n完成官府通缉： ", "\n宋金战场：     ","\n侠客任务：     "}
	for i = self.TASK_TASKID_EVENT_XOYO, self.TASK_TASKID_EVENT_XIAKE do
		local nCount = me.GetTask(self.TASK_GID, i);
		if nCount >0 and nCount < 2 then
			szColor = "white";
		elseif nCount >= 2 then
			szColor = "green";
		end
		szMsg = szMsg..string.format("<color=%s>%s%s/2<color>", szColor, tbNameGate[i - 149], nCount);
	end
	local nActiveTime = me.GetTask(self.TASK_GID, self.TASK_TASKID_ACTIVATE_TIME);
	if GetTime() - nActiveTime > 30 * 24 * 3600 then
		szMsg = szMsg.."\n\n<color=red>您激活时间已经超过30天有效期。<color>";
	end
	Dialog:Say(szMsg,{"Ta hiểu rồi"});
end

--激活家族奖励
function tbOldPlayerBack:ActivateKinAward()
	local bIsActivate = me.GetTask(self.TASK_GID, self.TASK_TASKID_ACTIVATE_OLD);
	if bIsActivate == 0 then
		Dialog:Say("您还没有江湖前辈资 ô.", {"Ta hiểu rồi"});
		return 0;
	end
	local nFlag = me.GetTask(self.TASK_GID, self.TASK_TASKID_KIN);
	if nFlag == 1 then
		Dialog:Say("你已经激活过家族奖励了。",{"Ta hiểu rồi"});
		return;
	end
	for i = self.TASK_TASKID_EVENT_XOYO, self.TASK_TASKID_EVENT_XIAKE do
		if me.GetTask(self.TASK_GID, i) < 2 then
			Dialog:Say("你还是先完成任务再来激活吧。",{"Ta hiểu rồi"});
			return;
		end
	end
	local dwKinId = me.GetKinMember();	
	if dwKinId == 0 then
		Dialog:Say("你还没有家族呢，加了家族才能激活家族奖励。",{"Ta hiểu rồi"});
		return;
	end
	if me.nKinFigure > 3 or me.nKinFigure == 0 then
		Dialog:Say("只有正式成员才可以激活家族奖励。",{"Ta hiểu rồi"});
		return;
	end
	GCExcute({"SpecialEvent.tbOldPlayerBack:SetKinMemberTask", dwKinId, me.nId});
	--self:SetKinMemberTask(dwKinId);	
	return;
end

--设置家族正式成员可获得奖励的次数
function tbOldPlayerBack:SetKinMemberTask(dwKinId, nPlayerId)
	local cKin = KKin.GetKin(dwKinId)
	local szKinName = "";
	if not cKin then
		return;
	end
	szKinName = cKin.GetName();
	local cMemberIt = cKin.GetMemberItor();
	local cMember = cMemberIt.GetCurMember();
	while cMember do
		local nFigure = cMember.GetFigure();
		local nBatch = cMember.GetOldPlayerBackBatch();
		if nBatch ~= self.nBatch then
			cMember.SetOldPlayerBack(0);
			cMember.SetOldPlayerBackBatch(self.nBatch);
		end
		if nFigure <= Kin.FIGURE_REGULAR and cMember.GetPlayerId() ~= nPlayerId then
			cMember.AddOldPlayerBack(1);
		end
		cMember = cMemberIt.NextMember();
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end	
	pPlayer.SetTask(self.TASK_GID, self.TASK_TASKID_KIN, 1);
	Player:SendMsgToKinOrTong(pPlayer, "激活了江湖前辈奖励，正式成员可以去礼官处领奖啦！", 0);
	pPlayer.Msg("恭喜您成功激活江湖前辈家族奖励。");
	Dialog:SendBlackBoardMsg(pPlayer, "恭喜您成功激活江湖前辈家族奖励。");
	StatLog:WriteStatLog("stat_info", "laowanjia2011", "provide", nPlayerId, szKinName);
	return 0;
end

--获得家族奖励
function tbOldPlayerBack:GetKinAward(nFlag)
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then
		Dialog:Say("你还没有家族恐怕无法领取奖励吧。",{"Ta hiểu rồi"});
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId)
	if (not cMember) then
		Dialog:Say("你还没有家族恐怕无法领取奖励吧。",{"Ta hiểu rồi"});
		return 0;
	end
	local nFigure = cMember.GetFigure();
	local nCanGetCount = cMember.GetOldPlayerBack();
	local nBatch =  cMember.GetOldPlayerBackBatch();
	if nBatch ~= self.nBatch then
		nCanGetCount = 0;
	end
	if nCanGetCount <= 0 then
		Dialog:Say("你没有家族奖励可以领取啦。\n获得奖励需符合条件：\n1、家族中的武林前辈激活家族奖励时为家族的正式成员\n2、领取次数未达10次（族长20次）",{"Ta hiểu rồi"});
		return 0;
	end
	local nGetCount = me.GetTask(self.TASK_GID, self.TASK_TASKID_KIN_GETAWARD);
	if (nFigure ~= 1 and nGetCount >= self.nKinAwardMaxCount) or (nFigure == 1 and nGetCount >= self.nKinAwardMaxCount * 2)  then
		Dialog:Say("你已经获得足够多了，机会还是留给其他人吧。",{"Ta hiểu rồi"});
		return 0;
	end
	if nGetCount >= nCanGetCount then
		Dialog:Say("你没有家族奖励可以领取啦。\n获得奖励需符合条件：\n1、家族中的武林前辈激活家族奖励时为家族的正式成员\n2、领取次数未达10次（族长20次）",{"Ta hiểu rồi"});
		return 0;
	end
	local bCanLoad, szMsg = self:CheckCanLoad(500000);
	if bCanLoad == 1 then
		Dialog:Say(szMsg,{"Ta hiểu rồi"});
		return;
	end
	if not nFlag then
		local nCouldGetCount = nCanGetCount - nGetCount;
		if nFigure ~= 1 and self.nKinAwardMaxCount < nCanGetCount then
			nCouldGetCount = self.nKinAwardMaxCount - nGetCount;
		end
		if nFigure == 1 and self.nKinAwardMaxCount * 2 < nCanGetCount then
			nCouldGetCount = self.nKinAwardMaxCount * 2 - nGetCount;
		end
		Dialog:Say(string.format("您现在有%s次家族奖励可以领取。", nCouldGetCount),{{"领取奖励", self.GetKinAward, self, 1},"Ta hiểu rồi"});
		return;
	end
	me.AddBindMoney(500000);
	me.AddBindCoin(500, Player.emKBINDCOIN_ADD_OLD_RETURN);
	me.SetTask(self.TASK_GID, self.TASK_TASKID_KIN_GETAWARD, nGetCount + 1);
	Dbg:WriteLog("OldplayerBack", "GetKinAward", me.szAccount, me.szName, "获得家族家族激活奖励");
end

--检查本服是不是有转服或者有老玩家
function tbOldPlayerBack:CheckHaveOldPlayer(nType)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate > self.nCloseDate[nType] then
		return 1, "活动已经结束。";
	end
	if not self.tbOldPlayerInfo or not self.tbOldPlayerInfo[nType] or Lib:CountTB(self.tbOldPlayerInfo[nType]) <= 0 then
		if nType == 1 then			
			return 1, "恐怕没有转入本服的武林前辈。";
		elseif nType == 2 then
			return 1, "本服恐怕没有回归的武林前辈。";
		end
	end	
	return 0;
end

--激活
function tbOldPlayerBack:ActivatePlayer(nType)
	if not self.tbOldPlayerInfo or not self.tbOldPlayerInfo[nType] then
		return;
	end
	local szAccount = string.lower(me.szAccount);
	if nType == 1 then
		if self.tbOldPlayerInfo[nType][szAccount] and self.tbOldPlayerInfo[nType][szAccount][7] and self.tbOldPlayerInfo[nType][szAccount][7] == 0 then
			if me.GetRoleCreateDate() <= self.nCreatDateLimit then
				Dialog:Say(string.format("只有%s之后建立的角色才可以激活转新服资 ô.", os.date("%Y-%m-%d", Lib:GetDate2Time(self.nCreatDateLimit))), {"Ta hiểu rồi"});			
				return 0;
			end
			self.tbOldPlayerInfo[nType][szAccount][7] = 1;
			me.SetTask(self.TASK_GID, self.TASK_TASKID_ACTIVATE_NEW, 1);
			Dialog:Say("恭喜您激活了转新服资 ô.",{"Ta hiểu rồi"});			
			Dialog:SendBlackBoardMsg(me, "恭喜您激活了转新服资 ô.");
		elseif not self.tbOldPlayerInfo[nType][szAccount] then
			Dialog:Say("你还没有资格激活转新服资 ô.",{"Ta hiểu rồi"});
			return;
		else
			Dialog:Say("该账号下已经有角色激活过转新服的资格了。",{"Ta hiểu rồi"});	
			return;
		end
	elseif nType == 2 then
		local tbOldPlayerInfo = self.tbOldPlayerInfo[nType][szAccount] or self.tbOldPlayerInfo2[szAccount] or self.tbOldPlayerInfo3[szAccount];
		if tbOldPlayerInfo and tbOldPlayerInfo[5] and tbOldPlayerInfo[5] == 0 then
			if Account:GetIntValue(me.szAccount, "OldPlayerBack.ActiveValue") == self.nActiveBatch then
				Dialog:Say("该账号已经激活过了。",{"Ta hiểu rồi"});
				return;
			end
			if me.GetRoleCreateDate() >= self.nRoleCreateDate then
				Dialog:Say(string.format("您的这个角色不是江湖前辈，请使用符合资格的角色来激活吧。\n<color=red>建立角色时间必须在%s之前<color>", os.date("%Y-%m-%d", Lib:GetDate2Time(self.nRoleCreateDate))),{"Ta hiểu rồi"});
				return;
			end			
			if self.tbOldPlayerInfo[nType][szAccount] then
				self.tbOldPlayerInfo[nType][szAccount][5] = 1;
			elseif  self.tbOldPlayerInfo2[szAccount] then
				self.tbOldPlayerInfo2[szAccount][5] = 1;
			elseif self.tbOldPlayerInfo3[szAccount] then
			self.tbOldPlayerInfo3[szAccount][5] = 1;
			end
			me.SetTask(self.TASK_GID, self.TASK_TASKID_ACTIVATE_OLD, 1);
			me.SetTask(self.TASK_GID, self.TASK_TASKID_ACTIVATE_TIME, GetTime())
			--me.SetActiveValue(2, 1);
			Account:ApplySetIntValue(me.szAccount, "OldPlayerBack.ActiveValue", self.nActiveBatch);
			Dialog:Say("恭喜您激活了江湖前辈资 ô.",{"Ta hiểu rồi"});
			Dialog:SendBlackBoardMsg(me, "恭喜您激活了江湖前辈资 ô.");
		elseif not tbOldPlayerInfo then
			Dialog:Say("你还没有资格激活江湖前辈资 ô.",{"Ta hiểu rồi"});	
			return;
		else
			Dialog:Say("该账号下已经有角色激活过江湖前辈的资格了。",{"Ta hiểu rồi"});	
			return;
		end
	end
	local szMsg = string.format("#剑侠世界# 江湖老前辈[%s]回归[%s-%s]啦！曾经一起战斗过的兄弟姐妹们，赶快来找我吧！", me.szName, ServerEvent:GetGateNameByGateway(GetGatewayName()), ServerEvent:GetServerNameByGateway(GetGatewayName()));
	Sns:NotifyClientNewTweet(me, "祝贺您获得<color=yellow>江湖老前辈<color>资格！\n把这个好消息分享给朋友们吧！", szMsg);
	StatLog:WriteStatLog("stat_info", "tuiguang", "active", me.nId);
	self:SaveBuffer_GS(nType, szAccount);
	return;	
end

--返还绑金
function tbOldPlayerBack:Return(pPlayer, nTotalCoin)
	local nReturnNum = pPlayer.GetTask(self.TASK_GID, self.TASK_TASKID_BANDCOIN_RETURN);
	if  nReturnNum <= 0 or nTotalCoin <= 0 then
		return;
	end
	if nReturnNum < nTotalCoin then
		pPlayer.AddBindCoin(nReturnNum, Player.emKBINDCOIN_ADD_OLD_RETURN);
		pPlayer.SetTask(self.TASK_GID, self.TASK_TASKID_BANDCOIN_RETURN, 0);
		pPlayer.Msg(string.format("恭喜您获得额外绑金返还%s，您的额外绑金返还点还剩余%s点",nReturnNum, 0));
		StatLog:WriteStatLog("stat_info", "tuiguang", "coin_restore", pPlayer.nId, nReturnNum);
	else
		pPlayer.AddBindCoin(nTotalCoin, Player.emKBINDCOIN_ADD_OLD_RETURN);
		pPlayer.SetTask(self.TASK_GID, self.TASK_TASKID_BANDCOIN_RETURN, nReturnNum - nTotalCoin);
		pPlayer.Msg(string.format("恭喜您获得额外绑金返还%s，您的额外绑金返还点还剩余%s点",nTotalCoin, nReturnNum - nTotalCoin));
		StatLog:WriteStatLog("stat_info", "tuiguang", "coin_restore", pPlayer.nId, nTotalCoin);
	end
	
end

function tbOldPlayerBack:SaveBuffer_GS(nType, szAccount, nAwardInfo, nTypeEx)
	GCExcute({"SpecialEvent.tbOldPlayerBack:SaveBuffer2_GC", nType, szAccount, nAwardInfo, nTypeEx});
end

function tbOldPlayerBack:LoadBuffer_GS()
	if (EventManager.IVER_bOpenPlayerCallBack == 0) then
		return;
	end
	
	local tbBuffer = GetGblIntBuf(GBLINTBUF_OLDPLAYERBACK, 0);
	local tbBuffer2 = GetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_1, 0);
	local tbBuffer3 = GetGblIntBuf(GBLINTBUF_OLDPLAYERBACK_2011_2, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbOldPlayerInfo = tbBuffer;
	end
	if tbBuffer2 and type(tbBuffer2) == "table" then
		self.tbOldPlayerInfo2 = tbBuffer2;
	end
	if tbBuffer3 and type(tbBuffer3) == "table" then
		self.tbOldPlayerInfo3 = tbBuffer3;
	end
end

function tbOldPlayerBack:SaveBuffer2_GS(nType, szAccount, nAwardInfo, nTypeEx)
	if not nType or not szAccount then
		return;
	end
	if nType == 1 then
		if not self.tbOldPlayerInfo[1][szAccount] then
			return;
		end		
		if nTypeEx and nAwardInfo then
			self.tbOldPlayerInfo[1][szAccount][nTypeEx] = nAwardInfo;
		else
			self.tbOldPlayerInfo[1][szAccount][7] = 1;
		end
	else
		if self.tbOldPlayerInfo[2][szAccount] then
			self.tbOldPlayerInfo[2][szAccount][5] = 1;
		elseif self.tbOldPlayerInfo2[szAccount] then
			self.tbOldPlayerInfo2[szAccount][5] = 1;
		elseif self.tbOldPlayerInfo3[szAccount] then
			self.tbOldPlayerInfo3[szAccount][5] = 1;
		end		
	end
end

--玩家上线事件
function tbOldPlayerBack:PlayerLogIn()
	local tbOldPlayerInfo = self.tbOldPlayerInfo[2][string.lower(me.szAccount)] or self.tbOldPlayerInfo2[string.lower(me.szAccount)] or self.tbOldPlayerInfo3[string.lower(me.szAccount)];
	--账号未激活过
	local bTell = me.GetTask(self.TASK_GID, self.TASK_TASKID_TELL);
	if tbOldPlayerInfo and Account:GetIntValue(me.szAccount, "OldPlayerBack.ActiveValue") ~= self.nActiveBatch and bTell ~= 1 then
		local szMsg = "恭喜您获得<color=green>江湖前辈资格<color>，2012年9月11日全新资料片<color=yellow>《新剑侠世界》<color>隆重登场，届时您可以到<color=yellow>礼官<color>处激活并领取奖励。";
		me.Msg(szMsg);
		Dialog:SendBlackBoardMsg(me,  "恭喜您获得<color=green>江湖前辈资格<color>，相关内容请注意查看邮件。");
		KPlayer.SendMail(me.szName, "重礼邀江湖前辈重出江湖",szMsg);
		me.SetTask(self.TASK_GID, self.TASK_TASKID_TELL, 1);
	end
end

function tbOldPlayerBack:CheckCanLoad(nBindMoney)
	if nBindMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
		return 1, "您的身上的绑定银两即将达到上限，请清理一下身上的绑定银两。";
	end
	return 0;
end

--PlayerEvent:RegisterGlobal("OnLogin", SpecialEvent.tbOldPlayerBack.PlayerLogIn, SpecialEvent.tbOldPlayerBack);
ServerEvent:RegisterServerStartFunc(SpecialEvent.tbOldPlayerBack.LoadBuffer_GS, SpecialEvent.tbOldPlayerBack);
