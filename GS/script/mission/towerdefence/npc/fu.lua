-- 文件名　：fu.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-22 18:11:50
-- 描  述  ：符
local tbNpc = Npc:GetClass("tower_fu");
local TIME_COLLECT_SKILL		 = 1; -- 采集技能需要用的时间，单位秒

function tbNpc:OnDialog()
	self:Collect("", TIME_COLLECT_SKILL, {self.GiveBuff, self, me.nId, him.dwId});
end

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

tbNpc.NPC_SKILL = {	
					[6687] = 1611,
					[6688] = 1612,
					[6689] = 1613,
					[6690] = 1614,
					[6691] = 1615,
					}

function tbNpc:Collect(szMsg, nTime, tbCallback)
	GeneralProcess:StartProcess(szMsg, nTime * Env.GAME_FPS, tbCallback, nil, tbEvent);
end

function tbNpc:GiveBuff(nPlayerId, dwNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	local pNpc = KNpc.GetById(dwNpcId);
	if (not pNpc) then
		return;
	end
	
	local nBuffId = self.NPC_SKILL[pNpc.nTemplateId];
	if not nBuffId then
		return;
	end
	local nTime = 30 * Env.GAME_FPS;
	
	local tbTemp = pPlayer.GetTempTable("TowerDefence");	
	if tbTemp.nAddSkillTimerId and tbTemp.nSkillId then
		Timer:Close(tbTemp.nAddSkillTimerId);
		self:RemoveSkill(nPlayerId, tbTemp.nSkillId);
	end
	
	pPlayer.AddFightSkill(nBuffId,1);
	
	FightSkill:SaveLeftSkillEx(pPlayer, TowerDefence.SKILL_ID_ORIGINAL);
	FightSkill:SaveRightSkillEx(pPlayer, nBuffId);
	
	tbTemp.nAddSkillTimerId = Timer:Register(nTime, self.RemoveSkill, self, pPlayer.nId, nBuffId);
	tbTemp.nSkillId = nBuffId;
	--pPlayer.AddSkillState(nBuffId, 1, 1, nTime, 1, 1, 1);
	pNpc.Delete();
end

function tbNpc:RemoveSkill(nPlayerId, nSkillId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (pPlayer) then	
		if pPlayer.IsHaveSkill(nSkillId) == 1 then
			pPlayer.DelFightSkill(nSkillId);
		end
		local tbTemp = pPlayer.GetTempTable("TowerDefence");
		tbTemp.nAddSkillTimerId = nil;
		tbTemp.nSkillId = nil;
		FightSkill:SaveLeftSkillEx(pPlayer, TowerDefence.SKILL_ID_ORIGINAL);
		FightSkill:SaveRightSkillEx(pPlayer, TowerDefence.SKILL_ID_ORIGINAL);
	end
	return 0;
end
