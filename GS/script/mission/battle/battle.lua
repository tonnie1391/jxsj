-----------------------------------------------------
--文件名		：	battle.lua
--创建者		：	zhouchenfei
--创建时间		：	2007-10-23
--功能描述		：	战场中的操作
------------------------------------------------------

Require("\\script\\mission\\battle\\define.lua");

-- 战场初始化
function Battle:Init()
	if (not self.tbMissions) then	-- 支持重载
		self.tbMissions		= {{},{},{}};
		self.tbBTSaveData	= {};
		self.tbRuleBases	= {};
	end

	-- 客户端不需要更多信息
	if (MODULE_GAMESERVER) then
		self:_LoadRuleList();

		ServerEvent:RegisterServerStartFunc(self.InitMapInfo, self);
		PlayerSchemeEvent:RegisterGlobalDailyEvent({self.OnBattleDailyEvent, self});
	end
end

function Battle:InitMapInfo()
	self:_LoadMapList();
	self:_InitSignupPos();
end

-- 加载地图列表
function Battle:_LoadMapList()
	local tbAllMapData	= {};
	local tbMapList	= Map.tbMapList;
	for nMapId, tbMapInfo  in pairs(tbMapList) do
		if (tbMapInfo.tbParam and tbMapInfo.tbParam.BattleMapInfoDir) then
			tbAllMapData[nMapId] = self:_LoadMapData(nMapId, tbMapInfo.tbParam.BattleMapInfoDir);
			tbAllMapData[nMapId].szMapName = tbMapInfo.szName;
		end
	end
	self.tbAllMapData	= tbAllMapData;
end

-- 报名点地图信息、坐标点整理
function Battle:_InitSignupPos()
	local tbSignUpPos	= {};
	local tbMapInfos	= {};
	for nLevel, tbMapId in pairs(self.MAPID_LEVEL_CAMP) do
		for nBattleSeq, tbMId in pairs(tbMapId) do
			local tbLevelPos	= {};
			-- 报名点地图信息
			for nCampId, nMapId in pairs(tbMId) do
				tbMapInfos[nMapId]	= {
					nMapId	= nMapId,
					nLevel	= nLevel,
					nCampId	= nCampId,
					nBattleSeq = nBattleSeq,
				};

				-- 报名点坐标集
				local tbPoss	= {};
				for nIndex, tbPos in pairs(self.POS_SIGNUP) do
					tbPoss[nIndex]	= {nMapId, tbPos[1], tbPos[2]};
				end
				tbLevelPos[nCampId]	= tbPoss;
			end
			if (not tbSignUpPos[nLevel]) then
				tbSignUpPos[nLevel] = {};
			end
			tbSignUpPos[nLevel][nBattleSeq]	= tbLevelPos;
		end
	end
	self.tbSignUpPos	= tbSignUpPos;
	self.tbMapInfos		= tbMapInfos;
end

-- 规则表载入
function Battle:_LoadRuleList()
	local tbRuleList	= {};
	local tbData		= Lib:LoadTabFile("\\setting\\battle\\songjin\\battlenpc.txt");	
	for _, tbRow in ipairs(tbData) do
		local nBattleLevel	= tonumber(tbRow.BATTLE_LEVEL);
		local tbRule		= tbRuleList[nBattleLevel];
		if (not tbRule) then
			tbRule	= {};
			tbRuleList[nBattleLevel]	= tbRule;
		end
		local nRuleType		= tonumber(tbRow.RULE_TYPE);
		local tbRuleData 	= tbRule[nRuleType];

		if (not tbRuleData) then
			tbRuleData	= {
				nRuleType		= nRuleType,
				nBattleLevel	= nBattleLevel,
			};
			tbRule[nRuleType]	= tbRuleData;
		end
		local tbAddNpcList	= tbRuleData.tbAddNpcList;
		local tbNpcRankId	= tbRuleData.tbNpcRankId;
		
		if (not tbAddNpcList) then
			tbAddNpcList = {{},{}};
			tbRuleData.tbAddNpcList = tbAddNpcList;
		end
		if (not tbNpcRankId) then
			tbNpcRankId = {};
			tbRuleData.tbNpcRankId = tbNpcRankId;
		end

		-- 宋方npc信息
		local nRankId		= tonumber(tbRow.NPC_RANK);
		local nNpcLevel		= tonumber(tbRow.NPC_LEVEL);
		local nNpcNumber1	= tonumber(tbRow.NPC_NUM_1);
		local nNpcNumber2	= tonumber(tbRow.NPC_NUM_2);
		
		local tbNumber = { [1] = nNpcNumber1, [2] = nNpcNumber2 };
		
		
		local tbAddNpc	= {
			nNpcId	= tonumber(tbRow.SONGNPC_ID);
			nLevel	= nNpcLevel;
			tbNumber= tbNumber;
		};
		tbAddNpcList[Battle.CAMPID_SONG][nRankId]	= tbAddNpc;		
		tbNpcRankId[tbAddNpc.nNpcId]	= nRankId;
		
		-- 金方npc信息
		tbAddNpc	= {
			nNpcId	= tonumber(tbRow.JINNPC_ID);
			nLevel	= nNpcLevel;
			tbNumber	= tbNumber;
		};
		tbAddNpcList[Battle.CAMPID_JIN][nRankId]	= tbAddNpc;		
		tbNpcRankId[tbAddNpc.nNpcId]	= nRankId;
	end
	self.tbRuleList	= tbRuleList;
end

-- 加载地图数据
function Battle:_LoadMapData(nMapId, szPath)
	local tbPosFileList		= {
		["BaseCamp"]		= "houying%d.txt";			-- 后营入口点
		["OuterCamp1"]		= "daying%d.txt";			-- 大营入口点
		["OuterCamp2"]		= "qianying%d.txt";			-- 前营入口点
		["Npc_guard"]		= "daying%dshouwei.txt";	-- 大营守卫
		["Npc_chuwuxiang"]	= "houying%dchuwuxiang.txt";-- 后营储物箱
		["Npc_junyiguan"]	= "houying%djunyiguan.txt";	-- 后营军医官
		["Npc_yewai"]		= "daying%dyewai.txt";		-- 野外刷怪点
		["Npc_shuaiqidian"]	= "shuaiqidian%d.txt";		-- 帅旗
		["Npc_dajiang"]		= "dajiang%d.txt";			-- 大营大奖
		["Npc_yuanshuai"]	= "yuanshuaidian%d.txt";	-- 大营元帅
		["Npc_boss"]		= "zhengduodianboss%d.txt";	-- 争夺点Boss
		["OuterCamp3"]		= "daying%d_1.txt";
		["OuterCamp4"]		= "daying%d_2.txt";
		["Effect_daying"]	= "dayingeffect%d.txt";
		["Effect_qianying"]	= "qianyingeffect%d.txt";
		["OuterCamp5"]		= "yewai_playernpc%d.txt";
		["Npc_Totem"]		= "npc_totem%d.txt";	--保护龙柱模式,龙柱地点
	};
	local tbMapData	= {};
	for nCamp = 1, 4 do
		local tbMapCampData	= {};
		for szName, szFileName in pairs(tbPosFileList) do
			local szFullPath	= szPath..string.format(szFileName, nCamp);
			local tbFileData	= Lib:LoadTabFile(szFullPath);
			if (tbFileData) then
				local tbData	= {};
				for nIndex, tbRow in ipairs(tbFileData) do
					if (tonumber(tbRow.TRAPX) and tonumber(tbRow.TRAPY)) then
						tbData[#tbData + 1]	= {nMapId, tonumber(tbRow.TRAPX), tonumber(tbRow.TRAPY)};
					end
				end
				tbMapCampData[szName]	= tbData;
			else
				if (szName == "BaseCamp") then
					tbMapCampData	= nil;
					break;
				end
			end
		end
		if (tbMapCampData and not tbMapCampData["OuterCamp1"]) then -- 大营点不存在，可能大营1_1存在，不存在就是不正常了
			tbMapCampData["OuterCamp1"] = tbMapCampData["OuterCamp3"];
		end
		Battle:DbgOut("LoadMapData", "..."..string.sub(szPath, 20), nCamp.." = "..tostring(tbMapCampData));
		tbMapData[nCamp]	= tbMapCampData;
	end
	assert(tbMapData[1] and tbMapData[3]);	-- 至少应加载两方信息
	return tbMapData;
end

-- 开启战场
function Battle:OpenBattle(nBattleId, nBattleLevel, nMapId, szMapName, nRuleType, nMapNpcNumType, nSeqNum, nBattleSeq, szBattleTime)
	Battle:DbgOut("OpenBattle", nBattleId, nBattleLevel, nMapId, szMapName, nRuleId);
--	assert(not self.tbMissions[nBattleLevel][nBattleSeq]);	-- 级别重复	
	
	self.szLastMapName	= szMapName;
	
	if (IsMapLoaded(nMapId) ~= 1) then
		return;	-- 未在本服务器加载
	end
	
	self.tbMapInfos[nMapId]	= { nMapId = nMapId, nLevel = nBattleLevel, nBattleSeq = nBattleSeq};
	
	if (not self.tbRuleList[nBattleLevel]) then
		Battle:DbgOut("OpenBattle", string.fromat("没有此等级规则%d级", nBattleLevel));
		return;
	end
	local tbRuleData	= self.tbRuleList[nBattleLevel][nRuleType];
	if (not self.tbRuleList[nBattleLevel][nRuleType]) then
		Battle:DbgOut("OpenBattle", string.format("没有此等级规则%d级，模式%d", nBattleLevel, nRuleType));
		print(string.format("没有此等级规则%d级，模式%d", nBattleLevel, nRuleType));
		return;
	end

	ClearMapNpc(nMapId);

	if (not self.tbAllMapData[nMapId]) then
		Battle:DbgOut("OpenBattle", "此地图信息不存在！");
		return;
	end
	local tbMission	= Lib:NewClass(self.tbMissionBase, nBattleId, tbRuleData, szMapName,
									self.tbAllMapData[nMapId], nMapId, nMapNpcNumType, nSeqNum, nBattleSeq, szBattleTime);

	if (not self.tbMissions[nBattleLevel]) then
		self.tbMissions[nBattleLevel] = {};
	end
	self.tbMissions[nBattleLevel][nBattleSeq]	= tbMission;
	tbMission:Open();
	self:SendBTOpenInfo();
end

-- 关闭战场
function Battle:CloseBattle(nBattleLevel, nBattleKey, nBattleSeq)
	Battle:DbgOut("CloseBattle", nBattleLevel, nBattleKey);
	local tbMission	= self.tbMissions[nBattleLevel][nBattleSeq];
	local nMapId	= tbMission.nMapId;
	
	assert(tbMission.nBattleKey == nBattleKey);	-- 安全检查
	
	tbMission:Close();

	ClearMapNpc(nMapId);
	
	self.tbMissions[nBattleLevel][nBattleSeq]	= nil;
	self.tbMapInfos[nMapId]			= nil;
end

function Battle:MyPrintf(tbBattleTeam)
	print("{");
	for i = 1, 6 do
		print("     [".. i .. "]");
		print("     {");
		if (tbBattleTeam[i]) then
			for _, tbTeamInfo in pairs(tbBattleTeam[i]) do
				print("          nNumber, nTeamId = ", tbTeamInfo.nNumber, tbTeamInfo.nTeamId);
			end
		end
		print("     }");
	end
	print("}"); 
end

-- 获得玩家临时table
function Battle:GetPlayerData(pPlayer)
	local tbPlayerData		= pPlayer.GetTempTable("Mission");
	local tbPLBTInfo	= tbPlayerData.tbPLBTInfo;
	return tbPLBTInfo;
end

-- 获得战场mission
function Battle:GetMission(nLevel, nBattleSeq)
	return self.tbMissions[nLevel][nBattleSeq];
end

-- 获得地图信息
function Battle:GetMapInfo(nMapId)
	local tbMapInfo	= self.tbMapInfos[nMapId];
	if not tbMapInfo then
		return {};
	end
	tbMapInfo.tbMission	= nil;
	tbMapInfo.tbCamp	= nil;
	
	local tbMission	= self.tbMissions[tbMapInfo.nLevel][tbMapInfo.nBattleSeq];
	if (tbMission) then
		tbMapInfo.tbMission	= tbMission;
		if (tbMapInfo.nCampId) then
			tbMapInfo.tbCamp	= tbMission.tbCamps[tbMapInfo.nCampId];
		end
	end
	return tbMapInfo;
end

-- 返回此地图是否为战场地图
function Battle:IsBattleMap(nMapId)
	local szMapInfo = GetMapSettingParam(nMapId, "BattleMapInfoDir")
	if (szMapInfo and szMapInfo ~= "") then
		return 1;
	else
		return 0;
	end
end

-- 检查玩家加入的是否是另外一个的战场
function Battle:IsDiffBattle(pPlayer, nBTKey)
	if (not nBTKey or nBTKey < 0) then
		return 0;
	end
	local nMyBTKey = pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_KEY);
	local nBattleSeqA = math.fmod(nMyBTKey, 10);
	local nBattleSeqB = math.fmod(nBTKey, 10);
	local nBattleTimeA = nMyBTKey - nBattleSeqA;
	local nBattleTimeB = nBTKey - nBattleSeqB;
	if (nMyBTKey ~= nBTKey or nBattleTimeA ~= nBattleTimeB) then
		return 1;
	end
	return 0;
end

-- 登陆加军需
function Battle:OnBattleDailyEvent(nCount)
	self:ResetJunXuUserNumber(nCount);
end

-- 返回此地图是否为战场或报名点地图
function Battle:IsRelatedMap(nMapId)
	if (self.tbAllMapData[nMapId] or self.tbMapInfos[nMapId]) then
		return 1;
	else
		return 0;
	end
end

-- 获得加入战场的等级
function Battle:GetJoinLevel(pPlayer)
	local nPlayerLevel 	= pPlayer.nLevel;
	local nJoinLevel	= 0;
	
	for nLevel, nPLevel in pairs(self.LEVEL_LIMIT) do
		if (nPlayerLevel >= nPLevel) then
			nJoinLevel = nLevel;
		end
	end

	return nJoinLevel;
end

function Battle:ChangeFeature(pPlayer, nChangeNpcId, nSkillLevel, nTime)
	-- pPlayer.ChangeFeature(0, 0, 2524, {});
	pPlayer.AddSkillState(nChangeNpcId, nSkillLevel, 0, nTime, 1, 1);
	if (9 == pPlayer.nFaction) then -- 如果玩家是武当派加个坐忘
		pPlayer.AddSkillState(1639, 5, 1, nTime, 1, 1);
	end
end

function Battle:RestoreFeature(pPlayer, nChangeNpcId)
	-- pPlayer.RestoreFeature();
	local nSkillLevel = pPlayer.GetSkillState(nChangeNpcId);
	if (nSkillLevel > 0) then
		pPlayer.RemoveSkillState(nChangeNpcId);
	end

	nSkillLevel = pPlayer.GetSkillState(1639);
	if (nSkillLevel > 0) then
		pPlayer.RemoveSkillState(1639);
	end	
end

-- 客户端脚本
if (MODULE_GAMECLIENT) then
function Battle:ChangeRightSkill(nRightSkill)
	self.nOrgSkillId	= me.nRightSkill;
	me.nRightSkill		= nRightSkill;
end

function Battle:RestoreRightSkill()
	if (not self.nOrgSkillId or self.nOrgSkillId <= 0) then
		return;
	end
	me.nRightSkill		= self.nOrgSkillId;
	self.nOrgSkillId	= 0;
end
end

-- 获得玩家人数
function Battle:GetPlayerCount(nBTLevel, nBattleSeq)
	local tbDbTaskId	= self.DBTASKID_PLAYER_COUNT[nBTLevel][nBattleSeq];
	local nSongCampNum	= KGblTask.SCGetTmpTaskInt(tbDbTaskId[self.CAMPID_SONG]) - 1; 
	local nJinCampNum	= KGblTask.SCGetTmpTaskInt(tbDbTaskId[self.CAMPID_JIN]) - 1;
	return nSongCampNum, nJinCampNum;
end

-- 功能:	玩家被传送到报名点,并且变成非战斗状态
-- 参数:	nMapId	报名点的地图Id
-- 参数:	pPlayer 需要被传送的对象
function Battle:EnterRegistPlace(nMapId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	local nIndex = math.floor( MathRandom(#self.POS_SIGNUP));	-- 随机取得self.POS_SIGNUP中某个坐标的下标
	pPlayer.NewWorld(nMapId, unpack(self.POS_SIGNUP[nIndex]));
	pPlayer.SetFightState(0);											-- 玩家到达报名点就会转化成非战斗状态
end

function Battle:SendBTOpenInfo()
	local szMsg = string.format("Mông Cổ-Tây Hạ đang bước vào giai đoạn đăng ký, các nhân sỹ hãy đến ghi danh chiến trường ở 7 thành thi, thời gian còn lại: %d phút. Điều kiện: đẳng cấp trên %d.", self.TIMER_SIGNUP / (Env.GAME_FPS * 60), self.LEVEL_LIMIT[1])
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
end

function Battle:DbgOut(szMode, ...)
	Dbg:Output("Battle", szMode, unpack(arg));
end

function Battle:DbgWrite(nLevel, szMode, ...)
	Dbg:WriteLogEx(nLevel, "Battle", szMode, unpack(arg));
end

function Battle:WriteLog(...)
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Mission", "Battle", unpack(arg));
end

function Battle:ResetJunXuUserNumber(nCount)
	local nJunXu = me.GetTask(self.TSKGID, self.TSK_BTPLAYER_JUNXU);
	nJunXu = nJunXu + self.BTPLJUNXUDIAN * nCount;
	if (nJunXu > 14) then
		nJunXu = 14;
	end
	me.SetTask(self.TSKGID, self.TSK_BTPLAYER_JUNXU, nJunXu);
	me.SetTask(self.TSKGID, self.TSK_BTPLAYER_DAY_JOIN_COUNT, 0);
end

-- 1632 这里当机保护，把技能清除了，之后技能最好不要用这个id，否则会被删掉 
function Battle:LogOutRV()
	for _, nSkillId in pairs(Battle.tbTemplateId2Skill) do
		if me.IsHaveSkill(nSkillId) == 1 then
			me.DelFightSkill(nSkillId);
		end
	end
end

function Battle:OnPlayerLogin(bExchangeServerComing)
	if (bExchangeServerComing ~= 1) then
		local nNowTime = tonumber(os.date("%Y%m%d", GetTime()));
		if (nNowTime < Battle.DEF_DEL_ZHANSHEN_SKILL_DEADLINE) then
			self:LogOutRV();
		end
	end
end

if (MODULE_GAMESERVER) then
	PlayerEvent:RegisterGlobal("OnLogin", Battle.OnPlayerLogin, Battle);
end

Battle:Init();
