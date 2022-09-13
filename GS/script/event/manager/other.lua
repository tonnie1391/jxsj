-- 文件名  : other.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-09 16:14:14
-- 描述    : 

if  MODULE_GAMESERVER then
	
EventManager.tbOther = EventManager.tbOther or {};
local tbAddEquitList = EventManager.tbOther;
tbAddEquitList.szFileName = "\\setting\\event\\manager\\other\\equitlist.txt";
tbAddEquitList.szSpecialEquitFileName = "\\setting\\event\\manager\\other\\specialequitlist.txt";

function tbAddEquitList:Load(szFileName)
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【AddEquit】读取文件错误，文件不存在", szFileName);
		return;
	end
	self.tbEquitList = {};	
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local nFaction = tonumber(tbParam.Faction) or 0;
			local nRoutId = tonumber(tbParam.RoutId) or 0;
			local nPartId = tonumber(tbParam.PartId) or 0;
			local nSex = tonumber(tbParam.Sex) or 0;
			local nGenre  = tonumber(tbParam.Genre) or 0;
			local nDetailType = tonumber(tbParam.DetailType) or 0;
			local nParticularType = tonumber(tbParam.ParticularType) or 0;
			local nLevel = tonumber(tbParam.Level) or 0;			
			if nFaction ~= 0 and nRoutId ~= 0 and nSex ~= 0 and nPartId ~= 0 then
				self.tbEquitList[nFaction] = self.tbEquitList[nFaction] or {};
				self.tbEquitList[nFaction][nRoutId] = self.tbEquitList[nFaction][nRoutId] or {};
				self.tbEquitList[nFaction][nRoutId][nSex] = self.tbEquitList[nFaction][nRoutId][nSex] or {};
				self.tbEquitList[nFaction][nRoutId][nSex][nPartId] = self.tbEquitList[nFaction][nRoutId][nSex][nPartId] or {};
				if nGenre ~= 0 and nDetailType ~= 0 and nParticularType ~= 0 and nLevel ~= 0 then
					self.tbEquitList[nFaction][nRoutId][nSex][nPartId] = {nGenre, nDetailType, nParticularType, nLevel};
				end
			end
		end
	end	
end

EventManager.tbOther:Load(EventManager.tbOther.szFileName);

function tbAddEquitList:LoadSpecialEquit(szFileName)
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【AddEquit】读取文件错误，文件不存在", szFileName);
		return;
	end
	self.tbSpecialEquitList = {};
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local nType = tonumber(tbParam.Type) or 0;
			local nTypeEx = tonumber(tbParam.TypeEx) or 0;
			local nSeries = tonumber(tbParam.Series) or 0;
			local nSex = tonumber(tbParam.Sex) or 0;
			local nGenre  = tonumber(tbParam.Genre) or 0;
			local nDetailType = tonumber(tbParam.DetailType) or 0;
			local nParticularType = tonumber(tbParam.ParticularType) or 0;
			local nLevel = tonumber(tbParam.Level) or 0;
			if nType ~= 0 and nTypeEx ~= 0 and nSeries ~= 0 and nSex ~= 0 then
				self.tbSpecialEquitList[nType] = self.tbSpecialEquitList[nType] or {};
				self.tbSpecialEquitList[nType][nTypeEx] = self.tbSpecialEquitList[nType][nTypeEx] or {};
				self.tbSpecialEquitList[nType][nTypeEx][nSeries] = self.tbSpecialEquitList[nType][nTypeEx][nSeries] or {};
				self.tbSpecialEquitList[nType][nTypeEx][nSeries][nSex] = self.tbSpecialEquitList[nType][nTypeEx][nSeries][nSex] or {};
				if nGenre ~= 0 and nDetailType ~= 0 and nParticularType ~= 0 and nLevel ~= 0 then
					self.tbSpecialEquitList[nType][nTypeEx][nSeries][nSex] = {nGenre, nDetailType, nParticularType, nLevel};
				end
			end
		end
	end	
end

EventManager.tbOther:LoadSpecialEquit(EventManager.tbOther.szSpecialEquitFileName);
----------------------------------------------------------------------------------------------------------
--Add Npc

local tbAddNpcList = EventManager.tbOther;
tbAddNpcList.tbNpc = {};
tbAddNpcList.tbNpcId = {};

function tbAddNpcList:AddNpc(nNpcId, szName, nMapId, nPosX, nPosY, nLiveTime, bIsNew, nNum)
	if SubWorldID2Idx(nMapId) >= 0 then
		local pNpc = KNpc.Add2(nNpcId, 100, -1, nMapId, nPosX, nPosY, 0, 0);
		if pNpc then
			if nLiveTime and nLiveTime > 0 then				
				pNpc.SetLiveTime(nLiveTime * Env.GAME_FPS);
			end
			if szName and szName ~= "" then
				pNpc.szName = szName;
			end
			local tbInfo = {nNpcId, szName, nMapId, nPosX, nPosY, nLiveTime, GetTime()};
			GCExcute({"EventManager.tbOther:SaveBuff_GC", tbInfo, pNpc.dwId, GetServerId(), bIsNew, nNum});
		end
	end	
end

function tbAddNpcList:LoadBuff_GS()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_KE_ADDNPC, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbNpc = tbBuffer;
	end
end


function tbAddNpcList:DeleteNpc(nServerId, dwNpcId)
	if GetServerId() == nServerId then
		local pNpc = KNpc.GetById(dwNpcId);
		if pNpc then
			pNpc.Delete();
		end
	end
end

--启动重加npc
function tbAddNpcList:SeverStart()
	self:LoadBuff_GS();	
	GCExcute({"EventManager.tbOther:ReStart", GetServerId()});
	for i, tbNpcInfo in pairs(self.tbNpc) do
		if tbNpcInfo[6] and tbNpcInfo[6]  > 0 then
			local nTime = GetTime() - tbNpcInfo[7];
			if nTime > 0 and nTime < tbNpcInfo[6] then
				self:AddNpc(tbNpcInfo[1], tbNpcInfo[2], tbNpcInfo[3], tbNpcInfo[4], tbNpcInfo[5], tbNpcInfo[6] - nTime, nil, i);
			end
		else
			self:AddNpc(tbNpcInfo[1], tbNpcInfo[2], tbNpcInfo[3], tbNpcInfo[4], tbNpcInfo[5], tbNpcInfo[6], nil, i);
		end
	end
end

ServerEvent:RegisterServerStartFunc(EventManager.tbOther.SeverStart, EventManager.tbOther);

end

if  MODULE_GC_SERVER then
EventManager.tbOther = EventManager.tbOther or {};
local tbAddNpcList = EventManager.tbOther;
tbAddNpcList.tbNpc = {};
tbAddNpcList.tbNpcId = {};

--存储buf
function tbAddNpcList:SaveBuff_GC(tbInfo, nNpcId, nServerId, bIsNew, nNum)
	if bIsNew then
		table.insert(self.tbNpc, tbInfo);
		SetGblIntBuf(GBLINTBUF_KE_ADDNPC, 0, 1, self.tbNpc);
		GlobalExcute({"EventManager.tbOther:LoadBuff_GS"});
	end
	self.tbNpcId[nServerId] = self.tbNpcId[nServerId] or {};
	if nNum and nNum > 0 then
		self.tbNpcId[nServerId][nNpcId] = nNum;
	else
		self.tbNpcId[nServerId][nNpcId] = #self.tbNpc;
	end
end

function tbAddNpcList:LoadBuff_GC()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_KE_ADDNPC, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbNpc = tbBuffer;
	end
end

--gs重启重置gc记录的id
function tbAddNpcList:ReStart(nServerId)
	self.tbNpcId[nServerId] = {};
end

function tbAddNpcList:DelNpc(nServerId, nNpcId)	
	local nNum = self.tbNpcId[nServerId][nNpcId];
	self.tbNpc[nNum] = {};
	self.tbNpcId[nServerId][nNpcId] = nil;
	SetGblIntBuf(GBLINTBUF_KE_ADDNPC, 0, 1, self.tbNpc);
	GlobalExcute({"EventManager.tbOther:LoadBuff_GS"});
	return GlobalExcute({"EventManager.tbOther:DeleteNpc", nServerId, nNpcId});
end

function tbAddNpcList:AddNpc(nNpcId, szName, nMapId, nPosX, nPosY, nLiveTime)
	if not nNpcId or nNpcId <= 0 or not nMapId and nMapId <= 0 or not nPosX or nPosX <= 0 or not nPosY or nPosY <= 0 then
		return "参数不正确";
	end
	return GlobalExcute({"EventManager.tbOther:AddNpc", nNpcId, szName, nMapId, nPosX, nPosY, nLiveTime, 1});
end

--关机事件，整理buff
function tbAddNpcList:ShutDown()
	local tbDel = {};
	for nKey, tbNpcInfo in pairs(self.tbNpc) do
		if tbNpcInfo[6] and tbNpcInfo[6]  > 0 then
			local nTime = GetTime() - tbNpcInfo[7];
			if nTime > 0 and nTime >= tbNpcInfo[6] then
				table.insert(tbDel, 1, nKey);
			end
		elseif #tbNpcInfo == 0 then
			table.insert(tbDel, 1, nKey);
		end
	end
	for i, nKey in ipairs(tbDel) do
		self.tbNpc[nKey] = nil;
	end
	SetGblIntBuf(GBLINTBUF_KE_ADDNPC, 0, 1, self.tbNpc);
end

GCEvent:RegisterGCServerStartFunc(EventManager.tbOther.LoadBuff_GC, EventManager.tbOther)
GCEvent:RegisterGCServerShutDownFunc(EventManager.tbOther.ShutDown, EventManager.tbOther)
end
