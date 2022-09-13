-------------------------------------------------------------------
--File: 	
--Author: sunduoliang
--Date:   2008-6-25
--Describe:	时间轴
--Describe:	GC数据为唯一正确数据,判断是否启动请在GC做判断.
-------------------------------------------------------------------

Require("\\script\\timeframe\\timeframe_define.lua");

function TimeFrame:MsgStateGS(szClass, pPlayer)
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
	local nDate_ServerStart = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nSec;
	if nFrameDay == 0 then
		nSec = nDate_ServerStart;
	else
		nSec = nDate_ServerStart + (nFrameDay -1) *86400 + (nHour*3600 + nMin*60);
	end	
	local szMsg_Frame = os.date("%c", nSec);
	local szMsg_Now = GetLocalDate("%c");
	local szState = "未开启"
	if self:GetStateGS(szClass) == 1 then
		szState = "已开启"
	elseif self:GetStateGS(szClass) == -1 then
		szState = "已手动关闭";
	end
	local szMsg = "(GS同步GC数据有延迟,以GC数据为准)\n开启时间: "..szMsg_Frame.."\n现在时间: "..szMsg_Now.."\n状态: "..szState;
	print(szMsg)
	if pPlayer then
		pPlayer.Msg(szMsg);
	end
	return szMsg;
end

function TimeFrame:SetStateGS(szClass, nState)
	if not self.tbClass or not self.tbClass[szClass] then
		return 0;
	end
	self.tbClass[szClass].OpenState = nState;
end

function TimeFrame:GetStateGS(szClass, nState)
	return self.tbClass[szClass].OpenState;
end
