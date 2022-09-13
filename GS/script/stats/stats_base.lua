-- 文件名　：stats_base.lua
-- 创建者　：furuilei
-- 创建时间：2009-05-21 20:17:50

if (MODULE_GAMECLIENT) then
	return;
end


function Stats:GetTaskBitFlag(nTaskId)
	local nValue = me.GetTask(self.TASK_GROUP, nTaskId);
	local nFlag = nValue % 10;
	return nFlag;
end

function Stats:SetTaskBitFlag(nTaskId, nFlag)
	local nValue = me.GetTask(self.TASK_GROUP, nTaskId);
	nValue = math.floor(nValue / 10) * 10 + nFlag;
	me.SetTask(self.TASK_GROUP, nTaskId, nValue);
end

function Stats:GetTaskValue(nTaskId)
	local nValue = me.GetTask(self.TASK_GROUP, nTaskId);
	nValue = math.floor(nValue / 10);
	return nValue;
end

function Stats:SetTaskValue(nTaskId, nValue)
	local nFlag = me.GetTask(self.TASK_GROUP, nTaskId) % 10;
	nValue = nValue * 10 + nFlag;
	me.SetTask(self.TASK_GROUP, nTaskId, nValue);
end
