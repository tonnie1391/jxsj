-- 文件名　：console.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-04-27 16:05:55
-- 描  述  ：
Require("\\script\\mission\\dragonboat\\dragonboat_def.lua");

Esport.DragonBoatConsole = Console:New(Console.DEF_DRAGON_BOAT);
local tbBoat = Esport.DragonBoatConsole;

function tbBoat:Start()
	self.tbCfg ={
		--[准备场Id] = {tbInPos={进入准备场的点},tbOutPos={离开准备场到的地图和点}};
		tbMap 			= {[1532]={tbInPos={1619,3224}},[1533]={tbInPos={1619,3224}},[1534]={tbInPos={1619,3224}}}; --准备场Id,可以多组;	
		nDynamicMap		= 1535;						--动态地图模版Id
		nMaxDynamic 	= 20;				 		--比赛场动态地图加载数量;
		nMaxPlayer  	= 160;						--每个准备场人数上限;
		nMinDynPlayer 	= 6;						--每个比赛场进4人才能开
		nMaxDynPlayer 	= 8;						--每个比赛场最多多少人
		nReadyTime		= 270*18;					--准备场时间(秒);
		tbDyInPos		= Esport.DragonBoat.MAP_POS_START;
	};
	self.tbMissionList = {};
	self.tbPlayerCfg   = {};
	self.tbPlayerMis = self.tbPlayerMis or {};		--玩家Id索引，记录mission；
end

-- tbBoat:Start()


function tbBoat:OnMySignUp()
	
	if self.tbMissionList then
		for _, tbWaitList in pairs(self.tbMissionList) do
			for _, tbMis in pairs(tbWaitList) do
				if tbMis:IsOpen() == 1 then
					tbMis:OnGameOver();
				end
			end
		end
	end
	self.tbMissionList = {};
	self.tbPlayerMis = {};
	self.tbPlayerCfg   = {};
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, "端午节划龙舟比赛已经开始报名了，请尽快去各新手村秦洼处报名参加。报名时间4分30秒！");
	--end
end

--进入活动场后开始活动
function tbBoat:OnMyStart(tbCfg)

	
	--开启前先关闭未关闭的mission
	
	local nWaitMapId	= tbCfg.nWaitMapId;		--准备场Id
	local nDyMapId 	 	= tbCfg.nDyMapId;		--活动场Id
	local tbGroupLists 	= tbCfg.tbGroupLists;	--队伍列表
	self.tbMissionList = self.tbMissionList or {};
	self.tbMissionList[nWaitMapId] = self.tbMissionList[nWaitMapId] or {};	
	self.tbMissionList[nWaitMapId][nDyMapId] = Lib:NewClass(Esport.DragonBoatMission);
	local tbMission = self.tbMissionList[nWaitMapId][nDyMapId];
	tbMission:OnStart(nDyMapId);
	for nGroupId, tbGroup in pairs(tbGroupLists) do
		local nMaxPos = #self.tbCfg.tbDyInPos;
		local tbPos = self.tbCfg.tbDyInPos[MathRandom(1, nMaxPos)];
		tbMission:SetGroupJoinPos(nGroupId, nDyMapId, unpack(tbPos));	
		tbMission:SetGroupLeavePos(nGroupId, self:GetLeaveMapPos());
		for _, nPlayerId in pairs(tbGroup.tbList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then	
				tbMission.tbSkillList[pPlayer.nId] = self.tbSkillList[pPlayer.nId];
				self.tbPlayerMis[pPlayer.nId] = tbMission;
				self.tbPlayerCfg[pPlayer.nId] = {1};
				tbMission:JoinPlayer(pPlayer, nGroupId);
			end
		end
	end
	tbMission:UpdataAllUi();
end

--分组逻辑
function tbBoat:OnGroupLogic(tbCfg)
	local nGroupDivide  = 0;
	local tbKickPlayerList = {};
	for nGroup, tbGroup in ipairs(tbCfg.tbGroupLists) do
		if nGroupDivide == 0 then
			--判断是否够4人
			if not tbCfg.tbGroupLists[nGroup + (self.tbCfg.nMinDynPlayer-1)] then
				--后面不够4组，踢出赛场；
				for nKickGroup = nGroup, #tbCfg.tbGroupLists do
					for _, nPlayerId in pairs(tbCfg.tbGroupLists[nKickGroup]) do
						local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
						if pPlayer then
							table.insert(tbKickPlayerList, pPlayer);
						end
					end
				end
				break;
			end
		end
		for _, nPlayerId in pairs(tbGroup) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			--对象，分配动态地图索引，组号；
			if pPlayer then
				self:OnDyJoin(pPlayer, tbCfg.nDyMapIndex, nGroup);
				nGroupDivide = nGroupDivide + 1;
			end
		end
		if nGroupDivide >= self.tbCfg.nMaxDynPlayer then
			nGroupDivide = 0;
			tbCfg.nDyMapIndex = tbCfg.nDyMapIndex + 1;
		end
	end
	for _, pPlayer in pairs(tbKickPlayerList) do
		self:KickPlayer(pPlayer);
		local szMsg = "你被随机分配到的组中不够6人，不能开启比赛，请下场再次参赛。";
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		pPlayer.Msg(string.format("<color=green>%s<color>",szMsg));
	end
end

--进入准备场地后
function tbBoat:OnJoinWaitMap()
	--print("OnJoinWaitMap", me.szName);
	local tbFind = me.FindItemInBags(unpack(Esport.DragonBoat.ITEM_BOAT_ID));
	if #tbFind < 1 then
		me.Msg("你身上没有龙舟");
		self:KickPlayer(me);
		return 0;
	end
	local pItem = tbFind[MathRandom(1,#tbFind)].pItem;
	self.tbSkillList = self.tbSkillList or {};
	self.tbSkillList[me.nId] = pItem.dwId;
	
	me.ClearSpecialState()			--清除特殊状态
	me.RemoveSkillStateWithoutKind(Player.emKNPCFIGHTSKILLKIND_CLEARDWHENENTERBATTLE) --清除状态
	me.DisableChangeCurCamp(1);		--设置与帮会有关的变量，不允许在竞技场战改变某个帮会阵营的操作
	me.SetFightState(0);	  		--设置战斗状态
	me.SetLogoutRV(1);				--玩家退出时，保存RV并，在下次等入时用RV(城市重生点，非退出点)
	me.ForbidEnmity(1);				--禁止仇杀
	me.ForbidExercise(1);			--禁止切磋
	me.DisabledStall(1);			--摆摊
	me.ForbitTrade(1);				--交易
	me.nPkModel = Player.emKPK_STATE_PRACTISE;--关闭PK开关
	me.TeamDisable(1);				--禁止组队
	me.TeamApplyLeave();			--离开队伍
	me.nForbidChangePK	= 1;	
	
	local szMsg = "<color=green>比赛开始剩余时间：<color=white>%s<color>";
	local nLastFrameTime = self:GetRestTime();
	self:OpenSingleUi(me, szMsg, nLastFrameTime);
	local szBoatMsg = "\n<color=white>你参赛龙舟情况<color>";
	local szTip = Item:GetClass("dragonboat"):GetSkillTip(pItem);
	szBoatMsg = szBoatMsg .. szTip;
	self:UpdateMsgUi(me, szBoatMsg);
	Dialog:SendBlackBoardMsg(me, "您报名参加端午节龙舟比赛，请等待比赛开始！");
	me.SetTask(Esport.DragonBoat.TSK_GROUP, Esport.DragonBoat.TSK_RANK, 0);	--清楚上次排名
end

--离开准备场地后
function tbBoat:OnLeaveWaitMap()
	if self.tbPlayerCfg[me.nId] and self.tbPlayerCfg[me.nId][1] == 1 then
		return 0;
	end
	if self.tbPlayerMis[me.nId] and self.tbPlayerMis[me.nId]:IsOpen() == 1 then
		if self.tbPlayerMis[me.nId]:GetPlayerGroupId(me) > 0 then
			self.tbPlayerMis[me.nId]:KickPlayer(me);
			self.tbPlayerMis[me.nId] = nil;
		end
	end
	self.tbPlayerCfg[me.nId] = nil;
	me.SetFightState(0);
	me.SetCurCamp(me.GetCamp());
	me.DisableChangeCurCamp(0);
	me.nPkModel = Player.emKPK_STATE_PRACTISE;--关闭PK开关
	me.nForbidChangePK	= 0;
	me.DisabledStall(0);	--摆摊
	if me.IsDisabledTeam() == 1 then
		me.TeamDisable(0);--禁止组队
	end	
	me.ForbitTrade(0);		--交易
	me.ForbidEnmity(0);
	me.ForbidExercise(0);
	me.SetLogOutState(0);			--设置还原状态	
end

--进入活动场地
function tbBoat:OnJoin()
	--print("OnJoin", me.szName)
	--me.SetFightState(1);	  		--设置战斗状态
	me.SetCurCamp(1);
	Dialog:SendBlackBoardMsg(me, "10秒后比赛开始，请将龙舟技能放到快捷栏，准备比赛！");
end

--离开活动场地
function tbBoat:OnLeave()
	--print("OnLeave", me.szName);
	--Esport.DragonBoat:LogOutRV();
	--me.SetLogOutState(0);			--设置还原状态	
	
	if self.tbPlayerMis[me.nId] and self.tbPlayerMis[me.nId]:IsOpen() == 1 then
		if self.tbPlayerMis[me.nId]:GetPlayerGroupId(me) > 0 then
			self.tbPlayerMis[me.nId]:KickPlayer(me);
			self.tbPlayerMis[me.nId] = nil;
		end
	end
end
