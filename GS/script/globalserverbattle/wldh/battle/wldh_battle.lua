-------------------------------------------------------
-- 文件名　：wldh_battle.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-08-20 14:33:58
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbBattle = Wldh.Battle;

-- 初始化
function tbBattle:Init()
	
	-- 支持重载
	if not self.tbMissions then	
		self.tbMissions		= {};	-- 1层mission就行了，不分级别
		self.tbBTSaveData	= {};	-- 存战场信息
		self.tbRuleBases	= {};	-- 规则信息
		self.tbMapInfo		= {};	-- 存战队分组，战场索引
	end

	-- 服务器
	if MODULE_GAMESERVER then
		
		-- 启动载入地图信息
		ServerEvent:RegisterServerStartFunc(self.InitMapInfo, self);
	end
end

-- 初始化地图信息
function tbBattle:InitMapInfo()
	self:_LoadMapList();
	self:_InitSignupPos();
end

-- 加载地图列表，最里面的表是一堆trap点，烦死
-- tbMapData = { [nMapId] = {[nCamp] = {["BaseCamp"] = {}, ["OuterCamp1"] = {} } }
function tbBattle:_LoadMapList()
	
	local tbMapData = {};
	
	for nIndex, nMapId in pairs(self.MAPID_MATCH) do
		
		tbMapData[nMapId] = self:_LoadMapData(nMapId, "\\setting\\battle\\map\\wulindahui\\");
		tbMapData[nMapId].szMapName = "武林大会团体赛" .. nIndex;
	end
	
	self.tbMapData = tbMapData;
end

-- 报名点
function tbBattle:_InitSignupPos()
	
	-- 报名点坐标集
	local tbSignUpInfo = {};
	
	for nBattleIndex, nMapId in pairs(self.MAPID_SIGNUP) do
		
		if not tbSignUpInfo[self.MAPID_MATCH[nBattleIndex]] then
			tbSignUpInfo[self.MAPID_MATCH[nBattleIndex]] = {};
		end
			
		for nIndex, tbPos in pairs(self.POS_SIGNUP) do
			tbSignUpInfo[self.MAPID_MATCH[nBattleIndex]][nIndex] = {nMapId, tbPos[1], tbPos[2]};
		end
	end

	self.tbSignUpInfo = tbSignUpInfo;
end


-- 加载地图数据
function tbBattle:_LoadMapData(nMapId, szPath)
	
	local tbPosFileList	= 
	{
		["BaseCamp"]		= "houying%d.txt",			-- 后营入口点
		["OuterCamp1"]		= "daying%d.txt",			-- 大营入口点
		["OuterCamp2"]		= "qianying%d.txt",			-- 前营入口点
		["OuterCamp3"]		= "daying%d_1.txt",
		["OuterCamp4"]		= "daying%d_2.txt",
		["Npc_chuwuxiang"]	= "houying%dchuwuxiang.txt",-- 后营储物箱
		["Npc_junyiguan"]	= "houying%djunyiguan.txt",	-- 后营军医官
		["Npc_chefu"]		= "chefu%d.txt",			-- 车夫
	};
	
	local tbMapData	= {};
	
	for nCamp = 1, 4 do
		
		local tbMapCampData	= {};
		for szName, szFileName in pairs(tbPosFileList) do
			
			local szFullPath = szPath..string.format(szFileName, nCamp);
			local tbFileData = Lib:LoadTabFile(szFullPath);
			
			if tbFileData then
				local tbData = {};
				for nIndex, tbRow in ipairs(tbFileData) do
					if tonumber(tbRow.TRAPX) and tonumber(tbRow.TRAPY) then
						tbData[#tbData + 1]	= {nMapId, tonumber(tbRow.TRAPX), tonumber(tbRow.TRAPY)};
					end
				end
				tbMapCampData[szName] = tbData;
			else
				if szName == "BaseCamp" then
					tbMapCampData = nil;
					break;
				end
			end
		end
		
		-- 大营点不存在，可能大营1_1存在，不存在就是不正常了
		if tbMapCampData and not tbMapCampData["OuterCamp1"] then
			tbMapCampData["OuterCamp1"] = tbMapCampData["OuterCamp3"];
		end
		
		tbMapData[nCamp] = tbMapCampData;
	end
	
	-- 至少应加载两方信息
	assert(tbMapData[1] and tbMapData[3]);
	return tbMapData;
end

-- 开启战场(只传第几场)
function tbBattle:OpenBattle(nBattleIndex, szLeagueNameSong, szLeagueNameJin, nFinalStep)
	
	local szBattleTime = GetLocalDate("%y%m%d%H");
	local nMapId = self.MAPID_MATCH[nBattleIndex];
	
	-- 未在本服务器加载
	if IsMapLoaded(nMapId) ~= 1 then
		return;	
	end
	
	-- 清除地图上所有npc
	ClearMapNpc(nMapId);
	
	-- 保存战队分组
	self.tbMapInfo[nMapId] = 
	{ 
		nBattleIndex = nBattleIndex, -- 存下也好，免得反查
		szLeagueNameSong = szLeagueNameSong;
		szLeagueNameJin = szLeagueNameJin;
	};

	-- 地图数据
	if not self.tbMapData[nMapId] then
		return;
	end
	
	-- 构建mission
	local tbMission	= Lib:NewClass(self.tbMissionBase, 
		nBattleIndex, nMapId, self.tbMapData[nMapId], 
		szBattleTime, szLeagueNameSong, szLeagueNameJin, nFinalStep);

	self.tbMissions[nBattleIndex] = tbMission;
	
	-- 开启mission
	tbMission:Open();
	
	-- 广播消息
	local szMsg = string.format("武林大会团体赛一触即发，目前正进入准备阶段，比赛开始剩余时间:%d分。", self.TIMER_SIGNUP / (Env.GAME_FPS * 60));
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	GCExcute({"Wldh:Gb_Anncone", szMsg});
end

-- 关闭战场
function tbBattle:CloseBattle(nBattleKey, nBattleIndex)
	
	local tbMission	= self.tbMissions[nBattleIndex];
	local nMapId = tbMission.nMapId;
	
	-- 安全检查
	assert(tbMission.nBattleKey == nBattleKey);	
	
	-- 关闭mission
	tbMission:Close();

	-- 清除npc
	ClearMapNpc(nMapId);
	
	-- 清除表数据
	self.tbMissions[nBattleIndex] = nil;
	self.tbMapInfo[nMapId] = nil;
end

-- 获得玩家临时table，存数据用的
function tbBattle:GetPlayerData(pPlayer)
	local tbPlayerData = pPlayer.GetTempTable("Wldh");
	local tbPlayerBattleInfo = tbPlayerData.tbPlayerBattleInfo;
	return tbPlayerBattleInfo;
end

-- 获得战场mission
function tbBattle:GetMission(nBattleIndex)
	return self.tbMissions[nBattleIndex];
end

function tbBattle:GetMissionByMapId(nMapId)
	local nBattleIndex = self.tbMapInfo[nMapId].nBattleIndex;
	return self.tbMissions[nBattleIndex];
end

-- 获得玩家人数
function tbBattle:GetPlayerCount(nBattleIndex)
	local tbDbTaskId	= self.DBTASKID_PLAYER_COUNT[nBattleIndex];
	local nSongCampNum	= KGblTask.SCGetTmpTaskInt(tbDbTaskId[self.CAMPID_SONG]) - 1; 
	local nJinCampNum	= KGblTask.SCGetTmpTaskInt(tbDbTaskId[self.CAMPID_JIN]) - 1;
	return nSongCampNum, nJinCampNum;
end

function tbBattle:GetGroupByLeagueName(szLeagueName)
	
	if not self.tbGroupIndex then
		return nil;
	end
	
	for nIndex, tbGroup in pairs(self.tbGroupIndex) do
		if Wldh.Battle.tbLeagueName[tbGroup[1]][1] == szLeagueName then
			return {nIndex, 1};
		elseif Wldh.Battle.tbLeagueName[tbGroup[2]][1] == szLeagueName then
			return {nIndex, 2};
		end
	end
	
	return nil;
end

tbBattle:Init();
