-- 文件名　：dts_gs.lua
-- 创建者　：jiazhenwei/zounan
-- 创建时间：2009-10-13
-- 描  述  ：大逃杀gs

Require("\\script\\globalserverbattle\\dataosha\\dts_def.lua");
if not MODULE_GAMESERVER then
	return;
end
function DaTaoSha:InitPKMap(nLevel)
	self.tbPKMapManger = self.tbPKMapManger or {};
	for _, nMapId in ipairs(self.MACTH_TYPE[nLevel].tbMacthMap) do 
		self.tbPKMapManger[nLevel] = self.tbPKMapManger[nLevel] or {};
		self.tbPKMapManger[nLevel][nMapId] = 0;
	end
end

function DaTaoSha:InitMatch()
	if GLOBAL_AGENT then
		for nLevel = self.MACTH_PRIM, self.MACTH_ADV do
			if  self.MACTH_TYPE[nLevel] then
				self:InitPKMap(nLevel);
				for _, nMapId in ipairs(self.MACTH_TYPE[nLevel].tbReadyMap) do
					if SubWorldID2Idx(nMapId) >= 0 then
						self.WaitMapMemList[nMapId] = self.WaitMapMemList[nMapId] or {};
						self.WaitMapMemList[nMapId].nLevel = nLevel;
						self.WaitMapMemList[nMapId].tbGroupList = self.WaitMapMemList[nMapId].tbGroupList or {};
					end
				end
			end
		end
	end
end

--分配准备场地图
function DaTaoSha:EnterReadyMap(nReadyMap, tbPlayerList, nFlag)
	local nGroupId = 0;
	self.WaitMapMemList[nReadyMap] = self.WaitMapMemList[nReadyMap] or {};
	self.WaitMapMemList[nReadyMap].tbGroupList = self.WaitMapMemList[nReadyMap].tbGroupList or {};
	if nFlag ~= 1 then
		nGroupId = #self.WaitMapMemList[nReadyMap].tbGroupList + 1;
		self.WaitMapMemList[nReadyMap].tbGroupList[nGroupId] = self.WaitMapMemList[nReadyMap].tbGroupList[nGroupId] or {};
	end	
	local tbPos = self:GetLeaveMapPos();
	for _, nPlayerId in ipairs(tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if  pPlayer then	
			if nFlag ~= 1 then
				pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_GROUPID, nGroupId);
			end
			
			if #tbPlayerList == 1 then
				pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_SHORTCUT10 ,1);
			else
				pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_SHORTCUT10 ,2);
			end	
			
			pPlayer.NewWorld(nReadyMap,unpack(tbPos));
		end
	end
end

function DaTaoSha:MapStateFull(tbPlayerList)
	for _,nPlayerId in ipairs(tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then			
			Dialog:SendBlackBoardMsg(pPlayer, "哎呀，这会想要去寒武遗迹的人实在太多了，您还是等会再来吧！");
		end
	end
end

function DaTaoSha:GetLeaveMapPos()	
	return self.MACTH_TRAP_ENTER[MathRandom(1, 3)];
end

--20秒轮询
function DaTaoSha:CycAsk()
	if  GLOBAL_AGENT then --global服务器执行轮询		
		self:CloseCycAsk();
		for nLevel = self.MACTH_PRIM, self.MACTH_ADV do
			if  self.MACTH_TYPE[nLevel] then
				self:InitPKMap(nLevel);
				for _, nMapId in ipairs(self.MACTH_TYPE[nLevel].tbReadyMap) do
					if SubWorldID2Idx(nMapId) >= 0 then
						self.tbReadyTimer[nMapId] = Timer:Register(self.MACTH_TIME_READY, self.CycAskEX, self, nMapId, nLevel);					
					end
				end
			end
		end
	end
end

function DaTaoSha:CloseCycAsk()
	if  GLOBAL_AGENT then --global服务器执行关闭轮询
		for nLevel = self.MACTH_PRIM, self.MACTH_ADV do 
			if self.MACTH_TYPE[nLevel] then	
				for _, nMapId in ipairs(self.MACTH_TYPE[nLevel].tbReadyMap) do
					if self.tbReadyTimer[nMapId] then
						Timer:Close(self.tbReadyTimer[nMapId]);
						self.tbReadyTimer[nMapId] =nil;
						self:CloseMsg(nMapId);
					end	
				end
			end	
		end
		GlobalExcute{"DaTaoSha:ClearPlayerGrouplist"};
		GCExcute{"DaTaoSha:ClearPlayerGrouplist"};
	end
end	
	

--轮询，找散人和队长
function DaTaoSha:CycAskEX(nMapId, nLevel)
	--结束前半分钟不再开启比赛
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	for _, nTime in pairs(self.CLOSETIME) do
		local nDiffTime = Lib:GetDate2Time(nDate * 10000 + nTime) - GetTime();
		if nDiffTime > 0 and nDiffTime <= 30 then
			return;
		end
	end
	local tbSelectGroupId = {};	
	local nGroupNum = 0;
	local tbPkPlayList =  {};	
	self.WaitMapMemList[nMapId] = self.WaitMapMemList[nMapId] or {};
	self.WaitMapMemList[nMapId].nLevel = nLevel; 	
	self.WaitMapMemList[nMapId].tbGroupList = self.WaitMapMemList[nMapId].tbGroupList or {};	
	--self:UpDataUiMsg2(self.WaitMapMemList[nMapId].tbGroupList, nLevel, nMapId); --20秒倒计时
	self:UpDataUiMsg(self.WaitMapMemList[nMapId].tbGroupList, nLevel, nMapId, 0); --相关信息
	for nGroupId, tbGroup in pairs(self.WaitMapMemList[nMapId].tbGroupList) do
		local nFlag = 1;
		local nNum = #tbPkPlayList+1;
		tbPkPlayList[nNum] = tbPkPlayList[nNum] or {};
		if (#tbGroup == self.PLAYER_TEAM_NUMBER) then
			for i = 1, #tbGroup do
				table.insert(tbPkPlayList[nNum], tbGroup[i]);
			end
			tbSelectGroupId[nGroupId] = 1;
			nGroupNum = nGroupNum + 1;
		elseif #tbGroup > 0 then
			if not tbSelectGroupId[nGroupId] then
				local nNeedNum = self.PLAYER_TEAM_NUMBER - #tbGroup;
				for i = 1, #tbGroup do
					table.insert(tbPkPlayList[nNum], tbGroup[i]);
				end
				tbSelectGroupId[nGroupId] = 1;
				for nGroupIdEx, tbGroupEx in pairs(self.WaitMapMemList[nMapId].tbGroupList) do
					if not tbSelectGroupId[nGroupIdEx] and #tbGroupEx > 0 then
						if #tbGroupEx == nNeedNum then
							for i = 1, #tbGroupEx do
								table.insert(tbPkPlayList[#tbPkPlayList], tbGroupEx[i]);
							end
							tbSelectGroupId[nGroupIdEx] = 1; 
							nGroupNum = nGroupNum + 1;
							nNeedNum = 0;
							nFlag =0;
						elseif #tbGroupEx < nNeedNum then
							for i = 1, #tbGroupEx do
								table.insert(tbPkPlayList[#tbPkPlayList], tbGroupEx[i]);	
							end
							tbSelectGroupId[nGroupIdEx] = 1; 	
							nNeedNum = nNeedNum - #tbGroupEx;
							if #tbPkPlayList[#tbPkPlayList] == self.PLAYER_TEAM_NUMBER then
								nGroupNum = nGroupNum + 1;
								nFlag =0;
							end
						end
					end
				end
			end	
			if nFlag == 1 then
				tbPkPlayList[#tbPkPlayList] = nil;
			end	
		end		
		if nGroupNum == math.floor(self.PLAYER_NUMBER/self.PLAYER_TEAM_NUMBER) then
			local nPkMapId = self:SelectPKMap(nLevel);	--选pk场
			if 0 ~= nPkMapId then        --开mission
				self:DeferTimes(tbPkPlayList, nPkMapId, nLevel, nMapId);     --延迟传入
			end	
			break;
		end	
	end		
end

function DaTaoSha:SelectPKMap(nLevel)
	local nMapIdEx = 0;
	local nFlag = 0;		
	for nMapId, nNum in pairs(self.tbPKMapManger[nLevel]) do	
		if SubWorldID2Idx(nMapId) >= 0 then		
			if 0 == nNum then			
				nFlag = 1;			
				nMapIdEx = nMapId;
				break;
			end
		end
	end
	if 0 == nFlag then
		return 0;
	end	
	return nMapIdEx;
end

--玩家进入pk场
function DaTaoSha:EnterPKGame(tbPkPlayList, nPkMapId, nLevel, nMapId)	
	--local nMonment= 1; --第一阶段	
	--地图置为占用	
	self.tbPKMapManger[nLevel][nPkMapId] = 1;
	self.tbTransferPlayerList = {};
	for _, tbPlayer in ipairs(tbPkPlayList) do
		for i, nPlayerId in ipairs (tbPlayer) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				local nAllTimes = GetPlayerSportTask(pPlayer.nId,self.GBTSKG_DATAOSHA, self.GBTASKID_ATTEND_ALLNUM) or 0;
				SetPlayerSportTask(pPlayer.nId,self.GBTSKG_DATAOSHA, self.GBTASKID_ATTEND_ALLNUM, nAllTimes + 1);
				--self:ClearPlayer(pPlayer);
			end
			table.insert(self.tbTransferPlayerList,nPlayerId);
		end
	end
	
	GlobalExcute{"DaTaoSha:DecreasemoreNum", nMapId, tbPkPlayList};
	
	self.MissionList[nPkMapId] = self.MissionList[nPkMapId] or Lib:NewClass(self.GameMission);	
	self.MissionList[nPkMapId]:Init(nPkMapId,nLevel);
	local nCamp = 1;
	for _, tbPlayer in ipairs(tbPkPlayList) do 	
		local nIsHavePlayer = 0;				
		for i, nPlayerId in ipairs (tbPlayer) do				
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);							
			if pPlayer then	
				self.MissionList[nPkMapId]:JoinGame(pPlayer, nCamp);
				local nGroupId = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_GROUPID);
				nIsHavePlayer = 1;
			end
		end		
		if nIsHavePlayer == 1 then
			nCamp = nCamp + 1;
		end
	end	
	
	self.MissionList[nPkMapId]:StartGame();
	GCExcute{"DaTaoSha:DecreasemoreNum", nMapId, tbPkPlayList};
	self.tbTransferPlayerList = {}
end

function DaTaoSha:ClearPlayer(pPlayer,nLevel)
	-- 删除身上物品	
	local tbBag = {
		Item.ROOM_EQUIP,	-- 装备着的
		Item.ROOM_EQUIPEX,	-- 装备切换空间
		Item.ROOM_MAINBAG,	-- 主背包			
		Item.ROOM_EXTBAG1,	-- 扩展背包1
		Item.ROOM_EXTBAG2,	-- 扩展背包2
		Item.ROOM_EXTBAG3,	-- 扩展背包3
		Item.ROOM_EXTBAGBAR,	-- 扩展背包放置栏
		};
	local tbEquit = {};
	local pItem = nil;
	for i = 1, #tbBag do 
		tbEquit = pPlayer.FindAllItem(tbBag[i]);	
		for _,nIndex in pairs(tbEquit) do 
			pItem = KItem.GetItemObj(nIndex);
			if pItem then
				pItem.Delete(pPlayer);
			end	
		end	
	end
	
	--清同伴(先召回在删)
	Partner:DoPartnerCallBack(pPlayer, 0);
	for i = pPlayer.nPartnerCount, 1, -1 do
		local pPartner = pPlayer.GetPartner(i - 1);
		if pPartner then
			pPlayer.DeletePartner(i - 1);
		end
	end
	
	pPlayer.CostMoney(pPlayer.nCashMoney, 0);
	
	local tbCommSkill = pPlayer.GetFightSkillList(0);
	for _ ,tbSkill in ipairs(tbCommSkill) do 
		if tbSkill.uId ~= 1  then    --不清拳攻击
			pPlayer.DelFightSkill(tbSkill.uId);
		end
	end
	pPlayer.AddFightSkill(281, 1);              -- 加普通怒气
	pPlayer.ClearState(0, 0xffffffff, 0, 1);    --清BUFF
	pPlayer.AddLevel(nLevel - pPlayer.nLevel);
	pPlayer.ResetFightSkillPoint();	-- 重置技能点
	pPlayer.UnAssignPotential();		-- 重置潜能点
	pPlayer.AddFightSkillPoint(-pPlayer.nRemainFightSkillPoint);	-- 清除技能点
	pPlayer.AddPotential(-pPlayer.nRemainPotential);	-- 清除潜能点
	pPlayer.JoinFaction(0);	-- 清除门派
	FightSkill:ClearShortcut(pPlayer, 1);	 --清快捷栏	
	pPlayer.SetTask(2,1,0);         --自动分配潜能点	
	pPlayer.AddFightSkillPoint(pPlayer.nLevel - 1);
	pPlayer.AddPotential(pPlayer.nLevel * 10);
end

function DaTaoSha:DeferTimes(tbPkPlayList, nPkMapId, nLevel, nMapId)
	Timer:Register( Env.GAME_FPS * 10 ,self.DeferTimesEx, self, tbPkPlayList, nPkMapId, nLevel, nMapId);		
	for _, tbPlayer in ipairs(tbPkPlayList) do
		for _, nPlayerId in ipairs(tbPlayer) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				local szMsg = "Sau <color=yellow>%s<color> sẽ bắt đầu!";
				self:OpenSingleUi(pPlayer, szMsg, Env.GAME_FPS * 10);
			end
		end				
	end
end

function DaTaoSha:DeferTimesEx( tbPkPlayList, nPkMapId, nLevel, nMapId)
	if 0 == self:IsSatisfyPlayerNumber(tbPkPlayList, nMapId) then
		self:EnterPKGame(tbPkPlayList, nPkMapId, nLevel, nMapId);
	else			
		for nCaptionId, tbPlayer in pairs(tbPkPlayList) do
			for _, nPlayerId in ipairs(tbPlayer) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer and pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_SHORTCUT10) > 0 then
					Dialog:SendBlackBoardMsg(pPlayer, "Số lượng không đủ, hãy kiên nhẫn chờ đợi!");
					self:CloseSingleUi(pPlayer);
				end
			end
		end
	end
	return 0;
end
--准备场ui界面更新
function DaTaoSha:UpDataUiMsg(tbPlayList, nLevel, nMapId, nNumber)
	if SubWorldID2Idx(nMapId) < 0 then		
		return;
	end
	for _, tbGroupList in pairs(tbPlayList) do			
		local szMsg = "\n<color=green>Thành viên trong nhóm: <color>\n<color=white>";
		for i = 1, #tbGroupList do 
			local pPlayer = KPlayer.GetPlayerObjById(tbGroupList[i]);
			if pPlayer then
				szMsg = szMsg..pPlayer.szName.."\n";
			end
		end
		szMsg = szMsg..string.format("<color>\nSố người tham gia: <color=yellow>%s/%s<color>", self.WaitMapMemList[nMapId].nCount, self.PLAYER_NUMBER);
		for i = 1, #tbGroupList do
			local pPlayer = KPlayer.GetPlayerObjById(tbGroupList[i]);
			if pPlayer then
				if not self.MissionList[pPlayer.nMapId]  or self.MissionList[pPlayer.nMapId]:GetPlayerGroupId(pPlayer) < 0 then
					Dialog:SetBattleTimer(pPlayer, "", 0);							
					local nNumberEx = self.WaitMapMemList[nMapId].tbRange[tbGroupList[i]];					
					if nNumberEx and nNumber and nNumber ~= 0 and nNumberEx > nNumber then
						nNumberEx = nNumberEx - 1;
						self.WaitMapMemList[nMapId].tbRange[tbGroupList[i]] = nNumberEx;
					end					
					local szMsg1 = szMsg..string.format("\nVị trí xếp hàng: <color=white>%s/%s<color>", nNumberEx or -1, self.PLAYER_NUMBER);
					Dialog:SendBattleMsg(pPlayer,  szMsg1, 0);
					Dialog:ShowBattleMsg(pPlayer, 1, 0);
				end
			end
		end
	end
end

function DaTaoSha:UpDataUiMsg2(tbPlayList, nLevel, nMapId)
	local szMsg1 = "大逃杀活动准备中...\n可能会在<color=white>%s<color>后开始！";
	for _, tbGroupList in pairs(tbPlayList) do	
		for i = 1, #tbGroupList do		
			local pPlayer = KPlayer.GetPlayerObjById(tbGroupList[i]);
			if pPlayer then
				Dialog:SetBattleTimer(pPlayer, szMsg1, 20*Env.GAME_FPS);		
			end
		end
	end
end

--开启界面
function DaTaoSha:OpenSingleUi(pPlayer, szMsg, nTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

--关闭界面
function DaTaoSha:CloseSingleUi(pPlayer)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	self:UpdateMsgUi(pPlayer, "");
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--更新界面信息
function DaTaoSha:UpdateMsgUi(pPlayer, szMsg)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SendBattleMsg(pPlayer, szMsg, 0);
end
--传送时判断选定的人是否都在场内
function DaTaoSha:IsSatisfyPlayerNumber(tbPkPlayList, nMapId)	
	local nFlag = 1;
	local  nGroupId = 0;
	for _, tbPlayer in ipairs(tbPkPlayList) do		
		for _, nPlayerId in ipairs(tbPlayer) do	
			nFlag = 1;
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);	
			if pPlayer then
				nGroupId = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_GROUPID);
				if pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_SHORTCUT10) <= 0 then	--没有进入方式的，表示没进比赛场
					return 1;
				end
			else
				return 1;
			end	
			if nGroupId ~= 0 then
				if not self.WaitMapMemList[nMapId].tbGroupList[nGroupId] then
					return 1;
				end 
				for _,nPlayerIdEx in ipairs(self.WaitMapMemList[nMapId].tbGroupList[nGroupId]) do				
					if nPlayerIdEx == nPlayerId then
						nFlag = 0
					end
				end
				if nFlag == 1 then
					return 1;
				end
			end
		end
	end
	return 0;
end

function DaTaoSha:KillNpc(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
end

function DaTaoSha:GetPlayerMission(pPlayer)
	if not pPlayer then
		print("【大逃杀】GetPlayerMission, player为空");
		return;
	end
	local tbMission = self.MissionList[pPlayer.nMapId];
	if not tbMission then
		print("【大逃杀】GetPlayerMission，玩家不在MISSION中");
		return;
	end
	return tbMission;
end

function DaTaoSha:MissionClose(nLevel, nMapId)
	if self.tbPKMapManger and self.tbPKMapManger[nLevel] then
	self.tbPKMapManger[nLevel][nMapId] = 0;	
	end
	self.MissionList[nMapId] = nil;
end

function DaTaoSha:ServerStartFunc()
	self:InitMatch();
	local nTime = tonumber(GetLocalDate("%H%M"));
	if (nTime > self.OPENTIME[1] and nTime <= self.CLOSETIME[1]) or (nTime > self.OPENTIME[2] and nTime <= self.CLOSETIME[2]) then	--时间在早十点到晚九点之间启动服务器	
		self:CycAsk();	
	end
	GCExcute{"DaTaoSha:ResetPlayerTable"};
end

function DaTaoSha:CloseMsg(nMapId)
	local szMsg = "活动已经结束请下个时间点再来参加吧。"
	for _, tbGroup in pairs(self.WaitMapMemList[nMapId].tbGroupList ) do	
		for i = 1, #tbGroup do 	
			local pPlayer = KPlayer.GetPlayerObjById(tbGroup[i]);							
			if pPlayer then	
				self:CloseSingleUi(pPlayer);
				Dialog:SendBlackBoardMsg(pPlayer, szMsg);
			end
		end
	end		
end

function DaTaoSha:CreaseNum(nMapId, nGroupId,  nId, nNumber)
	self.WaitMapMemList[nMapId].nCount = (self.WaitMapMemList[nMapId].nCount or 0) + 1;
	self.WaitMapMemList[nMapId].tbGroupList = self.WaitMapMemList[nMapId].tbGroupList or {};
	self.WaitMapMemList[nMapId].tbGroupList[nGroupId] = self.WaitMapMemList[nMapId].tbGroupList[nGroupId] or {};	
	table.insert(self.WaitMapMemList[nMapId].tbGroupList[nGroupId], nId);	

	self:UpDataUiMsg(self.WaitMapMemList[nMapId].tbGroupList, self.WaitMapMemList[nMapId].nLevel , nMapId, nNumber);
end

function DaTaoSha:DecreaseNum(nMapId, nGroupId,  nId, nNumber)	
	self.WaitMapMemList[nMapId].tbGroupList = self.WaitMapMemList[nMapId].tbGroupList or {};
	self.WaitMapMemList[nMapId].tbGroupList[nGroupId] = self.WaitMapMemList[nMapId].tbGroupList[nGroupId] or {};
	for i, nPlayerId in ipairs( self.WaitMapMemList[nMapId].tbGroupList[nGroupId]) do
		if nPlayerId == nId then
			table.remove(self.WaitMapMemList[nMapId].tbGroupList[nGroupId], i);	
			self.WaitMapMemList[nMapId].nCount = (self.WaitMapMemList[nMapId].nCount or 1) - 1;	
			self.WaitMapMemList[nMapId].tbRange = self.WaitMapMemList[nMapId].tbRange or {};
			self.WaitMapMemList[nMapId].tbRange[nId] = nil;
			break;
		end
	end
	self:UpDataUiMsg(self.WaitMapMemList[nMapId].tbGroupList, self.WaitMapMemList[nMapId].nLevel, nMapId, nNumber);	
end

function DaTaoSha:ClearPlayerGrouplist()
	for nLevel = self.MACTH_PRIM, self.MACTH_ADV do
		if self.MACTH_TYPE[nLevel] then
			for _, nMapId in ipairs(self.MACTH_TYPE[nLevel].tbReadyMap) do	
				self.WaitMapMemList[nMapId] = {};
				self.WaitMapMemList[nMapId].tbRange = {};
				self.WaitMapMemList[nMapId].tbGroupList = {};
				self.WaitMapMemList[nMapId].nCount = 0;
				self.WaitMapMemList[nMapId].nLevel = nLevel;
			end
		end
	end	
end

function DaTaoSha:ResetPlayerTable(tbAllPlayerList)
	self.WaitMapMemList = tbAllPlayerList;
end

function DaTaoSha:UpDataMapInf(nLevel)
	local nCount = 0;
	for nMapId, nNum in pairs(self.tbPKMapManger[nLevel]) do	
		if SubWorldID2Idx(nMapId) >= 0 then
			if 0 == nNum then
				nCount = nCount + 1;
			end
		end
	end
	return nCount;
end

function DaTaoSha:DecreasemoreNum(nMapId, tbPkPlayList)
	for _, tbPlayer in ipairs(tbPkPlayList) do 				
		for i, nPlayerId in ipairs (tbPlayer) do	
			local nGroupId = 0;
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				nGroupId = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_GROUPID);
			end			
			local nNumber = self.WaitMapMemList[nMapId].tbRange[nPlayerId];
			self:DecreaseNum(nMapId, nGroupId,  nPlayerId, nNumber);
		end
	end	
end

--登录累积次数
function DaTaoSha:PlayerOnLogin()
	--上线保护（所有聊天设置可使用）	
	me.SetChannelState(-1, 0);
	
	if GLOBAL_AGENT then
		return 0;
	end
	me.CallClientScript({"DaTaoSha:CloseTimer"});
	if me.nLevel < DaTaoSha.PLAYER_ATTEND_LEVEL  then
		return;
	end
	if me.nFaction <= 0 then
		return;
	end	
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate < DaTaoSha.nStatTime or nNowDate > DaTaoSha.nEndTime then
		return;
	end

	local nData = me.GetTask(self.TASKID_GROUP, self.TASKID_JOIN_DATA);
	local nLimitTimes = me.GetTask(self.TASKID_GROUP, self.TASKID_LIMIT_TIMES);
	local nAttendTimes = GetPlayerSportTask(me.nId,self.GBTSKG_DATAOSHA, self.GBTASKID_ATTEND_ALLNUM) or 0;		
	local nBatch = me.GetTask(self.TASKID_GROUP, self.TASKID_BATCH);
	local nGlobalBatch = GetPlayerSportTask(me.nId,self.GBTSKG_DATAOSHA, self.GBTASKID_BATCH) or 0;	
	--批次
	if nData ~= 0 or nLimitTimes ~= 0 or nAttendTimes ~= 0 then --以前玩过寒武的人
		if nBatch ~= self.nBatch then	--本服批次不等
			for i = 30, 39 do
				me.SetTask(self.TASKID_GROUP, i, 0);
			end
		end
	end
	if nGlobalBatch ~= self.nBatch then		--全局批次不等
		nAttendTimes = 0;
	end
	if nBatch ~= self.nBatch then		--第一次批次不一样改
		me.SetTask(self.TASKID_GROUP, self.TASKID_BATCH, self.nBatch);
		local nCurHonor = PlayerHonor:GetPlayerHonorByName(me.szName, PlayerHonor.HONOR_CLASS_LADDER1, 0);
		if nCurHonor > 0 then
			PlayerHonor:SetPlayerHonorByName(me.szName, PlayerHonor.HONOR_CLASS_LADDER1, 0, 0);
		end
		nLimitTimes = 0;
		nData = 0;
	end
	--end批次
	if nData ~= nNowDate then
		local nRemainTimes = nLimitTimes + self.nDayTime - nAttendTimes;
		if nRemainTimes >= self.nMaxDayTime then
			if nLimitTimes < nAttendTimes + self.nMaxDayTime then	--保护（防止出现设置小于前一天的次数的情况）
				me.SetTask(self.TASKID_GROUP, self.TASKID_LIMIT_TIMES, nAttendTimes + self.nMaxDayTime);
				me.SetTask(self.TASKID_GROUP, self.TASKID_JOIN_DATA, nNowDate);
			end
		else
			me.SetTask(self.TASKID_GROUP, self.TASKID_LIMIT_TIMES, nLimitTimes + self.nDayTime);
			me.SetTask(self.TASKID_GROUP, self.TASKID_JOIN_DATA, nNowDate);
		end
	end	
end

--复活清状态
function DaTaoSha:ClearPlayerDeath(pPlayer)
	local tbPlayerTempTable = pPlayer.GetPlayerTempTable();
	tbPlayerTempTable.tbDts = tbPlayerTempTable.tbDts or {};
	tbPlayerTempTable.tbDts.nDeath = 0;
end

--判定玩家是不是已经死了
function DaTaoSha:IsPlayerDeath(pPlayer)
	local tbPlayerTempTable = pPlayer.GetPlayerTempTable();
	tbPlayerTempTable.tbDts = tbPlayerTempTable.tbDts or {};
	return tbPlayerTempTable.tbDts.nDeath  or 0;		
end

--设置死亡状态
function DaTaoSha:SetPlayerDeath(pPlayer)
	local tbPlayerTempTable = pPlayer.GetPlayerTempTable();
	tbPlayerTempTable.tbDts = tbPlayerTempTable.tbDts or {};
	tbPlayerTempTable.tbDts.nDeath = 1;		
end

function DaTaoSha:ReFreshShotCutalias()	
	local nFlag = me.GetTask(self.TASKID_GROUP, self.TASKID_GROUP_POSY);
	local nFlag_Global = GetPlayerSportTask(me.nId,DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTASKID_SHOTCUT) or 0;
	if nFlag ~= nFlag_Global then
		FightSkill:RefreshShortcutWindow(me);
		me.SetTask(self.TASKID_GROUP, self.TASKID_GROUP_POSY, nFlag_Global);
	end
end

ServerEvent:RegisterServerStartFunc(DaTaoSha.ServerStartFunc, DaTaoSha);
PlayerEvent:RegisterGlobal("OnLogin", DaTaoSha.PlayerOnLogin, DaTaoSha);



---------------------------------------------------------------------------------------------
--奖励同步
function DaTaoSha:AddLadderScore_GS(pPlayer,nAwardType, nKillCount)
	local nAddScore  = DaTaoSha.DEF_AWARD_SCORE[nAwardType];
	nAddScore = nAddScore * 10000 + nKillCount;		--杀人算积分
	if nAddScore and nAddScore > 0 then
		GCExcute({"DaTaoSha:AddLadderScore_GA",  pPlayer.szName,Transfer:GetMyGateway(pPlayer), nAddScore});
	end
end

function DaTaoSha:AddGameResult_GS(pPlayer,nAwardType)
	GCExcute({"DaTaoSha:AddGameResult_GC", pPlayer.nId,nAwardType});
	if nAwardType == 4 and EventManager.IVER_bOpenGiveDaTaoShaExAward == 1 then -- 冠军要随一次
		if MathRandom(100) < self.DEF_AWARD_EXTRA_PROC then
			local nItemId = DaTaoSha.DEF_AWARD_ITEMLIST[5].tbId;
			pPlayer.Msg(string.format("恭喜您获得<color=yellow>%s<color>，请回到本服领取吧。",self.DEF_AWARD_ITEM[nItemId].szName));
			GCExcute({"DaTaoSha:AddGameResult_GC", pPlayer.nId,5});
		end
	end
end

function DaTaoSha:OnRefreshLadder_GS()
	GCExcute({"DaTaoSha:OnRefreshLadder_GA"});
end

function DaTaoSha:CD_ReadyPK(tbPlayerList, nPlayerIdEx)
	local pPlayerEx = KPlayer.GetPlayerObjById(nPlayerIdEx);
	if pPlayerEx then
		Dbg:WriteLog("DaTaoSha ", "Studio", pPlayerEx.szAccount, pPlayerEx.szName, "来回进入场地，捣乱市场繁荣，建议停封处理");
		for _,nPlayerId in ipairs(tbPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				Dialog:SendBlackBoardMsg(pPlayer, string.format("玩家<color=yellow>%s<color>出入场地过于频繁", pPlayerEx.szName));
			end
		end
	end
end
