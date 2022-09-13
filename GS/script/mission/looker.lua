-- 文件名　：looker.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-07-07 14:42:44
-- 描  述  ：观战

Looker.TSK_GROUP 	= 2099;
Looker.TSK_LOOKER 	= 1;	--观战标志（类型）
Looker.TSK_RE_MAPID = 2;	--离开返回地图Id
Looker.TSK_RE_POSX 	= 3;	--离开返还地图坐标X
Looker.TSK_RE_POSY 	= 4;	--离开返还地图坐标Y
Looker.TSK_MAPID 	= 5;	--进入观战地图Id；
Looker.TSK_LOKKER_KEY = 6;	--激活观战状态
Looker.TSK_PARAM_STR	= {11, 110};	--观战参数（字符型8个汉字）10个；(1个字符型8个任务变量记录,使用10个变量存一个,留2变量)
Looker.TSK_PARAM_INT	= {1001, 1010};	--观战参数（整型）10个；

Looker.DEF_SKILL 	= 1428;	--默认观战隐身技能Id

--离开回调处理
Looker.TYPE = {
	--类型 = {进入观战回调，离开观战回调，观战隐身技能Id}
	[1] = {{"Wlls:LookOnEnterReady"}, 	{"Wlls:LookOnLeaveReady"}, 	1428};	--联赛准备场回调
	[2] = {{"Wlls:LookOnEnterPk"}, 		{"Wlls:LookOnLeavePk"}, 	1428};	--联赛战斗场回调
	[3]	= {{"KinBattle:LookOnEnterPk"},	{"KinBattle:LookOnLeavePk"},1428},
}

--进入观战模式
--pPlayer玩家对象;
--nType特殊类型（1.联赛准备场，2.联赛战斗场，3.无进入和离开回调）;
--nMapId进入地图;nPosX坐标X;nPosY坐标Y;
--nLeaveType离开观战模式类型(0,回到进入前点，1回到指定点);
--tbLeavePos离开指定点{nMapId,nX,nY},离开类型为1时生效,为0时可不填;
--默认接口Looker:Join(me, 3, 4, 1625, 3267, 0); --以观战模式进入稻香村
function Looker:Join(pPlayer, nType, nMapId, nPosX, nPosY, nLeaveType, tbLeavePos)
	if pPlayer.nFightState == 1 then
		pPlayer.Msg("战斗状态不能进入观战。");
		Looker:Leave(pPlayer);
		return 0;
	end
	pPlayer.SetTask(self.TSK_GROUP, self.TSK_LOOKER, nType);
	if nLeaveType then
		local nLeaveMapId, nLeavePosX, nLeavePosY = pPlayer.GetWorldPos();
		if nLeaveType == 1 then
			nLeaveMapId = tbLeavePos[1];
			nLeavePosX	= tbLeavePos[2];
			nLeavePosY	= tbLeavePos[3];
		end
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_RE_MAPID, nLeaveMapId);
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_RE_POSX, nLeavePosX);
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_RE_POSY, nLeavePosY);
	end
	pPlayer.SetTask(self.TSK_GROUP, self.TSK_MAPID, nMapId);
	local nEnterMap = 1;
	if pPlayer.nMapId == nMapId then
		nEnterMap = 0;
	end
	pPlayer.NewWorld(nMapId, nPosX, nPosY);
	if nEnterMap == 0 then
		Looker:MapOnEnter();
	end
end

function Looker:Leave(pPlayer)
	if Looker:IsLooker(pPlayer) <= 0 then
		return 0;
	end
	
	pPlayer.SetLogoutRV(0);
	pPlayer.SetLogOutState(0);
	local nLeaveMapId =	pPlayer.GetTask(self.TSK_GROUP, self.TSK_RE_MAPID);
	local nLeavePosX = pPlayer.GetTask(self.TSK_GROUP, self.TSK_RE_POSX);
	local nLeavePosY = pPlayer.GetTask(self.TSK_GROUP, self.TSK_RE_POSY);
	if nLeaveMapId > 0 and nLeavePosX > 0 and nLeavePosY > 0 then
		pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
		return 0;
	end
	local tbNpc = Npc:GetClass("chefu");
	for _, tbMapInfo in ipairs(tbNpc.tbCountry) do
		if SubWorldID2Idx(tbMapInfo.nId) >= 0 then
			local nRandomPos = MathRandom(1, #tbMapInfo.tbSect)
			nLeaveMapId = tbMapInfo.nId
			nLeavePosX 	= tbMapInfo.tbSect[nRandomPos][1]
			nLeavePosY 	= tbMapInfo.tbSect[nRandomPos][2];
		end
	end
	if nLeaveMapId <= 0 then
			nLeaveMapId = 5;
			nLeavePosX 	= 1580;
			nLeavePosY 	= 3029;		
	end
	local nLeaveMap = 1;
	if pPlayer.nMapId == nLeaveMapId then
		nLeaveMap = 0;
	end
	pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
	if nLeaveMap == 0 then
		Looker:MapOnLeave();
	end
end

function Looker:GetSkillId()
	local nType = me.GetTask(self.TSK_GROUP, self.TSK_LOOKER);
	local nSkillId = self.DEF_SKILL;
	if self.TYPE[nType] and self.TYPE[nType][3] then
		nSkillId = self.TYPE[nType][3];
	end
	return nSkillId;
end

function Looker:MapOnEnter()
	--print("Looker:MapOnEnter", me.szName)
	local nType = me.GetTask(self.TSK_GROUP, self.TSK_LOOKER);
	local nSaveMapId = me.GetTask(self.TSK_GROUP, self.TSK_MAPID);
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	if nSaveMapId ~= nMapId then
		Looker:LogOutRV();
		return 0;
	end
	me.SetLogoutRV(1);
	me.DisableChangeCurCamp(1);	--设置与帮会有关的变量，不允许在竞技场战改变某个帮会阵营的操作
	me.SetFightState(0);	  	--设置战斗状态
	me.ForbidEnmity(1);			--禁止仇杀
	me.DisabledStall(1);		--摆摊
	me.ForbitTrade(1);			--交易
	me.TeamDisable(1);			--禁止组队
	me.TeamApplyLeave();		--离开队伍
	Faction:SetForbidSwitchFaction(me, 1); -- 进入准备场比赛场就不能切换门派
	
	
	
	local nSkillId = Looker:GetSkillId();
	--me.CastSkill(nSkillId, 1, nPosX*32, nPosY*32);
	me.AddSkillState(nSkillId, 1, 1, 12*3600*18);
	me.SetLogOutState(Mission.LOGOUTRV_DEF_LOOKER);
	me.CallClientScript({"Looker:OpenLookerEsc"});
	if self.TYPE[nType] and self.TYPE[nType][1] then
		Lib:CallBack(self.TYPE[nType][1]);
	end
	
end

function Looker:MapOnLeave()
	--print("Looker:MapOnLeave", me.szName)
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	local nType = me.GetTask(self.TSK_GROUP, self.TSK_LOOKER);
	local nSaveMapId = me.GetTask(self.TSK_GROUP, self.TSK_MAPID);
	if nMapId == nSaveMapId then
		if self.TYPE[nType] and self.TYPE[nType][2] then
			Lib:CallBack({unpack(self.TYPE[nType][2])});
		end
		Looker:LogOutRV();
		me.CallClientScript({"Looker:CloseLookerEsc"});
	end
end

function Looker:IsLooker(pPlayer)
	return pPlayer.GetTask(self.TSK_GROUP, self.TSK_LOOKER)
end

function Looker:GetParamInt(nId)
	if nId <= 0 or nId > 10 then
		print("【Looker:GetParam】参数错误", "最多只能允许10个整型参数。");
		return 0;
	end
	
	local nTaskId = self.TSK_PARAM_INT[1] + (nId - 1);
	return me.GetTask(self.TSK_GROUP, nTaskId);
end

function Looker:SetParamInt(nId, nValue)
	if nId <= 0 or nId > 10 then
		print("【Looker:GetParam】参数错误", "最多只能允许10个整型参数。");
		return 0;
	end
	local nTaskId = self.TSK_PARAM_INT[1] + (nId - 1);
	return me.SetTask(self.TSK_GROUP, nTaskId, nValue);
end

function Looker:GetParamStr(nId)
	if nId <= 0 or nId > 10 then
		print("【Looker:GetParam】参数错误", "最多只能允许10个字符串参数。");
		return 0;
	end
	
	local nTaskId = self.TSK_PARAM_STR[1] + (nId - 1)*10;
	return me.GetTaskStr(self.TSK_GROUP, nTaskId);
end

function Looker:SetParamStr(nId, szValue)
	if not szValue then
		return 0;
	end
	if nId <= 0 or nId > 10 then
		print("【Looker:GetParam】参数错误", "最多只能允许10个字符串参数。");
		return 0;
	end
	local nTaskId = self.TSK_PARAM_STR[1] + (nId - 1)*10;
	return me.SetTaskStr(self.TSK_GROUP, nTaskId, szValue);
end

function Looker:LogOutRV()
	local nSkillId = Looker:GetSkillId();
	if me.GetSkillState(nSkillId) > 0 then
		me.RemoveSkillState(nSkillId);
	end
	
	me.SetFightState(0);
	me.SetCurCamp(me.GetCamp());
	me.DisableChangeCurCamp(0);
	me.nForbidChangePK	= 0;
	me.SetDeathType(0);
	me.RestoreMana();
	me.RestoreLife();
	me.RestoreStamina();
	me.DisabledStall(0);	--摆摊
	me.TeamDisable(0);		--禁止组队
	me.ForbitTrade(0);		--交易
	me.ForbidEnmity(0);
	Faction:SetForbidSwitchFaction(me, 0); -- 进入准备场比赛场就切换门派还原
	me.LeaveTeam();
	
	me.SetTask(self.TSK_GROUP, self.TSK_LOOKER, 0);
	me.SetTask(self.TSK_GROUP, self.TSK_MAPID, 0);
	me.SetTask(self.TSK_GROUP, self.TSK_RE_MAPID, 0);
	me.SetTask(self.TSK_GROUP, self.TSK_RE_POSX, 0);
	me.SetTask(self.TSK_GROUP, self.TSK_RE_POSY, 0);	
	for nTask=self.TSK_PARAM_INT[1], self.TSK_PARAM_INT[2] do
		if me.GetTask(self.TSK_GROUP, nTask) ~= 0 then
			me.SetTask(self.TSK_GROUP, nTask, 0);
		end
	end
	for nTask=self.TSK_PARAM_STR[1], self.TSK_PARAM_STR[2] do
		if me.GetTask(self.TSK_GROUP, nTask) ~= 0 then
			me.SetTask(self.TSK_GROUP, nTask, 0);
		end
	end
end
