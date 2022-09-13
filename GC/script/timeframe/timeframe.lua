-------------------------------------------------------------------
--File: 	
--Author: sunduoliang
--Date:   2008-6-25
--Describe:	时间轴
-------------------------------------------------------------------

Require("\\script\\timeframe\\timeframe_define.lua");

function TimeFrame:Init()
	--初始化数据
	self.tbTimeFrameTxt = {};
	self.tbClass = {};
	self:LoadTimeFrameTxt();
	self:Create();
	return 0;
end

function TimeFrame:Create()
	for nId, tbFrame in pairs(self.tbTimeFrameTxt) do
		if tbFrame.szClassName ~= "" then
			self.tbClass[tbFrame.szClassName] = {}
			self.tbClass[tbFrame.szClassName].OpenState = 0; --状态标志
			self.tbClass[tbFrame.szClassName].tbFrame = tbFrame;
			if not MODULE_GAMECLIENT then
				self:GetState(tbFrame.szClassName);
			end
		end
	end
	return 0;
end

function TimeFrame:LoadTimeFrameTxt()
	local tbAllEvent = Lib:LoadTabFile(TimeFrame.TIMEFRAME_TABLE);	
	for nEventId, tbEvent in pairs(tbAllEvent) do
		if nEventId ~= 1 then
			local nId = tonumber(tbEvent.Id) or 0;
			self.tbTimeFrameTxt[nId] = {};
			self.tbTimeFrameTxt[nId].nId			= nId;
			self.tbTimeFrameTxt[nId].szName 		= tbEvent.Name;			
			self.tbTimeFrameTxt[nId].nTimeFrame 	= tonumber(tbEvent.TimeFrameDay) or -1;			
			self.tbTimeFrameTxt[nId].nTimeFrameEx = tonumber(tbEvent.TimeFrameDayEx) or -1;
			self.tbTimeFrameTxt[nId].nTimeFrameTime = tonumber(tbEvent.TimeFrameTime) or 0;
			self.tbTimeFrameTxt[nId].szClassName 	= tbEvent.ClassName;
		end
	end	
end

--nDate格式如(2008-6-25):20080625
function TimeFrame:SetStartServerTime(nDate)
	if string.len(nDate) ~= 8 then
		print("时间轴设置开服时间格式出错(YYYYmmdd)", nDate)
		return
	end
	local nDateTemp = nDate*10000;
	local nSec = Lib:GetDate2Time(nDateTemp);
	if nSec then
		KGblTask.SCSetDbTaskInt(DBTASD_SERVER_STARTTIME, nSec);
	end
end

function TimeFrame:GetStartServerTime(pPlayer)
	local nSec = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	if nSec == 0 then
		print("还没设置开服时间");
		if pPlayer then
			pPlayer.Msg("还没设置开服时间");
		end
		return 0;
	end
	local szMsg = os.date("%c", nSec);
	if pPlayer then
		pPlayer.Msg(szMsg);
	end
	return nSec;
end

--获得开服多少天了
function TimeFrame:GetServerOpenDay()
	local nSec = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	if nSec == 0 then
		return 1;
	end
	local nCurDay = Lib:GetLocalDay();
	local nOpenDay = Lib:GetLocalDay(nSec);
	local nDay =  (nCurDay - nOpenDay) + 1;
	return nDay;
end

--获取时间轴某类是否开启，1为开启，0为未开启，-1为手动临时关闭
function TimeFrame:GetState(szClass)
	if not self.tbClass then
		return -1;
	end
	if self.tbClass[szClass] == nil then
		print("时间轴","找不到该类别", szClass)
		return -1;
	end
	local tbClass = self.tbClass[szClass];
	local nFrameDay  = tbClass.tbFrame.nTimeFrame;
	local nOpen = KGblTask.SCGetDbTaskInt(DBTASK_TIMEFRAME_OPEN);
	if nOpen == 1 then
		nFrameDay = tbClass.tbFrame.nTimeFrameEx;
	end
	local nFrameTime = tbClass.tbFrame.nTimeFrameTime;
	if tbClass.OpenState < 0 or tbClass.OpenState > 0 then
		return tbClass.OpenState;
	end
	
	if nFrameDay < 0 then
		tbClass.OpenState = -1;
		return tbClass.OpenState;
	end
	
	if nFrameDay == 0 then
		tbClass.OpenState = 1;
		return tbClass.OpenState;
	end
	
	local nDate_ServerStart = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nDate_NowTime 	= GetTime();
	if nDate_ServerStart == nil then
		return 0;
	end
	
	local nHour = math.floor(nFrameTime / 100);
	local nMin  = math.mod(nFrameTime,100);
	
	if nDate_NowTime >= (nDate_ServerStart + (nFrameDay -1) * 86400 + (nHour*3600 + nMin*60)) then
		tbClass.OpenState = 1;
	else
		tbClass.OpenState = 0;
	end
	if (MODULE_GC_SERVER) then
		GlobalExcute({"TimeFrame:SetStateGS", szClass, tbClass.OpenState});
	end
	return tbClass.OpenState;
end

--获得某时间轴类开启时间，秒数
function TimeFrame:GetTime(szClass)
	if self.tbClass[szClass] == nil then
		return;
	end
	local tbClass = self.tbClass[szClass];
	local nFrameDay  = tbClass.tbFrame.nTimeFrame;
	local nOpen = KGblTask.SCGetDbTaskInt(DBTASK_TIMEFRAME_OPEN);
	if nOpen == 1 then
		nFrameDay = tbClass.tbFrame.nTimeFrameEx;
	end	
	local nFrameTime = tbClass.tbFrame.nTimeFrameTime;
	local nHour = math.floor(nFrameTime / 100);
	local nMin  = math.mod(nFrameTime,100);		
	local nDate_ServerStart = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nSec;
	if nFrameDay == 0 then
		nSec = nDate_ServerStart;
	else
		nSec = nDate_ServerStart + (nFrameDay -1) * 86400 + (nHour*3600 + nMin*60);
	end
	return nSec;
end

if (MODULE_GAMECLIENT) then
	ClientEvent:RegisterClientStartFunc(TimeFrame.Init, TimeFrame);
end
