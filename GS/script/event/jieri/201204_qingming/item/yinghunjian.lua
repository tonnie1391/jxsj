--
-- FileName: yinghunjian.lua
-- Author: lqy
-- Time: 2012/3/21 16:02
-- Comment: 英魂简
--

Require("\\script\\event\\jieri\\201204_qingming\\qingming_def.lua");
local tbQingMing2012 = SpecialEvent.tbQingMing2012;
local tbItem = Item:GetClass("qingming_yinghunjian_2012");

function tbItem:OnUse()
	if me.GetTask(tbQingMing2012.TASKGID, tbQingMing2012.TASK_LINGJIANG) == 1 then
		Dialog:Say("你今天已经领过奖了。");
		return;
	end
	if self:IsFinish() ~= 1 then
		Dialog:Say("尚未完成本日祭祀，不能领取奖励。");
		return;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("你的背包空间不足，请先整理出1个背包空间。");
		return;
	end

	me.AddItem(unpack(tbQingMing2012.nLiBaoId));
	me.SetTask(tbQingMing2012.TASKGID, tbQingMing2012.TASK_LINGJIANG, 1);
	me.SetTask(tbQingMing2012.TASKGID, tbQingMing2012.TASK_HAVEYINGHUNJIAN, 0);		
	return 1;
end

--是否已经完成今日祭祀
function tbItem:IsFinish()
	for n = 1, 8 do
		local nV = me.GetTask(tbQingMing2012.TASKGID,tbQingMing2012.TASK_CITY_HIGH[n]);
		if nV ~= 1 then 
			return 0;
		end
	end
	return 1;
end

function tbItem:InitGenInfo()
	local nEndSecond = Lib:GetDate2Time(tbQingMing2012.nEndTime)
	it.SetTimeOut(0, nEndSecond);	--绝对时间
	return {};
end
