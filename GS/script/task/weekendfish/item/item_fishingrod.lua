Require("\\script\\task\\weekendfish\\weekendfish_def.lua")

local tbClass = Item:GetClass("weekendfish_fishingrod");

function tbClass:OnUse()
	if me.GetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_FISHING_STATE) == 1 then -- 收鱼
		WeekendFish:FinishFishing(me.nId);
	else -- 开始钓鱼
		local nRet, var = WeekendFish:CheckCanFish(me);
		if nRet ~= 1 then
			me.Msg(var);
			return 0;
		end
		if me.CountFreeBagCell() < 1 then
			me.Msg("Hành trang không đủ chỗ trống.");
			return 0;
		end
		local nType = it.nLevel;
		local tbEvent = 
		{
			Player.ProcessBreakEvent.emEVENT_MOVE,
			Player.ProcessBreakEvent.emEVENT_ATTACK,
			Player.ProcessBreakEvent.emEVENT_SITE,
			--Player.ProcessBreakEvent.emEVENT_USEITEM,
			Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
			Player.ProcessBreakEvent.emEVENT_DROPITEM,
			Player.ProcessBreakEvent.emEVENT_SENDMAIL,
			Player.ProcessBreakEvent.emEVENT_TRADE,
			Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
			Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
			Player.ProcessBreakEvent.emEVENT_LOGOUT,
			Player.ProcessBreakEvent.emEVENT_DEATH,
		}
		local pNpcFish = KNpc.GetById(var);
		if not pNpcFish then
			return 0;
		end
		local tbNpcFishInfo = pNpcFish.GetTempTable("Npc").tbFishInfo;
		if not tbNpcFishInfo then
			return 0;
		end
		-- 找一个空闲的位置放鱼漂
		tbNpcFishInfo.tbFloatPos = tbNpcFishInfo.tbFloatPos or {};
		local nFreePos = 0;
		for i = 1, #WeekendFish.FLOAT_POS do
			if tbNpcFishInfo.tbFloatPos[i] ~= 1 then
				tbNpcFishInfo.tbFloatPos[i] = 0;
				nFreePos = i;
				break;
			end
		end
		if nFreePos <= 0 then
			return 0;
		end
		local nFishMapId, nFishPosX, nFishPosY = pNpcFish.GetWorldPos();
		-- 添加一个鱼漂
		local pNpcFloat = KNpc.Add2(WeekendFish.FISH_FLOAT[nType], 100, -1, nFishMapId, nFishPosX + WeekendFish.FLOAT_POS[nFreePos][1], nFishPosY + WeekendFish.FLOAT_POS[nFreePos][2]);
		if not pNpcFloat then
			return 0;
		end
		local nMapId, nPosX, nPosY = pNpcFloat.GetWorldPos();
		--pNpcFloat.CastSkill(WeekendFish.XIAGAN_SKILLID, 1, -1, pNpcFloat.nIndex);
		--Timer:Register(5, self.CastEffectSkill, self, pNpcFloat.dwId);
		me.CastSkill(WeekendFish.XIAGAN_SKILLID, 1, nPosX * 32, nPosY * 32);
		pNpcFloat.GetTempTable("Npc").tbFloatInfo = {};
		pNpcFloat.GetTempTable("Npc").tbFloatInfo.nOwnFishId = pNpcFish.dwId;
		pNpcFloat.GetTempTable("Npc").tbFloatInfo.nPosIndex = nFreePos;
		pNpcFloat.GetTempTable("Npc").tbFloatInfo.nOwnPlayer = me.nId;
		pNpcFloat.GetTempTable("Npc").tbFloatInfo.nState = 0;	-- 鱼漂状态，1表示可以收鱼
		tbNpcFishInfo.tbFloatPos[nFreePos] = 1;	
		tbNpcFishInfo.nFishingNum = tbNpcFishInfo.nFishingNum + 1;
		me.SetTask(WeekendFish.TASK_GROUP, WeekendFish.TASK_FISHING_STATE, 1);
		local nTimerId = Timer:Register(WeekendFish.DETECT_FISHING, WeekendFish.DetectFishing, WeekendFish, me.nId, pNpcFloat.dwId, pNpcFish.dwId, 1);
		pNpcFloat.GetTempTable("Npc").tbFloatInfo.nDetectFishingTimerId = nTimerId;
		GeneralProcess:StartProcess("Kiên nhẫn chờ đợi...", WeekendFish.PROCESS_TIME, 
			{WeekendFish.ProcessFinish, WeekendFish, me.nId, pNpcFloat.dwId, pNpcFish.dwId, 1}, 
			{WeekendFish.ProcessBreak, WeekendFish, me.nId, pNpcFloat.dwId, pNpcFish.dwId, 1}, 
			tbEvent);
		-- 定时器随机是否钓到鱼
		
	end
	return 0;
end

function tbClass:CastEffectSkill(dwId)
	local pNpc = KNpc.GetById(dwId);
	if not pNpc then
		return 0;
	end
	pNpc.CastSkill(WeekendFish.XIAGAN_SKILLID, 1, -1, pNpc.nIndex);
	return 0;
end
	