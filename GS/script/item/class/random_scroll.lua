
-- ====================== 文件信息 ======================

-- 剑侠世界随机任务 - 高级任务卷轴触发脚本
-- Edited by peres
-- 2007/06/03 PM 17:05

-- 2005/09/01 我写下了剑网随机任务卷轴任务的脚本
-- 2007/06/03 几乎是两年之后，我再次书写了剑网卷轴任务的脚本
-- By peres.

-- ======================================================

local tbBook = Item:GetClass("advanced_scroll");

function tbBook:OnUse()
	local nReferTaskId = it.GetGenInfo(1);
	local nMainTaskId = Task.tbReferDatas[nReferTaskId].nTaskId;
	
	if nReferTaskId==0 or nReferTaskId==nil then
		Dialog:Say("打开任务卷轴失败！");
		return;
	end;
	
	print (string.format("Apply scroll task: Main task id: %d / Refer task id: %d", nMainTaskId, nReferTaskId));
	
	Dialog:Say("你要接受该高级卷轴任务吗？<enter><enter>任务描述："..ScrollTask:GetTaskInfo(nReferTaskId).."<enter><enter>",
				{
					{"是的", tbBook.OnOkay, tbBook, nMainTaskId, nReferTaskId, it},
					{"不了"},
				}
		);
end;


function tbBook:OnOkay(nMainTaskId, nReferTaskId, item)
	print (string.format("Get scroll task id: Main task id: %d / Refer task id: %d", nMainTaskId, nReferTaskId));
	local tbReferTask = ScrollTask:HaveScrollTask();
	if tbReferTask then
		Dialog:Say("你目前有正在进行的高级卷轴任务：<color=yellow>"..tbReferTask.szName.."<color>，你必须完成或者放弃此任务才能开始新的高级卷轴任务！");
		return;
	end;
	
	Task:DoAccept(nMainTaskId, nReferTaskId);
	item.Delete(me);
end;


-- 获取任务描述
function tbBook:GetTip(nState)
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
