-- 09植树节 

--陈年树种
local tbOldSeed = Item:GetClass("item_seed_arbor_day_09Ex");

function tbOldSeed:OnUse()	
	if me.nLevel < SpecialEvent.ZhiShu2009.ATENDMINLEVEL then
		Dialog:Say("您等级不足60级，是不能种树的！",{"知道了"});
		return 0;
	end
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < SpecialEvent.ZhiShu2009.nStarTime or nData > SpecialEvent.ZhiShu2009.nCloseTime then	--活动期间外
		Dialog:Say("活动已经结束了！", {"知道了"});
		return 0;
	end
	if it.GetGenInfo(1) <= 0 then
		self:OnUseEx(it.dwId);
		return 0;
	end
	local szMsg = "看上去干瘪瘪的种子，种植可能需要花大量时间，你确定在这里种植这颗树种么？";
	local tbOpt = {
		{"就在这种", self.PlantTree, self, me, it.dwId},
        		{"我再考虑下"},
        };
        
    Dialog:Say(szMsg, tbOpt);
    return 0;
end

function tbOldSeed:OnUseEx(nItemId)
	local szMsg = "奇怪的树种，也不知道是什么树的树种，您要仔细辨认下么？";
	local tbOpt = {
		{"激活树种", self.ActiveSeed, self, nItemId},
      	  	{"我再考虑下"},
        };        
    Dialog:Say(szMsg, tbOpt);
    return 0;
end

function tbOldSeed:ActiveSeed(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < SpecialEvent.ZhiShu2009.nStarTime or nData > SpecialEvent.ZhiShu2009.nCloseTime then	--活动期间外
		Dialog:Say("活动已经结束了！", {"知道了"});
		return;
	end
	if me.nLevel < SpecialEvent.ZhiShu2009.ATENDMINLEVEL then
		Dialog:Say("您等级不足60级，还是提升下等级再来激活树种种树吧！",{"知道了"});
		return;
	end	
	local tbFind = me.FindItemInBags(unpack(SpecialEvent.ZhiShu2009.tbJug));
	if not tbFind[1] then
		Dialog:Say("激活树种需要一壶仙水！",{"知道了"});
		return;
	end
	me.ConsumeItemInBags(1, SpecialEvent.ZhiShu2009.tbJug[1], SpecialEvent.ZhiShu2009.tbJug[2], SpecialEvent.ZhiShu2009.tbJug[3], SpecialEvent.ZhiShu2009.tbJug[4], -1);
	pItem.SetGenInfo(1,  1);
	pItem.Sync();
	me.Msg("您激活了一粒种子！");
	return;
end

function tbOldSeed:PlantTree(pPlayer, dwItemId)
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		Dialog:Say("你的种子过期了。");
		return;
	end
	
	local nRes, szMsg = SpecialEvent.ZhiShu2009:CanPlantTree(pPlayer);
	
	if nRes == 1 then
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
			Player.ProcessBreakEvent.emEVENT_LOGOUT,
			Player.ProcessBreakEvent.emEVENT_DEATH,
		}
		
	--	if SpecialEvent.ZhiShu2009:HasReachXpLimit(pPlayer) == 1 then
	--		Dialog:SendBlackBoardMsg(pPlayer, "你通过种树得到的经验已达上限，种树不会再增加经验了。");
	--	end
		
		GeneralProcess:StartProcess("植树中", 5 * Env.GAME_FPS, 
			{SpecialEvent.ZhiShu2009.Plant1stTree, SpecialEvent.ZhiShu2009, pPlayer, dwItemId}, nil, tbEvent);
				
	elseif szMsg then
		Dialog:Say(szMsg);
	end
end

 local tbSeed = Item:GetClass("oldEx_seed_arbor_day_09");
 tbSeed.tbRate = {	[1] = {50, {18, 1, 954, 1}},
 				[2] = {80, {18, 1, 954, 2}},
 				[3] = {100, {18, 1, 954, 3}},
 					}
 
function tbSeed:OnUse()
	local szMsg = "奇怪的树种，也不知道是什么树的树种，您要仔细辨认下么？";
	local tbOpt = {
		{"激活树种", self.ActiveSeed, self, it.dwId},
      	  	{"我再考虑下"},
        };        
    Dialog:Say(szMsg, tbOpt);
    return 0;
end

function tbSeed:ActiveSeed(nItemId)	
	
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	local nTime = me.GetTask(SpecialEvent.ZhiShu2009.TASKGID, SpecialEvent.ZhiShu2009.TASK_JIHUO_TIME);
	if nTime < nNowTime then
		me.SetTask(SpecialEvent.ZhiShu2009.TASKGID, SpecialEvent.ZhiShu2009.TASK_JIHUO_NUM, 0);
		me.SetTask(SpecialEvent.ZhiShu2009.TASKGID, SpecialEvent.ZhiShu2009.TASK_JIHUO_TIME, nNowTime);
	end
	local nCount = me.GetTask(SpecialEvent.ZhiShu2009.TASKGID, SpecialEvent.ZhiShu2009.TASK_JIHUO_NUM);
	local nAllCount = me.GetTask(SpecialEvent.ZhiShu2009.TASKGID, SpecialEvent.ZhiShu2009.TASK_JIHUO_AllNUM);
	if nCount >= 5 then
		 Dialog:Say("今天你已经激活的够多了，还是明天吧！", {"知道了"});
		 return;
	end
	if nAllCount >= 100 then
		Dialog:Say("你已经激活足够多了，机会还是留给其他人吧！", {"知道了"});
		 return;
	end
	
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < SpecialEvent.ZhiShu2009.nStarTime or nData > SpecialEvent.ZhiShu2009.nCloseTime then	--活动期间外
		Dialog:Say("活动已经结束了！", {"知道了"});
		return;
	end
	if me.nLevel < SpecialEvent.ZhiShu2009.ATENDMINLEVEL then
		Dialog:Say("您等级不足60级，还是提升下等级再来激活树种种树吧！",{"知道了"});
		return;
	end
	local nNowTime = tonumber(GetLocalDate("%H%M"));
	if nNowTime >1200 and nNowTime < 1700 then
		Dialog:Say("该时间段您还不能激活种子，只能在00:00 - 12：00和17:00 - 00:00时间段内激活！",{"知道了"});
		return;
	end
	local tbFind = me.FindItemInBags(unpack(SpecialEvent.ZhiShu2009.tbJug));
	if not tbFind[1] then
		Dialog:Say("激活树种需要一壶仙水！",{"知道了"});
		return;
	end	
	
	local nTime = GetTime();	
	local nLastTime = me.GetTask(SpecialEvent.ZhiShu2009.TASKGID, SpecialEvent.ZhiShu2009.TASK_ACTIVE_TIME);
	if nLastTime ~= 0 and nTime - nLastTime <= SpecialEvent.ZhiShu2009.ACTIVE_TIME then
		Dialog:Say(string.format("还需要<color=yellow>%s<color>秒才能激活下一粒种子！", SpecialEvent.ZhiShu2009.ACTIVE_TIME - nTime + nLastTime),{"知道了"});
		return;
	end
	
	local nRate = Random(100);
	for i, tbRateItem in ipairs(self.tbRate) do
		if nRate <= tbRateItem[1] then
			local pItemEx = me.AddItem(unpack(tbRateItem[2]));
			if pItemEx then
				me.SetTask(SpecialEvent.ZhiShu2009.TASKGID, SpecialEvent.ZhiShu2009.TASK_ACTIVE_TIME, nTime);
				if i == 3 then
					me.SendMsgToFriend(string.format("恭喜[%s]在<%s>幸运获得黄金树种.", me.szName, GetMapNameFormId(me.nMapId)));
				end
				me.SetTask(SpecialEvent.ZhiShu2009.TASKGID, SpecialEvent.ZhiShu2009.TASK_JIHUO_NUM, nCount + 1);
				me.SetTask(SpecialEvent.ZhiShu2009.TASKGID, SpecialEvent.ZhiShu2009.TASK_JIHUO_AllNUM, nAllCount + 1);
				EventManager:WriteLog(string.format("[越南6月种树]激活种子获得:%s",pItemEx.szName), me);				
				me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[越南6月种树]激活种子获得:%s",pItemEx.szName));
				pItem.Delete(me);
				me.ConsumeItemInBags(1, SpecialEvent.ZhiShu2009.tbJug[1], SpecialEvent.ZhiShu2009.tbJug[2], SpecialEvent.ZhiShu2009.tbJug[3], SpecialEvent.ZhiShu2009.tbJug[4], -1);
			end
			return 0;
		end
	end
end

-- 饱满的树种
local tbNewSeed = Item:GetClass("new_seed_arbor_day_09");
function tbNewSeed:InitGenInfo()
	it.SetTimeOut(0, GetTime() + 24 * 3600);
	return {};
end

-- 洒水壶
local tbJug = Item:GetClass("jug_arbor_day_09");
function tbJug:InitGenInfo()
	it.SetTimeOut(0, Lib:GetDate2Time(20100701));
	return {};
end

-- ?pl DoScript("\\script\\event\\jieri\\200903_zhishujie\\tree_item.lua")