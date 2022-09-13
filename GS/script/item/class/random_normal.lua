
-- ====================== 文件信息 ======================

-- 剑侠世界随机任务 - 普通任务卷轴触发脚本
-- Edited by peres
-- 2007/06/03 PM 17:05

-- 2005/09/01 我写下了剑网随机任务卷轴任务的脚本
-- 2007/06/03 几乎是两年之后，我再次书写了剑网卷轴任务的脚本
-- By peres.

-- ======================================================

local tbRandom = Item:GetClass("random_scroll");

function tbRandom:OnUse()
	local nReferTaskId = it.GetGenInfo(1);
	local nMainTaskId = Task.tbReferDatas[nReferTaskId].nTaskId;
	
	if nReferTaskId==0 or nReferTaskId==nil then
		Dialog:Say("打开任务卷轴失败！");
		return;
	end;
	
	print (string.format("Apply task: Main task id: %d / Refer task id: %d", nMainTaskId, nReferTaskId));
	
	Dialog:Say("你要接受此任务吗？<enter><enter>任务描述："..RandomTask:GetTaskInfo(nReferTaskId).."<enter><enter>",
				{
					{"是的", tbRandom.OnOkay, tbRandom, nMainTaskId, nReferTaskId, it},
					{"不了"},
					{"丢弃此卷轴", tbRandom.OnDeleteAsk, tbRandom, it},
				}
		);
	
	-- 打开接受任务面版
	-- Task:AskAccept(nMainTaskId, nReferTaskId);
end;


function tbRandom:OnOkay(nMainTaskId, nReferTaskId, item)
	print (string.format("Get task id: Main task id: %d / Refer task id: %d", nMainTaskId, nReferTaskId));
	local tbReferTask = RandomTask:HaveRandomTask();
	if tbReferTask then
		Dialog:Say("你目前有正在进行的普通卷轴任务：<color=yellow>"..tbReferTask.szName.."<color>，你必须完成或者放弃此任务才能开始新的卷轴任务！");
		return;
	end;
	
	Task:DoAccept(nMainTaskId, nReferTaskId);
	item.Delete(me);
end;


-- 获取任务描述
function tbRandom:GetTip(nState)
	local nTaskId = it.GetGenInfo(1);
	local szMain = "任务卷轴<enter><enter>";
	
	if nTaskId==0 or nTaskId==nil then
		return szMain.."获取任务描述失败！";
	end;
	
	-- 任务信息描述
	szMain = szMain.."<color=yellow>任务描述<color>："..ScrollTask:GetTaskInfo(nTaskId).."<enter><enter>";
	
	szMain = szMain.."任务完成后所得奖励：<enter><enter>";
	
	-- 任务奖励描述
	szMain = szMain..ScrollTask:GetTaskAwardText(nTaskId);

	szMain = szMain.."右键点击卷轴即可获取详细的任务信息";
	return szMain;
end;


function tbRandom:OnDeleteAsk(item)
	
	local nReferTaskId = item.GetGenInfo(1);
	local nMainTaskId = Task.tbReferDatas[nReferTaskId].nTaskId;
		
	Dialog:Say("你确定要<color=yellow>丢弃此任务卷轴<color>吗？<enter><enter>任务描述：<color=green>"..RandomTask:GetTaskInfo(nReferTaskId).."<color>",
				{
					{"是的", tbRandom.OnDelete, tbRandom, item},
					{"不了"},
					}
				);
end;


function tbRandom:OnDelete(item)
	item.Delete(me);
	me.Msg("<color=yellow>你丢弃了一个任务卷轴<color>！");
end;
