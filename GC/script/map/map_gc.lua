-- 文件名　：map_gc.lua
-- 创建者　：furuilei
-- 创建时间：2009-02-13 17:48:40

if MODULE_GC_SERVER then
	
Map.tbGCDynamicForbiden = { };
-- 新手村
Map.tbVillage	= {
	[1]  = 2154,
	[2]  = 2254,
	[3]  = 2255,
	[4]  = 2256,
	[5]  = 2257,
	[6]  = 2258,
	[7]  = 2259,
};
-- 新手村个数配置
Map.tbVillageCfg	= {
	{0, 7},
	{1, 3},
	{3, 2},
	{7, 1},
};

if (EventManager.IVER_bOpenTiFu == 1) then
Map.tbVillageCfg	= {
	{0, 7},
	{1, 7},
	{3, 7},
	{7, 7},
};
end

-- 允许显示的限制比例,当负载率低于这个值的时候才同步
Map.KD_VILLAGE_SHOW_LIMIT	= 0.95
-- 新手村服务器负载状态表
Map.tbVillageStateCfg	= {
	{0.95, 3},	-- 爆满
	{0.80, 2},	-- 很满
	{0.00, 1},	-- 良好
};

local tbGCDynamicForbiden = Map.tbGCDynamicForbiden;

function Map:LogMapPlayerCount()
	GlobalExcute{"Map:LogMapPlayerCount_GS"};
end

--动态注册地图禁用，成功返回1
function Map:GCRegisterForbiden(nMapId, szItemClass)
	if (tbGCDynamicForbiden[nMapId] == nil) then
		tbGCDynamicForbiden[nMapId] = { };
	end
	tbGCDynamicForbiden[nMapId][szItemClass] = 1;
	GlobalExcute({"Map:OnRegisterForbiden", nMapId, szItemClass});
	return 1;
end

--动态反注册地图禁用，成功返回1
function Map:GCUnregisterForbiden(nMapId, szItemClass)
	if (tbGCDynamicForbiden[nMapId] == nil) then
		return 0;
	end
	if (tbGCDynamicForbiden[nMapId][szItemClass] == nil) then
		return 0;
	end
	tbGCDynamicForbiden[nMapId][szItemClass] = nil;
	GlobalExcute({"Map:OnUnregisterForbiden", nMapId, szItemClass});
	return 1;
end

function Map:GCUpdateForbidenInfo()
	GlobalExcute({"Map:OnUpdateForbidenInfo", tbGCDynamicForbiden});
end

-- 查询新手村
-- 供程序调用，主要不要有错误哈-_-
function Map:QueryVillage(bMiniServer)
	-- 根据承载获取状态
	-- 单服的情况
	if 1 == bMiniServer then
		local tbRet = {};
		for _, nMapId in ipairs(self.tbVillage) do
			table.insert(tbRet, {nMapId, 0, 1});
		end

		return tbRet;
	else
		local function _GetState(nPercent)
			local nState = 1;	-- 良好
			for _, tbState in ipairs(Map.tbVillageStateCfg) do
				if nPercent >= tbState[1] then
					return tbState[2];
				end
			end
			return nState;
		end
		-- 得到候选新手村
		local tbHouxuan = {}
		local tbServerPlayerCount = GetServerPlayerCount();
		for i, nMapId in ipairs(self.tbVillage) do
			local tbServer = GetMapInServer(nMapId);
			for _, nServerId in ipairs(tbServer) do
				local nPlayerCount = tbServerPlayerCount[nServerId] or 0;
				local nMaxPlayerCount = GetServerCapacity(nServerId);
				if nServerId > 0 and nMaxPlayerCount > 0 then
					local nPercent = nPlayerCount / nMaxPlayerCount;
					local nState = _GetState(nPercent);
					table.insert(tbHouxuan, {nMapId, nPlayerCount / nMaxPlayerCount, nState});
					break;
				end
			end
		end
		-- 开服几天了，计算出需要开启几个新手村
		local nOpenDay = TimeFrame:GetServerOpenDay();
		local nVillageNum = #self.tbVillage;
		for _, tbCfg in ipairs(self.tbVillageCfg) do
			if nOpenDay > tbCfg[1] then
				nVillageNum = tbCfg[2];
			end
		end
		-- 选择几个合适的新手村
		local bFroce = 1;
		local tbRet = {};
		for i = 1, nVillageNum do
			if not tbHouxuan[i] then
				break;
			end
			
			table.insert(tbRet, tbHouxuan[i]);
			-- 不是爆满
			if tbHouxuan[i][2] < self.KD_VILLAGE_SHOW_LIMIT then
				bFroce = 0;
			end
		end
		-- 所有新手村都满了，应该要找一个能够进入的新手村
		if 1 == bFroce and 0 < nVillageNum then
			for i = nVillageNum, #tbHouxuan do
				if tbHouxuan[i][2] < self.KD_VILLAGE_SHOW_LIMIT then
					table.insert(tbRet, tbHouxuan[i]);
					break;
				end
			end
		end
		
		return tbRet;
	end
end

end
