


--local BiWu = {
--//CONSTANT//--
							--稍微解释下 留给自己看
BiWu.TB_CITY_BIWU_INFO = {		--这里指定 每个城市都用哪个地图,所以:有同城市的不要用同样的擂台ID, 不同城市可以用但不利于调配服务器
				--city	= {bwmap1,bwmap2,....}
					[23] = {167,174},--bianjing
					[24] = {168,175},--fengxiang
					[25] = {169,176},--xiangyang
					[26] = {170,177},--yangzhou
					[27] = {171,178},--chengdu
					[28] = {172,179},--dali
					[29] = {173,180},--linan
						};
								--这里告诉了 每个擂台信息{白方pos点,紫方pos点,观众pos点,[在添加?]}
BiWu.TB_MAPTYPE_MAPDEC = {
								--地图名，		白色			紫色			观众
				[1] = {szName = "武林擂台", tbCampPos = {{1613,3182},{1642,3214},{1657,3169}},},
				[2] = {szName = "铁索栈桥", tbCampPos = {{1594,3187},{1706,3314},{1649,3265}},},
			};

if (not BiWu.TB_MAPID_MAPTYPE) then
	BiWu.TB_MAPID_MAPTYPE = {};
	for nCityId, tbBwMapId in pairs(BiWu.TB_CITY_BIWU_INFO) do
		for i = 1, #tbBwMapId do
			BiWu.TB_MAPID_MAPTYPE[tbBwMapId[i]] = i;
		end;
	end;
end;

--BiWu.TB_MAPID_MAPTYPE = {
--				[167]=1,[168]=1,[169]=1,[170]=1,[171]=1,[172]=1,[173]=1,
--				[174]=2,[175]=2,[176]=2,[177]=2,[178]=2,[179]=2,[180]=2,
--			};
								--这里表示了当前服务器中各擂台情况 是否在比赛,比赛类型,双方在场人数 等等,动态更改;所以要加个保护
								-- 这里还要保存TimerID,当前TimerID是动态分配 Open时保存 Close时 为nil好了(暂时)
								-- 恩,这个table 相当于原来的 MissionV and MissionS(这样有点头绪了吧)
if (not BiWu.tbMission) then
	BiWu.tbMission = {};
end;
			
				
--//TASK//--
BiWu.TSKG_BIWU = 2008;		--任务变量组
BiWu.TSK_SIGNPOSWORLD = 1;	--存储玩家的位置的任务变量 报名时MapID
BiWu.TSK_SIGNPOSX = 2;		--							报名时Xpos
BiWu.TSK_SIGNPOSY = 3;		--							报名时Ypos
	--这个是1V1的，2V2则 COUNT = (nType-1)*4+TSK_COUNT
BiWu.TSK_TB_COUNT = {4, 8, 12, 16, 20, 24};			--各类比赛参加的场次
BiWu.TSK_TB_TOTALWIN = {5, 9, 13, 17, 21, 25};		--各类比赛赢的场次
BiWu.TSK_TB_CURLINKWIN = {6, 10, 14, 18, 22, 26};	--  当前最大连胜场次, 输一次时清0
BiWu.TSK_TB_MAXLINKWIN = {7, 11, 15, 19, 23, 27};	--  历史最大连胜场次, 当前连胜场次超过时 历史连胜 = 当前连胜(赋值)
BiWu.TSK_DEATH_STATE = 28;
		
		--//MISSION//-- 不存在MissionValue了 Ok! 你被灭掉了 去 BiWu.tbMission 找对应吧
BiWu.MISSIONID = 1;	--这个做 CONSTANT了
			
BiWu.TIMER_1 = 20 * Env.GAME_FPS; -- 20秒公布一下战况
BiWu.TIMER_2 = 12 * 60 * Env.GAME_FPS ; --交战总时间为12分钟 ,1分钟报名，1分钟比赛准备，战斗10分钟
BiWu.TIMER_3 = 5 * Env.GAME_FPS; -- 5秒后送出选手
BiWu.GO_TIME = 3; -- 报名时间为1分钟

BiWu.nHideSkillId = 1462;	--观众隐身技能id
BiWu.LimitLevel	= 30;	-- 最小报名擂台等级
--		}


--玩家要求离开游戏
function BiWu:LeaveGame()
	me.SetFightState(0);
	local nCamp = me.GetCamp();--恢复原始阵营
	me.SetCurCamp(nCamp);
	ST_StopDamageCounter();	-- 停止伤害计算
	
	me.DisableChangeCurCamp(0);
--	me.TeamDisableChangeCamp(0);
	me.nPkModel = Player.emKPK_STATE_PRACTISE;--关闭PK开关
	me.nForbidChangePK	= 0;
	me.SetDeathType(0);
	me.RestoreMana();
	me.RestoreLife();
	me.RestoreStamina();
--	me.SetHide(0);			-- 观众恢复非隐形状态
	me.RemoveSkillState(self.nHideSkillId);	--观众恢复非隐形状态
	PARTNER_SetCallOutSwitch(1);	-- 观众允许同伴召唤
	
	me.DisabledStall(0);	--摆摊
	me.ForbitTrade(0);	--交易
	
	me.ForbidEnmity(0);
	me.LeaveTeam();
	
end;

function BiWu:GameOver(tbCurBiWuMapDec)		--仅仅将角色送出擂台
	local PTab,PCount = tbCurBiWuMapDec:GetPlayerList(0)
	for i  = 1, PCount do 
		Setting:SetGlobalObj(PTab[i]);
		tbCurBiWuMapDec:KickPlayer(me);
		local nW = me.GetTask(self.TSKG_BIWU, self.TSK_SIGNPOSWORLD);
		local nX = me.GetTask(self.TSKG_BIWU, self.TSK_SIGNPOSX);
		local nY = me.GetTask(self.TSKG_BIWU, self.TSK_SIGNPOSY);
		me.NewWorld(nW, nX, nY);
		me.SetLogoutRV(0);
		Setting:RestoreGlobalObj();
	end;
end;

function BiWu:JoinCamp(nMapId, nGroupId)
	
	local nW,nX,nY = me.GetWorldPos();
	
	me.SetTask(self.TSKG_BIWU, self.TSK_SIGNPOSWORLD, nW);
	me.SetTask(self.TSKG_BIWU, self.TSK_SIGNPOSX, nX);
	me.SetTask(self.TSKG_BIWU, self.TSK_SIGNPOSY, nY);
	
--	local nNewW = nMapId;
--	local nNewX = self.tbMission[nMapId].tbCampPos[nGroupId][1];
--	local nNewY = self.tbMission[nMapId].tbCampPos[nGroupId][2];
--	
--	me.NewWorld(nNewW, nNewX, nNewY);
	
	self.tbMission[nMapId]:JoinPlayer(me, nGroupId)	--将当前玩家加入mission
	
--	if (nGroupId == 1) then
--		EnterChannel(PlayerIndex, "擂台甲方");
--	elseif (nGroupId == 2) then
--		EnterChannel(PlayerIndex, "擂台乙方");
--	end;

	local szMsg = string.format("%s 已经进入了擂台。",me.szName);
	self.tbMission[nMapId]:BroadcastMsg(szMsg);	--向全组人发消息
end;

function BiWu:SetStateJoinin(nGroupId)

	me.DisableChangeCurCamp(1);--设置与帮会有关的变量，不允许在竞技场战改变某个帮会阵营的操作
--	me.TeamDisableChangeCamp(1);	--组队切换时不重设当前阵营
	me.SetFightState(0);	--设置战斗状态
	
	me.SetLogoutRV(1);		--玩家退出时，保存RV并，在下次等入时用RV(城市重生点，非退出点)
	me.ForbidEnmity(1);	--禁止仇杀
	me.DisabledStall(1);	--摆摊
	me.ForbitTrade(1);		--交易

	me.SetTask(BiWu.TSKG_BIWU, BiWu.TSK_DEATH_STATE, 0);

	--打开PK开关
	if (nGroupId == 3) then
		me.nPkModel = Player.emKPK_STATE_PRACTISE;
--		me.TeamDisableChangeCamp(1)
		me.SetCurCamp(0);
		local _, x, y = me.GetWorldPos();
		me.CastSkill(self.nHideSkillId, 1, x, y);	--释放隐形技能
--		me.SetHide(1)		--观众设置隐形状态 取代旧命令 ChangeOwnFeature(0, 0, -1, -1, -1, -1, -1);
		PARTNER_SetCallOutSwitch(0);					-- 观众禁止同伴召唤
		me.Msg("系统消息：你暂时变为隐身状态。");
	else
		me.nPkModel = Player.emKPK_STATE_CAMP;
--		me.TeamDisableChangeCamp(1)
		me.SetCurCamp(nGroupId);
		ST_StartDamageCounter();	--开始计算伤害
	end;
	me.nForbidChangePK	= 1;
--	DisabledUseTownP(1);	--禁止使用回城符
	--SetDeathType(-1);		--设置为死亡立即重生
end;

--告知擂台擂主比武的号码
function BiWu:OnShowKey(nMapId)
	if (not nMapId) then
		nMapId = self:CheckShowKey();
	end;
	if (nMapId == 0) then
		Dialog:Say(string.format("%s：对不起，你不是本次擂台的擂主之一，我不能告诉你入场号码。", him.szName), {{"Kết thúc đối thoại",self.OnCancel}});
		return 0;
	end;
	
	if (not self.tbMission[nMapId]) then
		Dialog:Say(string.format("%s：对不起，你不是本次擂台的擂主之一，我不能告诉你入场号码。", him.szName), {{"Kết thúc đối thoại",self.OnCancel}});
		return 0;
	end
	
	if (self.tbMission[nMapId].nType <= 1) then
		Dialog:Say(string.format("%s：你申请的比武擂台是1对1的比赛，不需要知道入场号码，你可以直接进场比赛。", him.szName), {{"Kết thúc đối thoại",self.OnCancel}});
		return 0;
	end
	
	local nKey = 0;
	for i = 1, 2 do
		if (me.szName == self.tbMission[nMapId].tbCaptainName[i]) then
			nKey = self.tbMission[nMapId].tbTeamKey[i];
			break
		end;
	end;
	if (nKey == 0) then
		print("it is impossible!!");
		return 0;
	end;
	
	Dialog:Say(string.format("%s：你的选手的入场号码为：<color=red>[%d]<color>，请把该号码通知你的参赛队员，队员只有输入正确该号码才能入场参加比赛，谢谢。", him.szName, nKey), {{"Kết thúc đối thoại",self.OnCancel}});
end


--CheckShowKey 暂时用这个名吧,
--其实应该是看本人是不是擂主，如果是返回擂主约定的场地ID
function BiWu:CheckShowKey()
	local nCityId = SubWorldIdx2ID(SubWorld);			--当前城市ID
	local tbBwMapInfo = self:GetBiWuMapInfo(nCityId);
	local nMapId, tbInfo = 0, {};
	for nMapId, tbInfo in pairs(tbBwMapInfo) do
		if (tbInfo.tbCaptainName and (tbInfo.tbCaptainName[1] == me.szName or tbInfo.tbCaptainName[2] == me.szName)) then
			return nMapId;
		end;
	end;
	return 0;
end;


--获得比武擂台 当前地图(或指定) 的mission value
function BiWu:GetCurMission(nMapId)
	if (not nMapId) then
		nMapId = SubWorldIdx2ID(SubWorld);
	end;
	local tbBiWuMapDec = self.tbMission
	if (not tbBiWuMapDec) then
		tbBiWuMapDec = {};
		self.tbMission = tbBiWuMapDec;
	end;
	
	return self.tbMission[nMapId];
end;


-- //获取当前城市对应的擂台场地信息
-- 
function BiWu:GetBiWuMapInfo(nCityId)
	if (not nCityId) then
		nCityId = me.GetMapId();
	end;
	
	local tbBwMapId = self.TB_CITY_BIWU_INFO[nCityId];	--当前城市对应的比武场地
	local tbBwMapInfo = {};
	for i, nMapId in pairs(tbBwMapId) do
		local nWorldIdx = SubWorldID2Idx(nMapId);
		
		if (nWorldIdx >= 0) then				-- 如果地图未加载就算了
			if (self.tbMission[nMapId] == nil) then
				tbBwMapInfo[nMapId] = {};
			else
				tbBwMapInfo[nMapId] = self.tbMission[nMapId];
			end;
		end;
	end;
	return tbBwMapInfo;
end;

-- //胜利组 胜利次数＋1
--	//当前连胜次数＋1
--	//最大连胜次数如果小于当前连胜次数，则 赋值为当前连胜次数
-- //失败组 当前连胜次数－1
function BiWu:AddWinState(tbCurBiWuMapDec, nGroupId)

	if (nGroupId == 0) then
		return 0;
	end;
	local tbPlayerWin =  tbCurBiWuMapDec:GetPlayerList(nGroupId);
	local nTaskIdWin = self.TSK_TB_TOTALWIN[tbCurBiWuMapDec.nType];
	local nTaskIdCLW = self.TSK_TB_CURLINKWIN[tbCurBiWuMapDec.nType];
	local nTaskIdMLW = self.TSK_TB_MAXLINKWIN[tbCurBiWuMapDec.nType];
	
	for i = 1, #tbPlayerWin do
		Setting:SetGlobalObj(tbPlayerWin[i]);
		me.SetTask(self.TSKG_BIWU, nTaskIdWin, me.GetTask(self.TSKG_BIWU, nTaskIdWin) + 1);
		me.SetTask(self.TSKG_BIWU, nTaskIdCLW, me.GetTask(self.TSKG_BIWU, nTaskIdCLW) + 1);
		if (me.GetTask(self.TSKG_BIWU, nTaskIdCLW) > me.GetTask(self.TSKG_BIWU, nTaskIdMLW)) then
			me.SetTask(self.TSKG_BIWU, nTaskIdMLW, me.GetTask(self.TSKG_BIWU, nTaskIdCLW));
		end;
		Setting:RestoreGlobalObj();
	end;
	local nGroupIdLose = 1;
	if (nGroupId == 1) then
		nGroupIdLose = 2;
	end;
	local tbPlayerLose = tbCurBiWuMapDec:GetPlayerList(nGroupIdLose);
	for i = 1, #tbPlayerLose do
		Setting:SetGlobalObj(tbPlayerLose[i]);
		me.SetTask(self.TSKG_BIWU, nTaskIdCLW, 0);
		Setting:RestoreGlobalObj();
	end;
end;

function BiWu:OnCancel()
end;



-- GM指令
function BiWu:StartGame(nMapId, nType, tbTeamKey, tbCaptainName, tbCaptainId)
	self.tbMission[nMapId]	= Lib:NewClass(self.tbMisBase);
	self.tbMission[nMapId]:InitGame(nMapId, nType, tbTeamKey, tbCaptainName, tbCaptainId);
end

