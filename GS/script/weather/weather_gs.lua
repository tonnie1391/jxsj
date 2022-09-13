-------------------------------------------------------------------
--File: 	weather_gs
--Author: 	sunduoliang
--Date: 	2011-07-06
--Describe:	

-------------------------------------------------------------------
if (not MODULE_GAMESERVER) then
	return;
end
Require("\\script\\weather\\weather_def.lua")
function Weather:Init()
	self:LoadBaseFile()
end

function Weather:LoadBaseFile()
	local tbFile = Lib:LoadTabFile(self.DEF_BASE_PATH..self.DEF_BASE_FILE);
	if not tbFile then
		return
	end
	self.tbMapWeathList = {};
	for _, tbPart in ipairs(tbFile) do
		local nId 		= tonumber(tbPart.WEATHER_ID) or 0;
		local szDesc 	= tbPart.DESC or "";
		local nState 	= tonumber(tbPart.STATE) or 0;
		local szMapFile = tbPart.MAPRATE_FILE;
		local nTotle_Weigth = tonumber(tbPart.TOTLE_WEIGTH) or 0;
		local nStart_L	= tonumber(tbPart.START_L) or 0;
		local nStart_R	= tonumber(tbPart.START_R) or 0;
		local nEnd_L	= tonumber(tbPart.END_L) or 0;
		local nEnd_R	= tonumber(tbPart.END_R) or 0;
		if nId > 0 and nState > 0 then
			if nStart_L > nStart_R then
				print("Weather:LoadBaseFile", "Error State", szDesc, "nStart_L < nStart_R")
				return 0;
			end
			if nEnd_L > nEnd_R then
				print("Weather:LoadBaseFile", "Error State", szDesc, "nStart_L < nStart_R")
				return 0;
			end
			
			self.tbWeathBase[nId] = self.tbWeathBase[nId] or {};
			self.tbWeathBase[nId].nTotle_Weigth = nTotle_Weigth;
			self.tbWeathBase[nId].nStart_L 		= nStart_L;
			self.tbWeathBase[nId].nStart_R 		= nStart_R;
			self.tbWeathBase[nId].nEnd_R   		= nEnd_R;
			self.tbWeathBase[nId].nEnd_L   		= nEnd_L;
			local tRateFile = Lib:LoadTabFile(self.DEF_BASE_PATH..szMapFile);
			if tRateFile then
				for _, tbMapWeatherInfor in ipairs(tRateFile) do
					local varMapId = tonumber(tbMapWeatherInfor.MAPID) or tbMapWeatherInfor.MAPID or 0;
					local tbMonthRate = {};
					for i=1,12 do
						tbMonthRate[i] = tonumber(tbMapWeatherInfor["MON"..i]) or 0;
					end
					self.tbMapWeathList[varMapId] = self.tbMapWeathList[varMapId] or {};
					self.tbMapWeathList[varMapId][nId] = self.tbMapWeathList[varMapId][nId] or {};
					self.tbMapWeathList[varMapId][nId].tbRate = tbMonthRate;
					self.tbMapWeathList[varMapId][nId].tbBase = self.tbWeathBase[nId];
				end
			end
		end
	end
end

function Weather:LoadMyServerMapList()
	self.tbMapInServerList = {};
	for nMapId, tbInfo in pairs(Map.tbMapIdList) do
		if SubWorldID2Idx(nMapId) >= 0 then
			self.tbMapInServerList[nMapId] = tbInfo.szMapType;
		end
	end
end

Weather:Init();

function Weather:StartSystemWeather()
	if self.DEF_OPEN == 0 then
		return 0;
	end
	if not self.tbMapInServerList then
		self:LoadMyServerMapList();
	end
	for nMapId, szType in pairs(self.tbMapInServerList) do
		if self.tbMapWeathList[nMapId] then
			self:OpenWeatherState1(nMapId, nMapId)
		elseif self.tbMapWeathList[szType] then
			self:OpenWeatherState1(nMapId, szType)
		end
	end
	return 0;
end

function Weather:OpenWeatherState1(nMapId, varMapId)
	local tbWeather = {};
	for nId, tbType in pairs(self.tbMapWeathList[varMapId]) do
		local nMonth = tonumber(GetLocalDate("%m"));
		local nRate = tonumber(tbType.tbRate[nMonth]) or 0;
		if nRate > 0 then
			local nP = MathRandom(1, tbType.tbBase.nTotle_Weigth);
			if nP <= nRate then
				table.insert(tbWeather, nId);
			end
		end
	end

	if #tbWeather > 0 then
		if #tbWeather == 1 then
			self:OpenWeatherState2(nMapId, tbWeather[1]);
		end
		if #tbWeather >= 2 then
			local nWId = tbWeather[MathRandom(1, #tbWeather)];
			self:OpenWeatherState2(nMapId, nWId);
		end
	end
end

function Weather:OpenWeatherState2(nMapId, nWId)
	local tbMapInit = {nTimerId=0,	nState=0, nWId=0};
	self.tbMapNowWeathList[nMapId] = self.tbMapNowWeathList[nMapId] or tbMapInit;
	if self.tbMapNowWeathList[nMapId].nTimerId > 0 then
		Timer:Close(self.tbMapNowWeathList[nMapId].nTimerId);
		self.tbMapNowWeathList[nMapId].nTimerId = 0;
		self.tbMapNowWeathList[nMapId].nState = 0;
	end
	if self.tbMapNowWeathList[nMapId].nWId > 0 then
		ChangeWorldWeather(nMapId, 0);
		self.tbMapNowWeathList[nMapId].nWId = 0;
	end
	local nWaitTime = MathRandom(self.tbWeathBase[nWId].nStart_L * 60 * 18, self.tbWeathBase[nWId].nStart_R * 60 * 18);
	if nWaitTime == 0 then
		nWaitTime = 18;
	end
	self.tbMapNowWeathList[nMapId].nTimerId = Timer:Register(nWaitTime, self.OpenWeatherState3, self, nMapId, nWId);
end

function Weather:OpenWeatherState3(nMapId, nWId)
	if self.tbMapNowWeathList[nMapId].nState == 1 then
		ChangeWorldWeather(nMapId, 0);
		self.tbMapNowWeathList[nMapId] = nil;
		return 0;
	end	
	self.tbMapNowWeathList[nMapId].nState = 1;
	ChangeWorldWeather(nMapId, nWId);
	Dbg:WriteLog("Weather", "OpenWeather", nMapId, nWId);
	self.tbMapNowWeathList[nMapId].nWId = nWId;
	local nWaitTime = MathRandom(self.tbWeathBase[nWId].nEnd_L * 60 * 18, self.tbWeathBase[nWId].nEnd_R * 60 * 18);
	return nWaitTime;
end

function Weather:CloseAllWeather()
	for nMapId, tbInfo in pairs(self.tbMapNowWeathList) do
		ChangeWorldWeather(nMapId, 0);
		if tbInfo.nTimerId > 0 then
			Timer:Close(tbInfo.nTimerId);
		end
	end
	self.tbMapNowWeathList = {};
end
