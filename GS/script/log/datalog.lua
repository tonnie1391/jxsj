-- 文件名　：datalog.lua
-- 创建者　：sunduoliang
-- 创建时间：2010-07-29 10:33:27

-- 定义行为标签，无功能性，只为数据分析做为依据
DataLog.DEF_DATA_LOG = {
	[1]  = "EventAttend", -- 活动参与
};

--定义Log类别
DataLog.DEF_EVENT_TYPE = {}
DataLog.DEF_EVENT_TYPE[1] = 
{
	szName = "逍遥谷",
	[1] = {"队长报名", "队伍Id,队员A,队员B,队员C,队员D,队员E",},
	[2] = {"通过关卡成功","房间Id,队伍Id,通关时间"},
	[3] = {"通过关卡失败","房间Id,队伍Id,通关时间"},
};

DataLog.DEF_EVENT_TYPE[2] = 
{
	szName = "秦始皇陵",
	[1] = {"杀死Boss","BossNpcId"},
	[2] = {"杀死玩家","被杀玩家名,地图Id"},
	[3] = {"进入地图","地图Id"},
	[4] = {"离开地图","地图Id"},
};

DataLog.DEF_EVENT_TYPE[3] = 
{
	szName = "官府通缉",
	[1] = {"接任务","任务Id"},
	[2] = {"杀死大盗","大盗NpcId"},
	[3] = {"杀死大盗队员","队伍Id,队员A,队员B,队员C,队员D,队员E"},
	[4] = {"交任务","任务Id"},
	[5] = {"有任务杀死大盗","大盗NpcId,队伍Id,队员A,队员B,队员C,队员D,队员E"},
};

DataLog.DEF_EVENT_TYPE[4] = 
{
	szName = "白虎堂",
	[1] = {"进入地图","地图Id"},
	[2] = {"杀死Boss","BossNpcId"},
	[3] = {"杀死玩家","被杀玩家名,地图Id"},
	[4] = {"离开地图","地图Id"},
};

DataLog.tbDataKEView = {};

--样列 xxx玩家	1	1001	111,xxxA,xxxB,xxxC
function DataLog:WriteELog(szName, nType, nSubAction, ...)
	local nAction = nType*1000 + nSubAction;
	local szScript = "未知事件";
	if DataLog.DEF_EVENT_TYPE[nType] and DataLog.DEF_EVENT_TYPE[nType][nSubAction] then
		szScript = string.format("[%s|%s|%s]", DataLog.DEF_EVENT_TYPE[nType].szName or "未知", DataLog.DEF_EVENT_TYPE[nType][nSubAction][1] or "未知", DataLog.DEF_EVENT_TYPE[nType][nSubAction][2] or "无参数");
	end
	
	self:WriteLog(szName, 1, nAction, szScript, unpack(arg))
end

function DataLog:WriteLog(szName, nDataType, nAction, szScript, ...)
	local szLog = "";
	if arg then
		szLog = table.concat(arg, ",");
	end	
	Dbg:WriteLog("DataAnalysisLog", szScript, szName, nDataType, nAction, szLog);
	
	--KE大电视展现数据统计使用
	if not MODULE_GC_SERVER then
		GCExcute({"DataLog:KEViewAddCountGC", szName, nDataType, nAction, szLog})
	end
end
function DataLog:KEViewInit(nDataType, nAction, nCurDate, nCurHour)
	self.tbDataKEView[nDataType] = self.tbDataKEView[nDataType] or {};
	self.tbDataKEView[nDataType][nAction] = self.tbDataKEView[nDataType][nAction] or {};
	self.tbDataKEView[nDataType][nAction][nCurDate] = self.tbDataKEView[nDataType][nAction][nCurDate] or {};
	self.tbDataKEView[nDataType][nAction][nCurDate][nCurHour] = self.tbDataKEView[nDataType][nAction][nCurDate][nCurHour] or 0;	
end

function DataLog:KEViewAddCountGC(szName, nDataType, nAction, szLog)
	if not nDataType or not nAction then
		return;
	end
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nCurHour = tonumber(GetLocalDate("%H"));
	self:KEViewInit(nDataType, nAction, nCurDate, nCurHour);
	self.tbDataKEView[nDataType][nAction][nCurDate][nCurHour] = self.tbDataKEView[nDataType][nAction][nCurDate][nCurHour] + 1;
end

--主类型， 子类型，详细类，是否当天（否则是服务器启动期间），小时（默认0当天所有时间，1.上1小时，2.上2个小时，n.上n个小时）
function DataLog:KEViewGetCountGC(nDataType, nType, nSubAction, nIsDay, nHours)
	local nAction = nType*1000 + nSubAction;
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nCurHour = tonumber(GetLocalDate("%H"));
	nHours = tonumber(nHours) or 0;
	self:KEViewInit(nDataType, nAction, nCurDate, nCurHour);
	if nIsDay == 1 then
		if nHours > 0 then
			local nSatrtHour = nCurHour - nHours;
			if nSatrtHour < 0 then
				nSatrtHour = 0;
			end
			local nEndHour = nCurHour - 1;
			if nEndHour < 0 then
				nEndHour = 0;
			end
			local nSum = 0;
			for i = nSatrtHour, nEndHour do
				if self.tbDataKEView[nDataType][nAction][nCurDate][i] then
					nSum = nSum + self.tbDataKEView[nDataType][nAction][nCurDate][i];
				end
			end
			return nSum;
		else
			local nSum = 0;
			for _, nCount in pairs(self.tbDataKEView[nDataType][nAction][nCurDate]) do
				nSum = nSum + nCount;
			end
			return nSum;
		end
	end
	local nSum = 0;
	for _, tbDate in pairs(self.tbDataKEView[nDataType][nAction]) do
		for _, nCount in pairs(tbDate) do
			nSum = nSum + nCount;
		end
	end
	return nSum;
end


