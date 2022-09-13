-------------------------------------------------------------------
--File: 	
--Author: sunduoliang
--Date:   2008-6-25
--Describe:	时间轴
-------------------------------------------------------------------

function TimeFrame:SaveStartServerTime()
	if KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME) == 0 then
		local nDate = tonumber(GetLocalDate("%Y%m%d")) * 10000;
		local nSec = Lib:GetDate2Time(nDate);
		KGblTask.SCSetDbTaskInt(DBTASD_SERVER_STARTTIME, nSec);
	end
end

--手动启动
function TimeFrame:ManuStartGC(szClass)
	if self.tbClass[szClass] == nil then
		print("找不到该类别", szClass);
		return;
	end
	self.tbClass[szClass].OpenState = 1;
	Dbg:WriteLog("TimeFrame","手动启动时间轴功能","时间轴Id", self.tbClass[szClass].nId); 
	GlobalExcute({"TimeFrame:SetStateGS", szClass, self.tbClass[szClass].OpenState});
end

--手动关闭
function TimeFrame:ManuCloseGC(szClass)
	if self.tbClass[szClass] == nil then
		print("找不到该类别", szClass);
		return;
	end
	self.tbClass[szClass].OpenState = -1
	Dbg:WriteLog("TimeFrame","手动关闭时间轴功能","时间轴Id", self.tbClass[szClass].nId); 
	GlobalExcute({"TimeFrame:SetStateGS", szClass, self.tbClass[szClass].OpenState});
end

function TimeFrame:MsgStateGC(szClass)
	if self.tbClass[szClass] == nil then
		print("时间轴","找不到该类别", szClass);
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
		nSec = nDate_ServerStart + (nFrameDay -1) *86400 + (nHour*3600 + nMin*60);
	end
	local szMsg_Frame = os.date("%c", nSec);
	local szMsg_Now = GetLocalDate("%c");
	local szState = "未开启"
	if self:GetState(szClass) == 1 then
		szState = "已开启"
	elseif self:GetState(szClass) == -1 then
		szState = "已手动关闭";
	end
	local szMsg = "\n开启时间: "..szMsg_Frame.."\n现在时间: "..szMsg_Now.."\n状态: "..szState;
	print(szMsg)
	return szMsg;
end
