-- 文件名　：weekendfish_base.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-08-05 17:16:10
-- 描  述  ：client和gs通用文件

if MODULE_GAMESERVER then
	Require("\\script\\task\\weekendfish\\weekendfish_def.lua")
else
	Require("\\script\\task\\weekendfish\\weekendfish_cdef.lua")
end

function WeekendFish:OnAccept()
	if MODULE_GAMESERVER then
		local tbTaskList = self:RandPlayerFishList(me);
		local nDay = Lib:GetLocalDay(GetTime());
		me.SetTask(self.TASK_GROUP, self.TASK_ACCEPT_DAY, nDay);
		local nWeek = tonumber(GetLocalDate("%W"));
		if nWeek ~= me.GetTask(self.TASK_GROUP, self.TASK_RANK_WEEK) then
			me.SetTask(self.TASK_GROUP, self.TASK_RANK_WEEK, nWeek);
			me.SetTask(self.TASK_GROUP, self.TASK_WEIGHT_FISH1, 0);
			me.SetTask(self.TASK_GROUP, self.TASK_WEIGHT_FISH2, 0)
			me.SetTask(self.TASK_GROUP, self.TASK_WEIGHT_FISH3, 0)
		end
		for i = 1, self.FISH_TASK_NUM do
			me.SetTask(self.TASK_GROUP,self.TASK_FISH_ID1 + i - 1, tbTaskList[i]);
		end
		me.SetTask(self.TASK_GROUP, self.TASK_TEAM_IDGROUP, 0);
		for i = 1, self.FISH_TASK_NUM do
			me.SetTask(self.TASK_GROUP, self.TASK_TARGET1 + i - 1, 0);
		end
		self:LoadDate(self.TASK_MAIN_ID, tbTaskList);
	end
end

function WeekendFish:DoAccept(tbTask, nTaskId, nReferId)
	if nTaskId == self.TASK_MAIN_ID and nReferId == self.TASK_MAIN_ID then
		self:OnAccept();
	end
end