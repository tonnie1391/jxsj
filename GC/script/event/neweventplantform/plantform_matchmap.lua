-- 文件名　：plantform_matchmap.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:54:39
-- 功能    ：无差别竞技

Require("\\script\\event\\neweventplantform\\plantform_def.lua");

local tbReadyMap = NewEPlatForm.tbReadyMap or {};
NewEPlatForm.tbReadyMap = tbReadyMap;

NewEPlatForm.tbFlagSetReady = {};
--LOGOUT 保护
NewEPlatForm.tbLogOut = {
	[1] = Mission.LOGOUTRV_DEF_MISSION_ESPORT;            	      	-- 雪仗
	[2] = Mission.LOGOUTRV_DEF_MISSION_DRAGONBOAT;	      	-- 龙舟
	[3] = Mission.LOGOUTRV_DEF_MISSION_TOWER;			-- 植物
	[4] = Mission.LOGOUTRV_DEF_MISSION_CASTLEFIGHT;		-- 城堡之战
	};

local tbMapPk = NewEPlatForm.tbMapPk or {};
NewEPlatForm.tbMapPk = tbMapPk;

-- 定义玩家进入事件
function tbReadyMap:OnEnter()
	NewEPlatForm.MACTH_ENTER_FLAG[me.nId] = 0;
	local nReadyId = NewEPlatForm:GetPlayerReadyId(me);
	local szLeagueName = me.GetTaskStr(NewEPlatForm.TASKID_GROUP, NewEPlatForm.TASKID_LEAGUENAME);
	if szLeagueName == "" then
		szLeagueName = me.szName;
	end
	if NewEPlatForm.ReadyTimerId <= 0 then
		NewEPlatForm:KickPlayer(me, "不是活动报名时间")
		return
	end
	NewEPlatForm:SetStateJoinIn(1);
	me.SetFightState(0);	  	--设置战斗状态	
	NewEPlatForm:AddGroupMember(nReadyId, szLeagueName, me.nId);
	local nLastFrameTime = tonumber(Timer:GetRestTime(NewEPlatForm.ReadyTimerId));
	local szMsg = "<color=green>剩余时间：<color=white>%s<color>";
	NewEPlatForm:OpenSingleUi(me, szMsg, nLastFrameTime);	
	Dialog:SendBattleMsg(me, "", 1);
	Dialog:SendBlackBoardMsg(me, "进入活动准备场，准备时间结束后，比赛将自动开始。")
	me.Msg("进入活动准备场，<color=yellow>准备时间结束后<color>，你会<color=yellow>自动进入比赛场<color>，请做好准备。");
	NewEPlatForm:WriteLog(string.format("玩家进入%s号准备场:%s", nReadyId, me.nMapId), me.szName)
end

-- 定义玩家离开事件
function tbReadyMap:OnLeave()
	if NewEPlatForm.MACTH_ENTER_FLAG[me.nId] == 1 then
		NewEPlatForm.MACTH_ENTER_FLAG[me.nId] = nil;
		return 0;
	end	
	NewEPlatForm:LeaveGame();	
	local nReadyId = NewEPlatForm:GetPlayerReadyId(me);
	local szLeagueName = me.GetTaskStr(NewEPlatForm.TASKID_GROUP, NewEPlatForm.TASKID_LEAGUENAME);
	if szLeagueName == "" then
		szLeagueName = me.szName;
	end
	NewEPlatForm:DelGroupMember(nReadyId, szLeagueName, me.nId);
	me.SetTaskStr(NewEPlatForm.TASKID_GROUP, NewEPlatForm.TASKID_LEAGUENAME, "");		--离开要清掉，退出不保留战队信息
	NewEPlatForm:CloseSingleUi(me)
	--end
end

function tbMapPk:OnEnter2()
	NewEPlatForm:SetStateJoinIn(1);	
	local nType = NewEPlatForm:GetMacthType();
	if nType > 0 then
		me.SetLogOutState(NewEPlatForm.tbLogOut[nType]); 		
	end	
end

function tbMapPk:OnLeave()
	local szLeagueName = "";
	local nReadyId = 0;
	local nDynId = 0;
	NewEPlatForm:LeaveGame();
	NewEPlatForm:CloseSingleUi(me)
	nReadyId = NewEPlatForm:GetPlayerReadyId(me);
	nDynId = NewEPlatForm:GetPlayerDynId(me);	
	szLeagueName = me.szName;
	if not szLeagueName then
		return 0;
	end
	-- 去除身上的道具效果
	local nRankSession	= NewEPlatForm:GetMacthSession();
	local tbMacthCfg 	= NewEPlatForm:GetMacthTypeCfg(NewEPlatForm:GetMacthType(nRankSession));
	if (tbMacthCfg and tbMacthCfg.tbMacthCfg and tbMacthCfg.tbMacthCfg.tbJoinItem) then
		for i, tbItemInfo in pairs(tbMacthCfg.tbMacthCfg.tbJoinItem) do
			if (tbItemInfo.tbItemSkill and tbItemInfo.tbItemSkill[1]) then
				if me.GetSkillState(tbItemInfo.tbItemSkill[1]) > 0 then
					me.RemoveSkillState(tbItemInfo.tbItemSkill[1]);
				end
			end
		end
	end

	if NewEPlatForm.MissionList[nReadyId] and 
		NewEPlatForm.MissionList[nReadyId][nDynId] and 
		NewEPlatForm.MissionList[nReadyId][nDynId]:IsOpen() == 1 and
		NewEPlatForm.MissionList[nReadyId][nDynId]:GetPlayerGroupId(me) >= 0 then
		NewEPlatForm.MissionList[nReadyId][nDynId]:KickPlayer(me);
	end
	NewEPlatForm:SetPlayerReadyId(me, 0);
	NewEPlatForm:SetPlayerDynId(me, 0);
end

-- 准备场
function NewEPlatForm:LoadMapFun_ReadyMap(tbReadyMapList)
	if (not tbReadyMapList) then
		return 0;
	end
	for _, varMap in pairs(tbReadyMapList) do
		local tbBattleMap = Map:GetClass(varMap);
		if (tbBattleMap) then
			for szFnc in pairs(NewEPlatForm.tbReadyMap) do
				tbBattleMap[szFnc] = NewEPlatForm.tbReadyMap[szFnc];
			end
		end
	end
end

function NewEPlatForm:LoadOneMapFun_PkMap(nMapId)
	local tbBattleMap = Map:GetClass(nMapId);
	if (not tbBattleMap) then
		return;
	end
	for szFnc in pairs(NewEPlatForm.tbMapPk) do
		tbBattleMap[szFnc] = NewEPlatForm.tbMapPk[szFnc];
	end	
end

function NewEPlatForm:LoadMapFun_PkMap(tbPkMapIdList)
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

function NewEPlatForm:LoadMapTable()	
	for nSession, tbInfo in pairs(NewEPlatForm.SEASON_TB) do
		local tbMCfg		= NewEPlatForm:GetMacthTypeCfg(NewEPlatForm:GetMacthType(nSession));
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
	ServerEvent:RegisterServerStartFunc(NewEPlatForm.LoadMapTable, NewEPlatForm);
end
