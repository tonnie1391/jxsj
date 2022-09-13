-- 文件名　：lockmis_file.lua
-- 创建者　：zounan
-- 创建时间：2009-12-16 10:10:06
-- 描  述  ：
--Require("\\script\\mission\\tbLockMisFile\\tbLockMisFile_def.lua");
--活动系统的字符串分割函数
--Require("\\script\\event\\manager\\function.lua");
CFuben.tbLockMisFile = {};
local tbLockMisFile = CFuben.tbLockMisFile;

tbLockMisFile.EVENT_NUM = 30;
tbLockMisFile.szCwd = "\\setting\\fuben\\";
tbLockMisFile.szRootFile = "fuben.txt";
-- 加载锁数据
function tbLockMisFile:LoadLock(szFile)
	local tbLock = {};
--	local tbFile = Lib:LoadTabFile("\\setting\\globalserverbattle\\dataosha\\birth.txt");
	--	读取LOCK
--	local tbFile = Lib:LoadTabFile("\\script\\mission\\tbLockMisFile\\test.txt");
	local tbFile = Lib:LoadTabFile(szFile);
	if not tbFile then
		print("【LockMis Error】读取文件错误，LoadLock",szFile);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		tbParam.LockId = tonumber(tbParam.LockId);
		tbLock[tbParam.LockId] = tbLock[tbParam.LockId] or {};
		tbLock[tbParam.LockId].nTime = tonumber(tbParam.Time);
		tbLock[tbParam.LockId].nNum  = tonumber(tbParam.Num);
		tbLock[tbParam.LockId].tbStartEvent  = tbLock[tbParam.LockId].tbStartEvent  or {};
		tbLock[tbParam.LockId].tbUnLockEvent = tbLock[tbParam.LockId].tbUnLockEvent or {};
		local tbPreLock = nil;
		if tbParam.PreLock == "" or tbParam.PreLock == "0" then
			tbPreLock = {};
		else	
		--	tbParam.PreLock = self:ClearString(tbParam.PreLock);
			tbPreLock = Lib:SplitStr(tbParam.PreLock, ",");
		end
		for nIndex, varParam in ipairs(tbPreLock) do
			local nSerLock =  tonumber(varParam);
			if nSerLock then                            --串锁 
				tbPreLock[nIndex] = nSerLock;
			else
				local tbParLock =  Lib:SplitStr(varParam,"|");             --并锁
				for nIndex2, varParLock in ipairs(tbParLock) do
					local nParLock = tonumber(varParLock);
					if not nParLock then
						print("【LockMis Error】ParLock");
					end
					tbParLock[nIndex2] = nParLock;
				end
				tbPreLock[nIndex] = tbParLock;
			end				
		end	
		
		tbLock[tbParam.LockId].tbPrelock = tbPreLock;	
		
		for i = 1, self.EVENT_NUM do
			if tbParam["StartEvent"..i] and tbParam["StartEvent"..i] ~= "" then
			--	tbParam["StartEvent"..i] = self:ClearString(tbParam["StartEvent"..i]);
				-- local tbStartEvent = EventManager.tbFun:SplitStr(tbParam["StartEvent"..i], ",");
				local tbStartEvent = Lib:SplitStr(tbParam["StartEvent"..i], ",");
				for nIndex, varParam in ipairs(tbStartEvent) do
					local nParam =  tonumber(varParam);
					if nParam then
						tbStartEvent[nIndex] = nParam;
					end
				end
				table.insert(tbLock[tbParam.LockId].tbStartEvent, tbStartEvent);
			end
		end
		
		for i = 1, self.EVENT_NUM do
			if tbParam["UnLockEvent"..i] and tbParam["UnLockEvent"..i] ~= "" then
			--	tbParam["UnLockEvent"..i] = self:ClearString(tbParam["UnLockEvent"..i]);
				-- local tbUnLockEvent = EventManager.tbFun:SplitStr(tbParam["UnLockEvent"..i], ",");
				local tbUnLockEvent = Lib:SplitStr(tbParam["UnLockEvent"..i], ",");
				for nIndex, varParam in ipairs(tbUnLockEvent) do
					local nParam =  tonumber(varParam);
					if nParam then
						tbUnLockEvent[nIndex] = nParam;
					end
				end
				table.insert(tbLock[tbParam.LockId].tbUnLockEvent, tbUnLockEvent);
			end
		end		
	end
	return tbLock;
end

-- 加载NPC刷点表
function tbLockMisFile:LoadNpcPoint(szPath)
	local tbFile = Lib:LoadTabFile(szPath);
	local tbNpcPoint = {};
	if not tbFile then
		print("【LockMis Error】LoadNpcPoint", szPath);
		return;
	end

	for nId, tbParam in ipairs(tbFile) do
		local szClassName = tbParam.ClassName;		
		tbNpcPoint[szClassName] = tbNpcPoint[szClassName] or {};
		local nPosX = math.floor((tonumber(tbParam.X))/32);
		local nPosY = math.floor((tonumber(tbParam.Y))/32);
		table.insert(tbNpcPoint[szClassName], {nPosX, nPosY});
	end
	return tbNpcPoint;
end

-- 加载NPC路线表
function tbLockMisFile:LoadNpcRoad(szPath)
	local tbFile = Lib:LoadTabFile(szPath);
	local tbRoad = {};
	if not tbFile then
		print("【LockMis Error】LoadNPcRoad", szPath);
		return;
	end

	for nId, tbParam in ipairs(tbFile) do
		local szRoadName = tbParam.RoadName;		
		tbRoad[szRoadName] = tbRoad[szRoadName] or {};
		local nPosX = math.floor((tonumber(tbParam.X))/32);
		local nPosY = math.floor((tonumber(tbParam.Y))/32);
		table.insert(tbRoad[szRoadName], {nPosX, nPosY});
	end
	return tbRoad;
end

-- 加载地图TRAP点表
function tbLockMisFile:LoadTrapInfo(szPath)
	local tbFile = Lib:LoadTabFile(szPath);
	local tbTrap = {};
	tbTrap.tbSrcTrap = {};            -- TRAP点
	tbTrap.tbDesTrap = {};            -- 触发TRAP点后传送的点 分两个TABLE 是为了方便MISSION全COPY
	if not tbFile then
		print("【LockMis Error】LoadTrapInfo", szPath);
		return;
	end

	for nId, tbParam in ipairs(tbFile) do
		local szClassName = tbParam.TrapClass;		
		tbTrap.tbSrcTrap[szClassName] = tbTrap.tbSrcTrap[szClassName] or {};
		local nTrapX = math.floor((tonumber(tbParam.TrapX))/32);
		local nTrapY = math.floor((tonumber(tbParam.TrapY))/32);
		table.insert(tbTrap.tbSrcTrap[szClassName], {nTrapX, nTrapY});
		if tbParam.DesX and tbParam.DesX ~= "" and tbParam.DesY and tbParam.DesY ~= "" then
			nTrapX = math.floor((tonumber(tbParam.DesX))/32);
			nTrapY = math.floor((tonumber(tbParam.DesY))/32);
			tbTrap.tbDesTrap[szClassName] = {nTrapX, nTrapY};            --传送点只有一个
		end
	end
	return tbTrap;
end


--副本表
function tbLockMisFile:LoadMisFile()
	local szPath = self.szCwd..self.szRootFile;
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		print("【LockMIs Error】LoadMisFile", szPath);
		return;
	end
	CFuben.tbLockMis = {};
	local tbLockMis = CFuben.tbLockMis;
	for nId, tbParam in ipairs(tbFile) do
		local nMis = tonumber(tbParam.FubenId);
		tbLockMis[nMis] = {}; 
		tbLockMis[nMis].tbLockMisCfg = {};
		local tbLockMisCfg = tbLockMis[nMis].tbLockMisCfg;
	
		--加载锁结构表
		local szLockPath = tbParam.LockPath;
		if szLockPath and szLockPath ~= "" then
			tbLockMisCfg.LOCK = self:LoadLock(self.szCwd..szLockPath);
		end		
		--加载NPC出生点表
		local szNpcPoint = tbParam.NpcPointPath;
		if szNpcPoint and szNpcPoint ~= "" then
			tbLockMisCfg.tbNpcPoint = self:LoadNpcPoint(self.szCwd..szNpcPoint);
		end
		--加载NPC路线表
		local szNpcRoad = tbParam.NpcRoadPath;
		if szNpcRoad and szNpcRoad ~= "" then
			tbLockMisCfg.tbRoad = self:LoadNpcRoad(self.szCwd..szNpcRoad);
		end		
		--加载地图TRAP点表
		local szTrap = tbParam.TrapPath;
		if szTrap and szTrap ~= "" then
			tbLockMisCfg.tbTrap = self:LoadTrapInfo(self.szCwd..szTrap);
		end		
				
		local nRevive = tonumber(tbParam.IsRevive);
		tbLockMisCfg.nOnDeath = nRevive or 0;
		
		local nDeathLeaveCanBack = tonumber(tbParam.nDeathLeaveCanBack);
		tbLockMisCfg.nDeathLeaveCanBack = nDeathLeaveCanBack or 0;	--死亡后是否还可以进入
	end
	return 	tbLockMis;
end


--把带有""的字符串的""号去掉
--[[
function tbLockMisFile:ClearString(szParam)
	if szParam == nil then
		szParam = "";
	end
	if string.len(szParam) > 1 then
		local nSit = string.find(szParam, "\"");
		if nSit ~= nil and nSit == 1 then
			local szFlag = string.sub(szParam, 2, string.len(szParam));
			local szLast = string.sub(szParam, string.len(szParam), string.len(szParam));
			szParam = szFlag;
			if szLast == "\"" then
				szParam = string.sub(szParam, 1, string.len(szParam)-1);
			end
		end
	end
	
	szParam = string.gsub(szParam, "\\\"","<doublequ>");
	szParam = string.gsub(szParam, "\"\"", "\"");
	szParam = string.gsub(szParam, "<doublequ>","\\\"");

	return szParam;
end
--]]
CFuben.tbLockMisFile:LoadMisFile();
