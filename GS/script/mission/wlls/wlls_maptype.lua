--联赛
--地图进入规则
--2008.09.23
--孙多良

--排序
local function OnSort(tbA, tbB)
	if tbA[2] == tbB[2] then
		return tbA[2] > tbB[2]
	end 
	return tbA[2] < tbB[2];
end

--获得会场的点
function Wlls:GetLeaveMapPos(tbMacthCfg, tbMacthLevelCfg, nReadyId, tbMapTypeParam)
	--随机会场
	local tbLeaveMap = {};
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_RANDOM then
		for _, nMapId in pairs(tbMacthLevelCfg.tbIntoMap) do
			if SubWorldID2Idx(nMapId) >= 0 then
				for _, tbPos in pairs(Wlls.MACTH_TRAP_LEAVE) do
					table.insert(tbLeaveMap , {nMapId, unpack(tbPos)});
				end
			end
		end
		-- 如果7台服务器都找不到地图那么就随机飞到任意一张会场
		if (#tbLeaveMap <= 0) then
			local nRand = MathRandom(1, #tbMacthLevelCfg.tbIntoMap);
			local nMapId = tbMacthLevelCfg.tbIntoMap[nRand];
			for _, tbPos in pairs(Wlls.MACTH_TRAP_LEAVE) do
				table.insert(tbLeaveMap, {nMapId, unpack(tbPos)});
			end
		end
	end
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_SERIES then
		if nReadyId <= 0 then
			nReadyId = tbMapTypeParam.nSeries;
		end
		for _, tbPos in pairs(Wlls.MACTH_TRAP_LEAVE) do
			table.insert(tbLeaveMap , {tbMacthLevelCfg.tbIntoMap[nReadyId], unpack(tbPos)});
		end		
	end
		
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_FACTION then
		if nReadyId <= 0 then
			nReadyId = tbMapTypeParam.nFaction;
		end		
		for _, tbPos in pairs(Wlls.MACTH_TRAP_LEAVE) do
			table.insert(tbLeaveMap , {tbMacthLevelCfg.tbIntoMap[nReadyId], unpack(tbPos)});
		end
	end
	
	return tbLeaveMap;
end

--获得准备场
function Wlls:GetReadyMapId(tbMacthCfg, tbMacthLevelCfg, nGameLevel, nMapId, tbMapTypeParam, szLeagueName)
	local nEnterReadyId = 0;
	
	if tbMacthCfg.nMapLinkType == self.MAP_LINK_TYPE_RANDOM then

		--如果自己是第一个战队成员进入，则直接进入准备场, 如果之前进入过该准备场，则直接进入。(优先选取奇数战队数，跟着在最小战队数服务器中随机)
		local tbGroupCount = {};
		for nReadyId, nMapId in ipairs(tbMacthLevelCfg.tbReadyMap) do
			if not self.GroupList[nGameLevel][nReadyId] then
				self.GroupList[nGameLevel][nReadyId] = {};
				self.GroupList[nGameLevel][nReadyId].nLeagueCount = 0;
			end
			table.insert(tbGroupCount, {nReadyId, self.GroupList[nGameLevel][nReadyId].nLeagueCount});
		end
		table.sort(tbGroupCount, OnSort);
		
		--八强赛队员都进入第一个场
		if Wlls:GetMacthState() == Wlls.DEF_STATE_ADVMATCH then
			return 1;
		end
		
		local nMinCount =  tbGroupCount[1][2];
		
		--如果之前进过这个准备场，则这轮比较就会进入这个场。
		if self.GroupListTemp[nGameLevel][szLeagueName] then
			if self.GroupList[nGameLevel][self.GroupListTemp[nGameLevel][szLeagueName]].nLeagueCount < self:GetPreMaxLeague() then
				return self.GroupListTemp[nGameLevel][szLeagueName];
			end
		end
		
		--如果自己战队已有队友进入了，则直接进入准备场。
		for nReadyId, nMapId in ipairs(tbMacthLevelCfg.tbReadyMap) do
			if self.GroupList[nGameLevel][nReadyId][szLeagueName] then
				return nReadyId;
			end
		end		
				
		if nMinCount >= self:GetPreMaxLeague() then
			--准备场已满。
			KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_MAP_STATE, 1)
			return 0;
		end
				
		for i, tbParam in pairs(tbGroupCount) do
			local nP = MathRandom(1, #tbGroupCount);
			tbGroupCount[i], tbGroupCount[nP] = tbGroupCount[nP], tbGroupCount[i];
		end
		
		for nReadyId, nMapId in ipairs(tbMacthLevelCfg.tbReadyMap) do
			if self.GroupList[nGameLevel][nReadyId].nLeagueCount < (self.MAP_SELECT_MIN)then
				nEnterReadyId = nReadyId;
				break;
			else
				if math.mod(self.GroupList[nGameLevel][nReadyId].nLeagueCount, 2) == 1 then
					nEnterReadyId = nReadyId;
					break;
				end
			end
		end
		if nEnterReadyId == 0 then
			local tbTemp = {};
			for _, tbParam in ipairs(tbGroupCount) do
				if tbParam[2] <= nMinCount then
					table.insert(tbTemp, tbParam[1]);
				end
			end
			nEnterReadyId = tbTemp[MathRandom(1, #tbTemp)];
		end
		self.GroupListTemp[nGameLevel][szLeagueName] = nEnterReadyId;
	end
	
	if tbMacthCfg.nMapLinkType == self.MAP_LINK_TYPE_SERIES then
		nEnterReadyId = tbMapTypeParam.nSeries;
		if not self.GroupList[nGameLevel][nEnterReadyId] then
			self.GroupList[nGameLevel][nEnterReadyId] = {};
			self.GroupList[nGameLevel][nEnterReadyId].nLeagueCount = 0;
		end
		
		--如果自己战队已有队友进入了，则直接进入准备场。
		if self.GroupList[nGameLevel][nEnterReadyId][szLeagueName] then
			return nEnterReadyId;
		end
		
		if self.GroupList[nGameLevel][nEnterReadyId].nLeagueCount >= self:GetPreMaxLeague() then
			--准备场已满。
			--最好加同步到GS，优先GS判断是否满人，提高效率
			return 0;
		end
		return nEnterReadyId;
	end
	
	if tbMacthCfg.nMapLinkType == self.MAP_LINK_TYPE_FACTION then
		nEnterReadyId = tbMapTypeParam.nFaction;
		if not self.GroupList[nGameLevel][nEnterReadyId] then
			self.GroupList[nGameLevel][nEnterReadyId] = {};
			self.GroupList[nGameLevel][nEnterReadyId].nLeagueCount = 0;
		end
		
		--如果自己战队已有队友进入了，则直接进入准备场。
		if self.GroupList[nGameLevel][nEnterReadyId][szLeagueName] then
			return nEnterReadyId;
		end
		
		if self.GroupList[nGameLevel][nEnterReadyId].nLeagueCount >= self:GetPreMaxLeague() then
			--准备场已满。
			--最好加同步到GS，优先GS判断是否满人，提高效率
			return 0;
		end
		return nEnterReadyId;		
	end
	
	return nEnterReadyId;
end

