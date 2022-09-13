-- 文件名　：card_random.lua
-- 创建者　：furuilei
-- 创建时间：2010-05-17 10:26:14
-- 功能描述：变换卡

SpecialEvent.tbWroldCup = SpecialEvent.tbWroldCup or {};
local tbEvent = SpecialEvent.tbWroldCup;

local tbItem = Item:GetClass("card_random");
tbItem.IdentifyDuration = Env.GAME_FPS * 10;		--鉴定时间

if MODULE_GAMESERVER then

function tbItem:CanUse()
	local szErrMsg = "";
	
	-- 活动日期判断
	if (tbEvent:CheckOpenState() == 0) then
		szErrMsg = "现在没有在盛夏活动期间，不能使用这张卡片。";
		return 0, szErrMsg;
	end
	
	--精活判断
	if (me.dwCurGTP < tbEvent.NUM_GTPMKP_IDENTIFY or
		me.dwCurMKP < tbEvent.NUM_GTPMKP_IDENTIFY) then
		szErrMsg = string.format("你的精活不足，使用这张卡片需要消耗精活各%s点。", tbEvent.NUM_GTPMKP_IDENTIFY);
		return 0, szErrMsg;
	end
	
	--背包判断
	if (me.CountFreeBagCell() < 1) then
		szErrMsg = "需要1格背包空间，整理下再来！";
		return 0, szErrMsg;
	end
	
	self:CheckIdendifyDate();
	local nNum_TodayIdentify = me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_IDENTIFY_TODAY);
	if (nNum_TodayIdentify >= tbEvent.MAX_NUM_IDENTIFY_PERDAY) then
		szErrMsg = string.format("每天最多只能使用%s张随机卡片，您的机会已经使用完了。", tbEvent.MAX_NUM_IDENTIFY_PERDAY);
		return 0, szErrMsg;
	end
	
	if (me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_IDENTIFY_TOTAL) >= tbEvent.MAX_NUM_IDENTIFY_TOTAL) then
		szErrMsg  = string.format("活动期间最多有%s次使用卡片的机会，你已经全部用完。", tbEvent.MAX_NUM_IDENTIFY_TOTAL);
		return 0, szErrMsg;
	end
	
	return 1;
end

function tbItem:OnUse()
	self:Identify(it.dwId);
	return 0;
end

function tbItem:Identify(nItemId, nSure)
	if (not nItemId or nItemId <= 0) then
		return;
	end
	
	local bCanUse, szErrMsg = self:CanUse();
	if (not bCanUse or bCanUse == 0) then
		if (szErrMsg and szErrMsg ~= "") then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	if (nSure and nSure == 1) then
		self:SuccessIdentify(nItemId);
		return 0;
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
		
	GeneralProcess:StartProcess("使用...", self.IdentifyDuration, {self.Identify, self,  nItemId, 1}, nil, tbEvent);
end

function tbItem:SuccessIdentify(nItemId)
	if (not nItemId or nItemId <= 0) then
		return;
	end
	local pItem = KItem.GetObjById(nItemId);
	if (not pItem) then
		return;
	end
	
	if pItem.Delete(me) ~= 1 then
		return 0;
	end
	
	me.ChangeCurGatherPoint(-tbEvent.NUM_GTPMKP_IDENTIFY);	--减1000精力
	me.ChangeCurMakePoint(-tbEvent.NUM_GTPMKP_IDENTIFY);	--减1000活力
	
	local nNum_TodayIdentify = me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_IDENTIFY_TODAY) + 1;
	me.SetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_IDENTIFY_TODAY, nNum_TodayIdentify);
	
	local nHaveUse = me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_IDENTIFY_TOTAL) + 1;
	me.SetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_IDENTIFY_TOTAL, nHaveUse);
	
	local tbRandomItem = Item:GetClass("randomitem");
	tbRandomItem:SureOnUse(82);
end

end -- MODULE_GAMESERVER

function tbItem:CheckIdendifyDate()
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	local nDate_LastIdentify = me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_DATE_LASTIDENDIFY);
	if (nCurDate > nDate_LastIdentify) then
		me.SetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_DATE_LASTIDENDIFY, nCurDate);
		me.SetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_IDENTIFY_TODAY, 0);
	end
end

function tbItem:GetTip()
	self:CheckIdendifyDate();
	
	local nNum_TodayIdentify = me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_IDENTIFY_TODAY);
	if (nNum_TodayIdentify > tbEvent.MAX_NUM_IDENTIFY_PERDAY) then
		nNum_TodayIdentify = tbEvent.MAX_NUM_IDENTIFY_PERDAY;
	end
	
	local nHaveUse = me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_NUM_IDENTIFY_TOTAL);
	if (nHaveUse > tbEvent.MAX_NUM_IDENTIFY_TOTAL) then
		nHaveUse = tbEvent.MAX_NUM_IDENTIFY_TOTAL;
	end
	
	local szTip = string.format("您今天已经使用了<color=yellow>%s<color>张随机卡片，还能使用<color=yellow>%s<color>张。\n在活动期间您已经一共使用了<color=yellow>%s<color>张卡片，还能使用<color=yellow>%s<color>张。\n注意：使用该卡片需要消耗精力和活力各<color=yellow>800<color>点。",
		nNum_TodayIdentify, tbEvent.MAX_NUM_IDENTIFY_PERDAY - nNum_TodayIdentify,
		nHaveUse, tbEvent.MAX_NUM_IDENTIFY_TOTAL - nHaveUse);
		
	return szTip;
end
