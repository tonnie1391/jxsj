--月满西楼
--孙多良
--2008.09.03

local tbItem = Item:GetClass("yuemanxilou")
tbItem.nAddHour = 30; --增加30分钟；
tbItem.DEF_MAX  = 100;
tbItem.TASK_GROUP = 2027;
tbItem.TASK_COUNT = 89;

function tbItem:OnUse()
	local nCount = me.GetTask(self.TASK_GROUP, self.TASK_COUNT);
	if nCount >= self.DEF_MAX then
		Dialog:Say("每个人最多只能食用100个，你已经食用太多了，不能再食用了。");
		return 0;
	end
	me.SetTask(self.TASK_GROUP, self.TASK_COUNT, nCount+1);
	me.AddSkillState(385, 7, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	me.AddSkillState(386, 7, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	me.AddSkillState(387, 7, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	me.AddSkillState(880, 4, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	me.AddSkillState(879, 6, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	me.AddExp(math.floor(me.GetBaseAwardExp() * 60));
	return 1;
end

function tbItem:InitGenInfo()
	-- 设定有效期限
	--local nSec = Lib:GetDate2Time(math.floor(SpecialEvent.ZhongQiu2008.TIME_STATE[3]*10000));
	--it.SetTimeOut(0, nSec);
	
	return	{ };
end

function tbItem:GetTip()
	local szTip = "";
	local nUse =  me.GetTask(self.TASK_GROUP, self.TASK_COUNT);
	szTip = szTip .. string.format("<color=green>已食用%s/%s个<color>", nUse, self.DEF_MAX);
	return szTip;
end
