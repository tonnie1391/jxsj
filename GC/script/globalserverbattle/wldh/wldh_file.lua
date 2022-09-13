--武林大会
--孙多良
--2008.09.17
--Require("\\script\\globalserverbattle\\self\\Wldh_def.lua")

--加载大会类型表
function Wldh:LoadGameType()
	local tbFile = Lib:LoadTabFile("\\setting\\globalserverbattle\\wldh\\league_type.txt")
	if not tbFile then
		return
	end
	self.MACTH_TYPE = {};
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nLeagueType = tonumber(tbParam.LeagueType);
			self.MACTH_TYPE[nLeagueType] = {};
			self.MACTH_TYPE[nLeagueType].szCfgFileName = tbParam.FileName;
			self.MACTH_TYPE[nLeagueType].szTrapFileName = tbParam.FileNameTrap;
			self.MACTH_TYPE[nLeagueType].nLGType = tonumber(tbParam.LGType);
			self.MACTH_TYPE[nLeagueType].szClassName = tbParam.ClassName;
		end
	end
	
	for nType, tbMacth  in pairs(self.MACTH_TYPE) do
		tbMacth.tbMacthCfg = {};
		tbMacth.tbWaitMap  = {};
		tbMacth.tbReadyMap = {};
		tbMacth.tbMacthMap = {};
		tbMacth.tbMacthMapPatch = {};
		tbMacth.tbPkPos    = {};
		
		local tbTypeFile = Lib:LoadTabFile("\\setting\\globalserverbattle\\wldh\\league_type\\"..tbMacth.szCfgFileName);
		if not tbTypeFile then
			print("【武林大会】读取文件错误，文件不存在", tbMacth.szCfgFileName);
			return
		end
		for nId, tbParam in ipairs(tbTypeFile) do
			if nId > 1 then
				local szName 		= tbParam.Name;
				local szDesc  		= tbParam.Desc;
				local nMapLinkType  = tonumber(tbParam.MapLinkType);
				local nMemberCount  = tonumber(tbParam.MemberCount);
				local nPlayerCount  = tonumber(tbParam.PlayerCount);
				local nSex  		= tonumber(tbParam.Sex);
				local nCamp  		= tonumber(tbParam.Camp);
				local nSeries 	 	= tonumber(tbParam.Series);
				local nFaction  	= tonumber(tbParam.Faction);
				local nTeacher  	= tonumber(tbParam.Teacher);
				local nWaitMap  	= tonumber(tbParam.WaitMap);
				local nReadyMap  = tonumber(tbParam.ReadyMap);
				local nMacthMap  = tonumber(tbParam.MacthMap);
				local nMacthMapPatch = tonumber(tbParam.MacthMapPatch);

				if szName and szName ~= "" then
					tbMacth.szName = szName;
				end
				if szDesc and szDesc ~= "" then
					tbMacth.szDesc = szDesc;
				end				
					
				tbMacth.nMapLinkType = tbMacth.nMapLinkType or nMapLinkType;
				tbMacth.tbMacthCfg.nMemberCount = tbMacth.tbMacthCfg.nMemberCount or nMemberCount;
				tbMacth.tbMacthCfg.nPlayerCount = tbMacth.tbMacthCfg.nPlayerCount or nPlayerCount;
				tbMacth.tbMacthCfg.nSex = tbMacth.tbMacthCfg.nSex or nSex;
				tbMacth.tbMacthCfg.nCamp = tbMacth.tbMacthCfg.nCamp or nCamp;
				tbMacth.tbMacthCfg.nSeries = tbMacth.tbMacthCfg.nSeries or nSeries;
				tbMacth.tbMacthCfg.nFaction = tbMacth.tbMacthCfg.nFaction or nFaction;
				tbMacth.tbMacthCfg.nTeacher = tbMacth.tbMacthCfg.nTeacher or nTeacher;
				
				if nWaitMap then
					table.insert(tbMacth.tbWaitMap, nWaitMap);
				end
				if nReadyMap then
					table.insert(tbMacth.tbReadyMap, nReadyMap);
				end
				if nMacthMap then
					table.insert(tbMacth.tbMacthMap, nMacthMap);
				end
				if nMacthMapPatch then
					table.insert(tbMacth.tbMacthMapPatch, nMacthMapPatch);
				end																							
			end
		end
		
		tbMacth.szName = tbMacth.szName or "【未填写类型】";
		tbMacth.szDesc = tbMacth.szDesc or "【未填写描述】";
		tbMacth.nMapLinkType = tbMacth.nMapLinkType or 1;
		tbMacth.tbMacthCfg.nMemberCount = tbMacth.tbMacthCfg.nMemberCount or 0;
		tbMacth.tbMacthCfg.nPlayerCount = tbMacth.tbMacthCfg.nPlayerCount or 0;
		tbMacth.tbMacthCfg.nSex = tbMacth.tbMacthCfg.nSex or 0;
		tbMacth.tbMacthCfg.nCamp = tbMacth.tbMacthCfg.nCamp or 0;
		tbMacth.tbMacthCfg.nSeries = tbMacth.tbMacthCfg.nSeries or 0;
		tbMacth.tbMacthCfg.nFaction = tbMacth.tbMacthCfg.nFaction or 0;
		tbMacth.tbMacthCfg.nTeacher = tbMacth.tbMacthCfg.nTeacher or 0;
		
		--加载pk场传入坐标
		local tbTypeFile = Lib:LoadTabFile("\\setting\\globalserverbattle\\wldh\\league_trap\\"..tbMacth.szTrapFileName);
		if not tbTypeFile then
			print("【武林大会】读取文件错误，文件不存在", tbMacth.szTrapFileName);
			return
		end
		for nId, tbParam in ipairs(tbTypeFile) do
			local nPosX = math.floor((tonumber(tbParam.TRAPX) )/32);
			local nPosY = math.floor((tonumber(tbParam.TRAPY) )/32);
			tbMacth.tbPkPos[nId] = {nPosX, nPosY};
		end
	end
end

if not MODULE_GAMECLIENT then
Wldh:LoadGameType();
end
