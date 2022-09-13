-- 文件名  : taskexp_gs.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-05 15:04:09
-- 描述    : 

if not MODULE_GAMESERVER then
	return;
end

Task.TaskExp = Task.TaskExp or {};
local tbTaskExp = Task.TaskExp;

----------------------------------------------------------------------------------------------------------------------------------
--经验书

--增加经验
function tbTaskExp:OnAddInsight(nInsightNumber)
	local nAddInsight = nInsightNumber;
	local tbFind = me.FindItemInBags(unpack(self.tbXinDeShu_ing));
	if #tbFind <= 0 then
		return;
	end
	me.Msg("你获得"..nAddInsight.."点修炼心得！");
	local nCurInsight = tbFind[1].pItem.GetGenInfo(1);
	if ((nCurInsight + nAddInsight) >= self.tbExp[me.nLevel][1]) then
		nAddInsight = self.tbExp[me.nLevel][1]- nCurInsight;
		self:FinishXiulian(tbFind, nInsightNumber - nAddInsight);
	else		
		tbFind[1].pItem.SetGenInfo(1, nCurInsight + nAddInsight);
		tbFind[1].pItem.Sync();
	end
end

--完成一本书修炼
function tbTaskExp:FinishXiulian(tbItem, nOvreFlow)	
	self:AddFinishBook(tbItem);
	local nAddInsight = 0;
	if #tbItem > 0 and nOvreFlow > 0 then
		local nCurInsight = tbItem[1].pItem.GetGenInfo(1);
		if ((nCurInsight + nOvreFlow) >= self.tbExp[me.nLevel][1]) then
			nAddInsight = self.tbExp[me.nLevel][1]- nCurInsight;
			self:FinishXiulian(tbItem, nOvreFlow - nAddInsight);
		else
			tbItem[1].pItem.SetGenInfo(1, nCurInsight + nOvreFlow);
			tbItem[1].pItem.Sync();
		end
	end
end

--加一本完成的书
function tbTaskExp:AddFinishBook(tbItem)
	local pItem = tbItem[1].pItem;
	table.remove(tbItem, 1);
	if pItem then
		pItem.Delete(me);
	end
	local pItemEx = me.AddItem(unpack(self.tbXinDeShu_ed));
	pItemEx.SetGenInfo(1, me.nLevel);
	pItemEx.SetCustom(Item.CUSTOM_TYPE_MAKER, me.szName);		-- 记录制造者名字
	pItemEx.Sync();
	me.Msg("恭喜你完成了一本经验书的修炼！");
	local tbRepositoryItem = me.FindItemInRepository(unpack(self.tbXinDeShu_ing));
	if #tbItem <= 0 and #tbRepositoryItem <= 0 then
		self:UnRegister();
	end
end

--注销掉积累经验
function tbTaskExp:UnRegister()	
	 local nRegisterId = me.GetTask(self.TASK_GID, self.TASK_TASKID);
	 if nRegisterId > 0 then
		PlayerEvent:UnRegister("OnAddInsightNew", nRegisterId);
		me.SetTask(self.TASK_GID, self.TASK_TASKID, 0);
	end
end

--玩家上线事件
function tbTaskExp:PlayerLogIn()
	--重新注册增加经验事件
	local nRegisterId = me.GetTask(self.TASK_GID, self.TASK_TASKID);
	if nRegisterId > 0 then
		nRegisterId = PlayerEvent:Register("OnAddInsightNew", self.OnAddInsight, self);
		me.SetTask(self.TASK_GID, self.TASK_TASKID, nRegisterId);
	end
	--增加平台自动撤销的任务的金币数
	self:AddPlatformCoin();
end

PlayerEvent:RegisterGlobal("OnLogin", Task.TaskExp.PlayerLogIn, Task.TaskExp);

----------------------------------------------------------------------------------------------------------------------------------
--经验平台

--启动事件加载数据
function tbTaskExp:SeverStart()
	if not self.tbItem then
		print("任务发布平台出错！");
		return;
	end
	for i = 1, #self.tbItem do
		self.tbTaskTemp[i] = DataForm_GetData(i);
		self.tbTask[i] = self.tbTask[i] or {};
		self:MakeTable(i);
	end
	
	self:MergeAndSortTable();
end

--整理分类表，用C内存中的Index做lua中的
function tbTaskExp:MakeTable(nIndex)
	for i,tbTaskExp in ipairs(self.tbTaskTemp[nIndex]) do
		local nTime = GetTime() - tbTaskExp[2];
		if tbTaskExp.nIndex > 0 and nTime  < self.nTimeFabu * 3600 then		
			self.tbTask[nIndex][tbTaskExp.nIndex] = {[1] = tbTaskExp[0], [2] = tbTaskExp[1], [3] = tbTaskExp[2], szBuf = tbTaskExp.szBuf};
		end
	end
end

--gs整理整个表结构
function tbTaskExp:MergeAndSortTable()
	for i = 1, #self.tbItem do
		for nIndex, tbTaskInfo in ipairs(self.tbTaskTemp[i]) do
			local nTime = GetTime() - tbTaskInfo[2];
			if tbTaskInfo.nIndex > 0 and nTime  < self.nTimeFabu * 3600 then
				table.insert(self.tbTaskAll, {i, tbTaskInfo.nIndex, tbTaskInfo[0], tbTaskInfo[1], tbTaskInfo[2], tbTaskInfo.szBuf}); 
			end
		end
	end
	local sort_cmp = function (tb1, tb2)
		if tb1[4] ~= tb2[4] then
			return tb1[4] > tb2[4];
		else
			return tb1[5] < tb2[5];
		end
	end
	if #self.tbTaskAll >= 2 then
		table.sort(self.tbTaskAll, sort_cmp);
	end
end

--完成任务回调
function tbTaskExp:FinishTask(nFormId, nIndex)
	if not self.tbTask[nFormId] or not self.tbTask[nFormId][nIndex] or not self.tbItem[nFormId] then
		me.Msg("您的操作不正当,或该任务已经被完成或取消！");
		Dialog:SendInfoBoardMsg(me, "您的操作不正当,或该任务已经被完成或取消！");
		return;
	end
	local szPlayerName = self.tbTask[nFormId][nIndex].szBuf;
	local nCount = self.tbTask[nFormId][nIndex][1];
	local nXing = self.tbTask[nFormId][nIndex][2];
	if me.szName == szPlayerName then
		me.Msg("您不可以完成自己发布的任务！");
		Dialog:SendInfoBoardMsg(me, "您不可以完成自己发布的任务！");
		return;
	end
	local nCanFinish = 0;
	for i = 1, self.nMaxViewTask do
		if self.tbTaskAll[i] and self.tbTaskAll[i][1] == nFormId and self.tbTaskAll[i][2] == nIndex then
			nCanFinish = 1;
		end
	end
	if nCanFinish == 0 then
		me.Msg("对不起，您操作有误！");
		Dialog:SendInfoBoardMsg(me, "对不起，您操作有误！");
		return;
	end
	Dialog:OpenGift(string.format("请放入<color=yellow>%s个<color>%s来完成任务\n您将获得%s：<color=yellow>%s<color>\n", nCount, self.tbItem[nFormId][2],IVER_g_szBindCoinName, self:CalculateAword(nFormId, nCount, nXing)), nil ,{self.OnOpenGiftOk,self, nCount, nFormId, nIndex});
end

function tbTaskExp:OnOpenGiftOk(nCount, nFormId, nIndex, tbItemObj)
	
	local nFlag , szMsg = self:CheckItem(nFormId, nCount, tbItemObj)
	if (nFlag == 0) then
		me.Msg(szMsg or "你放入了不符合要求的物品，或者数量不符合!");
		Dialog:SendInfoBoardMsg(me, szMsg or "你放入了不符合要求的物品，或者数量不符合!");
		return 0;
	end
	local nFlag = GCExcute({"Task.TaskExp:LockTask_GC", nFormId, nIndex, me.szName});
	if nFlag == 0 then
		return 0;
	end
	local tbTaskTemp = me.GetTempTable("Task");
	tbTaskTemp.tbItemDelete = tbTaskTemp.tbItemDelete or {};
	for _, pItem in pairs(tbItemObj) do
		table.insert(tbTaskTemp.tbItemDelete, pItem[1]);
	end
	-- 锁住玩家
	me.AddWaitGetItemNum(1);
	return 1;
end

-- 检测物品及数量是否符合
function tbTaskExp:CheckItem(nFormId, nCount, tbItemObj)
	local nAllCount = 0;
	for _, pItem in pairs(tbItemObj) do
		local tbNeedItem =  self.tbItem[nFormId][1]
		local szFollowItem 	= string.format("%s,%s,%s,%s", tbNeedItem[1], tbNeedItem[2], tbNeedItem[3], tbNeedItem[4]);
		local szItem		= string.format("%s,%s,%s,%s", pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
		if szFollowItem ~= szItem then
			return 0;
		end
		if self.tbItem[nFormId][8] and self.tbItem[nFormId][8] == 1 and pItem[1].szCustomString ~=  me.szName then			
			return 0, "您不能上交不是自己做的物品！";
		end
		nAllCount = nAllCount + 1;
	end
	if nAllCount ~= nCount then
		return 0;
	end
	return 1;
end

--锁定成功回调gs
function tbTaskExp:LockTaskFinish(nFormId, nIndex, szPlayerName)	
	if not self.tbTask[nFormId] or not self.tbTask[nFormId][nIndex] or not self.tbItem[nFormId] then
		print("系统出错！");
		return 0;
	end
	local nCount = self.tbTask[nFormId][nIndex][1];
	local nXing = self.tbTask[nFormId][nIndex][2];
	if self:DeleteTask(nFormId, nIndex) == 0 then
		return;
	end
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then	
		return;
	end	
	--delete item
	local tbTaskTemp = pPlayer.GetTempTable("Task");
	tbTaskTemp.tbItemDelete = tbTaskTemp.tbItemDelete or {};
	for _, pItem in ipairs(tbTaskTemp.tbItemDelete) do
		pItem.Delete(pPlayer);
	end
	tbTaskTemp.tbItemDelete = {};
	--add aword
	local nBindCoin = self:CalculateAword(nFormId, nCount, nXing);
	self:AddAword(nBindCoin, szPlayerName);
	self:AddItemOther(nFormId, nCount, szPlayerName);
	--call client
	self:SyncData(pPlayer);
		
	GCExcute({"Task.TaskExp:FinishTask_GC", nFormId, nIndex, szPlayerName});
	Dbg:WriteLog("ExpTask", "经验任务系统", string.format("%s 上交 %s %s本 获得 %s 绑金 任务ID：%s-%s", szPlayerName, self.tbItem[nFormId][2], nCount, nBindCoin, nFormId, nIndex));
	Dbg:WriteLogEx(1, "ExperienceTask", "给予物品", string.format("%s,%s,%s,%s,%s-%s", szPlayerName,  nCount,self.tbItem[nFormId][2], nBindCoin, nFormId, nIndex));
	--解锁
	pPlayer.AddWaitGetItemNum(-1);
end

--锁定失败回调gs
function tbTaskExp:LockTaskError(nFormId, nIndex, szPlayerName)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return;
	end
	pPlayer.Msg("任务正由其他玩家完成或是被撤销了！");
	Dialog:SendInfoBoardMsg(pPlayer, "任务正由其他玩家完成或是被撤销了！");
	--解锁
	pPlayer.AddWaitGetItemNum(-1);
	local tbTaskTemp = pPlayer.GetTempTable("Task");
	tbTaskTemp.tbItemDelete = nil;
end

--删除任务
function tbTaskExp:DeleteTask(nFormId, nIndex)
	if not self.tbTask[nFormId] or not self.tbTask[nFormId][nIndex] or not self.tbItem[nFormId] then
		print("系统出错！");
		return 0;
	end
	local nDeleteNum = 0;	
	self.tbTask[nFormId][nIndex] = nil;
	for i, tbTaskEx in ipairs (self.tbTaskAll) do
		if tbTaskEx[1] == nFormId and tbTaskEx[2] == nIndex then
			nDeleteNum = i;
			break;
		end
	end
	if nDeleteNum > 0 then		
		table.remove(self.tbTaskAll, nDeleteNum);
	end
	return 1;
end

--客户端撤销任务回调
function tbTaskExp:CanCelTask(nFormId, nIndex)
	if not self.tbTask[nFormId] or not self.tbTask[nFormId][nIndex] or not self.tbItem[nFormId] or me.szName ~= self.tbTask[nFormId][nIndex].szBuf then
		me.Msg("您的操作不正当,或该任务已经被完成或取消！");
		Dialog:SendInfoBoardMsg(me, "您的操作不正当,或该任务已经被完成或取消！");
		return;
	end
	-- 锁住玩家
	me.AddWaitGetItemNum(1);
	GCExcute({"Task.TaskExp:CanCelTask", nFormId, nIndex, me.szName});
end

--gc撤销任务失败回调
function tbTaskExp:CanCelTaskError(szPlayerName)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		pPlayer.AddWaitGetItemNum(-1);
		pPlayer.Msg("任务已经过期或是有人正在完成你的任务了！");
		Dialog:SendInfoBoardMsg(pPlayer, "任务已经过期或是有人正在完成你的任务了！");
	end
end

--gc撤销任务成功回调
function tbTaskExp:CanCelTaskFinish(nFormId, nIndex, nCoin, szPlayerName)
	if not self.tbTask[nFormId] or not self.tbTask[nFormId][nIndex] or not self.tbItem[nFormId] then
		print("系统出错！");
		return 0;
	end
	local nCount = self.tbTask[nFormId][nIndex][1];
	if self:DeleteTask(nFormId, nIndex) == 1 then
		local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
		if pPlayer then
			pPlayer.AddWaitGetItemNum(-1);
			if  nCoin > 0 then
				pPlayer.SetTask(self.TASK_GID, self.TASK_TASKCOIN, pPlayer.GetTask(self.TASK_GID, self.TASK_TASKCOIN) + nCoin);
				pPlayer.Msg(string.format("撤销任务成功，获得平台%s%s", Task.IVER_szTaskExpCoinName, nCoin));
				Dialog:SendInfoBoardMsg(pPlayer, string.format("撤销任务成功，获得平台%s%s", Task.IVER_szTaskExpCoinName, nCoin));
			end			
			
			--收购物品每日有上限的减掉撤销任务的物品数目
			if self.tbItem[nFormId][10] and self.tbItem[nFormId][10][1] == 1 and nCount then
				local nFabuNum = pPlayer.GetTask(self.tbItem[nFormId][10][2], self.tbItem[nFormId][10][3]);
				if  nFabuNum < nCount then
					pPlayer.SetTask(self.tbItem[nFormId][10][2], self.tbItem[nFormId][10][3], 0);
				else
					pPlayer.SetTask(self.tbItem[nFormId][10][2], self.tbItem[nFormId][10][3], nFabuNum - nCount);
				end
			end
			
			self:SyncData(pPlayer);
			
			Dbg:WriteLog("ExpTask", "经验任务系统", string.format("%s 撤销收购任务： %s-%s", szPlayerName, nFormId, nIndex));
			Dbg:WriteLogEx(1, "ExperienceTask", "取消情况", string.format("%s,%s-%s", szPlayerName, nFormId, nIndex));
		end
	end
end

--自动撤销任务
function tbTaskExp:AutoCanCelTask(nFormId, nIndex)
	if not self.tbTask[nFormId] or not self.tbTask[nFormId][nIndex] then
		return;
	end
	local szPlayerName = self.tbTask[nFormId][nIndex].szBuf;
	local nCoin = self:CalculateAword(nFormId, self.tbTask[nFormId][nIndex][1],self.tbTask[nFormId][nIndex][2]);
	self:DeleteTask(nFormId, nIndex);
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return;
	end
	pPlayer.SetTask(self.TASK_GID, self.TASK_TASKCOIN, pPlayer.GetTask(self.TASK_GID, self.TASK_TASKCOIN) + nCoin);
	pPlayer.Msg(string.format("您发布平台任务过期，返还您平台%s%s", Task.IVER_szTaskExpCoinName, nCoin));
	GCExcute({"Task.TaskExp:DeleteGlobleBuf", nCoin, szPlayerName});
end

--发布任务回调
function tbTaskExp:FaBuTask(nFormId, nCount, nXing)
	local tbTaskFaBu = {};
	if nFormId <= 0 or nCount <= 0 or nCount > self.nMaxCount or nXing <= 0 or nXing > self.nMaxXing or not self.tbItem[nFormId] then
		me.Msg("您操作有误！");
		return;
	end
	tbTaskFaBu[1] = nCount;
	tbTaskFaBu[2] = nXing;
	tbTaskFaBu.szBuf = me.szName;
	--任务变量	
	if self.tbItem[nFormId][10] and self.tbItem[nFormId][10][1] == 1 then
		local nFabuNum = me.GetTask(self.tbItem[nFormId][10][2], self.tbItem[nFormId][10][3]);
		if  nFabuNum >= self.tbItem[nFormId][10][4] then
			me.Msg("今天你收购该物品已经达到上限，不能再收购了!");
			Dialog:SendInfoBoardMsg(me, "今天你收购该物品已经达到上限，不能再收购了");
			return;
		elseif nFabuNum + nCount > self.tbItem[nFormId][10][4] then
			me.Msg(string.format("每天您只可以收购%s个该物品，今天您还能收购%s个", self.tbItem[nFormId][10][4], self.tbItem[nFormId][10][4] - nFabuNum));
			Dialog:SendInfoBoardMsg(me, string.format("每天您只可以收购%s个该物品，今天您还能收购%s个", self.tbItem[nFormId][10][4], self.tbItem[nFormId][10][4] - nFabuNum));
			return;
		end
	end
	--金币
	local nCoin = self:CalculateAword(nFormId, nCount, nXing);
	if nCoin <= 0 then
		me.Msg("您操作有误！");
		Dialog:SendInfoBoardMsg(me, "您操作有误！");
		return;
	end	
	local nPlatformCoin = me.GetTask(self.TASK_GID, self.TASK_TASKCOIN);
	local nCurCoin = me.nCoin + nPlatformCoin;
	if (IVER_g_nSdoVersion == 1) then
		nCurCoin = nPlatformCoin;
	end
	if nCurCoin < nCoin then
		local szMsg = "您的金币不足！";
		if (IVER_g_nSdoVersion == 1) then
			szMsg = "您的经验任务积分不足！";
		end
		me.Msg(szMsg);
		Dialog:SendInfoBoardMsg(me, szMsg);
		return;
	end
	--先扣平台点数再扣金币
	if nPlatformCoin >= nCoin then
		me.SetTask(self.TASK_GID, self.TASK_TASKCOIN, nPlatformCoin - nCoin);
		Dbg:WriteLog("ExpTask", "经验任务系统", string.format("%s 收购 %s %s本 花费 %s 平台金币",me.szName, self.tbItem[nFormId][2], nCount, nCoin));
	else
		if (IVER_g_nSdoVersion == 0) then
			nCoin = nCoin - nPlatformCoin;		
			if nPlatformCoin > 0 then
				Dbg:WriteLog("ExpTask", "经验任务系统", string.format("%s 收购 %s %s本 花费 %s 平台金币",me.szName, self.tbItem[nFormId][2], nCount, nPlatformCoin));
			end
			me.SetTask(self.TASK_GID, self.TASK_TASKCOIN, 0);
			local szLog = string.format("%s 收购 %s %s本 花费 %s 金币",me.szName, self.tbItem[nFormId][2], nCount, nCoin)
			Dbg:WriteLog("ExpTask", "经验任务系统", szLog);
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
			for i = 1, #self.tbAutoBuy do
				local nCount = math.floor(nCoin/self.tbAutoBuy[i][2]);
				nCoin = nCoin - nCount * self.tbAutoBuy[i][2]
				if nCount > 0 then
					me.ApplyAutoBuyAndUse(self.tbAutoBuy[i][1], nCount);
				end
			end
		end
	end
	me.SetTask(self.tbItem[nFormId][10][2], self.tbItem[nFormId][10][3], me.GetTask(self.tbItem[nFormId][10][2], self.tbItem[nFormId][10][3]) + nCount);
	GCExcute({"Task.TaskExp:FaBuTask", nFormId, tbTaskFaBu});
end

--gc发布任务回调
function tbTaskExp:FaBuTaskFinish(nFormId, nIndex, tbTaskFaBu, szPlayerName)
	if not self.tbTask[nFormId] then
		self.tbTask[nFormId] = {};
	end
	self.tbTask[nFormId][nIndex]= tbTaskFaBu;
	local nPos = 0;	
	for i, tbTaskEx in ipairs(self.tbTaskAll) do
		if tbTaskEx[4] < tbTaskFaBu[2] then
			nPos = i;			
			break;
		end
	end	
	if nPos == 0 then
		nPos = #self.tbTaskAll + 1;
	end	
	if nPos > 0 then
		table.insert(self.tbTaskAll, nPos, {nFormId, nIndex, tbTaskFaBu[1], tbTaskFaBu[2], tbTaskFaBu[3], tbTaskFaBu.szBuf});
	end
	local nCoin = self:CalculateAword(nFormId, tbTaskFaBu[1], tbTaskFaBu[2]);
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then		
		self:SyncData(pPlayer);
	end

	Dbg:WriteLog("ExpTask", "经验任务系统", string.format("%s 收购 %s %s本 花费 %s 金币 任务ID：%s-%s",szPlayerName, self.tbItem[nFormId][2], tbTaskFaBu[1], nCoin, nFormId, nIndex));
	Dbg:WriteLogEx(1, "ExperienceTask", "收购物品", string.format("%s,%s,%s,%s,%s-%s",szPlayerName, tbTaskFaBu[1], self.tbItem[nFormId][2], nCoin, nFormId, nIndex));
end

-- 服务器1发送邮件
function tbTaskExp:SendMail2Player(nFormId, nCount, szPlayerName)
	if not nFormId or not self.tbItem[nFormId] or not nCount or nCount <= 0 or not szPlayerName or szPlayerName == "system" then
		return;
	end 
	if GetServerId() == 1 then
		local tbItem = self.tbItem[nFormId][9];
		local tbProp = KItem.GetOtherBaseProp(tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
		if not tbProp then
			return 0;
		end
		local nStackMax = tonumber(tbProp.nStackMax) or 1;
		if nCount > nStackMax then
			local nNeedBag = math.ceil(nCount / nStackMax);
			for i = 1, nNeedBag - 1 do
				KPlayer.SendMail(szPlayerName, "任务平台收购物品", string.format("您从任务平台收购获得的%s",self.tbItem[nFormId][2]), 0, 0, nStackMax, tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
			end
			KPlayer.SendMail(szPlayerName, "任务平台收购物品", string.format("您从任务平台收购获得的%s",self.tbItem[nFormId][2]), 0, 0, nCount - nStackMax * (nNeedBag - 1), tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
		else
			KPlayer.SendMail(szPlayerName, "任务平台收购物品", string.format("您从任务平台收购获得的%s",self.tbItem[nFormId][2]), 0, 0, nCount, tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
		end
	end
end

--奖励 绑金
function tbTaskExp:AddAword(nBindCoin, szPlayerName)
	if nBindCoin <= 0 then
		return;
	end
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return;
	end
	pPlayer.AddBindCoin(nBindCoin);
	pPlayer.Msg("恭喜您完成任务获得"..tostring(nBindCoin)..IVER_g_szBindCoinName);
	Dialog:SendInfoBoardMsg(pPlayer, "恭喜您完成任务获得"..tostring(nBindCoin)..IVER_g_szBindCoinName);
	Dbg:WriteLog("ExpTask","完成任务获得奖金", string.format("玩家%s通过完成任务平台任务获得%s绑金",szPlayerName, nBindCoin));
end

--上交后给定其他物品
function tbTaskExp:AddItemOther(nFormId, nCount, szPlayerName)
	if not self.tbItem[nFormId] or  nCount <= 0 then
		return;
	end
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return;
	end
	local tbItem = self.tbItem[nFormId][5];
	--交东西和得东西的比例
	local nCount = math.floor(nCount * self.tbItem[nFormId][7] / 1000);
	if nCount > 0 then
		pPlayer.AddStackItem(tbItem[1], tbItem[2], tbItem[3], tbItem[4], nil, nCount);
	end
end

--计算花费金币
function tbTaskExp:CalculateAword(nFormId, nCount, nXing)
	if not self.tbItem[nFormId] or not nCount or nCount <= 0 or not nXing or nXing <= 0 then
		return 0;
	end
	return (self.tbItem[nFormId][3]  + self.tbItem[nFormId][4] * nXing) * nCount;
end

function tbTaskExp:LoadBuffer_GS()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_TASKPLATFORM, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbCheXiaoBuffer = tbBuffer;
	end
end

function tbTaskExp:AddPlatformCoin()
	if not self.tbCheXiaoBuffer[me.szName] or self.tbCheXiaoBuffer[me.szName] <= 0 then
		return;
	end
	me.SetTask(self.TASK_GID, self.TASK_TASKCOIN, me.GetTask(self.TASK_GID, self.TASK_TASKCOIN) + self.tbCheXiaoBuffer[me.szName]);
	me.Msg(string.format("您发布平台任务过期，返还您平台金币点数%s", self.tbCheXiaoBuffer[me.szName]));
	GCExcute({"Task.TaskExp:DeleteGlobleBuf", self.tbCheXiaoBuffer[me.szName], me.szName});	
end

function tbTaskExp:CheckOperate()
	if self.Open ~= 1 then
		return 0;
	end
	local nNowTime = GetTime();
	if nNowTime - me.GetTask(self.TASK_GID, self.TASK_OPERATETIME) < 5 then
		me.Msg("请不要过快操作！")
		Dialog:SendInfoBoardMsg(me, "请不要过快操作！");
		return 0;
	end
	return 1;
end

ServerEvent:RegisterServerStartFunc(Task.TaskExp.SeverStart, Task.TaskExp);
ServerEvent:RegisterServerStartFunc(Task.TaskExp.LoadBuffer_GS, Task.TaskExp);

-------------------------------------------------------
--玩家每天清变量
function tbTaskExp:DailyEvent()	
	me.SetTask(2130,6, 0);
end

PlayerSchemeEvent:RegisterGlobalDailyEvent({Task.TaskExp.DailyEvent, Task.TaskExp});



-------------------------------------------------------
--客户端打开回调
function tbTaskExp:OpenTaskWindow()

	if self:IsOpen(me) ~= 1 then
		return 0;
	end
		
	if (me.nFightState == 1 and SpecialEvent.tbTequan["opentaskexp"]:Check(me.nId) ~= 1) then
		me.CallClientScript({"Ui:ServerCall", "UI_INFOBOARD", "OnOpen" , "您现在不能使用经验平台"});
		return 0;
	end

	self:SyncData(me);	
end

function tbTaskExp:SyncData(pPlayer)
	pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_EXPTASK"});
	local tbPartDate = {}
	local nCount = 1;
	local tbMyTask = self:GetMyTask(pPlayer);
	local tbPartMyTask = {};
	--截取前50个任务
	if #self.tbTaskAll > self.nMaxViewTask then
		for i = 1 , self.nMaxViewTask do
			tbPartDate[i] = self.tbTaskAll[i];
		end		
	else
		tbPartDate = self.tbTaskAll;
	end
	
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_EXPTASK", "OnRecvData", 1,  tbPartDate});
	
	--个人任务超过显示的100个，分包发送
	if #tbMyTask > self.nMaxEveryOne then
		for i = 1, #tbMyTask do
			local nFMod = math.fmod(i, self.nMaxEveryOne);
			tbPartMyTask[nCount] = tbPartMyTask[nCount] or {};
			if nFMod ~= 0 then
				tbPartMyTask[nCount][nFMod] = self.tbTaskAll[i];
			else
				tbPartMyTask[nCount][self.nMaxEveryOne] = self.tbTaskAll[i];
				nCount = nCount + 1;
			end			
		end
		for i = 1, #tbPartDate do
			pPlayer.CallClientScript({"Ui:ServerCall", "UI_EXPTASK", "OnRecvData", 2, tbPartMyTask[i]});
		end
	else		
		pPlayer.CallClientScript({"Ui:ServerCall", "UI_EXPTASK", "OnRecvData", 2, tbMyTask});
	end
end

--分离我的任务
function tbTaskExp:GetMyTask(pPlayer)
	local tbMyTask = {};
	for nIndex ,tbTaskEx in ipairs(self.tbTaskAll) do
		if tbTaskEx[6] == pPlayer.szName then
			table.insert(tbMyTask, self.tbTaskAll[nIndex]);
		end
	end
	return tbMyTask;
end

function tbTaskExp:IsOpen(pPlayer)
	if pPlayer == nil then
		return 0;
	end
	if self.Open == 0 then
		Dialog:SendBlackBoardMsg(pPlayer, "任务平台还未开放，敬请期待！");
		return 0;
	end
	local szErrorMsg = "";
	if (0 == self:ForbitManger(pPlayer)) then
		szErrorMsg = "该地图不允许操作任务平台！";
	elseif pPlayer.IsAccountLock() ~= 0 then
		szErrorMsg = "Tài khoản đang bị khóa, không thể thao tác!";	
	end
	if (szErrorMsg ~= "") then 
		pPlayer.CallClientScript({"Ui:ServerCall", "UI_INFOBOARD", "OnOpen" , szErrorMsg});
		return 0;
	end
	return 1;
end


function tbTaskExp:ForbitManger(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	
	if (GLOBAL_AGENT) then
		return 0;
	end;
	
	if (pPlayer.nMapId <= 29) then
		return 1;
	end
	
	if SpecialEvent.tbTequan["opentaskexp"]:Check(pPlayer.nId) == 1 then
		return 1;
	end
	
	return 0;
end


-------------------------------------------------------
-- c2s call
-------------------------------------------------------

--完成任务
function c2s:ApplyFinishTask(nFormId, nIndex)
	if tbTaskExp:CheckOperate() == 1 then
		me.SetTask(tbTaskExp.TASK_GID, tbTaskExp.TASK_OPERATETIME, GetTime());
		tbTaskExp:FinishTask(nFormId, nIndex);
	end
end

--发布任务
function c2s:ApplyFaBuTask(nFormId, nCount, nXing)
	if tbTaskExp:CheckOperate() == 1 then
		me.SetTask(tbTaskExp.TASK_GID, tbTaskExp.TASK_OPERATETIME, GetTime());
		tbTaskExp:FaBuTask(nFormId, nCount, nXing);
	end
end

--撤销任务
function c2s:ApplyCanCelTask(nFormId, nIndex)
	if tbTaskExp:CheckOperate() == 1 then
		me.SetTask(tbTaskExp.TASK_GID, tbTaskExp.TASK_OPERATETIME, GetTime());
		tbTaskExp:CanCelTask(nFormId, nIndex);
	end
end

--打开面板

function c2s:ApplyOpenTask()
	tbTaskExp:OpenTaskWindow();
end
