
Require("\\script\\event\\eventplantform\\plantform_def.lua");

local tbReadyMap = EPlatForm.tbReadyMap or {};
EPlatForm.tbReadyMap = tbReadyMap;

EPlatForm.tbFlagSetReady = {};
--LOGOUT 保护
EPlatForm.tbLogOut = {
	[1] = Mission.LOGOUTRV_DEF_MISSION_ESPORT;             -- 雪仗
	[2] = Mission.LOGOUTRV_DEF_MISSION_DRAGONBOAT;	       -- 龙舟
	[3] = Mission.LOGOUTRV_DEF_MISSION_TOWER;		--植物
	[4] = Mission.LOGOUTRV_DEF_MISSION_CASTLEFIGHT;			-- 城堡之战
	};



local tbMapPk = EPlatForm.tbMapPk or {};
EPlatForm.tbMapPk = tbMapPk;

-- 定义玩家进入事件
function tbReadyMap:OnEnter()
	EPlatForm.MACTH_ENTER_FLAG[me.nId] = 0;
	local nReadyId = 0;
	local szLeagueName = "";
	
	if (EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_MATCH_1) then
		nReadyId = EPlatForm:GetPlayerReadyId(me);
		szLeagueName = me.szName;
	else
		szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, me.szName);
		if not szLeagueName then
			EPlatForm:KickPlayer(me, "您没有战队。");
			return
		end
		nReadyId = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_ATTEND);
	end

	if EPlatForm.ReadyTimerId <= 0 then
		EPlatForm:KickPlayer(me, "不是活动报名时间")
		return
	end
	EPlatForm:SetStateJoinIn(1);
	me.SetFightState(0);	  	--设置战斗状态
	EPlatForm:AddGroupMember(nReadyId, szLeagueName, me.nId, me.szName);
	local nLastFrameTime = tonumber(Timer:GetRestTime(EPlatForm.ReadyTimerId));
	local szMsg = "<color=green>剩余时间：<color=white>%s<color>";
	EPlatForm:OpenSingleUi(me, szMsg, nLastFrameTime);
	EPlatForm:UpdateAllMsgUi(nReadyId, szLeagueName);
	Dialog:SendBlackBoardMsg(me, "进入活动准备场，准备时间结束后，比赛将自动开始。")
	me.Msg("进入活动准备场，<color=yellow>准备时间结束后<color>，你会<color=yellow>自动进入比赛场<color>，请做好准备。");
	local nUsefulTime = 15 * 60 * 18;
	EPlatForm:SyncAdvMatchUiSingle(me, nReadyId, nUsefulTime)
	EPlatForm:WriteLog(string.format("玩家进入%s号准备场:%s", nReadyId, me.nMapId), me.szName)
end

-- 定义玩家离开事件
function tbReadyMap:OnLeave()
	if EPlatForm.MACTH_ENTER_FLAG[me.nId] == 1 then
		EPlatForm.MACTH_ENTER_FLAG[me.nId] = nil;
		return 0;
	end
	local szLeagueName = "";
	EPlatForm:LeaveGame();
	local nReadyId = 0;
	if (EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_MATCH_1) then
		nReadyId = EPlatForm:GetPlayerReadyId(me);
		szLeagueName = me.szName;
	else
		szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, me.szName);
		if not szLeagueName then
			return 0;
		end
		nReadyId = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_ATTEND);
	end
	if nReadyId <= 0 then
		return 0
	end
	--if EPlatForm.GameState == 1 then
	EPlatForm:DelGroupMember(nReadyId, szLeagueName, me.nId);
	EPlatForm:CloseSingleUi(me)
	EPlatForm:UpdateAllMsgUi(nReadyId, szLeagueName);
	EPlatForm:SyncAdvMatchUiSingle(me, nReadyId, 0);
	--end
end

function tbMapPk:OnEnter2()
	EPlatForm:SetStateJoinIn(1);	
	local nType = EPlatForm:GetMacthType();
	if nType > 0 then
		me.SetLogOutState(EPlatForm.tbLogOut[nType]); 		
	end
	local nSession = EPlatForm:GetMacthSession();
	if me.GetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_PLAYER_SESSION) < nSession then
		me.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_PLAYER_SESSION, nSession);
		Achievement:FinishAchievement(me, 37);
		Achievement:FinishAchievement(me, 38);
	end
end

function tbMapPk:OnLeave()
	local szLeagueName = "";
	local nReadyId = 0;
	local nDynId = 0;
	EPlatForm:LeaveGame();
	EPlatForm:CloseSingleUi(me)
	nReadyId = EPlatForm:GetPlayerReadyId(me);
	nDynId = EPlatForm:GetPlayerDynId(me);

	if (EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_MATCH_1) then
		szLeagueName = me.szName;
	else
		szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, me.szName);
		if nReadyId <=0 or not EPlatForm.MissionList or not EPlatForm.MissionList[nReadyId] or 
		not EPlatForm.MissionList[nReadyId][nDynId] or EPlatForm.MissionList[nReadyId][nDynId]:IsOpen() ~= 1 then
			return 0;
		end
	end	
	
	if not szLeagueName then
		return 0;
	end
	-- 去除身上的道具效果
	local nRankSession	= EPlatForm:GetMacthSession();
	local tbMacthCfg 	= EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType(nRankSession));
	if (tbMacthCfg and tbMacthCfg.tbMacthCfg and tbMacthCfg.tbMacthCfg.tbJoinItem) then
		for i, tbItemInfo in pairs(tbMacthCfg.tbMacthCfg.tbJoinItem) do
			if (tbItemInfo.tbItemSkill and tbItemInfo.tbItemSkill[1]) then
				if me.GetSkillState(tbItemInfo.tbItemSkill[1]) > 0 then
					me.RemoveSkillState(tbItemInfo.tbItemSkill[1]);
				end
			end
		end
	end

	if EPlatForm.MissionList[nReadyId] and 
		EPlatForm.MissionList[nReadyId][nDynId] and 
		EPlatForm.MissionList[nReadyId][nDynId]:IsOpen() == 1 and
		EPlatForm.MissionList[nReadyId][nDynId]:GetPlayerGroupId(me) >= 0 then
		EPlatForm.MissionList[nReadyId][nDynId]:KickPlayer(me);
	end
	EPlatForm:SetPlayerReadyId(me, 0);
	EPlatForm:SetPlayerDynId(me, 0);
end

-- 准备场
function EPlatForm:LoadMapFun_ReadyMap(tbReadyMapList)
	if (not tbReadyMapList) then
		return 0;
	end
	for _, varMap in pairs(tbReadyMapList) do
		local tbBattleMap = Map:GetClass(varMap);
		if (tbBattleMap) then
			for szFnc in pairs(EPlatForm.tbReadyMap) do
				tbBattleMap[szFnc] = EPlatForm.tbReadyMap[szFnc];
			end
		end
	end
end

function EPlatForm:LoadOneMapFun_PkMap(nMapId)
	local tbBattleMap = Map:GetClass(nMapId);
	if (not tbBattleMap) then
		return;
	end
	for szFnc in pairs(EPlatForm.tbMapPk) do
		tbBattleMap[szFnc] = EPlatForm.tbMapPk[szFnc];
	end	
end

function EPlatForm:LoadMapFun_PkMap(tbPkMapIdList)
	if (not tbPkMapIdList) then
		return 0;
	end
	for _, varMap in pairs(tbPkMapIdList) do
		if type(varMap) == "table" then
			for nMapId = varMap[1], varMap[2] do
				self:LoadOneMapFun_PkMap(nMapId);
			end
		else
			self:LoadOneMapFun_PkMap(varMap);
		end
	end
end

function EPlatForm:LoadMapTable()	
	for nSession, tbInfo in pairs(EPlatForm.SEASON_TB) do
		local tbMCfg		= EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType(nSession));
		if (tbMCfg) then
			if (not self.tbFlagSetReady[nSession]) then
				self:LoadMapFun_ReadyMap(tbMCfg.tbReadyMap);
				self:LoadMapFun_PkMap(tbMCfg.tbMacthMap);
				self.tbFlagSetReady[nSession] = 1;			
			end
		end
	end
end

if (MODULE_GAMESERVER) then
	ServerEvent:RegisterServerStartFunc(EPlatForm.LoadMapTable, EPlatForm);
end
