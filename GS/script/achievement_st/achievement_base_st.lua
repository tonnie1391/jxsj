-- 文件名　：achievement_base.lua
-- 创建者　：furuilei
-- 创建时间：2009-10-21 18:29:34


--==========================================================
local szAchievementPath = "\\setting\\achievement\\achievement_st.txt";
Achievement_ST.tbAchievementInfo = {};
--==========================================================

-- 从配置文件读取成就信息，该函数提供给gs和client使用
function Achievement_ST:LoadInfo()
	local tbAchievementSetting = Lib:LoadTabFile(szAchievementPath);
	-- 加载成就系统列表
	for nRow, tbRowData in pairs(tbAchievementSetting) do
		local tbTemp = {};
		tbTemp.nAchievementId = tonumber(tbRowData["AchivementId"]);
		tbTemp.szAchievement = tbRowData["Achivement"];
		tbTemp.szSystem = tbRowData["System"];
		tbTemp.szType = tbRowData["Type"];
		tbTemp.bEffective = tonumber(tbRowData["Effective"]);
		if (not self.tbAchievementInfo[tbTemp.nAchievementId] and tbTemp.bEffective == 1) then
			self.tbAchievementInfo[tbTemp.nAchievementId] = tbTemp;
		end
	end
end

-- 设置是否完成
function Achievement_ST:SetTaskValue(nTaskId, nValue)
	me.SetTaskBit(self.TASKGROUP, nTaskId * 2, nValue);
end

-- 设置是否领取过奖励
function Achievement_ST:SetTaskState(nTaskId, nState)
	me.SetTaskBit(self.TASKGROUP, nTaskId * 2 - 1, nState);
end

-- 获取是否完成
function Achievement_ST:GetTaskValue(nTaskId)
	return me.GetTaskBit(self.TASKGROUP, nTaskId * 2);
end

-- 获取是否领取过奖励
function Achievement_ST:GetTaskState(nTaskId)
	return me.GetTaskBit(self.TASKGROUP, nTaskId * 2 - 1);
end

-- 注册通用服务器开启事件
if (MODULE_GAMESERVER) then
	ServerEvent:RegisterServerStartFunc(Achievement_ST.LoadInfo, Achievement_ST);
end
