if not MODULE_GAMESERVER then
	return;
end

AutoTeam.tbc2sFun = {};
local function RegisterC2SFun(szFunName, fun)
	AutoTeam.tbc2sFun[szFunName] = fun;
end

--c2s call
function AutoTeam:JoinAutoTeam(nTeamType)
	if GLOBAL_AGENT then
		me.Msg("此功能当前禁止使用。");
		return;
	end
	
	if AutoTeam:CanIUseAutoTeam(nTeamType) ~= 1 then
		return;
	end
	GCExecute({ "AutoTeam:AddPlayer", nTeamType, me.nId });
end
RegisterC2SFun("JoinAutoTeam", AutoTeam.JoinAutoTeam);

--c2s call
function AutoTeam:LeaveAutoTeam()
	if GLOBAL_AGENT then
		me.Msg("此功能当前禁止使用。");
		return;
	end
	
	self:RemovePlayer(me, 1, "你退出了自动组队。");
end
RegisterC2SFun("LeaveAutoTeam", AutoTeam.LeaveAutoTeam);

--c2s call
function AutoTeam:OnClientConfirm(nConfirmCode)
	if GLOBAL_AGENT then
		me.Msg("此功能当前禁止使用。");
		return;
	end
	
	if nConfirmCode ~= self.CONFIRM_OK and nConfirmCode ~= self.CONFIRM_REFUSE then
		return;
	end
	GCExecute({ "AutoTeam:OnClientConfirm", me.nId, nConfirmCode });
end
RegisterC2SFun("OnClientConfirm", AutoTeam.OnClientConfirm);

function AutoTeam:RemovePlayer(pPlayer, bNotifyClient, szNotifyMsg)
	GCExecute({ "AutoTeam:RemovePlayer", pPlayer.nId , bNotifyClient, szNotifyMsg});
end

--gc调用此函数
function AutoTeam:RemovePlayer_Callback(nPlayerId, szNotifyMsg)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.Msg(szNotifyMsg);
		pPlayer.CallClientScript({ "AutoTeam:RemovePlayer" });
	end
end

function AutoTeam:OnEnterMap(nMapId)
	if self:IsAllowedMap(nMapId) ~= 1 then
		self:RemovePlayer(me, 1, "由于切换地图，你被移出了自动组队队列!");
	end
end

function AutoTeam:CanIUseAutoTeam(nTeamType)
	if self:DoCommonCheck() ~= 1 then
		return 0;
	end
	
	if self:IsTeamTypeXoyo(nTeamType) == 1 then
		return self:DoXoyoCheck();
	elseif self:IsTeamTypeArmy(nTeamType) == 1 then
		return self:DoArmyCheck(nTeamType);
	else
		return 0;
	end
end

function AutoTeam:DoCommonCheck()
	if me.nLevel < self.MIN_PLAYER_LEVEL then
		Dialog:Say(string.format("你未达到%d级，还是多加修行再使用自动组队功能吧。", self.MIN_PLAYER_LEVEL));
		return 0;
	elseif me.nFaction == 0 then	--必须加入门派
		Dialog:Say("你未加入门派，还是先加入一派再使用自动组队功能吧。");
		return 0;
	elseif self:IsAllowedMap(me.nMapId) ~= 1 then
		Dialog:Say("你当前所在的地图不允许使用自动组队功能。");
		return 0;
	end
	
	return 1;
end

function AutoTeam:DoXoyoCheck()
	local nTimes = XoyoGame:GetPlayerTimes(me);
	if nTimes > 0 then
		return 1;
	else
		Dialog:Say("你已经没有参加逍遥谷的次数了。");
		return 0;
	end
end

function AutoTeam:GetArmyInstancingTemplateId(nTeamType)
	if nTeamType == self.ARMY_FUNIUSHAN then
		return 1;
	elseif nTeamType == self.ARMY_BAIMANSHAN then
		return 2;
	elseif nTeamType == self.ARMY_HAIWANGLINGMU then
		return 3;
	else
		assert(false);
	end
end

function AutoTeam:DoArmyCheck(nTeamType)
	local nMinLevel = 90;
	if me.nLevel < nMinLevel then
		Dialog:Say(string.format("你未达到%d级，不能参加军营副本。", nMinLevel));
		return 0;
	end
	
	local tbManager = Task.tbArmyCampInstancingManager;
	local nInstancingTemplateId = self:GetArmyInstancingTemplateId(nTeamType);
	local tbSetting = tbManager:GetInstancingSetting(nInstancingTemplateId);
	if tbManager:CheckTaskLimit(me, tbSetting.nInstancingEnterLimit_D) == 1 then
		return 1;
	else
		Dialog:Say("你本日进入军营副本的次数已经达到上限。");
		return 0;
	end
end

--GC调用此函数
function AutoTeam:SyncTeamDataToAllClient(tbTeam, szMsgOptional, nPlayerIdNoMsg)
	for _, tbMemberInfo in ipairs(tbTeam.tbMember) do
		local pPlayer = KPlayer.GetPlayerObjById(tbMemberInfo.nId);
		--TO DO: 只序列化一次。需要提供新的脚本接口，类似于CallAllClientScript
		if pPlayer then
			if szMsgOptional and tbMemberInfo.nId ~= nPlayerIdNoMsg then
				pPlayer.Msg(szMsgOptional);
			end
			self:SyncTeamDataInternal(pPlayer, tbTeam);
		end
	end
end

function AutoTeam:ClearClientData(tbPlayerIdArray, szMsgOptional)
	for _, nPlayerId in ipairs(tbPlayerIdArray) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			if szMsgOptional then
				pPlayer.Msg(szMsgOptional);
			end
			self:SyncTeamDataInternal(pPlayer, nil);
		end
	end
end

function AutoTeam:SyncTeamDataInternal(pPlayer, tbTeam)
	assert(pPlayer);
	pPlayer.CallClientScript({ "AutoTeam:ProcessTeamData", tbTeam });
end

function AutoTeam:SyncTeamDataToOneClient(nPlayerId)
	GCExecute({"AutoTeam:SyncTeamDataToOneClient", nPlayerId});
end

--GC调用此函数
function AutoTeam:SyncTeamDataToOneClient_Callback(nPlayerId, tbTeam)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		self:SyncTeamDataInternal(pPlayer, tbTeam);
	end
end

--GC调用此函数
function AutoTeam:OnTeamDone(tbTeam)	
	for _, tbMemberInfo in ipairs(tbTeam.tbMember) do
		local pPlayer = KPlayer.GetPlayerObjById(tbMemberInfo.nId);
		--TO DO: 只序列化一次。需要提供新的脚本接口，类似于CallAllClientScript
		if pPlayer then
			pPlayer.CallClientScript({ "AutoTeam:OnTeamDone", tbTeam });
		end
	end
end

--GC调用此函数
function AutoTeam:TransferPlayer(tbTeam, tbPos)
	local pPlayer = nil;
	local nMapId, nX, nY = unpack(tbPos);
	for n, tbMemberInfo in ipairs(tbTeam.tbMember) do
		pPlayer = KPlayer.GetPlayerObjById(tbMemberInfo.nId);
		if pPlayer and self:IsAllowedMap(pPlayer.nMapId) == 1 then
			pPlayer.NewWorld(nMapId, nX, nY);
		end
	end
end

if not GLOBAL_AGENT then

	function AutoTeam:OnLogin(bExchangeServer)
		if bExchangeServer == 1 then
			--跨服时强制同步一次数据
			self:SyncTeamDataToOneClient(me.nId);
		else
			--正常上线，强制清一次该玩家的自动组队数据，预防gs宕机造成OnLogout未执行到的情况
			 GCExecute({ "AutoTeam:RemovePlayer", me.nId });
		end
	end
	
	function AutoTeam:OnLogout(szLogoutReason)
		if szLogoutReason == "Logout" then
			self:RemovePlayer(me, 0);
		elseif szLogoutReason == "GlobalExchange" then
			self:RemovePlayer(me, 0);
			--跨入全局服的情况还需要强制客户端清除本地数据，因为客户端不会经历OnEnterGame事件
			self:SyncTeamDataInternal(me, nil);
		end
	end
	
	--跨服后要强制同步一次队伍数据到客户端，防止丢数据
	PlayerEvent:RegisterGlobal("OnLogin", AutoTeam.OnLogin, AutoTeam);
	
	--玩家下线时要从组队中清除并同步给其他玩家
	PlayerEvent:RegisterGlobal("OnLogout", AutoTeam.OnLogout, AutoTeam);

end
