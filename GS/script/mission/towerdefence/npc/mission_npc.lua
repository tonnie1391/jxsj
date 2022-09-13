if (not MODULE_GAMESERVER) then
	return;
end

local TIME_COLLECT_SKILL		 = 1; -- 采集技能需要用的时间，单位秒
local TIME_COLLECT_BAOXIANG		 = 2; -- 采集宝箱需要用的时间，单位秒

local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_SIT,
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
	

local SkillSnow = Npc:GetClass("towerdefence_skillsnow");		-- 神奇雪堆/刷技能
local TrapSnow	= Npc:GetClass("towerdefence_trapsnow");		-- 冰原陷阱
local BuffSnow	= Npc:GetClass("towerdefence_buffsnow");		-- 雪原神符
local BaoXiang  = Npc:GetClass("towerdefence_baoxiang");		-- 宝箱

local tbFun = {};

function SkillSnow:OnDialog()
	tbFun:Collect("", TIME_COLLECT_SKILL, {self.GiveSkill, tbFun, me.nId, him.dwId})
end

function SkillSnow:GiveSkill(nPlayerId, dwNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	local pNpc = KNpc.GetById(dwNpcId);
	if (not pNpc) then
		return;
	end
	
	local nSkillId = TowerDefence.tbTemplateId2Skill[pNpc.nTemplateId];
	local nSkillLevel = TowerDefence.tbSkill2Level[nSkillId];
	local nTimeOut = 30 * Env.GAME_FPS;
	if (TowerDefence.tbSkill2Time[nSkillId] and TowerDefence.tbSkill2Time[nSkillId] > 0) then
		nTimeOut = TowerDefence.tbSkill2Time[nSkillId] * Env.GAME_FPS;
	end
	tbFun:GiveSkill(pPlayer, nSkillId, nSkillLevel, nTimeOut);
	FightSkill:SaveLeftSkillEx(pPlayer, TowerDefence.SKILL_ID_SNOWBALL_ORIGINAL);
	FightSkill:SaveRightSkillEx(pPlayer, nSkillId);
	pNpc.Delete();
end

function TrapSnow:OnDialog()
	tbFun:Collect("", TIME_COLLECT_SKILL, {self.UseTrap, tbFun, me.nId, him.dwId});
end

function TrapSnow:UseTrap(nPlayerId, dwNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	local pNpc = KNpc.GetById(dwNpcId);
	if (not pNpc) then
		return;
	end
	
	local mapId, x, y = pNpc.GetWorldPos();
	local nTrapId = TowerDefence.tbTemplateId2Trap[pNpc.nTemplateId];
	local nTrapLevel = TowerDefence.tbSkill2Level[nTrapId];
	pPlayer.CastSkill(nTrapId, nTrapLevel, x, y);
	pNpc.Delete();
end

function BuffSnow:OnDialog()
	tbFun:Collect("", TIME_COLLECT_SKILL, {self.GiveBuff, tbFun, me.nId, him.dwId});
end

function BuffSnow:GiveBuff(nPlayerId, dwNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	local pNpc = KNpc.GetById(dwNpcId);
	if (not pNpc) then
		return;
	end
	
	local nBuffId = TowerDefence.tbTemplateId2Buff[pNpc.nTemplateId];
	local nBuffLevel = TowerDefence.tbSkill2Level[nBuffId];
	local nTime = 15 * Env.GAME_FPS;
	if (TowerDefence.tbSkill2Time[nBuffId] and TowerDefence.tbSkill2Time[nBuffId] > 0) then
		nTime = TowerDefence.tbSkill2Time[nBuffId] * Env.GAME_FPS;
	end
	
--	if nBuffId == 1312 then
--		tbFun:GiveSkill2(pPlayer, nBuffId, nBuffLevel, nTime);
--	else
	pPlayer.AddSkillState(nBuffId, nBuffLevel, 1, nTime, 1, 1, 1);
--	end
	pNpc.Delete();
end

function tbFun:GiveSkill(pPlayer, nSkillId, nSkillLevel, nTimeoutFPS)
	for _, nSkillId in pairs(TowerDefence.tbTemplateId2Skill) do
		if pPlayer.IsHaveSkill(nSkillId) == 1 then
			pPlayer.DelFightSkill(nSkillId);
		end
	end
	pPlayer.AddFightSkill(nSkillId, nSkillLevel);
	local nOriginal = TowerDefence.tbSkill2Original[nSkillId] or TowerDefence.SKILL_ID_SNOWBALL_ORIGINAL;
	FightSkill:SaveLeftSkillEx(pPlayer, nOriginal);
	FightSkill:SaveRightSkillEx(pPlayer, nSkillId);
	
	local tbTemp = pPlayer.GetTempTable("TowerDefence");
	if tbTemp.nAddSkillTimerId then
		Timer:Close(tbTemp.nAddSkillTimerId);
	end
	
	tbTemp.nAddSkillTimerId = Timer:Register(nTimeoutFPS, self.__RemoveSkill, self, pPlayer.nId, nSkillId);
end

function tbFun:__RemoveSkill(nPlayerId, nSkillId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (pPlayer) then	
		if pPlayer.IsHaveSkill(nSkillId) == 1 then
			pPlayer.DelFightSkill(nSkillId);
		end
		local nOriginal = TowerDefence.tbSkill2Original[nSkillId] or TowerDefence.SKILL_ID_SNOWBALL_ORIGINAL;
		
		FightSkill:SaveLeftSkillEx(pPlayer, nOriginal);
		FightSkill:SaveRightSkillEx(pPlayer, nOriginal);
		local tbTemp = pPlayer.GetTempTable("TowerDefence");
		tbTemp.nAddSkillTimerId = nil;
	end
	return 0;
end

function tbFun:GiveSkill2(pPlayer, nSkillId, nSkillLevel, nTimeoutFPS)
	if pPlayer.IsHaveSkill(nSkillId) <= 0 then
		pPlayer.AddFightSkill(nSkillId, nSkillLevel);
	end
	
	local tbTemp = pPlayer.GetTempTable("TowerDefence");
	if tbTemp.nAddSkill2TimerId then
		Timer:Close(tbTemp.nAddSkill2TimerId);
	end
	
	tbTemp.nAddSkill2TimerId = Timer:Register(nTimeoutFPS, self.__RemoveSkill2, self, pPlayer.nId, nSkillId);
end

function tbFun:__RemoveSkill2(nPlayerId, nSkillId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (pPlayer) then	
		if pPlayer.IsHaveSkill(nSkillId) >= 1 then
			pPlayer.DelFightSkill(nSkillId);
		end
		local tbTemp = pPlayer.GetTempTable("TowerDefence");
		tbTemp.nAddSkill2TimerId = nil;
	end
	return 0;
end

-- tbCallback: {self.GetFruit, self,him.dwId,me.nId}
function tbFun:Collect(szMsg, nTime, tbCallback)
	GeneralProcess:StartProcess(szMsg, nTime * Env.GAME_FPS, tbCallback, nil, tbEvent);
end

BaoXiang.tbBaoXiang = {18, 1, 281, 1};	--开启获得宝箱

function BaoXiang:OnDialog()
	if me.CountFreeBagCell() < 1 then
		me.Msg("您背包空间不足，请整理1格背包空间。");
		return 0;
	end	
	GeneralProcess:StartProcess("拾取中...", TIME_COLLECT_BAOXIANG * Env.GAME_FPS, {self.OnSurePickUp, self, me.nId, him.dwId}, nil, tbEvent);
	
end

function BaoXiang:OnSurePickUp(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(nNpcId);
	if not pPlayer or not pNpc then
		return 0;
	end
	if pPlayer.CountFreeBagCell() < 1 then
		pPlayer.Msg("您背包空间不足，请整理1格背包空间。");
		return 0;
	end
	
	--获得物品奖励；
	if Item:GetClass("randomitem"):SureOnUse(12, 0, 0, 0) == 1 then
		pNpc.Delete();
	end
end

-- ?pl DoScript("\\script\\mission\\towerdefence\\npc\\mission_npc.lua")