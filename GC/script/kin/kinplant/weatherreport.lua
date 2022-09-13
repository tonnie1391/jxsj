-- 文件名　：weatherreport.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-12-07 14:20:39
-- 功能    ：天气预报

Require("\\script\\kin\\kinplant\\kinplant_def.lua");

--public
function KinPlant:ChangeWeather(nType)
	if MODULE_GC_SERVER then
		GlobalExcute({"KinPlant:ChangeWeather", nType});
	elseif MODULE_GAMESERVER then
		for nKinId, tbMapInfo in pairs(HomeLand.tbKinId2MapId) do
			if GetServerId() == tbMapInfo[1] then
				ChangeWorldWeather(tbMapInfo[2], nType);
				local tbType = {"家族领地内正下着瓢泼大雨",  "家族领地内正烈日炎炎",  "家族领地内正大雪纷飞"};
				if tbType[nType] then
					KKin.Msg2Kin(nKinId, tbType[nType], 0);
				end
			end
		end
		Timer:Register(self.nWeatherTime * 60 * Env.GAME_FPS, self.CloseWeather, self);
	end
	return 0
end

--gs
if MODULE_GAMESERVER then
--普通天气
function KinPlant:CloseWeather()
	for nKinId, tbMapInfo in pairs(HomeLand.tbKinId2MapId) do
		if GetServerId() == tbMapInfo[1] then
			ChangeWorldWeather(tbMapInfo[2], 0);
			KKin.Msg2Kin(nKinId, "家族领地内天气转变为多云", 0);
		end
	end
	return 0;
end

end

--gc
if MODULE_GC_SERVER then
--weather report
function KinPlant:RandWeatherReport()
	local nRate = MathRandom(self.nRandTotal);
	if nRate <= self.nRateWeather then
		local nTime = MathRandom(self.nRateTime);	--分钟
		local nType = MathRandom(self.nWeatherType);	--天气
		Timer:Register(nTime * 60 * Env.GAME_FPS, self.ChangeWeather, self, nType);
	end
end

end
