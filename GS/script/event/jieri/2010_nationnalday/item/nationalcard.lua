--=================================================
-- 文件名　：nationalcard.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-23 14:16:36
-- 功能描述：国庆卡片
--=================================================

local tbItem = Item:GetClass("nationalcard");
SpecialEvent.tbNationnalDay = SpecialEvent.tbNationnalDay or {};
local tbEvent = SpecialEvent.tbNationnalDay or {};

tbItem.IdentifyDuration = Env.GAME_FPS * 10;		--鉴定时间

function tbItem:CanUse()
	local szErrMsg = "";
	
	if (tbEvent:CheckOpenFlag() ~= tbEvent.STATE_OPEN) then
		szErrMsg = "现在不在活动期间，不能鉴定卡片。";
		return 0, szErrMsg;
	end
	
	if (me.dwCurGTP < tbEvent.JH_USECARD or
		me.dwCurMKP < tbEvent.JH_USECARD) then
		szErrMsg = string.format("你的精活不足，使用这张卡片需要消耗精活各%s点。", tbEvent.JH_USECARD);
		return 0, szErrMsg;
	end
	
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	local nLastUseDate = me.GetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_DATE);
	if (nCurDate ~= nLastUseDate) then
		me.SetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_DATE, nCurDate);
		me.SetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_COUNT_DAY, 0);
	end
	
	local nCount_Today = me.GetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_COUNT_DAY);
	if (nCount_Today >= tbEvent.COUNT_PERDAY) then
		szErrMsg = string.format("活动期间，每天最多只能开<color=yellow>%s<color>张卡，你今天的已经开满了，还是明天再来吧。", tbEvent.COUNT_PERDAY);
		return 0, szErrMsg;
	end	
	
	local nCount_Sum = me.GetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_COUNT_SUM);
	if (nCount_Sum >= tbEvent.COUNT_SUM) then
		szErrMsg = string.format("活动期间，每个人最多只能开<color=yellow>%s<color>张卡。你已经开完。", tbEvent.COUNT_SUM);
		return 0, szErrMsg;
	end
	
	if (me.CountFreeBagCell() < 2) then
		szErrMsg = "需要2个包裹空间。"
		return 0, szErrMsg;
	end
	
	local bCollectAll = 1;
	for i = 1, tbEvent.COUNT_AREA do
		if (tbEvent:GetAchieveFlag(i) == 0) then
			bCollectAll = 0;
			break;
		end
	end
	if (1 == bCollectAll) then
		szErrMsg = "恭喜你，你已经收集了所有的卡片，不需要继续使用其他卡片了。";
		return 0, szErrMsg;
	end
	
	return 1;
end

function tbItem:AfterUse()
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	local nCount_Today = me.GetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_COUNT_DAY) + 1;
	local nCount_Sum = me.GetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_COUNT_SUM) + 1;
	
	me.SetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_DATE, nCurDate);
	me.SetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_COUNT_DAY, nCount_Today);
	me.SetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_COUNT_SUM, nCount_Sum);
end

function tbItem:NeedAdd_CardCollection()
	local bNeed = 1;
	if (0 ~= me.GetTask(tbEvent.TSK_GROUP, tbEvent.TSKID_COUNT_SUM)) then
		bNeed = 0;
	end
	
	if (1 == bNeed) then
		local tbFind = me.FindItemInAllPosition(18, 1, 1008, 1);
		if (tbFind and #tbFind > 0) then
			bNeed = 0;
		end
	end
	
	return bNeed;
end

function tbItem:OnUse()
	self:Identify(it.dwId);
	return 0;
end

function tbItem:Identify(nItemId, bSure)
	local bCanUse, szErrMsg = self:CanUse();
	if (not bCanUse or 1 ~= bCanUse) then
		if (szErrMsg and "" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	if (not nItemId or nItemId <= 0) then
		return 0;
	end
	
	if (bSure and 1 == bSure) then
		self:SuccessUse(nItemId);
		return;
	end
	
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
		
	GeneralProcess:StartProcess("Đang giám định...", self.IdentifyDuration, {self.Identify, self,  nItemId, 1}, nil, tbEvent);
end

function tbItem:SuccessUse(nItemId)
	if (not nItemId or nItemId <= 0) then
		return;
	end
	
	local pCard = KItem.GetObjById(nItemId);
	if (not pCard) then
		return;
	end
	
	if (pCard.Delete(me) ~= 1) then
		return;
	end
	
	me.ChangeCurGatherPoint(-tbEvent.JH_USECARD);	--减精力
	me.ChangeCurMakePoint(-tbEvent.JH_USECARD);		--减活力
	
	if (1 == self:NeedAdd_CardCollection()) then
		local pItem = me.AddItem(18, 1, 1008, 1);
		if (pItem) then
			local nTimeOutSec = Lib:GetDate2Time(tbEvent.TIME_AWARD);
			me.SetItemTimeout(pItem, os.date("%Y/%m/%d/23/59/59", nTimeOutSec));
			pItem.Bind(1);
			pItem.Sync();
		end
	end
	
	local nRand = MathRandom(1, 100);
	if (nRand <= tbEvent.RATE_RANDCARD) then
		-- 随机到神州卡，另外处理
		local pItem = me.AddItem(18, 1, 1010, 1);
		if (pItem) then
			me.SetItemTimeout(pItem, os.date("%Y/%m/%d/23/59/59", GetTime()));
			pItem.Sync();
		end
	else
		-- 没随机到神州卡，随机选取一个地区
		nRand = MathRandom(1, tbEvent.COUNT_AREA)
		tbEvent:OnGetAreaCard(nRand);
	end
	
	self:AfterUse();
	
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Mid-autumnNational", "使用中华卡", me.szName);
end
