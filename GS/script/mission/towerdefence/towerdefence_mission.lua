--守卫先祖之魂mission
-- 文件名　：towerdefence_mission.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-05 17:21:32
-- 描  述  ：

Require("\\script\\mission\\towerdefence\\towerdefence_def.lua")

TowerDefence.Mission = TowerDefence.Mission or Mission:New();
local tbMission = TowerDefence.Mission;

-- Mission用常量
tbMission.TIME_FPS_REFRESH_NPC  		= Env.GAME_FPS * 1; 		--刷一个集团npc时间间隔
tbMission.TIME_FPS_REFRESH_WAIT		= Env.GAME_FPS * 1; 		--每波开始提示等待时间
tbMission.TIME_FPS_REST	  			= Env.GAME_FPS * 30; 		--开始结束等待时间
tbMission.TIME_FPS_ENDPLAYER	  	= Env.GAME_FPS * 120; 		--开始结束等待时间
tbMission.TIME_FPS_PLAY_TIME	  	= Env.GAME_FPS * 540;		--玩时间
tbMission.NPC_CHANGE_TIME			= Env.GAME_FPS * 14;		--每过多少秒打乱一次技能释放表对应的释放时间
tbMission.NPC_TOWERUPDATA_TIME	= Env.GAME_FPS * 2;		--每过多少秒升级一次塔

tbMission.NPC_MOVE_RAD				= 2;						--走路线随机的半径
tbMission.NPC_REFRESH_COUNT_ALL	= 12;						--总共刷多少波怪
tbMission.MONEY_START				= 150;						--系统开始给玩家的军饷数目
tbMission.TOWERPOSITIONRAD			= 3;						--每个塔堆的边长的一半
tbMission.CASTSKILL_GROUP_NUM		= 4;						--将怪物分为几个组施放技能

tbMission.REFRESH_BOSS_POINT		= {50848,	104672};			--刷boss点坐标
tbMission.MONEY_PER					= {50,80};					--每波怪系统加的军饷数目
tbMission.NPC_CASTSKILL_TIME		= {2,3,4,5,6,7,8};				--每个组对应怪物释放技能的时间(秒)
tbMission.TOWER_MIN_LIFE_UP			= {[1] = 100, [2] = 200, [3] = 300};	--塔升级下一级需要的血量值
tbMission.PLAYER_SKILL_ID 			= {1611,1612,1613,1614,1615};		--玩家初始随机给一个技能，几个玩家给的都不一样吧
tbMission.PLAYER2NPC_SKILL_ID		= {1606,1607,1608,1609,1610};		--玩家吃神符的技能
tbMission.tbFirst_Title 					= {6, 21, 1, 0};		----称号奖励：守护Tinh Anh（即时第一名）
tbMission.tbFirst_Title_Final 				= {6, 22, 1, 0};		----称号奖励：守护之神（没有放过一个怪）-todo
local tbMisEventList = 
	{
		{"countdown",		1,	"OnCountDown"},
		{"play",		tbMission.TIME_FPS_REST,		"OnPlay"},
		{"endplay", 		tbMission.TIME_FPS_PLAY_TIME, 		"OnEndPlay"},
		{"end", 		tbMission.TIME_FPS_ENDPLAYER, 		"OnEnd"},
	};
	
--怪物id对应的掉落表
tbMission.szNpc_droprate ={
		[6682] = {"\\setting\\npc\\droprate\\qingming\\qingming.txt",1},
		[6698] = {"\\setting\\npc\\droprate\\qingming\\qingming.txt",1},
		[6701] = {"\\setting\\npc\\droprate\\qingming\\qingming.txt",1},
		[6704] = {"\\setting\\npc\\droprate\\qingming\\qingming.txt",1},
		[6683] = {"\\setting\\npc\\droprate\\qingming\\qingming_jingying.txt",1},
		[6699] = {"\\setting\\npc\\droprate\\qingming\\qingming_jingying.txt",1},
		[6702] = {"\\setting\\npc\\droprate\\qingming\\qingming_jingying.txt",1},
		[6705] = {"\\setting\\npc\\droprate\\qingming\\qingming_jingying.txt",1},
		[6684] = {"\\setting\\npc\\droprate\\qingming\\qingming_shouling.txt",1},
		[6700] = {"\\setting\\npc\\droprate\\qingming\\qingming_shouling.txt",1},
		[6703] = {"\\setting\\npc\\droprate\\qingming\\qingming_shouling.txt",1},
		[6706] = {"\\setting\\npc\\droprate\\qingming\\qingming_shouling.txt",1},
		[6685] = {"\\setting\\npc\\droprate\\qingming\\qingming_boss.txt",24},
	};   

tbMission.szNpc_droprateNew ={
		[6682] = {"\\setting\\npc\\droprate\\qingming\\qingming1.txt",1},
		[6698] = {"\\setting\\npc\\droprate\\qingming\\qingming1.txt",1},
		[6701] = {"\\setting\\npc\\droprate\\qingming\\qingming1.txt",1},
		[6704] = {"\\setting\\npc\\droprate\\qingming\\qingming1.txt",1},
		[6683] = {"\\setting\\npc\\droprate\\qingming\\qingming_jingying1.txt",1},
		[6699] = {"\\setting\\npc\\droprate\\qingming\\qingming_jingying1.txt",1},
		[6702] = {"\\setting\\npc\\droprate\\qingming\\qingming_jingying1.txt",1},
		[6705] = {"\\setting\\npc\\droprate\\qingming\\qingming_jingying1.txt",1},
		[6684] = {"\\setting\\npc\\droprate\\qingming\\qingming_shouling1.txt",1},
		[6700] = {"\\setting\\npc\\droprate\\qingming\\qingming_shouling1.txt",1},
		[6703] = {"\\setting\\npc\\droprate\\qingming\\qingming_shouling1.txt",1},
		[6706] = {"\\setting\\npc\\droprate\\qingming\\qingming_shouling1.txt",1},
		[6685] = {"\\setting\\npc\\droprate\\qingming\\qingming_boss1.txt",24},
	};   
	
tbMission.tbCallback2ContextFun = 
	{		
		OnPlay		= "SetPlayContext",
		OnCountDown		= "SetCountDownContext",
		OnEndPlay		= "SetEndContext"
	};
	
tbMission.TRANSFORM_SKILL_ID 		= 1620; -- 变身技能
tbMission.NPC_TYPE			= {	[6682] = {"Lâu La", 1},
								[6698] = {"Lâu La", 1},
								[6701] = {"Lâu La", 1},
								[6704] = {"Lâu La", 1},
								[6683] = {"<color=blue>Tinh Anh<color>", 2},
								[6699] = {"<color=blue>Tinh Anh<color>", 2},
								[6702] = {"<color=blue>Tinh Anh<color>", 2},
								[6705] = {"<color=blue>Tinh Anh<color>", 2},
								[6684] = {"<color=purple>Thủ Lĩnh<color>",3}, 
								[6700] = {"<color=purple>Thủ Lĩnh<color>",3},
								[6703] = {"<color=purple>Thủ Lĩnh<color>",3},
								[6706] = {"<color=purple>Thủ Lĩnh<color>",3},
								[6685] = {"<color=gold>Quỷ Vương<color>",4},										
							};
tbMission.ITEM_SHOTCUT				= {{18,1,626,1,0},{18,1,627,1,0},{18,1,621,1,0},{18,1,622,1,0},{18,1,623,1,0},{18,1,624,1,0},{18,1,625,1,0}}; --物品快捷栏

tbMission.tbNpcGenPos 		= {};		--刷NPC的位置 {x,y}
tbMission.tbNpcMoveLeft		= {};		--左路行走路线
tbMission.tbNpcMoveRight	= {};		--右路行走路线
tbMission.tbBOSSMove		= {};		--bossAI路线
tbMission.tbTowerPosition	= {};		--建td的坐标
tbMission.tbPosition_fu		= {};		--刷符的坐标

local tbGenPox = Lib:LoadTabFile("\\setting\\mission\\towerdefence\\npc_refresh_pos.txt");
local tbMove_Lift = Lib:LoadTabFile("\\setting\\mission\\towerdefence\\npc_move_left.txt");
local tbMove_Right = Lib:LoadTabFile("\\setting\\mission\\towerdefence\\npc_move_right.txt");
local tbBossMove = Lib:LoadTabFile("\\setting\\mission\\towerdefence\\boss_move.txt");
tbMission.tbTowerPosition = Lib:LoadTabFile("\\setting\\mission\\towerdefence\\td_position.txt");
local tbPosition_fu = Lib:LoadTabFile("\\setting\\mission\\towerdefence\\fu_position.txt");

for _, pos in ipairs(tbGenPox) do
    table.insert(tbMission.tbNpcGenPos, {tonumber(pos["TRAPX"])/32, tonumber(pos["TRAPY"])/32});
end

for _, pos in ipairs(tbMove_Lift) do
    table.insert(tbMission.tbNpcMoveLeft, {tonumber(pos["TRAPX"]), tonumber(pos["TRAPY"])});
end

for _, pos in ipairs(tbMove_Right) do
    table.insert(tbMission.tbNpcMoveRight, {tonumber(pos["TRAPX"]), tonumber(pos["TRAPY"])});
end

for _, pos in ipairs(tbBossMove) do
    table.insert(tbMission.tbBOSSMove, {tonumber(pos["TRAPX"]), tonumber(pos["TRAPY"])});
end

for _, pos in ipairs(tbPosition_fu) do
    table.insert(tbMission.tbPosition_fu, {tonumber(pos["TRAPX"]), tonumber(pos["TRAPY"])});
end

--结束阶段倒计时
function tbMission:SetEndContext(pPlayer, nTime)
	nTime = nTime or self.TIME_FPS_REST;	
	Dialog:SetBattleTimer(pPlayer, "<color=green>Thời gian kết thúc: <color=white>%s<color>\n", nTime);	
	Dialog:ShowBattleMsg(pPlayer, 1, 0);
end

-- 开始倒计时
function tbMission:OnCountDown()	
	for _, pPlayer in pairs(self:GetPlayerList()) do		
		self:SetCountDownContext(pPlayer);	
		Dialog:SendBlackBoardMsg(pPlayer, "Quái vật sắp tấn công!!!");
	end
	self:GenerateAndSendMsg();
end

--开始刷怪倒计时
function tbMission:SetPlayContext(pPlayer, nTime)
	nTime = nTime or self.TIME_FPS_PLAY_TIME;	
	Dialog:SetBattleTimer(pPlayer, "<color=green>Thời gian phòng thủ: <color=white>%s<color>\n", nTime);
end

-- 进入游戏状态的回调
function tbMission:OnPlay()
	self.nResfreshNum = 1;
	for _, pPlayer in pairs(self:GetPlayerList()) do
		self:SetPlayContext(pPlayer);
	end	
	self.tbChangeGroupTimer = self:CreateTimer(self.NPC_CHANGE_TIME, self.ChangeTime, self);
	self.UpDataTowerTimer = self:CreateTimer(self.NPC_TOWERUPDATA_TIME, self.UpDataTower, self);
	self:CastSkill();
	self:RefreshNpc(self.nResfreshNum);
end

-- 防守阶段结束回调，倒计时结束游戏
function tbMission:OnEndPlay()
	self:BroadcastBlackBoardMsg(string.format("Phòng thủ kết thúc!!!",nNumber));
	self:CloseAllTimer();
	self:ClearAllNpc();
	--刷新右边倒计时	
	for _, pPlayer in pairs(self:GetPlayerList()) do
		self:SetEndContext(pPlayer);
	end
	--刷新界面
	self:GenerateAndSendMsg();
	--结果插到tbResult中
	--这里把玩家个人成绩解析为最终结果
	for nGroupId, tbGrade in ipairs(self.tbGrade_player) do
		if tbGrade[2] >= 0 then
			table.insert(self.tbResult, tbGrade);
		end
	end
	
	--提前到休息时间就算最终奖励了
	if self.tbCallbackOnClose then
		Lib:CallBack(self.tbCallbackOnClose);
	end
	
	for _, pPlayer in pairs(self:GetPlayerList()) do
		if self.tbCallbackEndPlay and type(self.tbCallbackEndPlay[1]) == "function" then
			self.tbCallbackEndPlay[1](self.tbCallbackEndPlay[2], pPlayer);
		end
	end
	
	--团体比赛奖励
	--self:SetAword();
	--加超级光环（没有放过一个怪物）
--	if self.nLostNpc == 0 and self.ISBossOver == 1 and self.tbGrade_player[1] then
--		local szFirstName = self.tbGrade_player[1][1];
--		local pPlayer = KPlayer.GetPlayerByName(szFirstName);
--		if pPlayer and self:GetPlayerGroupId(pPlayer) >= 0 then
--			pPlayer.AddTitle(unpack(self.tbFirst_Title_Final));
--			pPlayer.SetCurTitle(unpack(self.tbFirst_Title_Final));
--		end
--	end
end

function tbMission:GetCurRank(pPlayer)
	for nRank, tbRank in pairs(self.tbResult) do
		if tbRank[1] == pPlayer.szName then
			return nRank;
		end
	end
	return 0;
end

-- 休息
function tbMission:OnRest()
	for _, pPlayer in pairs(self:GetPlayerList()) do
		self:SetRestContext(pPlayer);
	end
end


--开始前倒计时，刷右侧面板
function tbMission:SetCountDownContext(pPlayer, nTime)
	nTime = nTime or self.TIME_FPS_REST;	
	Dialog:SetBattleTimer(pPlayer, "\n<color=green>Thời gian còn lại: <color=white>%s<color>",  nTime);
	Dialog:SendBattleMsg(pPlayer, "");	
	Dialog:ShowBattleMsg(pPlayer, 1, 0);
end

function tbMission:OnGameTimeOver()
	return 0;
end

--打乱施放技能的时间表
function tbMission:ChangeTime()
	Lib:SmashTable(self.NPC_CASTSKILL_TIME);
end

--开定时器释放技能
function tbMission:CastSkill()
	for i = 1 , self.CASTSKILL_GROUP_NUM do		
		self.tbCastSkillTimer[i] = self:CreateTimer(Env.GAME_FPS * self.NPC_CASTSKILL_TIME[i], self.CastSkillEx, self, i);
	end
end

--释放技能
function tbMission:CastSkillEx(nId)
	for _, nNpcId in ipairs(self.tbCastSkillGroup[nId]) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc and TowerDefence.NPC_SKILL[pNpc.nTemplateId] then
			pNpc.CastSkill(TowerDefence.NPC_SKILL[pNpc.nTemplateId], 1, 1, 1);
		end
	end
	return Env.GAME_FPS * self.NPC_CASTSKILL_TIME[nId];
end

--关闭所有的timer
function tbMission:CloseAllTimer()
	if self.tbReadyTimers then
		self.tbReadyTimers:Close();
		self.tbReadyTimers = nil;
	end
	
	if self.tbRefreshNpcTimers then
		self.tbRefreshNpcTimers:Close();
		self.tbRefreshNpcTimers = nil;
	end
		
	if self.tbChangeGroupTimer then
		self.tbChangeGroupTimer:Close();
		self.tbChangeGroupTimer = nil;		
	end
	for i = 1 ,#self.tbCastSkillTimer  do
		self.tbCastSkillTimer[i]:Close();
		self.tbCastSkillTimer[i] = nil;
	end
	if self.UpDataTowerTimer then
		self.UpDataTowerTimer:Close();
		self.UpDataTowerTimer = nil;
	end
end

--怪物死亡或者怪物跑到终点回调(nType为0表示塔或者人打死的)
function tbMission:OnDeathNpc(nNpcId, nKillerId, nType)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local nTemplateId = pNpc.nTemplateId;
	if nType and nType == 0 then
		if nKillerId and self.tbTD[nKillerId] then
			self:AddAword(nTemplateId, nKillerId);
			if self.szNpc_droprate and self.szNpc_droprate[nTemplateId] then				
				local szFile = self.szNpc_droprate[nTemplateId][1];
				--趣味活动掉落表不一样
				if NewEPlatForm:GetMatchState() == NewEPlatForm.DEF_STATE_STAR then
					szFile = self.szNpc_droprateNew[nTemplateId][1];
				end
				pNpc.DropRateItem(szFile, self.szNpc_droprate[nTemplateId][2], -1, -1, 0);
			end
		end
	else
		self.nLostNpc = self.nLostNpc + 1;
	end
	if self.tbRefreshNpcId[nNpcId] then
		self:DelRefreshNpc(nNpcId);
	end
end

--打死怪物奖励
function tbMission:AddAword(nTemplateId, nKillerId)
	if  not self.tbTD[nKillerId] then
		return;
	end
	local nPlayerId = self.tbTD[nKillerId][1];
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer  then
		return;
	end	
	local nGroupId = self:GetPlayerGroupId(pPlayer);
	if nGroupId <= 0 then
		return;
	end
	self.tbGrade[nGroupId] = self.tbGrade[nGroupId] + TowerDefence.NPC_AWORD[nTemplateId][1];	
	pPlayer.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_MONEY, 
		          pPlayer.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_MONEY) + TowerDefence.NPC_AWORD[nTemplateId][2]);
	for i, tbPlayerEx in ipairs(self.tbGrade_player) do
		if tbPlayerEx[1] == pPlayer.szName then
			self.tbGrade_player[i][2] = self.tbGrade_player[i][2] +  TowerDefence.NPC_AWORD[nTemplateId][1];
		end
	end
	self:GenerateAndSendMsg();
end

function tbMission:GetGroupName(nGroup)
	return self.tbGroupName[nGroup] or tostring(nGroup);
end

-- 每组的名字
function tbMission:AddGroupName(pPlayer, nGroupId, szGroupName)
	if szGroupName then
		self.tbGroupName[nGroupId] = szGroupName;
		return;
	end
	
	if self.tbGroupName[nGroupId] then
		return;
	end
	if pPlayer.nTeamId == 0 then
		self.tbGroupName[nGroupId] = pPlayer.szName;
	else
		local tbPlayerList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
		local pCaptin = KPlayer.GetPlayerObjById(tbPlayerList[1]);
		if pCaptin then
			self.tbGroupName[nGroupId] = pCaptin.szName;
		else
			self.tbGroupName[nGroupId] = pPlayer.szName;
		end
	end
end

--清楚掉所有npc
function tbMission:ClearAllNpc()
	--删除掉刷出来的怪
	for nNpcId, _ in pairs(self.tbRefreshNpcId) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();			
		end
	end
	self.tbRefreshNpcId = {};
	--删除boss
	if self.nRefreshBossId ~= 0 then
		local pNpc = KNpc.GetById(self.nRefreshBossId);
		if pNpc then
			pNpc.Delete();
		end
	end
	--删除塔和塔的占位
	for nNpcId, _ in pairs(self.tbTD) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();			
		end
	end
	self.tbTD = {};
	for nId, tbPosition in ipairs(self.tbTD_Position) do
		self.tbTD_Position[nId][3] = 0;
	end
	self.nRefreshBossId = 0;
	
end

--游戏结束回调
function tbMission:OnEnd()	
	ClearMapNpc(self.nMapId);
	ClearMapObj(self.nMapId);	
	self:Close();
	return 0;
end

function tbMission:OnClose()
	
end

function tbMission:OnDeath()
	if self:GetPlayerGroupId(me) >= 0 then
		self:KickPlayer(me);
	end
end

function tbMission:__open(tbEnterPos, tbLeavePos, nMatchType)
	if self:IsOpen() == 1 then
		print("守卫先祖之灵重复开启！");
		return;
	end
	
	self.nMapId	= tbEnterPos[1];
	self.tbMisCfg = {
		tbEnterPos				= {[0] = {tbEnterPos[1], 51456/32 ,	103488/32}, [1] = {tbEnterPos[1], 52128/32, 104160/32}},	-- 进入坐标
		tbLeavePos				= {[0] = tbLeavePos},	-- 离开坐标
		tbCamp					= {[1]=1,[2]=2},
		nPkState				= Player.emKPK_STATE_PRACTISE,
		nInLeagueState			= 1,
		nDeathPunish			= 1,
		nOnDeath				= 1,
		nForbidStall			= 1,
		--nOnKillNpc 		= 1,
		nForbidSwitchFaction	= 1,
		nLogOutRV				= Mission.LOGOUTRV_DEF_MISSION_TOWER,
	};	
	self.nStateJour 	= 0;
	self.tbGroups	= {};
	self.tbPlayers	= {};
	self.tbResult	= {};			--结果
	self.tbTimers	= {};			
	self.tbTD		= {};			--塔管理[nTDId] = {nPlayerId,类型 }
	--self.tbTD_EX	= {};			--tbTD表的反索引	[nPlayerId] = {tbTDId1,tbTDId2...},tbTDId1 = {属性值}
	self.tbGrade	= {};			--积分[gradeId] = nNumber
	self.tbMoney	= {};			--钱[nPlayerId]	= nNumber
	self.tbGrade_player = {};		--每个玩家的积分
	self.tbTD_Delete	= {};		--每次扫描后由于升级或者降级要删除掉的tower  Id
	self.tbTowerPositionEx = {};	--塔对应坐标点饭索引	
	self.tbRefreshNpcId = {};
	self.tbPlayerShotSkill		= {};		--每个玩家左键的快捷键
	self.tbRefreshNpcNumber = 0;	--每波怪已经刷出的个数
	self.tbMisEventList	= tbMisEventList;
	self.tbCastSkillGroup = {};	--怪释放技能的组	
	self.tbCastSkillTimer = {};	--释放技能的计时器
	self.tbGroupCaptain = {};		--队长的table
	self.tbTD_Position = {};
	self.tbGroupName = {};
	self.tbSkillList= {};	--龙舟技能表
	self.nRefreshBossId = 0;		--boss   id
	self.ISBossOver = 0;
	self.nGroupNum = 0;
	self.nLostNpc	= 0; 			--逃跑的npc
	self.nAwordFlag = 0;
	self.szFirstName = "";	
	self.nMatchType = nMatchType or 0;
	self.nResfreshNum = 1;
	--初始化几个释放技能的组table
	for i =1 , self.CASTSKILL_GROUP_NUM do
		self.tbCastSkillGroup[i] = {};
	end
	for _, pos in ipairs(self.tbTowerPosition) do
   	 	table.insert(self.tbTD_Position, {tonumber(pos["TRAPX"])/32, tonumber(pos["TRAPY"])/32, 0});
	end
end

function tbMission:__start()
	--self.tbGameSumTimer = self:CreateTimer(self.TIME_FPS_GAMESUM, self.OnGameTimeOver, self);
	self:GoNextState();
end

-- 测试的话不要直接调这个
-- 而是先 __open, 然后 JoinPlayer, 最后 __start
function tbMission:StartGame(tbEnterPos, tbLeavePos)	
	self:__open(tbEnterPos, tbLeavePos);
	self:__start();
end

function tbMission:GetGroupNum()
	return self.nGroupNum;
end

--变身
function tbMission:Transform(pPlayer, nGroup)	
	if pPlayer.GetSkillState(self.TRANSFORM_SKILL_ID) <= 0 then
		local nMapId, nX, nY = pPlayer.GetWorldPos();
		local tbLevel = {[0] = {1,3,5},[1] = {2,4,6}};
		if not tbLevel[pPlayer.nSex] then
			tbLevel[pPlayer.nSex] = {1,3,5};
		end
		local nSkillLevel = tbLevel[pPlayer.nSex][Random(3) + 1];
		pPlayer.CastSkill(self.TRANSFORM_SKILL_ID, nSkillLevel, nX, nY);		
	end
end

-- 获取结果
-- {[1] --> (nGroupId, grade), [2] --> ...}
function tbMission:GetResult()
	return self.tbResult;
end

-- 右侧排名
function tbMission:GenerateAndSendMsg()
	local tbMsg = {"\nBảng điểm đội:"};	
	local tbMsgEx = {};
	local tbGradeEx = {};
	for nGroupId, nGrade in pairs(self.tbGrade) do
		if nGrade >= 0 then
			table.insert(tbGradeEx,{nGroupId, nGrade});
		end
	end
	--排序	
	local sort_cmp = function (tb1, tb2)
		return tb1[2] > tb2[2];
	end
	table.sort(self.tbGrade_player, sort_cmp);
	table.sort(tbGradeEx, sort_cmp);
	for _, tbGroupGrade in ipairs(tbGradeEx) do
		table.insert(tbMsg, string.format("<color=blue>%-16s<color><color=white>%d<color>", "Đội-"..self.tbGroupCaptain[tbGroupGrade[1]], tbGroupGrade[2]));
	end
	local szMsg = table.concat(tbMsg, "\n");
	
	--第一名变了，加光环
	if self.tbGrade_player[1] and self.szFirstName ~= self.tbGrade_player[1][1] and self.tbGrade_player[1][2] ~= 0 and self.nStateJour < 4  then
		self:AddTitle(self.szFirstName, self.tbGrade_player[1][1]);
		self.szFirstName = self.tbGrade_player[1][1];
		self:BroadcastBlackBoardMsg(string.format("Top 1 đã bị %s cướp rồi!",self.szFirstName));		
	end
	
	
	tbMsgEx = {"\nBảng điểm người chơi:"};
	for _, tbGrade in ipairs(self.tbGrade_player) do
		table.insert(tbMsgEx, string.format("<color=yellow>%-16s<color><color=white>%d<color>", tbGrade[1], tbGrade[2]));	
	end
	szMsg = table.concat(tbMsgEx, "\n").."\n"..szMsg;

	
	for _, pPlayer in pairs(self:GetPlayerList())do
		local szMsgEx = szMsg..string.format("\n\n<color=yellow>Quân lương: %s\nSố quái tẩu thoát: %s<color>\nLượt quái thứ %s", pPlayer.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_MONEY), self.nLostNpc, self.nResfreshNum);
		Dialog:SendBattleMsg(pPlayer, szMsgEx, 1);
	end
end

--增加和删除以第一名的称号
function tbMission:AddTitle(szName1,szName2)	
	local pPlayer1 = KPlayer.GetPlayerByName(szName1);
	local pPlayer2 = KPlayer.GetPlayerByName(szName2);
	if pPlayer1 and pPlayer1.FindTitle(unpack(self.tbFirst_Title)) == 1 then
		pPlayer1.RemoveTitle(unpack(self.tbFirst_Title));
		pPlayer1.SetCurTitle(0, 0, 0, 0);
	end
	if pPlayer2 then
		pPlayer2.AddTitle(unpack(self.tbFirst_Title));
		pPlayer2.SetCurTitle(unpack(self.tbFirst_Title));
	end
end

-- 右侧更新货币，积分
function tbMission:UpdataMsg(nPlayerId, nGroupId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		Dialog:SendBattleMsg(pPlayer, string.format("\n<color=yellow>Quân lương: %s\n\nTích lũy: %s\n\nSố quái tẩu thoát: %s<color>", pPlayer.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_MONEY), self.tbGrade[nGroupId], self.nLostNpc));
	end
end

--怪物被塔打死或者跑到最终点了删掉怪物
function tbMission:DelRefreshNpc(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	pNpc.Delete();
	self.tbRefreshNpcId[nNpcId] = nil;
	if self.nResfreshNum == self.NPC_REFRESH_COUNT_ALL then
		self:GoNextState();
		return;
	end
	if Lib:CountTB(self.tbRefreshNpcId) == 0 then
		self.nResfreshNum = self.nResfreshNum + 1;
		self:RefreshNpc(self.nResfreshNum);
	end
	return 0;
end

--boss死亡回调
function tbMission:DelBoss(nNpcId,	nKillerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local nTemplateId = pNpc.nTemplateId;
	--pNpc.Delete();
	--趣味活动掉落表不一样
	local szFile = self.szNpc_droprate[nTemplateId][1];
	if NewEPlatForm:GetMatchState() == NewEPlatForm.DEF_STATE_STAR then
		szFile = self.szNpc_droprateNew[nTemplateId][1];
	end
	pNpc.DropRateItem(szFile, self.szNpc_droprate[nTemplateId][2], -1, -1, 0);
	self:AddAword(nTemplateId, nKillerId);
	self.nRefreshBossId = 0;
	if self.nResfreshNum == self.NPC_REFRESH_COUNT_ALL then
		self.ISBossOver = 1;
		self:GoNextState();
		return;
	end	
	self.nResfreshNum = self.nResfreshNum + 1;
	self:RefreshNpc(self.nResfreshNum);	
	return;
end

--td死亡回调
function tbMission:DelTower(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	pNpc.Delete();
	if self.tbTD[nNpcId] then
		self:SpecialTD(self.tbTD[nNpcId][1]);  --塔触发特殊效果
		self.tbTD[nNpcId] = nil;
	end
	local nId = self.tbTowerPositionEx[nNpcId];
	self.tbTD_Position[nId][3] = 0;		--该处置为可种植
	self.tbTowerPositionEx[nNpcId] = nil;
end

--是否要触发特殊塔效果
function tbMission:SpecialTD(nPlayerId)
	--ToDo(之前提到过，先保留)
end 

-- 控制刷npc（nNumber表示刷的第几波）
function tbMission:RefreshNpc(nNumber, nFlag)
	self:BroadcastBlackBoardMsg(string.format("Lượt quái thứ %s chuẩn bị tấn công!",nNumber));	
	if not nFlag then
		if nNumber ~= 1 then
			self:AddMoney(nNumber);
		end
		self.tbReadyTimers = self:CreateTimer(self.TIME_FPS_REFRESH_WAIT, self.RefreshNpc, self, nNumber, 1);
		return 1;
	end
	
	self.tbRefreshNpcNumber = 0;
	if (self:IsOpen() ~= 1)then
		return 0;
	end	
	if type(TowerDefence.NPC_TYPE_ID[nNumber]) == "table" then
		--不是boss波	
		self:BroadcastBlackBoardMsg(string.format("Lượt quái thứ %s bắt đầu tấn công!",nNumber));
		self.tbRefreshNpcTimers = self:CreateTimer(self.TIME_FPS_REFRESH_NPC, self.RefreshNpcEx, self, nNumber);
	else
		--是boss波
		self:RefreshBoss(nNumber, 1,  0);
	end
	--刷符
--	Lib:SmashTable(self.tbPosition_fu);
--	for i = 1, Lib:CountTB(self:GetPlayerList()) do
--		local nNpcId = Random(5) + 6687;
--		local pNpc = KNpc.Add2(nNpcId, 1, -1, self.nMapId, self.tbPosition_fu[i][1], self.tbPosition_fu[i][2]);
--		if pNpc then
--			pNpc.SetLiveTime(Env.GAME_FPS * 60);
--		end
--	end
	return 0;
end

--定时加军饷
function tbMission:AddMoney(nNumber)
	local nMoney = 1;
	if math.fmod(nNumber, 5) == 0 then
		nMoney = 2;
	end
	self:BroadcastBlackBoardMsg("Nghĩa quân phát động tấn công toàn lực!");
	for nGroup=1, self:GetGroupNum() do
		for _, pPlayer in pairs(self:GetPlayerList(nGroup)) do
			pPlayer.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_MONEY, 
				pPlayer.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_MONEY) + self.MONEY_PER[nMoney] + nNumber * 4 );		
		end
	end
	self:GenerateAndSendMsg();
end

--发黑色广告
function tbMission:BroadcastBlackBoardMsg(szMsg)
	for _, pPlayer in pairs(self:GetPlayerList()) do
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
end

--刷npc(每2秒刷一定个数)
function tbMission:RefreshNpcEx(nNumber)
	for i = 1, #self.tbNpcGenPos do
		local nNumberEx =  math.fmod(self.tbRefreshNpcNumber + 1, #TowerDefence.NPC_TYPE_ID[nNumber]);
		if nNumberEx == 0  then
			nNumberEx = #TowerDefence.NPC_TYPE_ID[nNumber];
		end
		local nNpcId = TowerDefence.NPC_TYPE_ID[nNumber][nNumberEx];
		local x, y = self.tbNpcGenPos[i][1], self.tbNpcGenPos[i][2];
		local pNpc = nil;		
		pNpc = KNpc.Add2(nNpcId, self.NPC_TYPE[nNpcId][2], -1, self.nMapId, x, y);		--等级决定血量光环的
		if pNpc then
			self.tbRefreshNpcId[pNpc.dwId] = 1;
			self:SetNpcMoveAI(nNumber, self.tbRefreshNpcNumber + 1, pNpc.dwId);
			pNpc.GetTempTable("Npc").nType = 0;
			pNpc.GetTempTable("Npc").tbMission = self;
			self.tbRefreshNpcNumber = self.tbRefreshNpcNumber + 1;
			--title
			if self.NPC_TYPE[nNpcId] and self.NPC_TYPE[nNpcId][2] ~= 1 then
				pNpc.SetTitle(self.NPC_TYPE[nNpcId][1]);
			end
			if self.tbRefreshNpcNumber ==  #TowerDefence.NPC_TYPE_ID[nNumber] then
				return 0;
			end
		end
	end

	return;
end

--加载npc行走AI
function tbMission:SetNpcMoveAI(nNumber, nCount, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbNpcMove = {};
	if math.fmod(nCount, 2) == 1 then
		tbNpcMove = self.tbNpcMoveLeft;
	else
		tbNpcMove = self.tbNpcMoveRight;
	end
	for i, tbMovePos in ipairs(tbNpcMove) do
		local nRanX = self.NPC_MOVE_RAD - Random(self.NPC_MOVE_RAD * 2);
		local nRanY = self.NPC_MOVE_RAD - Random(self.NPC_MOVE_RAD * 2);
		pNpc.AI_AddMovePos((tbMovePos[1]) * 32, (tbMovePos[2]) * 32);
	end
	pNpc.SetNpcAI(9, 1, 0, -1, 0, 0, 0, 0, 0, 0, 0);
	pNpc.SetActiveForever(1);
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnDeathNpc, self, nNpcId};
	pNpc.GetTempTable("Npc").tbMission = self;
	self:AttendNpc2Group( nNpcId);
end

--NPC技能Ai
function tbMission:AttendNpc2Group(nNpcId)	
	local nGroup = Random(self.CASTSKILL_GROUP_NUM) + 1;	
	table.insert(self.tbCastSkillGroup[nGroup], nNpcId);
end

--刷boss
function tbMission:RefreshBoss(nNumber, nFlag, nNpcId)		
	local pNpc = nil;
	if nFlag == 1 then
		self:BroadcastBlackBoardMsg("Quỷ Vương xuất hiện, mau ngăn cản trước khi quá muộn!");		
		local nNpcIdEx = TowerDefence.NPC_TYPE_ID[nNumber];
		local x, y = self.REFRESH_BOSS_POINT[1], self.REFRESH_BOSS_POINT[2];		
		pNpc = KNpc.Add2(nNpcIdEx, 4, -1, self.nMapId, x/32, y/32);
		if pNpc then
			pNpc.GetTempTable("Npc").nType = 1;
			pNpc.GetTempTable("Npc").tbMission = self;
		end
	else
		pNpc = KNpc.GetById(nNpcId);
	end
	if pNpc then
		self.nRefreshBossId = pNpc.dwId;
		for i, tbMovePos in ipairs(self.tbBOSSMove) do
			pNpc.AI_AddMovePos(tbMovePos[1]*32, tbMovePos[2]*32);
		end
		pNpc.SetNpcAI(9, 1, 0, -1, 0, 0, 0, 0, 0, 0, 0);
		pNpc.SetActiveForever(1);
		self:AttendNpc2Group(nNpcId);
		pNpc.GetTempTable("Npc").tbOnArrive = { self.RefreshBoss, self, nNumber, 0, pNpc.dwId};	
	end
end


function tbMission:OnJoin(nGroupId)
	local nItemId = self.tbSkillList[me.nId];
	local pItem = KItem.GetObjById(nItemId);
	
	if not pItem or not me.GetItemPos(pItem) then
		self:KickPlayer(me);
		return 0;
	end
	local tbItem = Item:GetClass("td_fuzou");	
	
	for _, nGenId in pairs(tbItem.GEN_SKILL_ATTACK) do
		local nUseSkillId = pItem.GetGenInfo(nGenId, 0);
		if nUseSkillId > 0 and me.IsHaveSkill(nUseSkillId) <= 0 then
			me.AddFightSkill(nUseSkillId, 1);
		end
	end
	if self:GetPlayerCount(nGroupId) == 1 then
		self.nGroupNum = self.nGroupNum + 1;		
		self.tbGroupCaptain[nGroupId] = me.szName;
	end
	
	self:Transform(me, nGroupId);
	me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_MONEY, self.MONEY_START);
	--self.tbTD_EX[me.nId] = {};
	self.tbGrade[nGroupId] = self.tbGrade[nGroupId]  or 0;
	me.SetFightState(1);
	local nGroupIdEx = math.fmod(nGroupId,2);
	me.SetCurCamp(nGroupIdEx);
	--记录玩家技能快捷键并设置新的键
	Player:SaveShotCut(self.tbPlayerShotSkill);
	for i =1, #self.ITEM_SHOTCUT do
		FightSkill:SetShortcutItem(me, i, self.ITEM_SHOTCUT[i], 1);
	end
	--建立自己的积分表
	table.insert(self.tbGrade_player,{me.szName, 0, nGroupId});
	--清除道具（防止玩家非法带进以前的道具）
	self:ClearPlayerItem(me);
	local tbPlayerTempTable = me.GetPlayerTempTable();
	tbPlayerTempTable.tbMission = self;
end

function tbMission:OnLeave(nGroupId, szReason)	
	-- 打回原形
	if me.GetSkillState(self.TRANSFORM_SKILL_ID) > 0 then
		me.RemoveSkillState(self.TRANSFORM_SKILL_ID);
	end
	me.RestoreLife();
	me.LeaveTeam();
	--清除player加的技能
	for i = 1, #self.PLAYER_SKILL_ID do
		if me.IsHaveSkill(self.PLAYER_SKILL_ID[i]) == 1 then
			me.DelFightSkill(self.PLAYER_SKILL_ID[i]);
		end
	end
	--清楚player吃符得到的技能
	for i = 1, #self.PLAYER2NPC_SKILL_ID do
		if me.IsHaveSkill(self.PLAYER2NPC_SKILL_ID[i]) == 1 then
			me.DelFightSkill(self.PLAYER2NPC_SKILL_ID[i]);
		end
	end
	--恢复快捷键	
	Player:RestoryShotCut(self.tbPlayerShotSkill);
	--清掉所有买的东西
	self:ClearPlayerItem(me);
	-- 回到入口处
	me.SetFightState(0);
	Dialog:ShowBattleMsg(me,  0,  0);
	--清掉所有td和人之间的指定关系
	--for _, nTDId in ipairs(self.tbTD_EX[me.nId]) do
	--	if self.tbTD[nTDId] then
	--		self.tbTD[nTDId] = nil;
	--	end
	--end
	--清掉军饷
	me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_MONEY, 0);
	--清光环
	if me.FindTitle(unpack(self.tbFirst_Title)) == 1 then
		me.RemoveTitle(unpack(self.tbFirst_Title));
		me.SetCurTitle(0, 0, 0, 0);
	end
	
	if self.tbOnLevelMision then
		Lib:CallBack(self.tbOnLevelMision);
	end
	
	--self.tbTD_EX[me.nId] = nil;
	if self:GetPlayerCount(nGroupId) == 0 and self.nStateJour < 4  and self.nAwordFlag ~= 1 then -- 全队早退会输掉比赛
		
		if self.nMatchType and self.nMatchType == 2 then			
			for nGroupIdEx, nGrade in pairs(self.tbGrade) do
				if nGroupId == nGroupIdEx then					
					self.tbGrade[nGroupId] = -1;
				end
			end
			--清个人积分
			for i , tbPlayerEx in ipairs(self.tbGrade_player) do
				if me.szName == self.tbGrade_player[i][1] then
					self.tbGrade_player[i][2] = 0;
				end
			end
			if (self:GetPlayerCount(0) > 1) then
				return 0;
			end
		end
		if self.nMatchType ~= 2 then
			self.tbGrade[nGroupId] = -1;
		end
		self.nStateJour = 3;
		self:GoNextState();
	end
	
end

--检查玩家站立的位置是不是能够种植物
function tbMission:CheckeUseItem(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0, 0;
	end
	local _, nX, nY = pPlayer.GetWorldPos();
	for nId, tbPosition in ipairs(self.tbTD_Position) do
		if math.abs(nX - tbPosition[1]) < self.TOWERPOSITIONRAD  and math.abs(nY - tbPosition[2]) < self.TOWERPOSITIONRAD and tbPosition[3] ~= 1 then
			return 1, nId;
		end
	end
	return 0, 0;
end

--种植物
function tbMission:AddTower(nPlayerId, nId, nItemId)
	local pItem = KItem.GetObjById(nItemId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pItem or not pPlayer then
		return 0;
	end
	local nNpcId = TowerDefence.TOWERID[pItem.nParticular - 620][1];		--本来用nlevel做索引对应塔的，之后由于scriptitem的原因改为用nparticular作为索引，所以第一个塔对应的是621和1，所以减去620
	local nX, nY = self.tbTD_Position[nId][1],self.tbTD_Position[nId][2];
	local pNpc = KNpc.Add2(nNpcId, 1, pItem.nParticular - 620, self.nMapId, nX, nY);
	if pNpc then
		self.tbTD_Position[nId][3] = 1;	--该位置被置为占用
		self.tbTD[pNpc.dwId] = {pPlayer.nId, pItem.nParticular - 620};
		self.tbTowerPositionEx[pNpc.dwId] = nId;
		--table.insert(self.tbTD_EX[nPlayerId], pNpc.dwId);
		if pPlayer.GetCurCamp() == 0 then
			pNpc.SetTitle(string.format("Nấm của %s", pPlayer.szName));
		else
			pNpc.SetTitle(string.format("<color=gold>Nấm của %s<color>", pPlayer.szName));
		end
		pNpc.SetCurCamp(pPlayer.GetCurCamp());
		pNpc.GetTempTable("Npc").tbMission = self;
		pNpc.GetTempTable("Npc").nGrade = 1;
		pNpc.GetTempTable("Npc").nCamp = pPlayer.GetCurCamp();
		pNpc.SetMaxLife(self.TOWER_MIN_LIFE_UP[3]);
		self:SpecialTD(nPlayerId);  --塔触发特殊效果
		return 1;
	end
	return 0;
end

--每过多少秒检测一次塔升级,降级
function tbMission:UpDataTower()
	for nNpcId, tbNpc in pairs(self.tbTD) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			local nGrade = pNpc.GetTempTable("Npc").nGrade;
			if nGrade > 1 and self.TOWER_MIN_LIFE_UP[nGrade - 1] > pNpc.nCurLife then
				self:UpDataTowerEx(pNpc.dwId, -1);			--降级
			elseif nGrade < 3 and self.TOWER_MIN_LIFE_UP[nGrade+1] <= pNpc.nCurLife then
				self:UpDataTowerEx(pNpc.dwId, 1);				--升级
			end 
		end
	end
	for _, nNpcId in ipairs(self.tbTD_Delete) do
		self.tbTD[nNpcId] = nil;
	end
	self.tbTD_Delete = {};
	--刷新界面（军饷）
	self:GenerateAndSendMsg()
end

--升级塔，换npc
function tbMission:UpDataTowerEx(nNpcId, nTypes)	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then		
		return;
	end
	local nGrade = pNpc.GetTempTable("Npc").nGrade;
	local nMapId, nX ,nY = pNpc.GetWorldPos();
		
	local nPlayerId,nType = self.tbTD[nNpcId][1], self.tbTD[nNpcId][2];
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return
	end	
	local nCamp = pNpc.GetTempTable("Npc").nCamp;
	table.insert(self.tbTD_Delete, nNpcId);
	--self.tbTD[nNpcId] = nil;		--清掉塔的记录
	local nPos = self.tbTowerPositionEx[nNpcId];
	self.tbTowerPositionEx[nNpcId] = nil;	--清掉位置记录
	pNpc.Delete();
	local pNpcEx = KNpc.Add2(TowerDefence.TOWERID[nType][nGrade + nTypes], nGrade + nTypes, nType, nMapId, nX, nY);
	if pNpcEx then
		pNpcEx.GetTempTable("Npc").tbMission = self;
		pNpcEx.GetTempTable("Npc").nGrade = nGrade + nTypes;
		self.tbTD[pNpcEx.dwId] = {nPlayerId, nType};
		self.tbTowerPositionEx[pNpcEx.dwId] = nPos;
		if nCamp == 0 then
			pNpcEx.SetTitle(string.format("Nấm của %s", pPlayer.szName));
		else
			pNpcEx.SetTitle(string.format("<color=gold>Nấm của %s<color>", pPlayer.szName));
		end
		pNpcEx.SetCurCamp(nCamp);
		pNpcEx.GetTempTable("Npc").nCamp = nCamp;
		pNpcEx.SetMaxLife(self.TOWER_MIN_LIFE_UP[3]);
		self:SpecialTD(nPlayerId);		--触发特殊塔效果
	end
end

--检查tower拥有者和点击该tower的plyaer是不是一个组的
function tbMission:CheckTower(nNpcId, nPlayerId)	
	local pNpc = KNpc.GetById(nNpcId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pNpc or not pPlayer then
		return 0;
	end
	if not self.tbTD[nNpcId] then
		return 0;
	end
	local nPlayerIdEx = self.tbTD[nNpcId][1];	
	local pPlayerEx = KPlayer.GetPlayerObjById(nPlayerIdEx);
	if not pPlayerEx then
		return 2;
	end
	if pPlayerEx.nTeamId ~= pPlayer.nTeamId then
		return 2;
	end
	return 1;
end

--设置奖励
function tbMission:SetAword()	
	local nResult = 3;	
	if self.tbResult[1][2] > self.tbResult[2][2] then
		nResult = 1;
	elseif self.tbResult[1][2] < self.tbResult[2][2] then
		nResult = 2;
	end
	if self:GetPlayerCount(2) <= 0 then
		nResult = 1;
	end
	if self:GetPlayerCount(1) <= 0 then
		nResult = 2;
	end
	local tbResult_Ex = {};
	for i,tbPlayer in ipairs(self.tbGrade_player) do
		tbResult_Ex[tbPlayer[3]] = tbResult_Ex[tbPlayer[3]] or {};
		table.insert(tbResult_Ex[tbPlayer[3]], self.tbGrade_player[i]);
	end 
	TowerDefence:AwardSingleSport(self:GetPlayerIdList(1), self:GetPlayerIdList(2), nResult, tbResult_Ex);
	self.nAwordFlag = 1;
end

--清楚掉比赛场买的道具
function tbMission:ClearPlayerItem(pPlayer)
	local tbTowerItem = pPlayer.FindClassItemInBags("tower_Item");
	local tbCanteen	=pPlayer.FindClassItemInBags("tower_canteen");
	local tbHoe = pPlayer.FindClassItemInBags("tower_hoe");
	for _,tbItem in ipairs (tbTowerItem) do
		tbItem.pItem.Delete(pPlayer);
	end
	for _,tbItem in ipairs (tbCanteen) do
		tbItem.pItem.Delete(pPlayer);
	end
	for _,tbItem in ipairs (tbHoe) do
		tbItem.pItem.Delete(pPlayer);
	end
end

-- ?pl DoScript("\\script\\mission\\tdgame\\tdgame_mission.lua")
