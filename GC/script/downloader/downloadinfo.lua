------------------------------------------------------
-- 文件名　：downloadinfo.lua
-- 创建者　：mini客户端资源下载情况统计
-- 创建时间：2011-10-25 10:59:14
-- 描  述  ：
------------------------------------------------------

Require("\\script\\lib\\timer.lua");

if not MiniResource.tbDownloadInfo then
	MiniResource.tbDownloadInfo = {};
end
local tbDownloadInfo = MiniResource.tbDownloadInfo;

------------------------client--------------------------------------

if MODULE_GAMECLIENT then
	
tbDownloadInfo.TIMER_SEND_INTERVAL	= 3;		-- 1分钟
tbDownloadInfo.TIMER_COUNT 			= 20;
tbDownloadInfo.LIMIT_SPEED			= 50;		-- 下载速度阀值

function tbDownloadInfo:OnTimer_SendMiniDownloadInfo()
	if IsAllPackComplete() == 1 then
		self:OnLogout();
		return 0;
	end
	
	self.tbCacheSpeed = self.tbCacheSpeed or {};
	self.nTimerNo = self.nTimerNo or 0;
	self.nTimerNo = self.nTimerNo + 1;
	
	local tbInfo = GetMiniDownloadInfo();
	if not tbInfo then
		return;
	end
	
	self.tbCacheSpeed[self.nTimerNo] = math.floor(tbInfo.nActualSpeed * 100/1024)/100;
	
	if self.nTimerNo >= self.TIMER_COUNT then
		local nSpeed = 0;
		for _, v in pairs(self.tbCacheSpeed) do
			nSpeed = nSpeed + v;
		end
		nSpeed = math.floor(nSpeed * 100/self.TIMER_COUNT)/100;
		self.nTimerNo = 0;
		self.tbCacheSpeed = nil;
	
		if nSpeed < self.LIMIT_SPEED then
			me.CallServerScript({"MiniDownloadInfoCmd", "ClientSendMiniDowloadInfo", nSpeed});
		end
	end
end

function tbDownloadInfo:OnLoginEnd()
	if self.nSyncTimerId then
		Timer:Close(tbDownloadInfo.nSyncTimerId);
		self.nSyncTimerId = nil;
	end
	
	if MINI_CLIENT then
		self.nSyncTimerId = Timer:Register(self.TIMER_SEND_INTERVAL * Env.GAME_FPS, 
			self.OnTimer_SendMiniDownloadInfo, self);
	end
end

function tbDownloadInfo:OnLogout()
	if self.nSyncTimerId then
		Timer:Close(tbDownloadInfo.nSyncTimerId);
		self.nSyncTimerId = nil;
	end
end

function tbDownloadInfo:OnDownloaderBlocked(pPlayer, dwHostIp, pszFile, nState)
	if (pPlayer.nId ~= 0) then	-- 表示没有连接GS
		pPlayer.CallServerScript({"MiniDownloadInfoCmd", "ApplyLogDownloaderBlockInfo", dwHostIp, pszFile, nState});
	end
end

end  -- if MODULE_GAMECLIENT then

-----------------------gameserver-----------------------------------

if MODULE_GAMESERVER then

tbDownloadInfo.tbc2sFun = {};
tbDownloadInfo.tbMapCalInfo = {};
-- 转发给GC，自己不存储
function tbDownloadInfo:OnClientSync(nSpeed)
	local szAddr = string.format("%s:%d", Lib:IntIpToStrIp(me.dwIp), me.nId);
	local szArea = GetIpAreaAddr(me.dwIp);	
	GCExcute{"MiniResource.tbDownloadInfo:RecordInfo_GC", szAddr, szArea, nSpeed};
end
tbDownloadInfo.tbc2sFun["ClientSendMiniDowloadInfo"] = tbDownloadInfo.OnClientSync;

-- 0是entermap状态，1是loadfinish状态
function tbDownloadInfo:OnClientSyncMapState(nState)
	if nState ~= 0 then
		self.tbMapCalInfo[me.nId] = nil;
	else
		self.tbMapCalInfo[me.nId] = {nState};
	end	
end
tbDownloadInfo.tbc2sFun["ClientSyncMapState"] = tbDownloadInfo.OnClientSyncMapState;

function tbDownloadInfo:OnClientSyncDownloadInfo2(szStep, nSpeed, nPercent)
	if not self.tbMapCalInfo[me.nId] then
		return;
	end
	
	self.tbMapCalInfo[me.nId][2] = szStep;
	self.tbMapCalInfo[me.nId][3] = nSpeed;
	self.tbMapCalInfo[me.nId][4] = nPercent;
	self.tbMapCalInfo[me.nId][5] = me.nTemplateMapId;
end
tbDownloadInfo.tbc2sFun["ClientSendMiniDowloadInfo2"] = tbDownloadInfo.OnClientSyncDownloadInfo2;

function tbDownloadInfo:OnLogout()
	if self.tbMapCalInfo[me.nId] and self.tbMapCalInfo[me.nId][1] == 0 then
		GCExcute{"MiniResource.tbDownloadInfo:RecordMapInfo_GC", me.szName, unpack(self.tbMapCalInfo[me.nId], 2, 5)};	
	end
	self.tbMapCalInfo[me.nId] = nil;
end

function tbDownloadInfo:ApplyLogDownloaderBlockInfo(dwHostIp, pszFile, nState)
	StatLog:WriteStatLog("stat_info", "mini_client", "download_fail", me.nId, string.format("%s,%s,%s,%d",
		Lib:IntIpToStrIp(dwHostIp), Lib:IntIpToStrIp(me.dwIp), pszFile, nState));
end
tbDownloadInfo.tbc2sFun["ApplyLogDownloaderBlockInfo"] = tbDownloadInfo.ApplyLogDownloaderBlockInfo;

end	 -- if MODULE_GAMESERVER then

-----------------------gamecenter-----------------------------------

if MODULE_GC_SERVER then

tbDownloadInfo.TIMER_BASE_TIME 		= 10 * 60;				-- 10分钟
tbDownloadInfo.RECORD_FREQUENCE		= 3;					-- 3倍基础时间
tbDownloadInfo.FILTER_FREQUENCE		= 1;					-- 1倍基础时间
tbDownloadInfo.nTimerCount 			= 0;
tbDownloadInfo.LOG_PATH				= "\\log\\datarecord\\%s\\downloadinfo_%s.txt";

-- szAddr    szIp:nPlayerId
function tbDownloadInfo:RecordInfo_GC(szAddr, szArea, nSpeed)
	self.tbInfo = self.tbInfo or {};
	
	-- 不用判断原来的值，总是覆盖写入
	self.tbInfo[szArea] = self.tbInfo[szArea] or {};
	self.tbInfo[szArea][szAddr] = {};
	self.tbInfo[szArea][szAddr].nSpeed = nSpeed;
	self.tbInfo[szArea][szAddr].nLastTime = GetTime();
end

-- 这个操作本身理应并不频繁，因此即时做IO操作，也不会有太大问题
function tbDownloadInfo:RecordMapInfo_GC(szName, szStep, nSpeed, nPercent, nTemplateMapId)
	local szCurrTime = os.date("%Y\\%m\\%d_%H:%M:%S", GetTime())
	local szCurrLogContent = string.format("%s\t%s\t%s_%s_%d\t%.2fK/s\t%d\r\n",
			"MapInfo", szCurrTime, szName, szStep or "NoSyncValue", nTemplateMapId or -1, nSpeed or 0, nPercent or -1);

	local szTime = os.date("%Y%m%d", GetTime());
	local szFileName = string.format(self.LOG_PATH, szTime, szTime);
	if not KFile.ReadTxtFile(szFileName) then
		szCurrLogContent = "logType\ttime\tarea(name_step_mapTemplate)\tspeed\tclient_cout(percent)\r\n"..szCurrLogContent;
		KFile.WriteFile(szFileName, szCurrLogContent);
	else
		KFile.AppendFile(szFileName, szCurrLogContent);
	end
end

function tbDownloadInfo:OnTimer_Statistic()
	self.nTimerCount = self.nTimerCount + 1;
	if (self.nTimerCount%self.FILTER_FREQUENCE == 0) then  -- 踢除10分钟内都没同步的项
		self:FilterRecrodConten();
	end
	
	if (self.nTimerCount%self.RECORD_FREQUENCE == 0) then  -- 记录当前内存的值
		self.nTimerCount = 0;
		self:LogRecord();
	end
end

function tbDownloadInfo:LogRecord()
	local szCurrLogContent = nil;
	local szCurrTime = os.date("%Y\\%m\\%d_%H:%M:%S", GetTime())
	
	-- tbInfo里的内容
	for szArea, tbData in pairs(self.tbInfo or {}) do
		local nClientCount = Lib:CountTB(self.tbInfo[szArea]);
		local nAverSpeed = 0;
		for _, _tbData in pairs(tbData) do
			nAverSpeed = nAverSpeed + _tbData.nSpeed;			
		end
		
		szCurrLogContent = szCurrLogContent or "";
		szCurrLogContent = szCurrLogContent .. string.format("%s\t%s\t%s\t%.2fK/s\t%d\r\n", 
			"DownloadInfo", szCurrTime, szArea, nAverSpeed/nClientCount, nClientCount);
	end
	
	if szCurrLogContent then
		local szTime = os.date("%Y%m%d", GetTime());
		local szFileName = string.format(self.LOG_PATH, szTime, szTime);
		if not KFile.ReadTxtFile(szFileName) then
			szCurrLogContent = "logType\ttime\tarea(name_step_mapTemplate)\tspeed\tclient_cout(percent)\r\n"..szCurrLogContent;
			KFile.WriteFile(szFileName, szCurrLogContent);
		else
			KFile.AppendFile(szFileName, szCurrLogContent);
		end
	end
	
	-- 要清空吗？？？？
	-- self.tbInfo = nil;
end

function tbDownloadInfo:FilterRecrodConten()
	for szArea, tbData in pairs(self.tbInfo or {}) do
		for szAddr, _tbData in pairs(tbData) do
			if GetTime() - self.FILTER_FREQUENCE * self.TIMER_BASE_TIME > _tbData.nLastTime then
				self.tbInfo[szArea][szAddr] = nil;	-- 超过10分钟没更新了，剔除掉
				if Lib:CountTB(self.tbInfo[szArea]) == 0 then
					self.tbInfo[szArea] = nil;
				end
			end
		end		
	end
	
	if self.tbInfo and Lib:CountTB(self.tbInfo) == 0 then
		self.tbInfo = nil;
	end
end

if tbDownloadInfo.nStatisticTimerId then
	Timer:Close(tbDownloadInfo.nStatisticTimerId);
end
tbDownloadInfo.nStatisticTimerId = Timer:Register(tbDownloadInfo.TIMER_BASE_TIME * Env.GAME_FPS, 
	tbDownloadInfo.OnTimer_Statistic, tbDownloadInfo);
	
end -- if MODULE_GC_SERVER then
 