-----------------------------------------------------------
-- 文件名　：mask.lua
-- 文件描述：面具脚本
-- 创建者　：ZhangDeheng
-- 创建时间：2008-11-18 09:59:01
-----------------------------------------------------------
Require("\\script\\item\\class\\equip.lua");
-- 面具
local tbMask = Item:NewClass("mask", "equip");

function tbMask:InitGenInfo()
	--设置道具的生存期
	local nStateLog = 0;
	if self.tbMaskLiveTimeList[it.nParticular] and self.tbMaskLiveTimeList[it.nParticular][it.nLevel] then
		local nLiveTime = self.tbMaskLiveTimeList[it.nParticular][it.nLevel].nLiveTime;
		nStateLog = self.tbMaskLiveTimeList[it.nParticular][it.nLevel].nStateLog;
		if nLiveTime > 0 then
			it.SetTimeOut(0, GetTime() + nLiveTime * 60);
		end
	end
	
	if MODULE_GAMESERVER and nStateLog > 0 then
		Task.tbArmyCampInstancingManager.StatLog:WriteLog(16, 1, nil, it.nParticular);
	end
	
	return	{ };
end

function tbMask:LoadMaskFile()
	self.tbMaskLiveTimeList = {};
	local tbsortpos = Lib:LoadTabFile("\\setting\\item\\001\\other\\mask_time.txt");
	if not tbsortpos then
		return
	end
	local nLineCount = #tbsortpos;
	for nLine=2, nLineCount do
		local nProbability = tonumber(tbsortpos[nLine].Probability) or 0;
		local nParticularType = tonumber(tbsortpos[nLine].ParticularType) or 0;
		local nLevel = tonumber(tbsortpos[nLine].Level)or 0;
		local nLiveTime = tonumber(tbsortpos[nLine].LiveTime) or 0;
		local nStateLog = tonumber(tbsortpos[nLine].StateLog) or 0;
		if nParticularType > 0 then
			if not self.tbMaskLiveTimeList[nParticularType] then
				self.tbMaskLiveTimeList[nParticularType] = {};
			end
			if not self.tbMaskLiveTimeList[nParticularType][nLevel] then
				self.tbMaskLiveTimeList[nParticularType][nLevel] = {}
			end
			self.tbMaskLiveTimeList[nParticularType][nLevel] = {nLiveTime = nLiveTime, nStateLog = nStateLog};
		end
	end
end

tbMask:LoadMaskFile()
