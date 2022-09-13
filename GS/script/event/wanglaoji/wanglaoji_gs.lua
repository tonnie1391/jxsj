--王老吉活动
--孙多良
--2008.08.25

Require("\\script\\event\\wanglaoji\\wanglaoji_def.lua")

local WangLaoJi = SpecialEvent.WangLaoJi;

function WangLaoJi:GetTask(nTaskId)
	return me.GetTask(self.TASK_GROUP, nTaskId)
end

function WangLaoJi:SetTask(nTaskId, nValue)
	return me.SetTask(self.TASK_GROUP, nTaskId, nValue)
end

function WangLaoJi:GetCard(pPlayer, nNum)
	for i=1, nNum do
		local pItem = me.AddItem(unpack(self.ITEM_CARD));
		if pItem then
			me.Msg("您获得了<color=yellow>王老吉降火卡<color>。");
			self:WriteLog(string.format("获得了一张:%s", pItem.szName), me.nId)
		end
	end
end

function WangLaoJi:CheckEventTime(nState)
	local nDate = tonumber(GetLocalDate("%Y%m%d"))
	if nDate >= self.TIME_STATE_NEW[1] and nDate < self.TIME_STATE_NEW[nState] then
		return 1;
	end
	return 0;
end

function WangLaoJi:CheckExAward()
	local nDate = tonumber(GetLocalDate("%Y%m%d"))
	if nDate >= self.TIME_STATE_NEW[3] and nDate < self.TIME_STATE_NEW[5] then
		for i=1, KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) do
			local szName = KGblTask.SCGetDbTaskStr(self.KEEP_SORT[i]);
			local nPoint = KGblTask.SCGetDbTaskInt(self.KEEP_SORT[i]);
			if szName == me.szName and nPoint >= self.DEF_WEEK_EXGRAGE then
				return 1;
			end
		end
		return 0;
	end
	return 0;
end

--防上火领取奖励
function WangLaoJi:OnDialog()
	local szMsg = [[<color=yellow>庆国庆-江湖防上火行动<color>
	
活动时间：<color=yellow>9月17日维护后 — 11月25日0:00<color>
	
领奖时间：<color=yellow>12月02日24：00前<color>
    
活动奖励：
    在整个活动期间，每周（周二0点到下周二0点）积分第一，并且积分不低于5000分，将会获得<color=yellow>盛夏白银令牌（获得绑定）<color>。活动结束时，最终排名2—20的玩家，积分达到5000分可以获得<color=yellow>盛夏青铜令牌<color>，没达到5000分可以获得<color=yellow>7级玄晶（绑定）<color>
    
    更详细的信息请查看帮助锦囊]]
		
	local tbOpt = 
	{	
		{"领取每周头名奖励", self.GetWeekAward, self},
		{"领取最终排名奖励", self.GetFinishAward, self},
		{"Ta chỉ đến xem thôi"}
	}
	Dialog:Say(szMsg, tbOpt)
end

function WangLaoJi:GetWeekAward()
	if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) <= 0 then
		Dialog:Say("暂时还没产生每周头名。")
		return 0;
	end
	
	local szMsg = "每周的头名并且积分不低于5000分奖励名单如下：\n\n";
	local tbAward = {};
	for i=1, KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) do
		local nPoint = KGblTask.SCGetDbTaskInt(self.KEEP_SORT[i])
		local szName = KGblTask.SCGetDbTaskStr(self.KEEP_SORT[i])
		if szName == "" then
			szName = "<color=purple>本周轮空<color>"
		end
		szMsg = szMsg .. string.format("<color=yellow>第%s周%s：%s<color>\n", Lib:Transfer4LenDigit2CnNum(i), self.WEEK_MSG[i], szName);
		if szName == me.szName then
			table.insert(tbAward, {i, szName, nPoint});
		end
	end
	local tbOpt = {
		{"Kết thúc đối thoại"}
	}
	if #tbAward == 0 then
		szMsg = szMsg .. "\n您没有获得每周头名奖励，请继续努力。";
	else
		local nGetFlag = 0;
		for i, tbTemp in ipairs(tbAward) do
			local szMsgGet = "奖励已领取"
			if self:GetTask(self.TASK_WEEK_AWARD[tbTemp[1]]) == 0 then
				szMsgGet = "奖励未领取";
				nGetFlag = 1;
			end
			szMsg = szMsg .. string.format("\n您在<color=yellow>第%s周<color>获得了第一名[<color=yellow>%s<color>]", Lib:Transfer4LenDigit2CnNum(tbTemp[1]), szMsgGet);
		end
		if nGetFlag == 1 then
			table.insert(tbOpt, 1, {"领取周头名奖励", self.SureGetWeekAward, self})
		end
	end
	Dialog:Say(szMsg, tbOpt);
end

function WangLaoJi:SureGetWeekAward()
	local tbAward = {};
	local tbReadyAward = {};
	for i=1, KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) do
		local nPoint = KGblTask.SCGetDbTaskInt(self.KEEP_SORT[i])
		local szName = KGblTask.SCGetDbTaskStr(self.KEEP_SORT[i])
		if szName == me.szName then
			table.insert(tbAward, {i, szName, nPoint});
		end
	end
	if #tbAward == 0 then
		return;
	else
		local nGetFlag = 0;
		for i, tbTemp in ipairs(tbAward) do
			if self:GetTask(self.TASK_WEEK_AWARD[tbTemp[1]]) == 0 then
				nGetFlag = 1;
				table.insert(tbReadyAward, self.TASK_WEEK_AWARD[tbTemp[1]]);
			end
		end
		if nGetFlag == 0 then
			return 0;
		end
	end	
	if me.CountFreeBagCell() < #tbReadyAward then
		Dialog:Say(string.format("对不起，您的背包空间不足，需要%s格背包空间", #tbReadyAward));
		return 0;
	end
	for i, nTaskId in pairs(tbReadyAward) do
		local pItem = me.AddItem(unpack(self.ITEM_TOKEN));
		if pItem then
			pItem.Bind(1);
			self:SetTask(nTaskId, 1);
			self:WriteLog(string.format("领取了周排名奖励:%s", pItem.szName), me.nId)
		end
	end
	Dialog:Say("您成功领取了周头名奖励。");
end

function WangLaoJi:GetWeekFinishAward(nSure)
	local szMsg = "";
	--local szMsg = "每周的头名并且积分不低于5000分奖励名单如下：\n\n";
	local tbAward = {};
	for i=1, KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) do
		local nPoint = KGblTask.SCGetDbTaskInt(self.KEEP_SORT[i])
		local szName = KGblTask.SCGetDbTaskStr(self.KEEP_SORT[i])
		--if szName == "" then
		--	szName = "<color=purple>本周轮空<color>"
		--end
		--szMsg = szMsg .. string.format("<color=yellow>第%s周%s：%s  积分：%s<color>\n", Lib:Transfer4LenDigit2CnNum(i), self.WEEK_MSG[i], szName, nPoint);
		if szName == me.szName and nPoint >= self.DEF_WEEK_EXGRAGE then
			table.insert(tbAward, {i, szName, nPoint});
		end
	end
	local tbOpt = {
		{"Kết thúc đối thoại"}
	}
	if #tbAward == 0 then
		szMsg = szMsg .. "\n您没有获得防上火行动额外奖励。";
	else
		local nGetFlag = 0;
		local nExCount = 0;
		for i, tbTemp in ipairs(tbAward) do
			szMsg = szMsg .. string.format("\n您在<color=yellow>第%s周<color>获得了第一名", Lib:Transfer4LenDigit2CnNum(tbTemp[1]));
			if tbTemp[3] >= self.DEF_WEEK_EXGRAGE then
				local nCount = math.floor((tbTemp[3] - self.DEF_WEEK_EXGRAGE) / self.DEF_WEEK_EXPREGRAGE) + 1;
				if nCount > 5 then
					nCount = 5;
				end
				nExCount = nExCount + nCount;
			end
		end
		if nSure then
			if self:GetTask(self.TASK_EXAWARD) > 0 then
				Dialog:Say(string.format("您已领取过了防上火行动额外奖励"));				
				return 0;
			end
			if me.CountFreeBagCell() < nExCount then
				Dialog:Say(string.format("对不起，您的背包空间不足，需要%s格背包空间", nExCount));
				return 0;
			end
			self:SetTask(self.TASK_EXAWARD, nExCount);
			for ni=1, nExCount do 
				local pItem = me.AddItem(unpack(self.ITEM_TOKEN500));
				if pItem then
					self:SetTask(self.TASK_EXAWARD, nExCount);
					self:WriteLog(string.format("领取了防上火行动额外奖励:%s", pItem.szName), me.nId)
				end
			end
			return 0;
		end
		local szMsgGet = "已领取";
		if self:GetTask(self.TASK_EXAWARD) == 0 then
			szMsgGet = "未领取";
			nGetFlag = 1;
		end
		szMsg = szMsg .. string.format("，您可领取<color=yellow>%s<color>个盛夏青铜令牌[<color=yellow>%s<color>]", nExCount, szMsgGet);
		if nGetFlag == 1 and nExCount > 0 then
			table.insert(tbOpt, 1, {"领取防上火行动额外奖励", self.GetWeekFinishAward, self, 1})
		end
	end
	Dialog:Say(szMsg, tbOpt);	
end

function WangLaoJi:GetFinishAward()
	if self:CheckEventTime(3) == 1 then
		Dialog:Say("在<color=yellow>11月25日<color>活动结束后，<color=yellow>最终排名2-20名<color>的玩家才能领取奖励。现在活动还未结束，请继续努力！")
		return 0;
	end
	if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) < 10 then
		Dialog:Say("在<color=yellow>11月25日<color>活动结束后，<color=yellow>最终排名2-20名<color>的玩家才能领取奖励。现在活动还未结束，请继续努力！")
		return 0;		
	end
	
	local nAwardFlag = 0;
	local nRank = 0;
	local nPoint = 0;
	local szMsg = "很可惜，您最终排名没有进入前20名。"; 
	for i=DBTASD_EVENT_SORT01, DBTASD_EVENT_SORT20 do
		nRank = nRank + 1;
		if nRank == 1 then
			if me.szName == KGblTask.SCGetDbTaskStr(i) then
				szMsg = "恭喜您，您是周头名，请选择领取周头名奖励。";
				if KGblTask.SCGetDbTaskInt(i) < self.DEF_WEEK_GRAGE then
					nAwardFlag = nRank;
					nPoint = KGblTask.SCGetDbTaskInt(i);
					break;
				end
			end
		elseif me.szName == KGblTask.SCGetDbTaskStr(i) then
			nAwardFlag = nRank;
			nPoint = KGblTask.SCGetDbTaskInt(i);
			break;
		end
	end
	if nAwardFlag == 0 then
		Dialog:Say(szMsg);
		return 0;
	end
	
	if self:GetTask(self.TASK_AWARD) == 1 then
		Dialog:Say("您已经领取过了前20名奖励。");
		return 0;		
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("对不起，您的背包空间不足，需要1格背包空间");
		return 0;
	end
	local tbAwardItem = self.ITEM_XUANJIN;
	local nBind = 1;
	if nPoint >= self.DEF_WEEK_GRAGE then
		tbAwardItem = self.ITEM_TOKEN500;
		nBind = 0;
	end
	
	local pItem = me.AddItem(unpack(tbAwardItem));
	if pItem then
		if nBind == 1 then
			pItem.Bind(1);
		end
		self:SetTask(self.TASK_AWARD, 1);
		self:WriteLog(string.format("排名：%s,分数：%s,领取了一个绑定的%s", nRank, nPoint, pItem.szName), me.nId)
	end
	Dialog:Say(string.format("恭喜您成功领取了王老吉前20奖励，一个<color=yellow>%s<color>。", pItem.szName));
end

function WangLaoJi:AwardMsg(nWeek)
	local szMsg = string.format("\n  <color=yellow>您已经获得了王老吉活动的第%s周第一名，可以到各城市盛夏活动推广员处领取盛夏活动白银令牌（获得绑定）。同时您的积分将被清0。<color>", Lib:Transfer4LenDigit2CnNum(nWeek));
	Dialog:Say(szMsg, {"Xác nhận", self.XiuLianZhu, self});
end

--修炼珠
function WangLaoJi:XiuLianZhu(nFlag)
	local nWeek = self:GetTask(self.TASK_WEEK);
	--print(nWeek,  KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10))
	if nWeek < KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) then
		for i = nWeek + 1 , KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10) do
			--print(me.szName, KGblTask.SCGetDbTaskStr(self.KEEP_SORT[i]))
			if me.szName == KGblTask.SCGetDbTaskStr(self.KEEP_SORT[i]) then
				self:SetTask(self.TASK_GRAGE, 0);
				self:SetTask(self.TASK_WEEK, KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10));
				self:AwardMsg(i);
				return 0;
			end
		end
		self:SetTask(self.TASK_WEEK, KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10));
	end
	local szMsg = "目前王老吉凉茶积分排行榜:\n\n<color=yellow>";
	if not nFlag then
		local nRank = 0;
		for ni = DBTASD_EVENT_SORT01, DBTASD_EVENT_SORT20 do
			local nPoint = KGblTask.SCGetDbTaskInt(ni);
			local szName = KGblTask.SCGetDbTaskStr(ni);
			nRank = nRank + 1;
			--if nPoint > 0 and szName ~= "" then
			szMsg = szMsg .. Lib:StrFillL(string.format("第%2s名：%s", nRank, szName), 25).. nPoint .."分\n"
			--end
		end
		szMsg = szMsg .. "<color>\n结束时间：<color=red>11月25日0：00<color>";
		szMsg = szMsg .. "\n\n您目前的积分：".. string.format("<color=yellow>%s分<color>", self:GetTask(self.TASK_GRAGE));
		
		Dialog:Say(szMsg, {{"继续查看各周头名", self.XiuLianZhu, self, 1}, {"Kết thúc đối thoại"}} );
		return 0;
	end
	
	szMsg = szMsg .. "\n\n<color>各周第一名并且积分不低于5000分名单<color=yellow>（周二0点到下周二0点）<color>：\n\n";
	local nWeek = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_KEEP10);
	for i=1, 10 do
		local szWeekName = KGblTask.SCGetDbTaskStr(self.KEEP_SORT[i]);
		if szWeekName == "" then
			szWeekName = "<color=purple>本周轮空<color>";
		end
		if nWeek >= i then
			szMsg = szMsg .. string.format("<color=yellow>第%s周%s：%s\n", Lib:Transfer4LenDigit2CnNum(i),  self.WEEK_MSG[i], szWeekName) ;
		else
			szMsg = szMsg .. string.format("<color=gray>第%s周%s：还未揭晓\n", Lib:Transfer4LenDigit2CnNum(i), self.WEEK_MSG[i]);				
		end
	end
	local tbOpt = 
	{
		{"Ta hiểu rồi"};
	}
	Dialog:Say(szMsg, tbOpt);
end
	
function WangLaoJi:OnLogin()
	if self:CheckExAward() == 1 and self:GetTask(self.TASK_EXAWARD) == 0 then
		me.Msg("您在<color=yellow>江湖防上火行动<color>中表现积极，特此奖励<color=yellow>盛夏青铜令牌<color>，请到盛夏活动推广员处领取。");
	end
end

function WangLaoJi:WriteLog(szLog, nPlayerId)
	if nPlayerId then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if (pPlayer) then
			Dbg:WriteLog("SpecialEvent.WangLaoJi", "王老吉活动", pPlayer.szAccount, pPlayer.szName, szLog);
			return 1;
		end
	end
	Dbg:WriteLog("SpecialEvent.WangLaoJi", "王老吉活动", szLog);

end


--掉落王老吉卡片开关扩展函数（活动系统）
local tbClass = EventManager:GetClass("wanglaoji")

function tbClass:ExeStartFun(tbParam)
	--执行限时事件
	SpecialEvent.WangLaoJi.CAN_GETCARD_FLAG = 1;
	return 0;
end

function tbClass:ExeEndFun(tbParam)
	--执行限时事件结束
	SpecialEvent.WangLaoJi.CAN_GETCARD_FLAG = 0;
	return 0;
end

PlayerEvent:RegisterOnLoginEvent(SpecialEvent.WangLaoJi.OnLogin, SpecialEvent.WangLaoJi);