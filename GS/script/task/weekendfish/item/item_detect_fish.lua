Require("\\script\\task\\weekendfish\\weekendfish_def.lua")

local tbClass = Item:GetClass("weekend_detect_fish");

function tbClass:OnUse()
	local nRes, var = WeekendFish:CheckCanDetectFish(me);
	if nRes ~= 1 then
		me.Msg(var);
		return 0;
	end
	local pNpcFish = KNpc.GetById(var);
	if not pNpcFish then
		return 0;
	end
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	local pNpcDetect = KNpc.Add2(WeekendFish.NPC_DETECT, 100, -1, nMapId, nPosX + 1, nPosY + 1);
	if not pNpcDetect then
		return 0;
	end
	--pNpcDetect.SetActiveForever(1);
	--pNpcDetect.SetNpcAI(1,100);
	pNpcDetect.SetLiveTime(WeekendFish.DETECT_FISH_SORT * 18);
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
	GeneralProcess:StartProcess("Đang giám định...", WeekendFish.DETECT_FISH_SORT, 
			{WeekendFish.DetectFinishSort, WeekendFish, me.nId, var, pNpcDetect.dwId}, 
			{WeekendFish.DetectFinishSortBreak, WeekendFish, me.nId, pNpcDetect.dwId}, tbEvent);
	return 0;
end