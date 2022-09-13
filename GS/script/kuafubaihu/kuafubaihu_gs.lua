 -- 文件名　：kuafubaihu_gs.lua
-- 创建者　：zhangjunjie
-- 创建时间：2010-12-14 17:03:05
-- 描述：

if not MODULE_GAMESERVER then
	return;
end


Require("\\script\\kuafubaihu\\kuafubaihu_def.lua")

--小怪的pos
KuaFuBaiHu.tbNpcPos["shiyuelolo"] = {};
local tbNumColSet = {["TRAPX"]=1,["TRAPY"]=1};
local tbData = {};
tbData = Lib:LoadTabFile("\\setting\\kuafubaihu\\pos\\kuafubaihu_xiaoguai.txt", tbNumColSet);
for _, tbRow in ipairs(tbData) do
	local tbPos = {
			nX = tbRow.TRAPX;
			nY = tbRow.TRAPY;
		}
	table.insert(KuaFuBaiHu.tbNpcPos["shiyuelolo"], tbPos);
end	


KuaFuBaiHu.tbMissionList = {}

function KuaFuBaiHu:IsFightMapInServer()	--这个服务器上是否有这个
	local tbMapId = self.tbFightMapIdList[GetServerId()];
	if not tbMapId then
		return 0;
	elseif #tbMapId == 0 then
		return 0;
	else
		return 1;
	end
end


function KuaFuBaiHu:CreateMissions()	--tbGroup为分组信息,为gc传过来的，格式{{nGroupID,{nCamp1,nCamp2,...,}},..,{}}
	local tbMapList = self.tbFightMapIdList[GetServerId()];
	for i=1,#self.tbPlayerGroupInfo[GetServerId()] do
		local tbMis = self.tbMissionList[i] or Lib:NewClass(self.tbMissionBase);
		tbMis.nMisIndex = i;
		self.tbMissionList[i] = tbMis;
		if self.tbMissionList[i]:OnStart(tbMapList[i]) == 0 then	--如果创建mission失败，则将mission移除
			table.remove(self.tbMissionList,i);
		end
	Dbg:WriteLogEx(2, "KuafuBaiHu","KuaFuBaiHu CreateMission", tbMapList[i]);
	end
end


function KuaFuBaiHu:Open()
	for i,tbMis in pairs(self.tbMissionList) do
		tbMis:Begin();
		Dbg:WriteLogEx(2, "KuafuBaiHu","Mission Open", tbMis.nMapId);
	end
end

function KuaFuBaiHu:MissionStop()
	for nMisId,tbMis in pairs(self.tbMissionList) do
		if (tbMis:IsOpen() == 1) then
			tbMis:Close();
			Dbg:WriteLogEx(2, "KuafuBaiHu","Mission Stop", tbMis.nMapId);
		end
	end
end

function KuaFuBaiHu:JoinGame(pPlayer)	--加入mission，如果图满或者超时或者在进入时间内死亡出来不能进入
	local nPlayerServerId,nPlayerMapIndex,nPlayerCampId = self:GetPlayerGroupIndex(pPlayer);
	local tbPos	= KuaFuBaiHu.tbEnterPos[MathRandom(#KuaFuBaiHu.tbEnterPos)];
	if not nPlayerCampId then
		return ;
	end
	local nPlayerMapId = self.tbFightMapIdList[nPlayerServerId][nPlayerMapIndex];
	Dbg:WriteLogEx(2, "KuafuBaiHu", nPlayerMapId,nPlayerServerId,nPlayerMapIndex,nPlayerCampId);
	pPlayer.NewWorld(nPlayerMapId,tbPos.nX /32,tbPos.nY /32);
	return 1;
end

function KuaFuBaiHu:GetPlayerGroupIndex(pPlayer)
	local nPlayerTongId	= pPlayer.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_ID);--帮会id，在本服上进行设置
	local nPlayerUnionId = pPlayer.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_UNION_ID);
	local nPlayerCampId = (nPlayerUnionId ~= 0 and nPlayerUnionId ) or nPlayerTongId; 
	local tbServerGroup	= self.tbPlayerGroupInfo;
	for nIndex,tbGroup in ipairs(tbServerGroup) do
		for nMapIndex,tbServer in ipairs(tbGroup) do
			for i,nId in ipairs(tbServer) do
				if nId == nPlayerCampId then
					return nIndex,nMapIndex,nPlayerCampId;	--返回玩家的帮会分组在那个gs上，对应的地图索引，玩家帮会id
				end
			end
		end
	end
	return;
end

function KuaFuBaiHu:GetMission(nIndex)	--返回对应nindex索引的mission
	if nIndex then
		return self.tbMissionList[nIndex];
	end
end

function KuaFuBaiHu:TransferAllPlayer()	--将玩家全部传回送本服,在新的白虎堂活动开始的时候由GC调用
	local szMsg = "密室已经关闭，请以后再进去！！";
	local tbWaitMapList = self.tbWaitMapIdList[GetServerId()];
	if tbWaitMapList and #tbWaitMapList ~= 0 then
		for _,nWaitMapId in ipairs(tbWaitMapList) do
			local tbPlayer,nCount = KPlayer.GetMapPlayer(nWaitMapId);
			if (nCount > 0) then
				KDialog.Msg2PlayerList(tbPlayer, szMsg, "系统提示");
				for i,pPlayer in pairs(tbPlayer) do
					if (pPlayer.GetCamp() ~= 6) then	-- 不是GM阵营进行传走
						pPlayer.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_CURRENT_GET_SCORES,0);
						Dbg:WriteLogEx(2, "KuafuBaiHu Transfer", pPlayer.szName,pPlayer.nId);
						KuaFuBaiHu:NewWorld2MyServer(pPlayer);
					end
				end
			end
		end
	end
end

function KuaFuBaiHu:ShowTimeInfo(pPlayer,nState)	--显示时间
	if (pPlayer.GetCamp() == 6) then	-- GM阵营
		return;
	end
	local nScoresTotal = pPlayer.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_GB_TOTAL_SCORES);
	local nScoresGet	= pPlayer.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_CURRENT_GET_SCORES) or 0; 
	local szMsg = string.format("<color=yellow>\n您当前的累计积分为:%s\n\n您当前获得的积分为:%s<color>",tostring(nScoresTotal),tostring(nScoresGet));
	Dialog:ShowBattleMsg(pPlayer, 0, 0);
	Dialog:SendBattleMsg(pPlayer, szMsg);
	local nRemainFrame		= Timer:GetRestTime(self.nRegisterLeftTimer);
	local szMsgFormat		= "";
	if nState == KuaFuBaiHu.FIGHTSTATE then
		szMsgFormat = "<color=green>距离活动结束还有：<color> <color=white>%s<color>";
	elseif nState == KuaFuBaiHu.APPLYSTATE then
		szMsgFormat = "<color=green>距离活动开始还有：<color><color=white>%s<color>";
	elseif nState == KuaFuBaiHu.BEFORETRANSCLOSE then
		nRemainFrame= Timer:GetRestTime(self.nRegisterCloseDoorTimer);
		szMsgFormat = "<color=green>距离入口关闭还有：<color><color=white>%s<color>";
	elseif nState == KuaFuBaiHu.RESTSTATE then
		szMsgFormat = "";
	end
	Dialog:SetBattleTimer(pPlayer, szMsgFormat, nRemainFrame);
	Dialog:ShowBattleMsg(pPlayer, 1, 0);
end

function KuaFuBaiHu:ChangeScoresShow(pPlayer)
	if (pPlayer.GetCamp() == 6) then	-- GM阵营
		return;
	end
	local nScoresTotal = pPlayer.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_GB_TOTAL_SCORES);
	local nScoresGet   = pPlayer.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_CURRENT_GET_SCORES) or 0; 
	local szMsg = string.format("<color=yellow>\n您当前的累计积分为:%s\n\n您当前获得的积分为:%s<color>",tostring(nScoresTotal),tostring(nScoresGet));
	Dialog:SendBattleMsg(pPlayer, szMsg);
end

function KuaFuBaiHu:OnPKTimerLeft()
	return 0 ;
end

function KuaFuBaiHu:OnApplyTimerLeft()
	return 0;
end

function KuaFuBaiHu:OnPKTimerCloseDoor()
	return 0;
end

function KuaFuBaiHu:PKStart_GS(tbGroup,nState)
	if nState then
		self.nActionState	= nState;
	else
		self.nActionState	= KuaFuBaiHu.FIGHTSTATE;
	end
	self.tbPlayerGroupInfo = {};
	if tbGroup then	--GC将玩家分组信息广播给每个gs
		self.tbPlayerGroupInfo = tbGroup;
	end
	self.nRegisterLeftTimer = Timer:Register(self.nTotalTimeOut * 60 * Env.GAME_FPS, self.OnPKTimerLeft, self);	--用于时间显示
	self.nRegisterCloseDoorTimer = Timer:Register(self.nTransTimeOut * 60 * Env.GAME_FPS, self.OnPKTimerCloseDoor, self);	--用于时间显示
	self:ProcessFightStart();
	if self:IsFightMapInServer() == 0 then	--如果没有战斗地图，则不创建mission,但时间轴继续走，因为可能该server上有准备场地图
		return;
	end
	self:CreateMissions();
	self:Open();--活动开始pk就开始
	Dbg:WriteLogEx(2, "KuafuBaiHu", "PKStart",self.nActionState);
end

function KuaFuBaiHu:ApplyStart_GS(nState)
	if nState then
		self.nActionState	= nState;
	else
		self.nActionState	= KuaFuBaiHu.APPLYSTATE;
	end
	self.nRegisterLeftTimer = Timer:Register(self.nTransTimeOut * 60 * Env.GAME_FPS, self.OnApplyTimerLeft, self);	--用于时间显示
	self:MissionStop();
	Dbg:WriteLogEx(2, "KuafuBaiHu", "ApplyStart",self.nActionState);
end

function KuaFuBaiHu:PKStop_GS(nState)
	if nState then
		self.nActionState	= nState;
	else
		self.nActionState	= KuaFuBaiHu.RESTSTATE;
	end
	self:MissionStop();
	self:ProcessFightStop();
	Dbg:WriteLogEx(2, "KuafuBaiHu", "PKStop",self.nActionState);
end

function KuaFuBaiHu:ApplyForbidSign_GS(nState)	--开启5分钟后，收到gc广播，无法进入战斗场
	if nState then
		self.nActionState	= nState;
	else
		self.nActionState	= KuaFuBaiHu.FORBIDENTER;
	end
	self:ProcessTransferClose();
	Dbg:WriteLogEx(2, "KuafuBaiHu", "ApplyForbidSign",self.nActionState);
end


function KuaFuBaiHu:ProcessTransferClose() --传送开启5分钟后的通知
	local szMsg = "<color=yellow>跨服白虎PK已经开始5分钟，未进入战斗场地的玩家请下次再来！<color>"
	local tbWaitMapList = self.tbWaitMapIdList[GetServerId()];
	if tbWaitMapList and #tbWaitMapList ~= 0 then
		for _,nWaitMapId in ipairs(tbWaitMapList) do
			local tbPlayer,nCount = KPlayer.GetMapPlayer(nWaitMapId);
			if (nCount > 0) then
				KDialog.Msg2PlayerList(tbPlayer, szMsg, "系统提示");
				for i,pPlayer in pairs(tbPlayer) do
					self:ShowTimeInfo(pPlayer,KuaFuBaiHu.RESTSTATE);
					self:ShowInfoBoard(pPlayer,szMsg);
				end
			end
		end
	end
end


function KuaFuBaiHu:ProcessFightStart()	--处理开始
	--广播pk开始
	local szMsg = "<color=yellow>跨服白虎PK已经开始，请玩家速到<color><color=green>白虎堂亲卫<color><color=yellow>处报名进入战斗场地。<color>"
	local tbWaitMapList = self.tbWaitMapIdList[GetServerId()];
	if tbWaitMapList and #tbWaitMapList ~= 0 then
		for _,nWaitMapId in ipairs(tbWaitMapList) do
			local tbPlayer,nCount = KPlayer.GetMapPlayer(nWaitMapId);
			if (nCount > 0) then
				KDialog.Msg2PlayerList(tbPlayer, szMsg, "系统提示");
				for i,pPlayer in pairs(tbPlayer) do
					self:ShowInfoBoard(pPlayer,szMsg);
					self:ShowTimeInfo(pPlayer,KuaFuBaiHu.BEFORETRANSCLOSE);
				end
			end
		end
	end
end

function KuaFuBaiHu:ProcessFightStop()	--时间到了，清除地图内对象
	local szMsgBoard = string.format("<color=yellow>密室内厅已关闭，请找车夫处回到本服！<color>");
	local szMsgSys	 = string.format("<color=yellow>密室内厅已关闭，请找车夫回到本服。您可在<color=green>白虎堂护卫<color>处用积分兑换宝箱。<color>");
	local tbFightMapList = self.tbFightMapIdList[GetServerId()];
	if tbFightMapList and #tbFightMapList ~= 0 then
		for _,nMapId in ipairs(tbFightMapList) do
			ClearMapObj(nMapId);
			ClearMapNpc(nMapId);	
		end
	end
	local tbWaitMapList = self.tbWaitMapIdList[GetServerId()];
	if tbWaitMapList and #tbWaitMapList ~= 0 then
		for _,nWaitMapId in ipairs(tbWaitMapList) do
			local tbPlayer,nCount = KPlayer.GetMapPlayer(nWaitMapId);
			if (nCount > 0) then
				KDialog.Msg2PlayerList(tbPlayer, szMsgSys, "系统提示");
				for i,pPlayer in pairs(tbPlayer) do
					pPlayer.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_OUT_FOR_DEATH,0);	--将每个玩家死亡标记设置为0
					self:ShowInfoBoard(pPlayer,szMsgBoard);
					self:ShowTimeInfo(pPlayer,KuaFuBaiHu.RESTSTATE);
				end
			end
		end
	end
end

--增加玩家称号，服务器名+帮会名
function KuaFuBaiHu:AddPlayerTitle(pPlayer,nIndex)
	if not pPlayer then
		return 0;
	end
	local szGate = pPlayer.GetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_SERVER_NAME);	--服务器名
	local szGateName = ServerEvent:GetServerNameByGateway(szGate);	--获取中文网关名
	local szTongName = pPlayer.GetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_NAME); --帮会名
	local szTitle = szGateName .. "·" .. szTongName;
	pPlayer.AddSpeTitle(szTitle, GetTime() + 60 * 30, self.GROUP_COLOR[nIndex]);
end

--删除玩家称号
function KuaFuBaiHu:RemovePlayerTitle(pPlayer)
	if not pPlayer then 
		return 0;
	end
	local szGate = pPlayer.GetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_SERVER_NAME);	--服务器名
	local szGateName = ServerEvent:GetServerNameByGateway(szGate);	--获取中文网关名
	local szTongName = pPlayer.GetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_NAME); --帮会名
	local szTitle = szGateName .. "·" .. szTongName;
	pPlayer.RemoveSpeTitle(szTitle);
end

function KuaFuBaiHu:ShowInfoBoard(pPlayer,szMsg)	--向玩家列表发送大字消息
	if pPlayer then
		Dialog:SendBlackBoardMsg(pPlayer, szMsg)
	end
end


-------------gc启动开关------------------------
function KuaFuBaiHu:SwitchKuaFuBaiHu(bOpen)
	if bOpen then
		GCExcute{"KuaFuBaiHu:Switch",bOpen};
	end
end



----测试指令--------------------------------------
function KuaFuBaiHu:ChangeTime_GS(tbTime)
	if tbTime and self.nActionState == self.APPLYSTATE then
		for i , v in ipairs(tbTime) do
			self.tbTimerFunc[i][2] = v;
		end
	end
end



















