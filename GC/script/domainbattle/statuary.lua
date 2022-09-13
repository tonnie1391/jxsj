-- 领土战雕像
-- 2009-6-15 10:59:45
-- zhouchenfei

Domain.tbStatuary = {};
local tbStatuary = Domain.tbStatuary;

tbStatuary.TYPE_EVENT_NORMAL	= 1;
tbStatuary.TYPE_EVENT_GBWLLS	= 2000; -- 为跨服联赛点的标记，这1000个标记位置已经占了

tbStatuary.TSKGROUPID = 2097;
tbStatuary.TSKID_FLAG = 19;
tbStatuary.TSKID_FUDAINOGIVE = 20;

tbStatuary.INFOID_PLAYERNAME	= 1;
tbStatuary.INFOID_REVERE		= 2;
tbStatuary.INFOID_ENDURE		= 3;
tbStatuary.INFOID_NPCID			= 4;
tbStatuary.INFOID_STATUARYINDEX	= 5;
tbStatuary.INFOID_ADDTIME		= 6;
tbStatuary.INFOID_EVENTTYPE		= 7;

tbStatuary.MAX_ENDURE			= 10000;
tbStatuary.DEC_ENDURE_WORSHIP	= 1;
tbStatuary.DEC_ENDURE_SPIT		= 1;
tbStatuary.INC_REVERE			= 1;
tbStatuary.NPCID_BROKEN			= 3678;
tbStatuary.NPC_LEVEL_BROKEN		= 50;
tbStatuary.STATE_TIME			= 60 * 60 * 24 * 30; -- 30天

tbStatuary.TYPE_REVERE_NORMAL	= 1;
tbStatuary.TYPE_REVERE_GBWLLS	= 2;

tbStatuary.STATUARY_PLACE_PATH			= "\\setting\\domainbattle\\statuaryplace.txt";
tbStatuary.STATUARY_NPCSETTING_PATH		= "\\setting\\domainbattle\\statuarynpc.txt";

tbStatuary.NPC_LEVEL_ENDURE		= {
		{3000, 100},
		{6000, 120},
		{10000, 150},
	};

-- {{nMapId, nX, nY,nId, nLevel, nTime},{playername, revere, endure, nNpcId, nStatuaryId, nAddTime}}

function tbStatuary:Init()
	self.tbStatuData	= {};
	self.tbNpcSetting	= {};
	if (MODULE_GAMESERVER) then
		self:LoadNpcSetting();
	end
	self:LoadStatuaryNpcPlace();
end

function tbStatuary:GetRevereType(nEventType)
	-- 开门任务雕像
	if (self.TYPE_EVENT_NORMAL == nEventType) then
		return self.TYPE_REVERE_NORMAL;
	end
	
	-- 跨服联赛雕像
	if (self.TYPE_EVENT_GBWLLS <= nEventType and self.TYPE_EVENT_GBWLLS + 1000 > nEventType) then
		return self.TYPE_REVERE_GBWLLS;
	end
	return 0;
end

function tbStatuary:LoadStatuaryNpcPlace()
	local tbData		= Lib:LoadTabFile(self.STATUARY_PLACE_PATH);
	if (not tbData) then
		return;
	end
	local tbPList		= {};
	for _, tbRow in ipairs(tbData) do
		local nMapId	= tonumber(tbRow["MAP_ID"]);
		local nX		= tonumber(tbRow["MAP_X"]);
		local nY		= tonumber(tbRow["MAP_Y"]);
		local nEventType= tonumber(tbRow["EVENT_TYPE"]) or self.TYPE_EVENT_NORMAL;
		local tbInfo	= {};
		tbInfo.tbNpcInfo	= {};
		tbInfo.tbPlayerInfo	= {};
		tbInfo.tbNpcInfo.nMapId = nMapId;
		tbInfo.tbNpcInfo.nX		= math.floor(nX/32);
		tbInfo.tbNpcInfo.nY		= math.floor(nY/32);
		tbInfo.tbNpcInfo.nLevel	= 0;
		tbInfo.tbNpcInfo.nId	= 0;
		tbInfo.tbNpcInfo.nTimeId= 0;
		tbInfo.tbNpcInfo.nEventType = nEventType;
		tbPList[#tbPList + 1]	= tbInfo;
	end
	self.tbStatuData = tbPList;
end

function tbStatuary:LoadNpcSetting()
	local tbData		= Lib:LoadTabFile(self.STATUARY_NPCSETTING_PATH);
	if (not tbData) then
		return;
	end
	local tbPList		= {};
	for _, tbRow in ipairs(tbData) do
		local nNpcId		= tonumber(tbRow["NPCID"]);
		local nSex			= tonumber(tbRow["SEX"]);
		local nFactionId	= tonumber(tbRow["FACTION"]);
		if (not tbPList[nFactionId]) then
			tbPList[nFactionId] = {};
		end
		tbPList[nFactionId][nSex]	= nNpcId;
	end
	self.tbNpcSetting = tbPList;
end

function tbStatuary:OnRecConnectEvent(nConnectId)
	self:WriteLog("tbStatuary:OnRecConnectEvent", nConnectId);
	GSExcute(nConnectId, {"Domain.tbStatuary:LoadStatuaryInfo", self.tbStatuData});
end

function tbStatuary:LoadStatuaryInfo(tbStatuData)
	if (not self.tbStatuData) then
		self:WriteLog("tbStatuary:LoadStatuaryInfo()", "There is no tbStatuData");
		return;
	end
	
	local nCurDay = tonumber(os.date("%Y%m%d", GetTime()));
	if (MODULE_GC_SERVER) then
		local tbLoadBuf = GetGblIntBuf(GBLINTBUF_DOMAINSTATUARY, 0);
		if (not tbLoadBuf) then
			return;
		end
		
		local nSaveFlag = 0;
		local tbNoPlaceStatuary = {}; -- 保存那些还没有位置的雕像
		for _, tbInfo in ipairs(tbLoadBuf) do
			if (tbInfo[self.INFOID_PLAYERNAME] and tbInfo[self.INFOID_PLAYERNAME] ~= "") then
				-- 将崇敬度更新到玩家的playermanager上
				if (tbInfo[self.INFOID_REVERE] and tbInfo[self.INFOID_REVERE] > 0) then
					local szPlayerName = tbInfo[self.INFOID_PLAYERNAME];
					local nType	= self:GetRevereType(tbInfo[self.INFOID_EVENTTYPE]);
					local nOrgRevere = self:GetPlayerRevereByName(szPlayerName, nType);
					if (nOrgRevere <= 0) then
						self:SetPlayerRevereByName(szPlayerName, nType, tbInfo[self.INFOID_REVERE]);
						nSaveFlag = 1;
						self:WriteLog("LoadStatuaryInfo", "UpdatePlayerRevere", szPlayerName, string.format("OrgRevere: %d, SetRevere: %d", nOrgRevere, tbInfo[self.INFOID_REVERE]));
						tbInfo[self.INFOID_REVERE] = 0;
					end
				end
				
				local nId = 0;
				for i, tbIn in ipairs(self.tbStatuData) do
					if (not tbIn.tbPlayerInfo or not tbIn.tbPlayerInfo[self.INFOID_PLAYERNAME]) then
						if (tbIn.tbNpcInfo and tbIn.tbNpcInfo.nEventType and tbIn.tbNpcInfo.nEventType == tbInfo[self.INFOID_EVENTTYPE]) then
							nId = i;
							break;
						end
					end
				end
				if (nId > 0) then
					tbInfo[self.INFOID_STATUARYINDEX] = nId;
					self.tbStatuData[nId].tbPlayerInfo = tbInfo;
				else
					tbNoPlaceStatuary[#tbNoPlaceStatuary + 1] = tbInfo;
				end
			end
		end
		
		if (#tbNoPlaceStatuary > 0) then
			for i, tbInfo in ipairs(tbNoPlaceStatuary) do
				local nIndex = #self.tbStatuData + 1;
				tbInfo[self.INFOID_STATUARYINDEX] = nIndex;
				self.tbStatuData[nIndex] = {};
				self.tbStatuData[nIndex].tbPlayerInfo = tbInfo;
			end
		end
		
		-- 结构重组需要重新保存
		if (1 == nSaveFlag) then
			self:SaveStatuaryInfo();
		end
	end

	if (MODULE_GAMESERVER) then
		for nIndex, tbInfo in pairs(tbStatuData) do
			if (not self.tbStatuData[nIndex]) then
				self.tbStatuData[nIndex] = {};
			end

			self.tbStatuData[nIndex].tbPlayerInfo = tbInfo.tbPlayerInfo;
		end
	end
	
end

function tbStatuary:OnServerStartAddNpc()
	if (not self.tbStatuData) then
		self:WriteLog("OnServeStartAddNpc()", "There is no tbStatuData");
		return;
	end	
	for nIndex, tbInfo in pairs(self.tbStatuData) do
		local tbResInfo = self:AddNpc(tbInfo);
		self.tbStatuData[nIndex] = tbResInfo;
	end
end

function tbStatuary:SaveStatuaryInfo(nSaveFlag)
	if (not self.tbStatuData) then
		self:WriteLog("tbStatuary:SaveStatuaryInfo()", "There is no tbStatuData");
		return;
	end	

	if (MODULE_GAMESERVER) then
		if (not nSaveFlag or nSaveFlag ~= 1) then
			GCExcute({"Domain.tbStatuary:SaveStatuaryInfo"});
			return;			
		end
	end
	if (MODULE_GC_SERVER) then
		local tbSaveBuf = {};
		for nId, tbInfo in pairs(self.tbStatuData) do
			if (tbInfo.tbPlayerInfo and tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] and tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] ~= "") then
				tbInfo.tbPlayerInfo[self.INFOID_STATUARYINDEX] = nId;
				tbSaveBuf[#tbSaveBuf + 1] = tbInfo.tbPlayerInfo;
			end
		end
		SetGblIntBuf(GBLINTBUF_DOMAINSTATUARY, 0, 1, tbSaveBuf);
	end
end

-- 检查是否有树雕像的资格
-- 1.表示只有资格还没立，2.表示已经树立雕像的，3.表示有资格没雕像位置的
function tbStatuary:CheckStatuaryState(szName, nEventType)
	if (not szName) then
		return 0;
	end

	if (not self.tbStatuData or #self.tbStatuData <= 0) then
		return 0;
	end
	for _, tbInfo in pairs(self.tbStatuData) do
		if (tbInfo.tbPlayerInfo) then
			if (tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] and tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] == szName) then
				local nType = tbInfo.tbPlayerInfo[self.INFOID_EVENTTYPE] or 0;
				if (nType == nEventType) then
					if (tbInfo.tbPlayerInfo[self.INFOID_NPCID] > 0) then
						return 2;
					end
					if (not tbInfo.tbNpcInfo) then
						return 3;
					end
					
					return 1;
				end
			end
		end
	end
	return 0;
end

-- 添加树立雕像的资格
function tbStatuary:AddStatuaryCompetence(szName, nEventType)
	if (not szName) then
		return 0;
	end

	if (self:GetStatuaryComInfoByName(szName, nEventType)) then
		self:WriteLog("AddStatuaryCompetence", szName, "statury is exist", nEventType);
		return 0;
	end

	local tbPlayerInfo = {};
	tbPlayerInfo[self.INFOID_PLAYERNAME]	= szName;
	tbPlayerInfo[self.INFOID_REVERE]		= 0;
	tbPlayerInfo[self.INFOID_ENDURE]		= 0;
	tbPlayerInfo[self.INFOID_STATUARYINDEX]	= 0;
	tbPlayerInfo[self.INFOID_ADDTIME]		= 0;
	tbPlayerInfo[self.INFOID_NPCID]			= 0;
	tbPlayerInfo[self.INFOID_EVENTTYPE]		= nEventType or 0;

	local nPos = 0;	
	for nId, tbInfo in pairs(self.tbStatuData) do
		-- 表示还没插入过
		if (not tbInfo.tbPlayerInfo or not tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME]) then
			if (tbInfo.tbNpcInfo and tbInfo.tbNpcInfo.nEventType and tbInfo.tbNpcInfo.nEventType == tbPlayerInfo[self.INFOID_EVENTTYPE]) then
				nPos = nId;
				break;
			end
		end
	end
	
	if (nPos > 0) then
		tbPlayerInfo[self.INFOID_STATUARYINDEX] = nPos
		self.tbStatuData[nPos].tbPlayerInfo = tbPlayerInfo;
	else
		local tbInfo = {};
		tbPlayerInfo[self.INFOID_STATUARYINDEX] = #self.tbStatuData + 1;
		tbInfo.tbPlayerInfo = tbPlayerInfo;
		self.tbStatuData[#self.tbStatuData + 1] = tbInfo;
	end

	self:UpdateStatuaryData(tbPlayerInfo);
	self:SaveStatuaryInfo();
	self:WriteLog("AddStatuaryCompetence", szName, "Add statury Competence success", nEventType);
	
	return 1;
end

function tbStatuary:ApplyAddStatuaryCompetence(szName, nEventType)
	if (not MODULE_GAMESERVER) then
		return 0;
	end
	
	if (not szName) then
		return 0;
	end

	-- 已经有资格了就不能给资格了，目前的机制是这样
	local tbInfo = self:GetStatuaryComInfoByName(szName, nEventType);
	if (tbInfo) then
		return 0;
	end	
	
	GCExcute{"Domain.tbStatuary:AddStatuaryCompetence", szName, nEventType};
	return 1;
end

-- 添加树立雕像的资格
-- 这里一定要注意雕像删除情况
function tbStatuary:DelStatuaryCompetence(szName, nEventType, nSaveFlag)
	if (not szName) then
		return 0;
	end

	for nId, tbInfo in pairs(self.tbStatuData) do
		-- 表示还没插入过
		if (tbInfo.tbPlayerInfo and 
			tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] and 
			tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] == szName and 
			tbInfo.tbPlayerInfo[self.INFOID_EVENTTYPE] == nEventType) then
			tbInfo.tbPlayerInfo = {};
			-- tbInfo.tbPlayerInfo[self.INFOID_STATUARYINDEX] = nId;
			self.tbStatuData[nId] = tbInfo;
			self:WriteLog("DelStatuaryCompetence", szName, "Del statury Competence success", nEventType);
			break;
		end
	end

	if (MODULE_GAMESERVER) then
		if (not nSaveFlag or nSaveFlag ~= 1) then
			GCExcute({"Domain.tbStatuary:DelStatuaryCompetence", szName, nEventType});
			return;			
		end
	end

	if (MODULE_GC_SERVER) then
		self:SaveStatuaryInfo();
		GlobalExcute({"Domain.tbStatuary:DelStatuaryCompetence", szName, nEventType, 1});
	end
	return 0;
end

-- 树立雕像gs
function tbStatuary:AddStatuary(szName, nEventType, nFaction, nSex, szMsg)
	if (not szName) then
		return 0;
	end
	
	for nId, tbInfo in pairs(self.tbStatuData) do
		-- 表示还没插入过
		if (tbInfo.tbPlayerInfo and 
			tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] and 
			tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] == szName and
			tbInfo.tbNpcInfo and
			tbInfo.tbNpcInfo.nMapId > 0 and
			tbInfo.tbNpcInfo.nX > 0 and
			tbInfo.tbNpcInfo.nY > 0 and
			tbInfo.tbNpcInfo.nEventType == nEventType) then
			tbInfo.tbPlayerInfo[self.INFOID_REVERE]			= 0;
			tbInfo.tbPlayerInfo[self.INFOID_ENDURE]			= self.MAX_ENDURE;
			tbInfo.tbPlayerInfo[self.INFOID_STATUARYINDEX]	= nId;
			tbInfo.tbPlayerInfo[self.INFOID_ADDTIME]		= 0;
			tbInfo.tbPlayerInfo[self.INFOID_NPCID]			= self:GetNpcId(nFaction, nSex);
			tbInfo.tbPlayerInfo[self.INFOID_EVENTTYPE]		= nEventType or 0;
			self:UpdateStatuaryData(tbInfo.tbPlayerInfo);
			tbInfo = self:AddNpc(tbInfo);
			self.tbStatuData[nId] = tbInfo;
			self:SaveStatuaryInfo();
			if (not szMsg) then
				szMsg = string.format("%s的雕像树立在临安城", tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME]);
			end
			KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
			self:AddHelpNews_Statuary(szName, nEventType);
			return 1;
		end
	end
	return 0;
end

function tbStatuary:AddNpc(tbInfo)
	if (not tbInfo) then
		self:WriteLog("AddNpc", "there is no tbInfo");
		return tbInfo;
	end
	
	if (not tbInfo.tbPlayerInfo) then
		self:WriteLog("AddNpc", "there is no tbInfo.tbPlayerInfo");
		return tbInfo;
	end
	
	if (not tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME]) then
		self:WriteLog("AddNpc", "there is no tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME]");
		return tbInfo;
	end
	
	if (tbInfo.tbPlayerInfo[self.INFOID_NPCID] <= 0) then
		self:WriteLog("AddNpc", "the statuary have not build before");
		return tbInfo;
	end
	
	if (not tbInfo.tbNpcInfo) then
		self:WriteLog("AddNpc", "the statuary have not place for statuary", tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME]);
		return tbInfo;
	end	
	
	local nNpcId = tbInfo.tbPlayerInfo[self.INFOID_NPCID];

	if (tbInfo.tbNpcInfo.nTimeId and tbInfo.tbNpcInfo.nTimeId > 0) then
		Timer:Close(tbInfo.tbNpcInfo.nTimeId);
		tbInfo.tbNpcInfo.nTimeId = 0;
	end	

	local nNowTime	= GetTime();
	local nTime		= 0;

	if (not tbInfo.tbPlayerInfo[self.INFOID_ADDTIME]) then
		tbInfo.tbPlayerInfo[self.INFOID_ADDTIME] = 0;
	end
	-- 这种情况比较特殊
	if (tbInfo.tbPlayerInfo[self.INFOID_ENDURE] <= 0 and tbInfo.tbPlayerInfo[self.INFOID_ADDTIME] <= 0) then
		tbInfo.tbPlayerInfo[self.INFOID_ADDTIME] = nNowTime;
	end

	if (tbInfo.tbPlayerInfo[self.INFOID_ADDTIME] > 0) then
		nTime = self.STATE_TIME - (nNowTime - tbInfo.tbPlayerInfo[self.INFOID_ADDTIME]);
		if (nTime > self.STATE_TIME) then
			nTime = self.STATE_TIME;
		end
		
		if (nTime <= 0) then
			self:DelStatuary(tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME], tbInfo.tbPlayerInfo[self.INFOID_EVENTTYPE]);
			self:WriteLog("AddNpc", "there is statuary time out", nNpcId, tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME]);
			return tbInfo;
		end
	end

	
	local nNpcId	= 0;
	local nLevel	= self:GetNpcLevel(tbInfo.tbPlayerInfo[self.INFOID_ENDURE]);
	if (nLevel <= 0) then
		nNpcId	= self.NPCID_BROKEN;
		nLevel	= self.NPC_LEVEL_BROKEN;
	else
		nNpcId = tbInfo.tbPlayerInfo[self.INFOID_NPCID];
	end
	local tbNpcInfo = tbInfo.tbNpcInfo;
	
	local pNpc = KNpc.Add2(nNpcId, nLevel, 1, tbNpcInfo.nMapId, tbNpcInfo.nX, tbNpcInfo.nY);
	if (not pNpc) then
		self:WriteLog("AddNpc", "Create Statuary failed!", nNpcId, tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME]);
		return tbInfo;
	end

	if (tbInfo.tbPlayerInfo[self.INFOID_ENDURE] <= 0) then
		if (nTime > 0) then
			tbInfo.tbNpcInfo.nTimeId	= Timer:Register(nTime * Env.GAME_FPS, self.DelStatuary, self, tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME], tbInfo.tbPlayerInfo[self.INFOID_EVENTTYPE]);
		end
	end

	tbInfo.tbNpcInfo.nLevel		= nLevel;
	tbInfo.tbNpcInfo.nId		= pNpc.dwId;
	local tbTempDate = self:GetNpcTempTable(pNpc);
	tbTempDate.nEventType = tbInfo.tbNpcInfo.nEventType;
	pNpc.SetTitle(string.format("<color=yellow>%s<color>", tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME]));
	self:WriteLog("AddNpc", nNpcId, tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME], "Add Statuary Success", tbInfo.tbPlayerInfo[self.INFOID_EVENTTYPE]);
	return tbInfo;
end

function tbStatuary:DelNpc(tbInfo)
	if (not tbInfo) then
		return tbInfo;
	end
	
	if (not tbInfo.tbNpcInfo or not tbInfo.tbNpcInfo.nId) then
		return tbInfo;
	end

	local pNpc = KNpc.GetById(tbInfo.tbNpcInfo.nId or 0);

	if (not pNpc) then
		return tbInfo;
	end

	if (tbInfo.tbNpcInfo.nTimeId and tbInfo.tbNpcInfo.nTimeId > 0) then
		Timer:Close(tbInfo.tbNpcInfo.nTimeId);
		tbInfo.tbNpcInfo.nTimeId = 0;
	end
	
	tbInfo.tbNpcInfo.nLevel = 0;
	tbInfo.tbNpcInfo.nId	= 0;
	
	pNpc.Delete();
	
	return tbInfo;
end

function tbStatuary:GetNpcLevel(nEndure)
	if (nEndure <= 0) then
		return 0;
	end
	for _, tbInfo in ipairs(self.NPC_LEVEL_ENDURE) do
		if (nEndure <= tbInfo[1]) then
			return tbInfo[2];
		end
	end
	return 0;
end


function tbStatuary:RefreshStatuary(szName, nEventType)
	if (not szName) then
		return;
	end

	local tbResInfo = {};
	local nIndex	= 0;
	for nId, tbInfo in pairs(self.tbStatuData) do
		-- 表示还没插入过
		local tbPlayerInfo = tbInfo.tbPlayerInfo;
		if (tbPlayerInfo[self.INFOID_PLAYERNAME] and tbPlayerInfo[self.INFOID_PLAYERNAME] == szName and 
			(tbPlayerInfo[self.INFOID_EVENTTYPE] or 0) == nEventType) then
			tbResInfo	= tbInfo;
			nIndex		= nId;
			break;
		end
	end		
	
	if (not tbResInfo.tbPlayerInfo or not tbResInfo.tbNpcInfo) then
		return;
	end
	
	local nLevel = self:GetNpcLevel(tbResInfo.tbPlayerInfo[self.INFOID_ENDURE]);
	if (nLevel <= 0) then
		nLevel	= self.NPC_LEVEL_BROKEN;
	end
	if (nLevel == tbResInfo.tbNpcInfo.nLevel) then
		return;
	end
	
	tbResInfo = self:DelNpc(tbResInfo);
	tbResInfo = self:AddNpc(tbResInfo);
	self.tbStatuData[nIndex] = tbResInfo;
	return;
end

-- 现在因为只会在一个地方树立雕像，所以就暂时不同步到各个gs了
function tbStatuary:UpdateStatuaryData(tbPlayerInfo, nSaveFlag)
	if (not tbPlayerInfo) then
		self:WriteLog("UpdateStatuaryData", "there is not tbPlayerInfo");
		return 0;
	end

	if (MODULE_GAMESERVER) then
		if (not nSaveFlag or nSaveFlag ~= 1) then
			GCExcute({"Domain.tbStatuary:UpdateStatuaryData", tbPlayerInfo});
			return;			
		end
	end

	if (not self.tbStatuData) then
		self.tbStatuData = {};
	end

	if (not self.tbStatuData[tbPlayerInfo[self.INFOID_STATUARYINDEX]]) then
		self.tbStatuData[tbPlayerInfo[self.INFOID_STATUARYINDEX]] = {};
	end
	self.tbStatuData[tbPlayerInfo[self.INFOID_STATUARYINDEX]].tbPlayerInfo = tbPlayerInfo;
	if (MODULE_GC_SERVER) then
		GlobalExcute({"Domain.tbStatuary:UpdateStatuaryData", tbPlayerInfo, 1});
	end
end

function tbStatuary:GetNpcId(nFaction, nSex)
	if (not self.tbNpcSetting) then
		return 0;
	end
	
	if (not self.tbNpcSetting[nFaction]) then
		return 0;
	end
	
	if (not self.tbNpcSetting[nFaction][nSex]) then
		return 0;
	end
	return self.tbNpcSetting[nFaction][nSex];
end

-- 雕像删除了，资格还在，可以继续树立雕像
function tbStatuary:DelStatuary(szName, nEventType, nSaveFlag)
	if (not szName) then
		return;
	end

	for nId, tbInfo in pairs(self.tbStatuData) do
		-- 表示还没插入过
		local tbPlayerInfo = tbInfo.tbPlayerInfo;
		if (tbPlayerInfo[self.INFOID_PLAYERNAME] and tbPlayerInfo[self.INFOID_PLAYERNAME] == szName and tbPlayerInfo[self.INFOID_EVENTTYPE] == nEventType) then
			if (MODULE_GAMESERVER) then
				tbInfo = self:DelNpc(tbInfo);
			end
			tbInfo.tbPlayerInfo[self.INFOID_REVERE]			= 0;
			tbInfo.tbPlayerInfo[self.INFOID_ENDURE]			= 0;
			tbInfo.tbPlayerInfo[self.INFOID_ADDTIME]		= 0;
			tbInfo.tbPlayerInfo[self.INFOID_NPCID]			= 0;
			self.tbStatuData[nId] = tbInfo;
			break;
		end
	end

	if (MODULE_GAMESERVER) then
		if (not nSaveFlag or nSaveFlag ~= 1) then
			GCExcute({"Domain.tbStatuary:DelStatuary", szName, nEventType or 0});
			return;			
		end
		KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, string.format("%s的雕像消失了", szName));
	end

	if (MODULE_GC_SERVER) then
		self:SaveStatuaryInfo();
		GlobalExcute({"Domain.tbStatuary:DelStatuary", szName, nEventType or 0, 1});
	end

end

function tbStatuary:GetNpcBelongWho(nNpcId, nEventType)
	if (not self.tbStatuData or #self.tbStatuData <= 0) then
		return;
	end
	
	for _, tbInfo in pairs(self.tbStatuData) do
		if (tbInfo.tbNpcInfo) then
			if (tbInfo.tbNpcInfo.nId > 0 and tbInfo.tbNpcInfo.nId == nNpcId and tbInfo.tbNpcInfo.nEventType == nEventType) then
				if (tbInfo.tbPlayerInfo) then
					return tbInfo.tbPlayerInfo[1];
				end
				break;
			end
		end
	end
	return;
end

function tbStatuary:SetStatuaryValueByName(szName, nEventType, nId, Value, nSaveFlag)
	if (not szName) then
		return;
	end

	local tbInfo = self:GetStatuaryInfoByName(szName, nEventType);

	if (tbInfo) then
		tbInfo.tbPlayerInfo[nId] = Value;
	end	
	
	if (MODULE_GAMESERVER) then
		if (not nSaveFlag or nSaveFlag <= 0) then
			GCExcute({"Domain.tbStatuary:SetStatuaryValueByName", szName, nEventType, nId, Value});
			return 0;
		end
	end
	
	if (MODULE_GC_SERVER) then
		GlobalExcute({"Domain.tbStatuary:SetStatuaryValueByName", szName, nEventType, nId, Value, 1});
	end
end

function tbStatuary:GetStatuaryValueByName(szName, nEventType, nId)	
	if (not szName) then
		return;
	end

	local tbInfo = self:GetStatuaryInfoByName(szName, nEventType);
	if (tbInfo and tbInfo.tbPlayerInfo[nId]) then
		return tbInfo.tbPlayerInfo[nId];
	end
	return;
end

-- 判断是否已经有资格了，同一类型的雕像资格不能重复
function tbStatuary:GetStatuaryComInfoByName(szName, nEventType)
	if (not szName) then
		return;
	end

	if (not self.tbStatuData or #self.tbStatuData <= 0) then
		return;
	end
	for _, tbInfo in pairs(self.tbStatuData) do
		if (tbInfo.tbPlayerInfo) then
			if (tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] and 
				tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] == szName and
				tbInfo.tbPlayerInfo[self.INFOID_EVENTTYPE] == nEventType) then
				return tbInfo;
			end
		end
	end
	return;
end

function tbStatuary:GetStatuaryInfoByName(szName, nEventType)
	if (not szName) then
		return;
	end

	if (not self.tbStatuData or #self.tbStatuData <= 0) then
		return;
	end
	for _, tbInfo in pairs(self.tbStatuData) do
		if (tbInfo.tbPlayerInfo) then
			if (tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] and 
				tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] == szName and
				tbInfo.tbPlayerInfo[self.INFOID_NPCID] > 0 and
				tbInfo.tbPlayerInfo[self.INFOID_EVENTTYPE] == nEventType) then
				return tbInfo;
			end
		end
	end
	return;
end

function tbStatuary:DecreaseEndure(szName, nEventType, nDEndure)
	if (not szName) then
		return;
	end
	
	local nEndure	= self:GetEndure(szName, nEventType) - nDEndure;
	if (nEndure < 0) then
		nEndure = 0;
	end

	self:SetStatuaryValueByName(szName, nEventType, self.INFOID_ENDURE, nEndure);

	if (nEndure <= 0) then
		local nTime = self:GetStatuaryValueByName(szName, nEventType, self.INFOID_ADDTIME);
		if (nTime <= 0) then
			self:SetStatuaryValueByName(szName, nEventType, self.INFOID_ADDTIME, GetTime());
		end
	end

	self:RefreshStatuary(szName, nEventType);
end

function tbStatuary:IncreaseEndure(szName, nEventType, nDEndure, nEffectFlag)
	if (not szName) then
		return;
	end

	local nEndure	= self:GetEndure(szName, nEventType) + nDEndure;
	if (nEndure > self.MAX_ENDURE) then
		nEndure = self.MAX_ENDURE;
	end
	self:SetStatuaryValueByName(szName, nEventType, self.INFOID_ENDURE, nEndure);

	if (nEndure > 0) then
		local nTime = self:GetStatuaryValueByName(szName, nEventType, self.INFOID_ADDTIME);
		if (nTime > 0) then
			self:SetStatuaryValueByName(szName, nEventType, self.INFOID_ADDTIME, 0);
		end
	end	
	
	self:RefreshStatuary(szName, nEventType);
	
	if (not nEffectFlag or nEffectFlag <= 0) then
		return;
	end
	
	local tbInfo = self:GetStatuaryInfoByName(szName, nEventType);
	if (not tbInfo) then
		return;
	end
	
	local dwId	= tbInfo.tbNpcInfo.nId;
	local pNpc	= KNpc.GetById(dwId);
	if (not pNpc) then
		return;
	end
	pNpc.CastSkill(306, 1, -1, pNpc.nIndex);
end

function tbStatuary:GetEndure(szName, nEventType)
	if (not szName) then
		return 0;
	end
	
	local nValue = self:GetStatuaryValueByName(szName, nEventType, Domain.tbStatuary.INFOID_ENDURE)
	if (not nValue) then
		nValue = 0;
	end
	return nValue;
end

function tbStatuary:DecreaseRevere(szName, nEventType, nDecRevere)
	if (not szName) then
		return;
	end	
	
	local nRevere	= self:GetRevere(szName, nEventType) - nDecRevere;
	if (nRevere < 0) then
		nRevere = 0;
	end
	local nType = self:GetRevereType(nEventType);
	self:SetPlayerRevereByName(szName, nType, nRevere);
end

function tbStatuary:IncreaseRevere(szName, nEventType, nAddRevere)
	if (not szName) then
		return;
	end
	
	local nRevere	= self:GetRevere(szName, nEventType) + nAddRevere;
	local nType = self:GetRevereType(nEventType);
	self:SetPlayerRevereByName(szName, nType, nRevere);
end

function tbStatuary:GetRevere(szName, nEventType)
	if (not szName) then
		return 0;
	end
	
	local nType = self:GetRevereType(nEventType);
	local nValue = self:GetPlayerRevereByName(szName, nType)
	if (not nValue) then
		nValue = 0;
	end
	return nValue;
end

function tbStatuary:GetStateTime(szName, nEventType)
	if (not szName) then
		return 0;
	end
	
	local nValue = self:GetStatuaryValueByName(szName, nEventType or 0, self.INFOID_ADDTIME)
	if (not nValue) then
		nValue = 0;
	end
	return nValue;
end

function tbStatuary:AddHelpNews_Statuary(szName, nEventType)
	if (self.TYPE_EVENT_NORMAL == nEventType) then
		local szTitle	= string.format("%s树立了雕像！", szName);
		local szMsg		= string.format("宁宗皇帝为表彰%s的卓越贡献，特授权为其树立雕像。\n", szName);
		szMsg = szMsg .. [[    雕像树立后，还将考验其在广大民众中的口碑和影响力。广大民众可以前往<link=npcpos:雕像,0,4470>处，对雕像膜拜或唾弃。
	    每个角色每天只能对雕像膜拜或唾弃一次。
	    膜拜之后，会获得奖励，同时提高雕像的崇敬度，降低雕像的耐久度。
	    唾弃之后，会降低雕像的耐久度。]];
	
		local nAddTime	= GetTime();
		local nEndTime	= nAddTime + 3600 * 24 * 60;
		Task.tbHelp:SetDynamicNews(Task.tbHelp.NEWSKEYID.NEWS_STATUARY, szTitle, szMsg, nEndTime, nAddTime);
	end
end

function tbStatuary:AddHelpNews_Result(tbTongInfo)
	local szTitle	= "霸主之战最终战况揭晓！";
	local szName	= KGblTask.SCGetDbTaskStr(DBTASK_BAZHUZHIYIN_MAX);
	local szMsg		= string.format("    霸主之战最终战况揭晓！\n    收集霸主之印最多的人：%s\n    为表彰%s在领土争夺战“霸主任务”中作出的杰出贡献，皇帝在宫中设下宴席，并特许百姓通过临安皇宫门前的礼部侍郎进入朝圣阁观礼。\n    请%s及朋友们前往临安府的<link=npcpos:礼部侍郎,0,4470>处，参加仪式\n收集霸主之印最多的10大帮会：\n", szName, szName, szName);
	
	for i, tbInfo in ipairs(tbTongInfo) do
		local szRank		= string.format("Hạng %d", i);
		szRank				= self:GetTabString(szRank, 12);
		local szTongName	= self:GetTabString(tbInfo.szTongName, 24);
		local szValue		= self:GetTabString(string.format("%d", tbInfo.nValue), 8);
		szMsg = string.format("%s%s%s%s\n", szMsg, szRank, szTongName, szValue);
	end

	local nAddTime	= GetTime();
	local nEndTime	= nAddTime + 3600 * 24 * 3;
	Task.tbHelp:SetDynamicNews(Task.tbHelp.NEWSKEYID.NEWS_DOMAINTASK, szTitle, szMsg, nEndTime, nAddTime);
end

function tbStatuary:GetTabString(szValue, nLen)
	local nVLen = string.len(szValue);
	local nDet  = nLen - nVLen;
	if (nDet <= 0) then
		return szValue;
	end
	for i=1, nDet do
		szValue = szValue .. " ";
	end
	return szValue;
end

function tbStatuary:ZoneMergeStatuary(tbNewStatData)
	print("GCEvent:ZoneMergeStatuary1 start ......");
	self.tbStatuData = {};
	self:LoadStatuaryNpcPlace();
	self:LoadStatuaryInfo();
	
	local tbNoPlacePlayerList = {};
	
	for _, tbInfo in pairs(tbNewStatData) do
		local nFindPlace = 0;
		
		if (tbInfo.tbPlayerInfo and tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] and tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME] ~= "") then
			print("SubZoneStatuary Name ", tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME], tbInfo.tbPlayerInfo[self.INFOID_EVENTTYPE]);
			for i, tbOInfo in pairs(self.tbStatuData) do
				if (not tbOInfo.tbPlayerInfo or not tbOInfo.tbPlayerInfo[self.INFOID_PLAYERNAME]) then
					if (tbOInfo.tbNpcInfo and tbOInfo.tbNpcInfo.nEventType == tbInfo.tbPlayerInfo[self.INFOID_EVENTTYPE]) then
						nFindPlace = i;
						break;
					end
				end
			end
	
			if (nFindPlace <= 0) then
				tbNoPlacePlayerList[#tbNoPlacePlayerList + 1] = tbInfo;
			else
				tbInfo.tbPlayerInfo[self.INFOID_STATUARYINDEX] = nFindPlace;
				self.tbStatuData[nFindPlace] = tbInfo;
			end
		end
	end
	for _, tbInfo in pairs(tbNoPlacePlayerList) do
		tbInfo.tbPlayerInfo[self.INFOID_STATUARYINDEX] = #self.tbStatuData + 1;
		self.tbStatuData[#self.tbStatuData + 1] = tbInfo;
	end
	self:SaveStatuaryInfo();
	print("GCEvent:ZoneMergeStatuary1 and .......");
end

function tbStatuary:GetNpcTempTable(pNpc)
	if (not pNpc) then
		return nil;
	end
	local tbTemp = pNpc.GetTempTable("Domain").tbStatuary;
	if (not tbTemp) then
		tbTemp = {};
		pNpc.GetTempTable("Domain").tbStatuary = tbTemp;
	end
	return tbTemp;
end

function tbStatuary:ClearGbWllsStatuary()
	if (not MODULE_GC_SERVER) then
		return 0;
	end
	local tbDelList = {};
	for _, tbInfo in pairs(self.tbStatuData) do
		if (tbInfo.tbPlayerInfo) then
			local nType = tbInfo.tbPlayerInfo[self.INFOID_EVENTTYPE];
			if (nType and nType > 0) then
				local nModeType = math.floor(nType / 1000);
				if (nModeType == 2) then
					tbDelList[#tbDelList + 1] = {tbInfo.tbPlayerInfo[self.INFOID_PLAYERNAME], tbInfo.tbPlayerInfo[self.INFOID_EVENTTYPE]};
				end
			end
		end
	end

	for _, tbInfo in pairs(tbDelList) do
		self:DelStatuary(tbInfo[1], tbInfo[2]);
		self:DelStatuaryCompetence(tbInfo[1], tbInfo[2]);
	end
end



function tbStatuary:SetPlayerRevereByName(szPlayerName, nType, nValue)
	if (not szPlayerName or not nType or nType <= 0 or not nValue) then
		return 0;
	end	
	
	if (MODULE_GAMESERVER) then
		GCExcute({"Domain.tbStatuary:SetPlayerRevereByName", szPlayerName, nType, nValue});
		return 1;
	end
	
	if (MODULE_GC_SERVER) then
		local nPlayerId = KGCPlayer.GetPlayerIdByName(szPlayerName);
		if (not nPlayerId) then
			return 0;
		end
		SetPlayerRevere(nPlayerId, nType, nValue);
		return 1;
	end

	return 1;
end

function tbStatuary:GetPlayerRevereByName(szPlayerName, nType)
	if (not szPlayerName or not nType or nType <= 0) then
		return 0;
	end
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if (not nPlayerId) then
		return 0;
	end
	return GetPlayerRevere(nPlayerId, nType);
end

tbStatuary:Init();

if (MODULE_GC_SERVER) then
	GCEvent:RegisterGCServerStartFunc(Domain.tbStatuary.LoadStatuaryInfo, Domain.tbStatuary);
	GCEvent:RegisterGCServerShutDownFunc(Domain.tbStatuary.SaveStatuaryInfo, Domain.tbStatuary);
end

if (MODULE_GAMESERVER) then
	ServerEvent:RegisterServerStartFunc(Domain.tbStatuary.OnServerStartAddNpc, Domain.tbStatuary);
end

function tbStatuary:WriteLog(...)
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Domain", "Statuary", unpack(arg));
	end
	if (MODULE_GAMECLIENT) then
		Dbg:Output("Domain", "Statuary", unpack(arg));
	end
	if (MODULE_GC_SERVER) then
		print("Domain", "Statuary", unpack(arg));
	end
end
