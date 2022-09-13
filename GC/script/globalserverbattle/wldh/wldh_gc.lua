--武林大会
--孙多良
--2008.09.11
if (not MODULE_GC_SERVER) then
	return 0;
end

--进入准备场；
function Wldh:EnterReadyMap(nPlayerId, szLeagueName, nType, nMapId, tbMapTypeParam, nCaptain)
	local nEnterReadyId = Wldh:GetReadyMapId(nType, nMapId, tbMapTypeParam, szLeagueName);
	if nEnterReadyId <= 0 then
		GlobalExcute{"Wldh:MapStateFull", nPlayerId};
		return 0;
	end
	
	if not self.GroupList[nType][nEnterReadyId][szLeagueName] then
		self.GroupList[nType][nEnterReadyId][szLeagueName] = {};
		self.GroupList[nType][nEnterReadyId].nLeagueCount = self.GroupList[nType][nEnterReadyId].nLeagueCount + 1;
	end
	if nCaptain > 0 then
		table.insert(self.GroupList[nType][nEnterReadyId][szLeagueName], 1, nPlayerId);
	else
		table.insert(self.GroupList[nType][nEnterReadyId][szLeagueName], nPlayerId);
	end
	local nLGType = Wldh:GetLGType(nType);
	--战队参赛
	if League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_ATTEND) ~= nEnterReadyId then
		League:SetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_ATTEND, nEnterReadyId);
	end
	League:SetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_ENTER, League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_ENTER) + 1);
	GlobalExcute{"Wldh:EnterReadyMap", nPlayerId, szLeagueName, nEnterReadyId, nType};
end

function Wldh:GetAdvMacthListByLeague(nType, bSyncGs, bNewCreate)
	local nLGType = Wldh:GetLGType(nType);

	if bNewCreate == 1 then
		Wldh.AdvMatchLists[nType] = {};
		for nReadyId, nMapId in pairs(self:GetMapReadyTable(nType)) do
			Wldh.AdvMatchLists[nType][nReadyId] = {};
			for _, nRank in pairs(Wldh.MACTH_STATE_ADV_TASK) do
				Wldh.AdvMatchLists[nType][nReadyId][nRank] = {};
			end
			
			if self:GetMapLinkType(nType) == Wldh.MAP_LINK_TYPE_RANDOM then
				if nReadyId == 1 then
					for nId, tbLeague in ipairs(self.RankLeagueList[nType]) do
						if nId <= 32 then
							Wldh:WriteLog(string.format("【32强名单】%s类型%s名：%s", nType, nId, tbLeague.szName or ""));
							Wldh.AdvMatchLists[nType][nReadyId][32][nId] = {szName =tbLeague.szName, nRank=nId, tbResult={}};
							League:SetLeagueTask(nLGType, tbLeague.szName, Wldh.LGTASK_RANK_ADV, 32);
						end
					end
				end
			end	
	
			if self:GetMapLinkType(nType) == Wldh.MAP_LINK_TYPE_FACTION then
				for nId, tbLeague in ipairs(self.RankLeagueList[nType][nReadyId] or {}) do
					if nId <= 32 then
						Wldh:WriteLog(string.format("【32强名单】%s类型%s名：%s", nType, nId, tbLeague.szName or ""));
						Wldh.AdvMatchLists[nType][nReadyId][32][nId] = {szName = tbLeague.szName, nRank=nId, tbResult={}};
						League:SetLeagueTask(nLGType, tbLeague.szName, Wldh.LGTASK_RANK_ADV, 32);
					end
				end
			end
		end
	end
	
	if bSyncGs == 1 then
		for nReadyId, nMapId in pairs(self:GetMapReadyTable(nType)) do
			if Wldh.AdvMatchLists[nType] and Wldh.AdvMatchLists[nType][nReadyId] then
				for nKey, tbList in pairs(Wldh.AdvMatchLists[nType][nReadyId]) do
					GlobalExcute{"Wldh:SyncAdvMatchList", nType, nReadyId, nKey, tbList};
				end
			end
		end
	end	
end

function Wldh:Gc_Anncone(szAnncone)
	GC_AllExcute({"Wldh:Gb_Anncone", szAnncone});
end
	
function Wldh:Gb_Anncone(szAnncone)
	if GLOBAL_AGENT then
		GC_AllExcute({"Wldh:Anncone_GC", szAnncone});
	end
end

function Wldh:Anncone_GC(szAnncone)
	local nGate = tonumber(string.sub(GetGatewayName(), 5, -1));
	if Wldh.Battle.tbLeagueName[nGate] then
		GlobalExcute({"Wldh:Anncone_GS", szAnncone});
	end
end

