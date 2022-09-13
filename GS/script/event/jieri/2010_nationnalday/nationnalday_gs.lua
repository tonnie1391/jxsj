--=================================================
-- 文件名　：nationnalday_gs.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-23 14:23:19
-- 功能描述：2010国庆活动gs
--=================================================

SpecialEvent.tbNationnalDay = SpecialEvent.tbNationnalDay or {};
local tbEvent = SpecialEvent.tbNationnalDay or {};

-- 获取某一个地区的信息
function tbEvent:OnGetAreaCard(nIndex)
	self:GetSpeArea_FromGblTask();
	if (self:CheckOpenFlag() ~= self.STATE_OPEN) then
		return;
	end
	
	if (not nIndex or nIndex <= 0 or nIndex > self.COUNT_AREA) then
		return;
	end
	
	local nFlag = self:GetAchieveFlag(nIndex);
	local bHaveGet = 0;
	if (nFlag and nFlag == 1) then
		bHaveGet = 1
	end
	
	self:__OnGetAreadCard(nIndex);
	self:__SendMsg(nIndex, bHaveGet);
	self:__ShowDialog(nIndex);
end

function tbEvent:__ShowDialog(nIndex)
	if (not nIndex or nIndex <= 0) then
		return;
	end
	local tbAreaInfo = self:GetAreaInfo(nIndex);
	if (not tbAreaInfo) then
		return;
	end
	local szMsg = string.format("<color=yellow>%s【%s】<color>\n\n<color=green>你已经收集到该区域的信息<color>\n\n%s", tbAreaInfo.szName or "",
		tbAreaInfo.szShortName or "", tbAreaInfo.szDesc or "");
	Dialog:Say(szMsg, {"我又学到了新的知识"});
end

function tbEvent:__OnGetAreadCard(nIndex)
	self:SetAchiveFlag(nIndex, 1);
	
	local bIsSpeArea = 0;
	for _, v in pairs(self.tbSpeArea) do
		if (v == nIndex) then
			bIsSpeArea = 1;
			break;
		end
	end
	if (1 == bIsSpeArea) then
		self:__Award_SpeArea();
	end
end

-- 开出福地的特殊奖励
function tbEvent:__Award_SpeArea()
	me.AddBindMoney(88888, Player.emKBINDMONEY_ADD_EVENT);
	me.AddBindCoin(888, Player.emKBINDCOIN_ADD_EVENT);
	
--	local nBaseExp = me.GetBaseAwardExp();
--	local nExp = nBaseExp * 120;	-- 两小时的基准经验
--	me.AddExp(nExp);
end

function tbEvent:__SendMsg(nIndex, bHaveGet)
	local szMsg = "";
	if (bHaveGet and 1 == bHaveGet) then
		szMsg = self:__GetMsg_AlreadyHave(nIndex);
	end
	
	if (szMsg and "" == szMsg) then
		for _, v in pairs(self.tbSpeArea) do
			if (v == nIndex) then
				szMsg = self:__GetMsg_SpeArea(nIndex);
				break;
			end
		end
	end
	
	if (szMsg and "" == szMsg) then
		szMsg = self:__GetMsg_New(nIndex);
	end
	
	me.Msg(szMsg);
	Dialog:SendBlackBoardMsg(me, szMsg);
end

function tbEvent:__GetMsg_AlreadyHave(nIndex)
	if (not nIndex or nIndex <= 0) then
		return;
	end
	local tbAreaInfo = self:GetAreaInfo(nIndex);
	if (not tbAreaInfo) then
		return;
	end
	local szMsg = string.format("你收集到了<color=green>【%s】<color><color=red>（重复收集）<color>，望再接再厉！", tbAreaInfo.szShortName or "");
	return szMsg;
end

function tbEvent:__GetMsg_New(nIndex)
	if (not nIndex or nIndex <= 0) then
		return;
	end
	local tbAreaInfo = self:GetAreaInfo(nIndex);
	if (not tbAreaInfo) then
		return;
	end
	local szMsg = string.format("恭喜你，在爱我中华活动中收集到了<color=green>【%s】<color>。", tbAreaInfo.szShortName or "");
	return szMsg;
end

function tbEvent:__GetMsg_SpeArea(nIndex)
	if (not nIndex or nIndex <= 0) then
		return;
	end
	local tbAreaInfo = self:GetAreaInfo(nIndex);
	if (not tbAreaInfo) then
		return;
	end
	local szMsg = string.format("恭喜你，开出今日福地<color=green>%s（%s）<color>，获得了额外的惊喜！", tbAreaInfo.szShortName or "", tbAreaInfo.szName or "");
	return szMsg;
end

function tbEvent:CanGetAward()
	local szErrMsg = "";
	if (self:CheckOpenFlag() ~= self.STATE_AWARD) then
		szErrMsg = "现在不是兑奖期，不能兑换奖励。";
		return 0, szErrMsg;
	end
	
	return 1;
end

function tbEvent:GetAward(nItemId)
	local bCanGetAward, szErrMsg = self:CanGetAward();
	if (not bCanGetAward or 0 == bCanGetAward) then
		if (szErrMsg and "" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return;
	end
	
	local pCardCollection = KItem.GetObjById(nItemId);
	if (not pCardCollection) then
		return;
	end
	
	local tbAwardInfo = self:__GetAwardInfo();
	if (not tbAwardInfo) then
		Dialog:Say("根据您收集的卡片数量，没有奖励可以领取。");
		return;
	end
	
	local nRet = self:__GetAward(tbAwardInfo);
	if (nRet and 1 == nRet) then
		pCardCollection.Delete(me);
	end
	
	local nCollectNum = self:GetCollectNum();
	local nTotalNum = me.GetTask(self.TSK_GROUP, self.TSKID_COUNT_SUM);
	local szLog = string.format("%s,%s,%s", me.szName, nCollectNum, nTotalNum);
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Mid-autumnNational", "兑换奖励", szLog);
end

function tbEvent:__GetAward(tbAward)
	if (not tbAward) then
		return 0;
	end
	
	if (tbAward.nCount and tbAward.nCount > 0) then
		if (me.CountFreeBagCell() < tbAward.nCount) then
			Dialog:Say(string.format("请清理出<color=yellow>%s<color>格包裹空间再来领取奖励。", tbAward.nCount));
			return 0;
		end
		for i = 1, tbAward.nCount do
			local pItem = me.AddItem(unpack(tbAward.tbGDPL));
			if (pItem) then
				me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 3600 * 24 * 30));
				pItem.Bind(1);
			end
		end
	end
	
	if (tbAward.nBindMoney and tbAward.nBindMoney > 0) then
		local nMaxCarryMoney = me.GetMaxCarryMoney();
		local nBindMoney = me.GetBindMoney();
		if (tbAward.nBindMoney > (nMaxCarryMoney - nBindMoney)) then
			Dialog:Say("您已经不能携带更多的绑定银两了。");
			return 0;
		end
		me.AddBindMoney(tbAward.nBindMoney, Player.emKBINDMONEY_ADD_EVENT);
	end
	
	return 1
end

function tbEvent:__GetAwardInfo()
	local nCollectNum = self:GetCollectNum();
	if (not nCollectNum or nCollectNum <= 0) then
		return;
	end
	
	for _, tbInfo in pairs(self.TBAWARD) do
		if (nCollectNum >= tbInfo.nMin and nCollectNum <= tbInfo.nMax) then
			return tbInfo;
		end
	end
end

-- gs启动的时候，从全局变量读取福地信息
function tbEvent:GetSpeAreaInfo()
	self:GetSpeArea_FromGblTask();
end


if (MODULE_GAMESERVER) then
	ServerEvent:RegisterServerStartFunc(SpecialEvent.tbNationnalDay.GetSpeAreaInfo, SpecialEvent.tbNationnalDay);
end
