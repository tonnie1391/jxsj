-- 批量关天牢

local BatchArrest	= GM.BatchArrest or {};
GM.BatchArrest		= BatchArrest;


BatchArrest.TIME_TIMEOUT	= 3600*24*30;	-- 操作30天后过期

-- 读取列表文件
function BatchArrest:ReadList(szDataPath, bArrest, nStartTime)
	bArrest		= (bArrest == 1 and 1) or 0;
	nStartTime	= nStartTime or GetTime();
	local nMyTypeId		= Env:GetZoneType(GetGatewayName());
	local szStartTime	= os.date("%Y-%m-%d %H:%M:%S", nStartTime);
	local tbData		= Lib:LoadTabFile(szDataPath);
	local nLoadCount	= 0;
	for _, tbRow in ipairs(tbData) do
		if tbRow.RoleName then
			local nPlayerId	= KGCPlayer.GetPlayerIdByName(tbRow.RoleName);
			if (nPlayerId and nMyTypeId == Env:GetZoneType(tbRow.GatewayID)) then
				local nJailTime	= tonumber(tbRow.JailTime) or 0;
				self.tbProcessList[tbRow.RoleName]	= {
					nStartTime	= nStartTime;
					bArrest		= bArrest;
					nJailTime	= nJailTime;
				};
				self:ScriptLogF(tbRow.RoleName, "AddProcessList\t%s,%d,%d", szStartTime, nJailTime, bArrest);
				nLoadCount	= nLoadCount + 1;
			end
		end
	end

	if (MODULE_GC_SERVER) then
		self:SaveData();
		GlobalExcute({"GM.BatchArrest:ReadList", "\\..\\gamecenter"..szDataPath, bArrest, nStartTime});
	end
	
	if (MODULE_GAMESERVER) then
		for _, pPlayer in pairs(KPlayer.GetAllPlayer()) do
			self:ProcessPlayer(pPlayer);
		end
	end
	
	return nLoadCount;
end

-- 检查过期（只能在GS未连接时使用）
function BatchArrest:CheckOverdue()
	local nPassTime	= GetTime() - self.TIME_TIMEOUT;
	for szName, tbProcess in pairs(self.tbProcessList) do
		if (tbProcess.nStartTime < nPassTime) then
			self.tbProcessList[szName]	= nil;
			local szMsg	= string.format("[%s]的批量[%s]操作因超时被放弃。",
				os.date("%Y-%m-%d %H:%M:%S", tbProcess.nStartTime), (tbProcess.bArrest == 1 and "关天牢") or "解除天牢");
			local nPlayerId	= KGCPlayer.GetPlayerIdByName(szName);
			if (not nPlayerId) then
				self:ScriptLogF(szName, "(PlayerNotFound!)\t%s", szMsg);
			else
				KGCPlayer.PlayerLog(nPlayerId, Log.emKPLAYERLOG_TYPE_GM_OPERATION, szMsg);
			end
		end
	end
	self:SaveData();
end

-- 存档
function BatchArrest:SaveData()
	local tbSaveData	= {};
	for szName, tbProcess in pairs(self.tbProcessList) do
		tbSaveData[#tbSaveData + 1]	= {szName, tbProcess.nStartTime, tbProcess.bArrest, tbProcess.nJailTime};
	end
	SetGblIntBuf(GBLINTBUF_ARREST_LIST, 0, 1, tbSaveData);
end

-- 读档
function BatchArrest:LoadData()
	self.tbProcessList	= {};
	
	local tbSaveData	= GetGblIntBuf(GBLINTBUF_ARREST_LIST, 0);
	if (type(tbSaveData) ~= "table") then
		tbSaveData	= {};
	end
	
	for _, tbData in ipairs(tbSaveData) do
		self.tbProcessList[tbData[1]]	= {
			nStartTime	= tbData[2];
			bArrest		= tbData[3];
			nJailTime	= tbData[4];
		};
	end
end

function BatchArrest:CoZoneUpdateArrestListBuf(tbCoZoneArrestListBuf)
	print("[CoZoneUpdateArrestListBuf] Start!!");
	self:LoadData();
	if (type(tbCoZoneArrestListBuf) ~= "table") then
		tbCoZoneArrestListBuf	= {};
	end
	
	for _, tbData in ipairs(tbCoZoneArrestListBuf) do
		self.tbProcessList[tbData[1]]	= {
			nStartTime	= tbData[2];
			bArrest		= tbData[3];
			nJailTime	= tbData[4];
		};
	end
	self:SaveData();
end

-- 服务器启动
function BatchArrest:OnServerStart()
	self:LoadData();
	if (MODULE_GC_SERVER) then
		self:CheckOverdue();
	end
end

-- 玩家登入
function BatchArrest:OnLogin()
	self:ProcessPlayer(me);
end

-- 检查玩家是否有操作需要处理，并执行
function BatchArrest:ProcessPlayer(pPlayer)
	local tbProcess	= self.tbProcessList[pPlayer.szName];
	if (not tbProcess) then
		return 0;
	end
	
	local szMsg	= string.format("[%s]的批量[%s]操作被执行。", os.date("%Y-%m-%d %H:%M:%S", tbProcess.nStartTime), (tbProcess.bArrest == 1 and "关天牢") or "解除天牢")
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_GM_OPERATION, szMsg);
	
	if (tbProcess.bArrest == 1) then
		Player:Arrest(pPlayer.szName, tbProcess.nJailTime);
	else
		Player:SetFree(pPlayer.szName);
	end
	
	GCExcute({"GM.BatchArrest:RemoveProcess", pPlayer.szName});
	
	return 1;
end

-- 移除一条处理记录
function BatchArrest:RemoveProcess(szName)
	local tbProcess	= self.tbProcessList[szName];
	self.tbProcessList[szName]	= nil;
	if (not tbProcess) then
		self:ScriptLogF(szName, "RemoveProcess\tNot Found!");
	else
		self:ScriptLogF(szName, "RemoveProcess\t%s,%d,%d", os.date("%Y-%m-%d %H:%M:%S", tbProcess.nStartTime), tbProcess.bArrest, tbProcess.nJailTime);
	end
	if (MODULE_GC_SERVER) then
		GlobalExcute({"GM.BatchArrest:RemoveProcess", szName});
	end
end

-- 调试输出
function BatchArrest:DebugShow()
	local nCount	= 0;
	for szName, tbProcess in pairs(self.tbProcessList) do
		nCount	= nCount + 1;
		print("[BatchArrest]", szName, os.date("%Y-%m-%d %H:%M:%S", tbProcess.nStartTime), tbProcess.bArrest, tbProcess.nJailTime);
	end
	print("[BatchArrestCount]", nCount);
	if (MODULE_GC_SERVER) then
		GlobalExcute({"GM.BatchArrest:DebugShow", szName});
	end
end

-- 写脚本日志
function BatchArrest:ScriptLogF(szName, ...)
	local szMsg	= string.format(unpack(arg));
	Dbg:WriteLogEx(Dbg.LOG_INFO, "GM", "BatchArrest", szName, szMsg);
end

-- 各种回调注册
if (not BatchArrest.bReged) then
	-- Server Start
	local function fnServerStart()
		BatchArrest:OnServerStart();
	end
	-- GC Close
	local function fnGCClose()
		BatchArrest:SaveData();
	end
	-- Player Login
	local function fnOnLogin()
		BatchArrest:OnLogin();
	end

	if (MODULE_GAMESERVER) then
		PlayerEvent:RegisterOnLoginEvent(fnOnLogin);
		ServerEvent:RegisterServerStartFunc(fnServerStart);
	end
	
	if (MODULE_GC_SERVER) then
		GCEvent:RegisterGCServerStartFunc(fnServerStart);
		GCEvent:RegisterGCServerShutDownFunc(fnGCClose);
	end
	
	BatchArrest.bReged	= 1;
end

--?gc GM.BatchArrest:DebugShow()
--?gc GM.BatchArrest:ReadList("\\arrest.txt", 1)
