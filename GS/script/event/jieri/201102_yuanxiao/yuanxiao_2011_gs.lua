-------------------------------------------------------
-- 文件名　：yuanxiao_2011_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-01-06 17:27:15
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201102_yuanxiao\\yuanxiao_2011_def.lua");

local tbYuanxiao_2011 = SpecialEvent.Yuanxiao_2011;

function tbYuanxiao_2011:_Reset(pPlayer)
	if pPlayer then
		pPlayer.SetTask(self.TASK_GID, self.TASK_AWARD_TYPE, 0);
		pPlayer.SetTask(self.TASK_GID, self.TASK_START_LEVEL, 0);
		pPlayer.SetTask(self.TASK_GID, self.TASK_STEP_LEVEL, 0);
	end
end

function tbYuanxiao_2011:CheckState(pPlayer)
	if pPlayer then
		local nType = pPlayer.GetTask(self.TASK_GID, self.TASK_AWARD_TYPE);
		local nStartLevel = pPlayer.GetTask(self.TASK_GID, self.TASK_START_LEVEL);
		local nStepLevel = pPlayer.GetTask(self.TASK_GID, self.TASK_STEP_LEVEL);
		if nType == 0 and nStartLevel == 0 and nStepLevel == 0 then
			return 1;
		elseif nType > 0 and nStartLevel > 0 and nStepLevel > 0 then
			if nType > self.MAX_TYPE or nStartLevel > self.MAX_START_LEVEL or nStepLevel > self.MAX_STEP_LEVEL then
				return 0;
			elseif nStepLevel < self.MAX_STEP_LEVEL then
				return 2;
			else
				return 3;
			end
		end
	end
	return 0;
end

function tbYuanxiao_2011:GetStartResult(pPlayer)
	
	if not self.tbRate then
		self.tbRate = Lib:LoadTabFile(self.RATE_FILE_PATH);
	end
	
	if #self.tbRate <= 0 or self:CheckState(pPlayer) ~= 1 then
		return 0;
	end

	local nAdd = 0;	
	local nIndex = 0;
	local nRand = MathRandom(1, 10000);

	for i = 1, #self.tbRate do
		nAdd = nAdd + self.tbRate[i].Rate;
		if nAdd >= nRand then
			nIndex = i;
			break;
		end
	end

	if nIndex == 0 then
		return 0;
	end
	
	local nType = tonumber(self.tbRate[nIndex].Type);
	local nLevel = tonumber(self.tbRate[nIndex].Level);
	
	pPlayer.SetTask(self.TASK_GID, self.TASK_AWARD_TYPE, nType);
	pPlayer.SetTask(self.TASK_GID, self.TASK_START_LEVEL, nLevel);
	pPlayer.SetTask(self.TASK_GID, self.TASK_STEP_LEVEL, 1);
end

function tbYuanxiao_2011:GetContinueResult(dwItemId)
	
	if self:CheckState(me) ~= 2 then
		return 0;
	end

	local nType = me.GetTask(self.TASK_GID, self.TASK_AWARD_TYPE);
	local nStartLevel = me.GetTask(self.TASK_GID, self.TASK_START_LEVEL);
	local nStepLevel = me.GetTask(self.TASK_GID, self.TASK_STEP_LEVEL);
	
	local nRand = MathRandom(1, 100);
	if nRand > self.STEP_RATE then
		
		self:_Reset(me);
		StatLog:WriteStatLog("stat_info", "chunjie2011", "yx_jinzhenzhu", me.nId, nStepLevel + 1, "失败");
		
		local pItem = KItem.GetObjById(dwItemId);
		if pItem then
			pItem.Delete(me);
		end
		
		Dialog:Say("很遗憾，打开下层失败了，一无所获。");
		return 0;
	end
	
	me.SetTask(self.TASK_GID, self.TASK_STEP_LEVEL, nStepLevel + 1);
	
	local tbItem = Item:GetClass("jade2011");
	tbItem:OnDialog(dwItemId);
end

function tbYuanxiao_2011:InitGame(pPlayer)
	if self:CheckState(pPlayer) == 0 then
		self:_Reset(pPlayer);
	end
	if self:CheckState(pPlayer) == 1 then
		self:GetStartResult(pPlayer);
	end
end

function tbYuanxiao_2011:GetAward(dwItemId)
	
	if self:CheckState(me) < 2 then
		Dialog:Say("对不起，你现在无法领取奖励。");
		return 0;
	end
	
	local nType = me.GetTask(self.TASK_GID, self.TASK_AWARD_TYPE);
	local nStartLevel = me.GetTask(self.TASK_GID, self.TASK_START_LEVEL);
	local nStepLevel = me.GetTask(self.TASK_GID, self.TASK_STEP_LEVEL);
	
	local nLevel = nStartLevel + nStepLevel - 1;
	local nValue = tonumber(self.TYPE_LEVEL_VALUE[nType].tbLevel[nLevel]);
	
	-- 玄晶
	if nType == 1 then
		local nNeed = 1;
		if me.CountFreeBagCell() < nNeed then
			Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
			return 0;
		end
		me.AddItem(18, 1, 114, nValue);
	
	-- 魂石
	elseif nType == 2 then
		local nNeed = KItem.GetNeedFreeBag(18, 1, 205, 1, {bForceBind = 1}, nValue);
		if me.CountFreeBagCell() < nNeed then
			Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
			return 0;
		end
		me.AddStackItem(18, 1, 205, 1, {bForceBind = 1}, nValue);
	
	-- 绑银
	elseif nType == 3 then
		if nValue + me.GetBindMoney() > me.GetMaxCarryMoney() then
			Dialog:Say("领取后您身上的绑定银两将会超出上限，请整理后再来。");
			return 0;
		end
		me.AddBindMoney(nValue);
		
	-- 绑金
	elseif nType == 4 then
		me.AddBindCoin(nValue);
	end
	
	local szItemName = self.TYPE_LEVEL_VALUE[nType].szName;
	local szCurItem = string.format("%s%s", Item:FormatMoney(nValue), szItemName);
	local szMsg = string.format("<color=yellow>%s<color>有幸打开了金珍珠的第<color=green>%s<color>层，领取了<color=yellow>%s<color>！", me.szName, nStepLevel, szCurItem);
	
	if nLevel >= 3 then
		me.SendMsgToFriend(szMsg);
	end
	
	if nStepLevel == 6 then
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
	end
	
	local pItem = KItem.GetObjById(dwItemId);
	if pItem then
		pItem.Delete(me);
	end
	
	self:_Reset(me);
	StatLog:WriteStatLog("stat_info", "chunjie2011", "yx_jinzhenzhu", me.nId, nLevel, szItemName, nValue);
end

-- 启动事件
function tbYuanxiao_2011:StartEvent_GS()
	self.tbRate = Lib:LoadTabFile(self.RATE_FILE_PATH);
end

-- 每日事件
function tbYuanxiao_2011:DailyEvent_GS()
	me.SetTask(self.TASK_GID, self.TASK_USE_DINNER, 0);
	me.SetTask(self.TASK_GID, self.TASK_EAT_DINNER, 0);
end

ServerEvent:RegisterServerStartFunc(SpecialEvent.Yuanxiao_2011.StartEvent_GS, SpecialEvent.Yuanxiao_2011);
PlayerSchemeEvent:RegisterGlobalDailyEvent({SpecialEvent.Yuanxiao_2011.DailyEvent_GS, SpecialEvent.Yuanxiao_2011});
