-------------------------------------------------------------------
--File: domainmanager.lua
--Author: luobaohang
--Date: 2008-10-15 16:59
--Describe: 领土管理脚本（gameserver、client端需要）
-------------------------------------------------------------------

-- 获取区域名
function Domain:GetDomainName(nDomainId)
	return self.tbDomainName[nDomainId];
end

-- 获得所有区域及其名字
function Domain:GetDomains()
	return self.tbDomainName;
end

-- 获取区域归属（帮会id 或 联盟id）
function Domain:GetDomainOwner(nDomainId)
	local nId = KLib.Number2UInt(KGblTask.GetGblInt(67, nDomainId));
	if not KTong.GetTong(nId) and not KUnion.GetUnion(nId) then
		nId = 0;
	end
	return nId;
end

-- 获取区域的地图类型(MapType)
function Domain:GetDomainType(nDomainId)
	return self.tbDomainType[nDomainId];
end

-- 获取相邻的地图集合
function Domain:GetBorderDomains(nDomainVersion, nDomainId)
	if self.tbDomainRelation[nDomainVersion] then
		return self.tbDomainRelation[nDomainVersion][nDomainId];
	end
end

-- 获取某领土的相邻结点个数
function Domain:GetBorderCount(nDomainVersion, nDomainId)
	if self.tbRelationCount[nDomainVersion] then
		return self.tbRelationCount[nDomainVersion][nDomainId] or 0;
	end
	return 0
end

-- 获得区域所属国家
function Domain:GetDomainCountry(nDomainId)
	return self.tbDomainCountry[nDomainId];
end

-- 获得领土与对应的宣战帮会
function Domain:GetDeclareTongNames(nDomainId)
	local szDeclareTongNames = "";
	if self.tbDeclareDomainTong[nDomainId] then		
		for _, nTongId in pairs(self.tbDeclareDomainTong[nDomainId]) do
			local pTong = KTong.GetTong(nTongId);
			szDeclareTongNames = szDeclareTongNames..pTong.GetName().."\n";
		end	
	end
	return szDeclareTongNames;
end

-- 设置领土与对应的宣战帮会
function Domain:SetDeclareDomainTong(nDomainId, nTongId)
	-- 检查是否已经对该领土宣战
	if not self.tbTongDeclare[nTongId] then
		self.tbTongDeclare[nTongId] = {}
	end
	for i = 1, #self.tbTongDeclare[nTongId] do
		if nDomainId == self.tbTongDeclare[nTongId][i] then
			return;
		end
	end
	-- 检查可宣战领土个数（合服补偿可能大于1个宣战领土）
	local nDeclareNum = self:GetConzoneDelareNum(nTongId);
	if nDeclareNum <= 0 then
		nDeclareNum = 1;
	end
	local nToReMoveDomain = 0;
	if #self.tbTongDeclare[nTongId] >= nDeclareNum then
		local nToDelDomain = self.tbTongDeclare[nTongId][1];
		local tbTong = self.tbDeclareDomainTong[nToDelDomain];
		for nIter = 1, #tbTong do
			if nTongId == tbTong[nIter] then
				table.remove(tbTong, nIter);
				break;
			end
		end
		table.remove(self.tbTongDeclare[nTongId], 1);
	end
	
	table.insert(self.tbTongDeclare[nTongId], nDomainId);
	if self.tbDeclareDomainTong[nDomainId] then
		table.insert(self.tbDeclareDomainTong[nDomainId], nTongId);
	else
		self.tbDeclareDomainTong[nDomainId] = {nTongId};
	end
end

-- 获得帮会可宣战个数
function Domain:GetConzoneDelareNum(nTongId)
	local nBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	local nConBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_DOMAIN_BATTLE_NO);
	local nConzoneTime = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);	-- 合服时间
	if nConBattleNo > 0 and nBattleNo == (nConBattleNo + 1) and nConzoneTime > 0 then		
		local pTong = KTong.GetTong(nTongId);
		if not pTong then
			return 0;
		end
		return pTong.GetCozoneAttackNum();
	end
	return 0;
end

function Domain:GetDomainToAttack(nTongId)
	return self.tbTongDeclare[nTongId] or {};
end

function Domain:IsTongDeclareDomain(nTongId, nDomainId)
	local tbDeclareDomain = self:GetDomainToAttack(nTongId);
	for i = 1, #tbDeclareDomain do
		if tbDeclareDomain[i] == nDomainId then
			return 1;
		end
	end
	return 0;
end

function Domain:IsUnionDeclareDomain(nUnionId, nDomainId)
	if not self.tbUnionDeclear then
		self:MakeUpUnionDeclear();
	end
	if self.tbUnionDeclear[nUnionId] and self.tbUnionDeclear[nUnionId][nDomainId] then
		return 1;
	end
	return 0;
end

-- 进入征战期才调用，组织记录联盟内宣战的领土
function Domain:MakeUpUnionDeclear()
	self.tbUnionDeclear = {}
	for nTongId, tbDeclearDomain in pairs(self.tbTongDeclare) do
		local pTong = KTong.GetTong(nTongId);
		if pTong and pTong.GetBelongUnion() ~= 0 then
			local nUnionId = pTong.GetBelongUnion()
			if not self.tbUnionDeclear[nUnionId] then
				self.tbUnionDeclear[nUnionId] = {};
			end
			for i = 1, #tbDeclearDomain do
				self.tbUnionDeclear[nUnionId][tbDeclearDomain[i]] = 1;
			end
		end
	end
end


	
---- 获得区域称号
--function Domain:GetDomainTitleDetail(nDomainId)
--	return self.tbTitleDetail[nDomainId];
--end

if MODULE_GAMESERVER or MODULE_GC_SERVER then
Domain.nDataVer = 0;
------------------------Gameserver-Begin----------------------------
-- 获取区域地图数组
--function Domain:GetDomainMap(nDomainId)
--	local aryMap;
--	return aryMap;
--end
-- 获取地图所在区域
function Domain:GetMapDomain(nMapId)
	return self.tbMapDomain[nMapId] or 0;
end

-- 设置区域归属（0为无归属）
function Domain:SetDomainOwner(nDomainId, nOwnerId)
	return KGblTask.SetGblInt(67, nDomainId, nOwnerId);
end

-- 获取区域争夺地图（地图id）
function Domain:GetDomainFightMap(nDomainId)
	return self.tbDomainFightMap[nDomainId];
end

-- 获取当前时间轴对应的相应属性
function Domain:GetOpenStateTable()
	local nState = 0;
	local nCurTime = GetTime();
	for i = 1, #self.OPENSTATE_TO_LEVEL do 
		local tbTmp = self.OPENSTATE_TO_LEVEL[i]
		if nCurTime - TimeFrame:GetTime(tbTmp.szOpenState) > tbTmp.nOffsetDay * 3600 * 24 then
			nState = i
		end
	end
	return self.OPENSTATE_TO_LEVEL[nState];
end

-- 获取所有区域的声望参数总值（即总星级）
function Domain:GetTotalReputeParam(nTongId)
	local nTotalReputeParam = 0;
	local pTong = KTong.GetTong(nTongId)
	if pTong then
		local pDomainItor = pTong.GetDomainItor();
		local nCurId = pDomainItor.GetCurDomainId();
		  -- 领土合计的星级
		while (nCurId and nCurId ~= 0) do
			nTotalReputeParam = nTotalReputeParam + self:GetReputeParam(nCurId);
			nCurId = pDomainItor.NextDomainId();
		end	
	end
	return nTotalReputeParam;
end

-- 根据领土星级计算领土总分（总荣誉值）
function Domain:CalculateDomainScore(nReputeParam)
	if nReputeParam < 1 then
		return 0;
	end
	local nLevel = 1;
	for i = 1, #self.DOMAINBATTLE_REPUTE_PRESENT do 
		if self.DOMAINBATTLE_REPUTE_PRESENT[nLevel][1] <= nReputeParam then
			nLevel = nLevel + 1;
		end
	end
	local nLevelValue = self.DOMAINBATTLE_REPUTE_PRESENT[nLevel][2];
	local nOverValue = (nReputeParam - self.DOMAINBATTLE_REPUTE_PRESENT[nLevel - 1][1]) * self.DOMAINBATTLE_REPUTE_PRESENT[nLevel][3];
	return self.REPUTE_PRE_BORDER *(nLevelValue + nOverValue);
end

-- 获得联盟领土总分（总荣誉值）
function Domain:GetUnionDomainScore(nUnionId)
	local nTotalValue = 0;
	local pUnion = KUnion.GetUnion(nUnionId);
	if pUnion then
		-- 未分配的领土的星级
		local nUnionReputeParam = 0;
		local pDomainItor = pUnion.GetDomainItor();
		local nCurId = pDomainItor.GetCurDomainId();
		while (nCurId and nCurId ~= 0) do
			nUnionReputeParam = nUnionReputeParam + self:GetReputeParam(nCurId);
			nCurId = pDomainItor.NextDomainId();
		end	
		nTotalValue = nTotalValue + Domain:CalculateDomainScore(nUnionReputeParam);
		
		-- 各成员帮会的领土的星级
		local pTongItor =  pUnion.GetTongItor();
		local nCurTongId = pTongItor.GetCurTongId();
		while nCurTongId ~= 0 do
			local pCurTong = KTong.GetTong(nCurTongId);
			if pCurTong then
				local nTongReputeParam = self:GetTotalReputeParam(nCurTongId);
				nTotalValue = nTotalValue + Domain:CalculateDomainScore(nTongReputeParam);
			end
			nCurTongId = pTongItor.NextTongId();
		end
	end
	return nTotalValue;
end

------------------------Gameserver-End----------------------------
else
------------------------Client-Begin----------------------------
Domain.tbDomainInfo = {};
-- 获取区域信息：帮会、是否主城
function Domain:GetDomainInfo(nDomainId)
	return self.tbDomainInfo[nDomainId];
end

function Domain:SetDomainInfo(tbDomainInfo)
	self.tbDomainInfo = tbDomainInfo;
--	if szTongName then
--		self.tbDomainInfo[nDomainId] = {szTongName, nColor, bCaptical};
--	else
--		self.tbDomainInfo[nDomainId] = nil;
--	end
	
end
------------------------Client-End-----------------------------
end

-- 获得区域的中心区域
function Domain:GetCenterRange(nDomainId)
	return self.tbCenterRange[nDomainId];
end
-- 获得某征战地图的NPC坐标表
function Domain:GetNpcPosTable(nMapId)
	return self.tbNpcPos[nMapId];
end

-- 获得占领积分
function Domain:GetOccupyScore(nOccupyMinu, nDeathTimes)
	local nMaxMinu = #self.tbOcuppyScore
	if nMaxMinu < 0 then
		return 0;
	end
	if nOccupyMinu > nMaxMinu then
		nOccupyMinu = nMaxMinu;
	end
	local nMaxTimes = #self.tbOcuppyScore[nOccupyMinu];
	if nMaxTimes < 0 then
		return 0;
	end
	if nDeathTimes > nMaxTimes then
		nDeathTimes = nMaxTimes;
	end
	return self.tbOcuppyScore[nOccupyMinu][nDeathTimes];
end

-- 获得领土星数
function Domain:GetReputeParam(nDomainId)
	return self.tbReputeParam[nDomainId] or 0;
end

---------------------- Private 私有函数 -----------------------------------
-- 变量定义
Domain.tbMapDomain = {} -- 地图id对应区域id
Domain.tbDomainName = {};
Domain.tbDomainCountry = {};
Domain.tbDomainType = {};
Domain.tbDomainFightMap = {};
Domain.tbCountryName = {};
Domain.tbReputeParam = {};		-- 领土星数
Domain.tbCenterRange = {};
Domain.tbReactRate = {};
Domain.tbDomainRelation = {};	-- 区域关系表
Domain.tbRelationCount = {};	-- 相邻个数
Domain.tbDeclareDomainTong = {};  -- 地图id对应的宣战帮会表
Domain.tbTongDeclare = {};		-- 帮会ID对应宣战表
Domain.tbTitleDetail = {};		-- 区域称号类型

Domain.tbNpcPos = {};			-- NPC坐标表
Domain.tbOcuppyScore = {}		-- 占领标志NPC得分表
Domain.tbBossPos= {};			-- BOSS坐标表

local szDomainSetting = "\\setting\\domainbattle\\domainsetting.txt";
local szDomainRelation = "\\setting\\domainbattle\\domainrelation_stage%d.txt";
local szCountrySetting = "\\setting\\domainbattle\\countrysetting.txt";
local szMapList = "\\setting\\map\\maplist.txt";

local NPC_POS_FILE 	= "\\setting\\domainbattle\\domain_npc_pos%s.txt"
local OCCUPY_SCORE	= "\\setting\\domainbattle\\occupy_score.txt";
local BOSS_POS_FILE = "\\setting\\domainbattle\\domain_boss_pos.txt";
local MAX_DEATHTIMES = 10;

-- 加载区域配置表
function Domain:LoadDomainSetting()
	local tbDomainSetting = Lib:LoadTabFile(szDomainSetting);	
	local tbCountrySetting = Lib:LoadTabFile(szCountrySetting);		
	assert(tbDomainSetting and tbCountrySetting);
	-- 加载区域配置
	for nRow, tbRowData in pairs(tbDomainSetting) do
		local nDomainId = tonumber(tbRowData["DomainId"]);
		if (nDomainId) then
			self.tbDomainName[nDomainId] = tbRowData["DomainName"];
			self.tbDomainCountry[nDomainId] = tonumber(tbRowData["CountryId"]);
			self.tbDomainFightMap[nDomainId] = tonumber(tbRowData["FightMap"]);
			self.tbDomainType[nDomainId] = tbRowData["MapType"];
			self.tbReputeParam[nDomainId] =tonumber(tbRowData["ReputeParam"]);		-- 领土星数
			self.tbReactRate[nDomainId] = tonumber(tbRowData["ReactRate"]);
			self.tbTitleDetail[nDomainId] = tonumber(tbRowData["TitleDetail"]);
			self.tbCenterRange[nDomainId] = 
			{
				nX = tonumber(tbRowData["CenterX"]),
				nY = tonumber(tbRowData["CenterY"]),
				nRange	 = tonumber(tbRowData["nRange"]),	
			};
		end
	end
	-- 加载国家配置
	for nRow, tbRowData in pairs(tbCountrySetting) do
		local nCountryId = tonumber(tbRowData["CountryId"]);
		self.tbCountryName[nCountryId] = tbRowData["CountryName"];	
		if MODULE_GAMESERVER then			-- 服务器加载NPC点
			self:LoadNpcPos(nCountryId);
		end
	end
	-- 加载区域关系配置
	for nVersion = 1, 3 do
		local tbDomainRelationFiles	= KLib.LoadTabFile(string.format(szDomainRelation, nVersion));
		assert(tbDomainRelationFiles and tbDomainRelationFiles[1]);
		self.tbDomainRelation[nVersion] = {}
		self.tbRelationCount[nVersion] = {};
		local tbColName = tbDomainRelationFiles[1];
		local nColNums = #tbColName;
		for nRow, tbRowData in pairs(tbDomainRelationFiles) do
			local nDomainId = tonumber(tbRowData[1]);
			if nDomainId  then
				if self.tbDomainRelation[nVersion][nDomainId] == nil then
					self.tbDomainRelation[nVersion][nDomainId] = {};
					self.tbRelationCount[nVersion][nDomainId] = 0
				end
				for i = 2, nColNums do
					local nDomainId2 = tonumber(tbRowData[i]);
					if nDomainId2 then 
						self.tbDomainRelation[nVersion][nDomainId][nDomainId2] = 1;
						self.tbRelationCount[nVersion][nDomainId] = self.tbRelationCount[nVersion][nDomainId] + 1;
					end
				end
			end
		end
	end
if MODULE_GAMESERVER then
	-- 加载maplist的区域配置
	local tbMapList	= KLib.LoadTabFile(szMapList);
	assert(tbMapList and tbMapList[1]);
	local nColMapId, nColDomain;
	for nCol, szCol in pairs(tbMapList[1]) do
		if szCol == "Domain" then
			nColDomain = nCol;
		elseif szCol == "TemplateId" then
			nColMapId = nCol;
		end
	end
	assert(nColMapId and nColDomain);
	tbMapList[1] = nil; -- 英文字段头
	tbMapList[2] = nil; -- 中文字段头
	for nRow, tbDataRow in pairs(tbMapList) do
		self.tbMapDomain[tonumber(tbDataRow[nColMapId])] = tonumber(tbDataRow[nColDomain]);
	end
	-- 加载占领积分表
	local tbScore = Lib:LoadTabFile(OCCUPY_SCORE);
	for _, tbCol in pairs(tbScore) do
		local nMinute = tonumber(tbCol.Minute)
		self.tbOcuppyScore[nMinute] = {};
		local nScore = 0;
		for i = 0, MAX_DEATHTIMES do
			local szColName = string.format("Death%s", i);
			if tbCol[szColName] then
				nScore = tonumber(tbCol[szColName]);
			end
			self.tbOcuppyScore[nMinute][i] = nScore;
		end
	end
	Domain:LoadBossNpcPos()
end -- if MODULE_GAMESERVER then
end

-- 加载征战地图NPC坐标
function Domain:LoadNpcPos(nCountryId)
	local szFile = string.format(NPC_POS_FILE, nCountryId)
	local tbFile = Lib:LoadTabFile(szFile);
	if not tbFile then
		print("can't read file "..szFile);
		return 0;
	end
	for _, tbRowData in pairs(tbFile) do
		local nMapId = tonumber(tbRowData.MapId);
		local nTemplateId = tonumber(tbRowData.Template);
		local nReactNpcId = tonumber(tbRowData.ReactNpc);
		if not self.tbNpcPos[nMapId] then
			self.tbNpcPos[nMapId] = {};
		end
		if not self.tbNpcPos[nMapId][nTemplateId] then
			self.tbNpcPos[nMapId][nTemplateId] = {};
		end
		table.insert(self.tbNpcPos[nMapId][nTemplateId], 
			{nX = tonumber(tbRowData.X), nY = tonumber(tbRowData.Y), nReactNpcId = nReactNpcId});
	end
end

function Domain:LoadBossNpcPos()
	local tbFile = Lib:LoadTabFile(BOSS_POS_FILE);
	if tbFile then
		for _, tbRowData in pairs(tbFile) do
			local nMapId = tonumber(tbRowData.nMapId);
			local nTimes = tonumber(tbRowData.nTimes);
			if not self.tbBossPos[nMapId] then
				self.tbBossPos[nMapId] = {};
			end
			if not self.tbBossPos[nMapId][nTimes] then
				self.tbBossPos[nMapId][nTimes] = {};
			end
			table.insert(self.tbBossPos[nMapId][nTimes], 
				{nTemplateId = tonumber(tbRowData.nTemplateId), nX = tonumber(tbRowData.nX), nY = tonumber(tbRowData.nY)});
		end
	end
end

Domain:LoadDomainSetting();

