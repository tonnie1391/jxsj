-- 文件名　：serverlist.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-12-03 11:38:13
-- 描  述  ：加载服务器表

ServerEvent.szServerListCfgPath = "\\setting\\serverlistcfg.txt";

--战区
ServerEvent.tbDefGlobalAreaName = {
	[1] = {"Chiến khu 1", DBTASK_GLOBAL_NEWLAND_CITYER1, "gate0100"};
	[2] = {"电信二号战区", DBTASK_GLOBAL_NEWLAND_CITYER2, "gate0300"};
	[3] = {"电信三号战区", DBTASK_GLOBAL_NEWLAND_CITYER3, "gate0600"};
	[4] = {"电信四号战区", DBTASK_GLOBAL_NEWLAND_CITYER4, "gate0700"};
	[5] = {"电信五号战区", DBTASK_GLOBAL_NEWLAND_CITYER5, "gate1000"};
	[6] = {"网通一号战区", DBTASK_GLOBAL_NEWLAND_CITYER6, "gate0200"};
	[7] = {"网通二号战区", DBTASK_GLOBAL_NEWLAND_CITYER7, "gate1100"};
}

function ServerEvent:LoadServerList(tbFile, bSave)
	--区服表读取列
	local tbLoadIntTab = {
		["GlobalArea"] = 1,
		};
	self.tbServerListCfg = {
		tbNameList={};
		tbGateList={};
		tbGateCount={};
		tbIndex={};
		};
	local tbNameList = self.tbServerListCfg.tbNameList;
	local tbGateList = self.tbServerListCfg.tbGateList; 
	local tbGateCount = self.tbServerListCfg.tbGateCount;
	local tbIndex	= self.tbServerListCfg.tbIndex;
	
	local tbServerNameLists = {}; 
	for _, tbTemp in ipairs(tbFile) do
		tbNameList[tbTemp.ZoneName] = tbNameList[tbTemp.ZoneName] or {};
		tbNameList[tbTemp.ZoneName][tbTemp.ServerName] = tbNameList[tbTemp.ZoneName][tbTemp.ServerName] or tbTemp.GatewayId;
		tbGateCount[tbTemp.ZoneName] = tbGateCount[tbTemp.ZoneName] or 0;
		
		tbServerNameLists[tbTemp.GatewayId] = tbServerNameLists[tbTemp.GatewayId] or {};
		if tonumber(tbTemp.MainServer) == 1 then
			table.insert(tbServerNameLists[tbTemp.GatewayId], 1, tbTemp.ServerName);
		else
			table.insert(tbServerNameLists[tbTemp.GatewayId], tbTemp.ServerName);
		end
		
		if tonumber(tbTemp.MainServer) == 1 then
			if tbGateList[tbTemp.GatewayId] then
				print("stack traceback", "setting\\servernamecfg.txt Error", "Have More 2 ServerMain", tbTemp.GatewayId);				
			end
			tbGateList[tbTemp.GatewayId] = tbGateList[tbTemp.GatewayId] or {};
			tbGateList[tbTemp.GatewayId].ZoneType = tonumber(tbTemp.ZoneType) or 1;
			tbGateList[tbTemp.GatewayId].ZoneTypeName = tbTemp.ZoneTypeName or "电信";
			--tbGateList[tbTemp.GatewayId].ZoneId = tbTemp.ZoneId;
			tbGateList[tbTemp.GatewayId].ZoneName = tbTemp.ZoneName;			
			tbGateList[tbTemp.GatewayId].ServerName = tbTemp.ServerName;
			tbGateList[tbTemp.GatewayId].tbAllServerName = tbServerNameLists[tbTemp.GatewayId];
			
			for szCom in pairs(tbLoadIntTab) do
				tbGateList[tbTemp.GatewayId][szCom] = tonumber(tbTemp[szCom]) or 0;
			end
			tbGateCount[tbTemp.ZoneName] = tbGateCount[tbTemp.ZoneName] + 1;
		end
	end
	
	--检查并服后是否没有主服的区服
	for szZone, tbServer in pairs(tbNameList) do
		local nTransferId = 0;
		for szServer, szGateWay in pairs(tbServer) do
			if not tbGateList[szGateWay] then
				print("stack traceback", "setting\\servernamecfg.txt Error", "Not ServerMain", szGateWay);
			end
			if tbGateList[szGateWay] then
				tbGateList[szGateWay].nTransferId = 0;
			end
		end
	end
	if (MODULE_GC_SERVER)and bSave == 1 then
		SetGblIntBuf(GBLINTBUF_SERVER_LIST, 0, 1, self.tbServerListCfg);
	end
	self:LoadGlobalArea();	--加载战区结构表
	return 1;
end

function ServerEvent:LoadGlobalArea()
	self.tbGlobalArea = {};
	local tbGlobalAreaTransferId = {};
	for szgateway, tbInfor in pairs(self.tbServerListCfg.tbGateList) do
		local nAreaId = tbInfor.GlobalArea;
		if nAreaId > 0 and  self.tbDefGlobalAreaName[nAreaId] then
			self.tbGlobalArea[nAreaId] = self.tbGlobalArea[nAreaId] or {};
			self.tbGlobalArea[nAreaId][szgateway] = tbInfor;
			
			--按战区区分跨服英雄岛
			tbGlobalAreaTransferId[nAreaId] = tbGlobalAreaTransferId[nAreaId] or 0;
			tbInfor.nTransferId = math.mod(tbGlobalAreaTransferId[nAreaId], 14) + 1;
			tbGlobalAreaTransferId[nAreaId] = tbGlobalAreaTransferId[nAreaId] + 1;
			if tbGlobalAreaTransferId[nAreaId] > 15 then
				print("stack traceback warning!!!", "setting\\servernamecfg.txt Error", "Aread to much!!over 14!!");
			end
		end
		
	end
end

function ServerEvent:GetGlobalAreaId(szGate)
	local szMyGate = GetGatewayName();
	local szGateway = szGate or szMyGate;
	local nAreaId = 0;
	if self.tbServerListCfg.tbGateList[szGateway] then
		nAreaId = self.tbServerListCfg.tbGateList[szGateway].GlobalArea;
	end
	return nAreaId;
end

function ServerEvent:GetGlobalAreaName(szGate)
	local nAreaId = self:GetGlobalAreaId(szGate);
	local szNameArea = (self.tbDefGlobalAreaName[nAreaId] and self.tbDefGlobalAreaName[nAreaId][1]) or "未设置战区";
	return szNameArea;
end

function ServerEvent:GetGlobalAreaNameById(nAreaId)
	local szNameArea = (self.tbDefGlobalAreaName[nAreaId] and self.tbDefGlobalAreaName[nAreaId][1]) or "未设置战区";
	return szNameArea;
end

function ServerEvent:GetGlobalAreaGbTaskById(nAreaId)
	local szNameArea = (self.tbDefGlobalAreaName[nAreaId] and self.tbDefGlobalAreaName[nAreaId][2]) or 0;
	return szNameArea;
end

function ServerEvent:LoadServerFile(szPath, bSave, bSync)
	local tbFile = Lib:LoadTabFile(szPath);
	if tbFile then
		self:LoadServerList(tbFile, bSave);
		if (MODULE_GC_SERVER) and bSync ==1 then
			GlobalExcute({"ServerEvent:ReloadServerFile"});
		end
		return 1;
	end
	return 0;
end

function ServerEvent:ReloadServerFile()
	self.tbServerListCfg = GetGblIntBuf(GBLINTBUF_SERVER_LIST, 0);
end

--获得区服名称表
--返回表格式:
--tb = { 
--	["青龙区"] = {
--		["永乐镇"] = "gate0103",
--		...
--	},
--	...
--}
function ServerEvent:GetServerNameList()
	return self.tbServerListCfg.tbNameList;
end

function ServerEvent:GetServerGateList()
	return self.tbServerListCfg.tbGateList;
end

--获得区服信息表
--返回表格式:
--tb = { 
--	ZoneName="青龙区",
--	ServerName="永乐镇",
--	tbServerName={"永乐镇"}, --合区表，第一个为主服
--	GlobalWldh=1,
--  nTransferId=1,
--}
function ServerEvent:GetServerInforByGateway(szGateway)
	return self.tbServerListCfg.tbGateList[szGateway];
end

-- 返回中文网关
function ServerEvent:GetServerNameByGateway(szGateway)
	local tbInfo = self.tbServerListCfg.tbGateList[szGateway];
	if not tbInfo then
		return "未知服";
	end
	return tbInfo.ServerName;
end

-- 返回中文大区
function ServerEvent:GetGateNameByGateway(szGateway)
	local tbInfo = self.tbServerListCfg.tbGateList[szGateway];
	if not tbInfo then
		return "未知区";
	end
	return tbInfo.ZoneName;
end

-- 判断是否主服
function ServerEvent:CheckIsMainServer(szServerName, szGateway)
	local tbInfo = self.tbServerListCfg.tbGateList[szGateway];
	if not tbInfo then
		return 0;
	end
	print(szServerName, szGateway, tbInfo.ServerName);
	return (szServerName == tbInfo.ServerName) and 1 or 0;
end

--获得自己所在区服信息表
function ServerEvent:GetMyServerInforByGateway()
	local szGateway = GetGatewayName();
	return ServerEvent:GetServerInforByGateway(szGateway);
end

--获得自己所在大区的区服数量
function ServerEvent:GetMyZoneServerCount()
	local szGateway = GetGatewayName();
	local tbGate = self.tbServerListCfg.tbGateList[szGateway];
	return self.tbServerListCfg.tbGateCount[tbGate.ZoneName] or 0;
end

--获得自己所在大区的区服数量
function ServerEvent:GetZoneServerCount(szGateway)
	local tbGate = self.tbServerListCfg.tbGateList[szGateway];
	if not tbGate or not tbGate.ZoneName then
		return 0;
	end
	return self.tbServerListCfg.tbGateCount[tbGate.ZoneName] or 0;
end

function ServerEvent:ServerListCfgInit()
	if KGblTask.SCGetDbTaskInt(DBTASK_SERVER_LIST_LOADBUFF) == 0 then
		--ServerEvent:LoadServerFile(self.szServerListCfgPath);
		return 0;
	end
	self.tbServerListCfg = GetGblIntBuf(GBLINTBUF_SERVER_LIST, 0);
end

--大区名，服务器名，网关，英雄岛Id，大区类型（1电信，2网通），大区类型名（1电信，2网通）
function ServerEvent:AddOneServerInfo(szZoneName, szServerName, szGateway, nTransferId, nZoneType, ZoneTypeName)
	ServerEvent.tbServerListCfg.tbNameList[szZoneName][szServerName] = szGateway;
	ServerEvent.tbServerListCfg.tbGateList[szGateway] = {
	ZoneName=szZoneName,
	ZoneType= tonumber(nZoneType) or 1,
	ZoneTypeName = ZoneTypeName or "电信";
	ServerName=szServerName,
	tbAllServerName={szServerName},
 	nTransferId=tonumber(nTransferId) or 14,
	};
end

--先读取包内默认服务器表
ServerEvent:LoadServerFile(ServerEvent.szServerListCfgPath, 0);
