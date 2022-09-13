-- 文件名　：angerskill_c.lua
-- 创建者　：zhouchenfei
-- 创建时间：2008-03-23 22:34:52

Require("\\script\\lib\\timer.lua");

if (not MODULE_GAMECLIENT) then
	return;
end

FightSkill.nAngerSkillTime 	= 0;
FightSkill.MAXANGER			= 10000;
FightSkill.ANGERTIME		= 30;
FightSkill.UPDATETIME		= 9;
FightSkill.FRAMETIME		= 18;
FightSkill.SKILLEFFECT		= 93;
FightSkill.nLastAnger		= 0;

FightSkill.TSKGROUP			= 2014;
FightSkill.TSKID			= 1;

function FightSkill:AngerInit()
	self.nLastAngerTime = 0;
	Timer:Register(self.UPDATETIME, self.OnTimer_OnUpdateAngerState, self);
end

function FightSkill:OnTimer_OnUpdateAngerState()
	local nNowAnger = me.GetTask(self.TSKGROUP, self.TSKID);
	if (nNowAnger == self.nLastAnger) then
		return;
	end
	if (nNowAnger >= self.MAXANGER) then
		if (self.nLastAnger < nNowAnger) then
			self:OpenAnger();
		end
	else
		self.nLastAnger = nNowAnger;
		CoreEventNotify(UiNotify.emCOREEVENT_SETANGEREVENT);
	end
	self.nLastAnger = nNowAnger;
	return;
end

function FightSkill:GetAngerState()
--	local nNowAnger = me.GetTask(self.TSKGROUP, self.TSKID);
	return self.nLastAnger, self.nLastAngerTime;
end

function FightSkill:OpenAnger()
	me.StartAnger();
	self.nOrgSkillId = me.nLeftSkill;
	me.nLeftSkill = self.tbAngerSkill[me.nSeries];
	me.AddSkillEffect(self.SKILLEFFECT);
	self.nLastAngerId = Timer:Register(self.ANGERTIME * self.FRAMETIME, self.OnTimer_ResetAnger, self);
	self.nLastAngerTime = GetTime();
	self.nLastAnger = 0;
	me.SetTask(self.TSKGROUP, self.TSKID, 0);
	CoreEventNotify(UiNotify.emCOREEVENT_ANGEREVENT);
end

function FightSkill:OnTimer_ResetAnger()
	me.nLeftSkill = self.nOrgSkillId;
	self.nLastAngerId = nil;
	me.RemoveSkillEffect(self.SKILLEFFECT);
	self.nLastAngerTime = 0;
	CoreEventNotify(UiNotify.emCOREEVENT_ANGEREVENT);
	return 0;
end

FightSkill:AngerInit();
