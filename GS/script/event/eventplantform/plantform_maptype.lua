--联赛
--地图进入规则

--排序
local function OnSort(tbA, tbB)
	if tbA[2] == tbB[2] then
		return tbA[2] > tbB[2]
	end 
	return tbA[2] < tbB[2];
end

--获得准备场
function EPlatForm:GetReadyMapId(tbMacthCfg, nMapId, tbMapTypeParam, szLeagueName)
	local nEnterReadyId = 0;
	local nState = EPlatForm:GetMacthState();
	
	if (nState == EPlatForm.DEF_STATE_MATCH_1) then
		for nReadyId, nMapId in ipairs(tbMacthCfg.tbReadyMap) do
			if not self.GroupList[nReadyId] then
				self.GroupList[nReadyId] = {};
				self.GroupList[nReadyId].nLeagueCount = 0;
			end
			if (self.GroupList[nReadyId].nLeagueCount < self:GetPreMaxLeague()) then
				self.GroupListTemp[szLeagueName] = nReadyId
				return nReadyId;
			end
		end
		--准备场已满。
		KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_MAP_STATE, 1)
		return 0;		
	end
	

	--如果自己是第一个战队成员进入，则直接进入准备场, 如果之前进入过该准备场，则直接进入。(优先选取奇数战队数，跟着在最小战队数服务器中随机)
	local tbGroupCount = {};
	for nReadyId, nMapId in ipairs(tbMacthCfg.tbReadyMap) do
		if not self.GroupList[nReadyId] then
			self.GroupList[nReadyId] = {};
			self.GroupList[nReadyId].nLeagueCount = 0;
		end
		table.insert(tbGroupCount, {nReadyId, self.GroupList[nReadyId].nLeagueCount});
	end
	table.sort(tbGroupCount, OnSort);
	
	--八强赛队员都进入第一个场
	if nState == EPlatForm.DEF_STATE_ADVMATCH then
		return 1;
	end
	
	local nMinCount =  tbGroupCount[1][2];
	
	--如果之前进过这个准备场，则这轮比较就会进入这个场。
	if self.GroupListTemp[szLeagueName] then
--		if self.GroupList[self.GroupListTemp[szLeagueName]].nLeagueCount < self:GetPreMaxLeague() then
		return self.GroupListTemp[szLeagueName];
--		end
	end
	
	--如果自己战队已有队友进入了，则直接进入准备场。
	for nReadyId, nMapId in ipairs(tbMacthCfg.tbReadyMap) do
		if self.GroupList[nReadyId][szLeagueName] then
			return nReadyId;
		end
	end		

--	if nMinCount >= self:GetPreMaxLeague() then
--		--准备场已满。
--		KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_MAP_STATE, 1)
--		return 0;
--	end
			
	for i, tbParam in pairs(tbGroupCount) do
		local nP = MathRandom(1, #tbGroupCount);
		tbGroupCount[i], tbGroupCount[nP] = tbGroupCount[nP], tbGroupCount[i];
	end
	
	for nReadyId, nMapId in ipairs(tbMacthCfg.tbReadyMap) do
		if (self.GroupList[nReadyId].nLeagueCount < self.MAP_SELECT_MIN)then
			nEnterReadyId = nReadyId;
			break;
		else
			if math.mod(self.GroupList[nReadyId].nLeagueCount, 2) == 1 then
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
	self.GroupListTemp[szLeagueName] = nEnterReadyId;
	
	return nEnterReadyId;
end

