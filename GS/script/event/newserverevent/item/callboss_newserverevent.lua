-- 文件名　：callboss_newserverevent.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-11-09 17:19:36
-- 描述：新服活动家族召唤boss

SpecialEvent.NewServerEvent =  SpecialEvent.NewServerEvent or {};
local NewServerEvent = SpecialEvent.NewServerEvent;

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
	Player.ProcessBreakEvent.emEVENT_ATTACKED,
}

local tbItem = Item:GetClass("callboss_newserverevent");

function tbItem:InitGenInfo()
	local nServerStartTime = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nEndTime	= NewServerEvent.nEndDate * 24 * 60 * 60;
	it.SetTimeOut(0, nServerStartTime + nEndTime);
	return	{};
end

function tbItem:CanUse(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0,"玩家不存在。";
	end
	if NewServerEvent:IsEventOpen() ~= 1 then
		return 0,"活动已经截止，无法使用。";	
	end
	local cKin = KKin.GetKin(pPlayer.dwKinId);
	if not cKin then
		return 0,"你没有家族，无法使用。";
	end
	local nLastGetTime = cKin.GetLastGetCallBossTime();
	if os.date("%Y%m%d",nLastGetTime) ~= os.date("%Y%m%d",GetTime()) then
		GCExcute{"SpecialEvent.NewServerEvent:ClearCallBossData_GC",me.dwKinId};	--每日清空下
	end
	local nMapId = pPlayer.GetWorldPos();
	if GetMapType(nMapId) ~= "fight" then
		return 0, "对不起，该地图无法使用，请到野外地图再使用。";
	end
	local nNowTime = tonumber(os.date("%H%M",GetTime()));
	if nNowTime < NewServerEvent.nCallKinBossTimeStart or nNowTime > NewServerEvent.nCallKinBossTimeEnd then
		return 0,"    现在还不是使用的时间，家族召唤BOSS令牌每天的使用时间为<color=yellow>18:30<color>到<color=yellow>23:00<color>，在该时间段内，各家族可以在野外地图进行BOSS的召唤。"
	end
	local nCallCount = cKin.GetCallBossCount();
	if nCallCount >= NewServerEvent.nCallBossMaxCount  then
		return 0,string.format("你们家族当天的召唤次数已经达到上限，每个家族每天只能召唤<color=yellow>%s<color>次BOSS",NewServerEvent.nCallBossMaxCount);
	end
	return 1;
end

function tbItem:OnUse()
	local nRet,szError = self:CanUse(me.nId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	GeneralProcess:StartProcess("召唤中...", 1 * Env.GAME_FPS, {self.CallBoss,self,it.dwId},nil,tbEvent);
end

function tbItem:CallBoss(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local cKin = KKin.GetKin(me.dwKinId);
	if not cKin then
		return 0;
	end
	local nTemplateId = NewServerEvent.nKinBossTemplateId;
	local nMapId,nX,nY = me.GetWorldPos();
	local pNpc = KNpc.Add2(nTemplateId,50,-1,nMapId,nX,nY);
	local nIsBuy = pItem.GetGenInfo(1,0) or 0;
	if pNpc then
		if me.DelItem(pItem,0) == 1 then
			StatLog:WriteStatLog("stat_info", "kin_boss","use",me.nId,nIsBuy);
			local nCallCount = cKin.GetCallBossCount();
			pNpc.GetTempTable("SpecialEvent").nKinId = me.dwKinId;
			pNpc.GetTempTable("SpecialEvent").nDeleteTimer = Timer:Register(NewServerEvent.nBossExistDelay,Npc:GetClass("boss_newserverevent").OnDelete,Npc:GetClass("boss_newserverevent"),pNpc.dwId);
			GCExcute{"SpecialEvent.NewServerEvent:SetCallBossCount_GC",me.dwKinId,nCallCount + 1};
			local szMsg = string.format("家族族长在<color=green>%s<color>地图召唤出了<color=red>%s<color>，请速度前往击杀！",GetMapNameFormId(nMapId),pNpc.szName);
			KKinGs.KinClientExcute(me.dwKinId,{"KKin.ShowKinMsg",szMsg}); 
		end
	else
		Dbg:WriteLog("New Server Event","Call Boss Failed",me.szName);
	end
end

------------------奇珍阁自动使用
local tbCallBoss_Ib = Item:GetClass("callboss_newserverevent_ibshop");

function tbCallBoss_Ib:OnUse()
	local pItem = me.AddItem(unpack(NewServerEvent.tbCallBossGDPL));
	if pItem then
		local cKin = KKin.GetKin(me.dwKinId);
		local nGetCount = cKin.GetBuyCallBossItemCount();
		pItem.SetGenInfo(1,1);	--标记是否是购买的
		GCExcute{"SpecialEvent.NewServerEvent:SetBuyCallBossItemCount_GC",me.dwKinId,nGetCount + 1};
		return 1;
	else
		Dialog:Say("道具使用错误，请联系GM！");
		Dbg:WriteLog("NewServerEvent","Give Free Call Boss Item Failed",me.szName);
		return 0;
	end
end