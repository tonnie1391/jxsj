-- 文件名　：relation_gc.lua
-- 创建者　：furuilei
-- 创建时间：2009-08-03 10:25:21
-- 功能描述：gamecenter的人际关系逻辑

if (not MODULE_GC_SERVER) then
	return;
end

-- 判断是否可以添加关系
function Relation:CheckCanAddRelation(nAppId, nDstId, nType, nRole)
	-- 对方不在线
	local nDstOnline = KGCPlayer.OptGetTask(nDstId, KGCPlayer.TSK_ONLINESERVER);
	if (nDstOnline <= 0) then
		self:SetInfoMsg("对方玩家不在线。");
		return self.emKEPLAYER_NOTONLINE;
	end
	
	-- 数据没有加载完
	local nAppIsLoadEnd = KRelation.CheckIsLoadEnd(nAppId);
	local nDstIsLoadEnd = KRelation.CheckIsLoadEnd(nDstId);
	if (nAppIsLoadEnd == 0 or nDstIsLoadEnd == 0) then
		self:SetInfoMsg("玩家数据没有加载完成。");
		return self.emKEADDRELATION_FAIL;
	end
	
	-- 检查冲突和依赖关系
	local nCheckDepRep = self:CheckCreateDepRep(nType, nRole, nAppId, nDstId);
	if (0 == nCheckDepRep) then
		return self.emKEADDRELATION_FAIL;
	end	
	
	-- 是否可以添加关系
	local nCanAddRelation = self:CanCreateRelation(nType, nRole, nAppId, nDstId);
	if (nCanAddRelation == 0) then
		return self.emKEADDRELATION_FAIL;
	end
	
	return self.emKEADDRELATION_SUCCESS;
end

-- 添加关系
function Relation:AddRelation_GC(szAppName, szDstName, nType, nRole)
	local nAppId = KGCPlayer.GetPlayerIdByName(szAppName);
	local nDstId = KGCPlayer.GetPlayerIdByName(szDstName);
	if (not nAppId or not nDstId or nAppId <= 0 or nDstId <= 0) then
		return;
	end
	
	self:ClearInfoMsg();
	
	local nResult = self:CheckCanAddRelation(nAppId, nDstId, nType, nRole);
	if (nResult == self.emKEADDRELATION_SUCCESS) then
		nResult = KRelation.CreateRelation(nType, nAppId, nDstId, nRole);
		if (nResult == 1) then
			Relation:ProcessAfterAddRelation_GC(nType, nRole, nAppId, nDstId);
			
			-- 添加人际成功后的提示信息
			local szType = self.tbRelationName[nType] or "";
			local szMsg = string.format("您已经成功将 %s 添加到%s列表中。", szDstName, szType);
			self:SetInfoMsg(szMsg);
			if nType >= 5 and nType <= 9 then
				if (nRole == 0) then
					local szAccount = KGCPlayer.GetPlayerAccount(nAppId);
					StatLog:WriteStatLog("stat_info", "relationship", "create", nDstId, szAccount, szAppName, nType, 0);
				else
					local szAccount = KGCPlayer.GetPlayerAccount(nDstId);
					StatLog:WriteStatLog("stat_info", "relationship", "create", nAppId, szAccount, szDstName, nType, 0);
				end
			end
		end
	end
	
	self:TellPlayerMsg_GC(nAppId);
end

function Relation:AfterAddRelation_GC(nAppId, nDstId, nType)
	if (not nAppId or not nDstId or not nType or
		nAppId <= 0 or nDstId <= 0) then
		return;
	end
	
	GlobalExcute{"Relation:AfterAddRelation_GS", nAppId, nDstId, nType};
end

-- 判断是否可以删除关系
function Relation:CheckCanDelRelation(nAppId, nDstId, nType, nRole)
	-- 数据是否加载完成
	local nAppIsLoadEnd = KRelation.CheckIsLoadEnd(nAppId);
	if (nAppIsLoadEnd == 0) then
		return 0;
	end
	
	-- 检查冲突和依赖关系
	local nCheckDepRep = self:CheckDelDepRep(nType, nRole, nAppId, nDstId);
	if (0 == nCheckDepRep) then
		return 0;
	end
	
	return 1;
end

-- 删除关系
function Relation:DelRelation_GC(nAppId, szDstName, nType, nRole)
	local nDstId = KGCPlayer.GetPlayerIdByName(szDstName);
	if (not nDstId or nAppId == nDstId) then
		return;
	end
	
	self:ClearInfoMsg();
	
	local nCanDelRelation = self:CheckCanDelRelation(nAppId, nDstId, nType, nRole);
	if (1 == nCanDelRelation) then
		if (1 == KRelation.DelRelation(nType, nAppId, nDstId, nRole)) then
			Relation:ProcessAfterDelRelation_GC(nType, nRole, nAppId, nDstId);
			if nType >= 5 and nType <= 9 then
				if (nRole == 0) then
					local szAccount = KGCPlayer.GetPlayerAccount(nAppId);
					local szName = KGCPlayer.GetPlayerName(nAppId);
					StatLog:WriteStatLog("stat_info", "relationship", "remove", nDstId, szAccount, szName, nType, 0);
				else
					local szAccount = KGCPlayer.GetPlayerAccount(nDstId);
					local szName = szDstName;
					StatLog:WriteStatLog("stat_info", "relationship", "remove", nAppId, szAccount, szName, nType, 0);
				end
			end
			if (Player.emKPLAYERRELATION_TYPE_BUDDY ~= nType and Player.emKPLAYERRELATION_TYPE_TRAINED ~= nType) then
				self:ProcessDelGroupFriend(nAppId, szDstName);
			end
		end
	end
	
	self:TellPlayerMsg_GC(nAppId);
end

-- 检查是否可以增加亲密度
function Relation:CheckCanAddFavor(nAppId, nDstId, nFavor, nMethod)
	-- 某一方不在线
	local nDstOnline = KGCPlayer.OptGetTask(nDstId, KGCPlayer.TSK_ONLINESERVER);
	local nAppOnline = KGCPlayer.OptGetTask(nAppId, KGCPlayer.TSK_ONLINESERVER);
	if (nDstOnline <= 0 or nAppOnline <= 0) then
		return 0;
	end
	
	-- 数据没有加载完
	local nAppIsLoadEnd = KRelation.CheckIsLoadEnd(nAppId);
	local nDstIsLoadEnd = KRelation.CheckIsLoadEnd(nDstId);
	if (nAppIsLoadEnd == 0 or nDstIsLoadEnd == 0) then
		return 0;
	end

	return 1;
end

-- 增加亲密度
function Relation:AddFriendFavor_GC(szAppName, szDstName, nFavor, nMethod, bByHand)
	if (not szAppName or not szDstName or szAppName == szDstName or nFavor <= 0) then
		return;
	end
	
	bByHand =  bByHand or 0;
	
	self:ClearInfoMsg();
	
	local nAppId = KGCPlayer.GetPlayerIdByName(szAppName);
	local nDstId = KGCPlayer.GetPlayerIdByName(szDstName);
	
	local nCanAddFavor = self:CheckCanAddFavor(nAppId, nDstId, nFavor, nMethod);
	if (1 == nCanAddFavor) then
		KRelation.ResetLimtWhenCrossDay(nAppId, nDstId);
		KRelation.AddFriendFavor(nAppId, nDstId, nFavor, nMethod,  bByHand);
		KRelation.SyncFriendInfo(nAppId, nDstId);

	end
	
	self:TellPlayerMsg_GC(nAppId);
end

-- 给玩家返还提示信息
function Relation:TellPlayerMsg_GC(nPlayerId)
	if (not nPlayerId or nPlayerId <= 0) then
		return;
	end
	
	-- 没有信息的话，返回
	if (self:CheckInfoMsg() == 0) then
		return;
	end
	local szMsg = self:GetInfoMsg();
	local nOnline = KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_ONLINESERVER);
	if (nOnline > 0) then
		GSExcute(nOnline, {"Relation:TellPlayerMsg_GS", nPlayerId, szMsg});
	end
end

-- 在玩家上线的时候获取密友关系即将一年到期的信息，并且给出玩家提示
function Relation:GetCloseFriendTimeInfo_GC(nPlayerId)
	if (nPlayerId <= 0) then
		return;
	end
	
	local tbTimeInfo = KRelation.GetCloseFriendTimeInfo(nPlayerId);
	if (not tbTimeInfo or Lib:CountTB(tbTimeInfo) == 0) then
		return;
	end
	
	local tbInfo = {};
	for i, v in pairs(tbTimeInfo) do
		-- 如果剩余时间是0，就表示该关系需要删除
		if (v.nTime == 0) then
			KRelation.DelOverTimeRelation(v.nType, nPlayerId, v.nPlayerId, v.bAsMaster);
			if v.nType >= 5 and v.nType <= 9 then
				if (v.bAsMaster == 0) then
					local szAccount = KGCPlayer.GetPlayerAccount(nPlayerId);
					local szName = KGCPlayer.GetPlayerName(nPlayerId);
					StatLog:WriteStatLog("stat_info", "relationship", "remove", v.nPlayerId, szAccount, szName, v.nType, 0);
				else
					local szAccount = KGCPlayer.GetPlayerAccount(v.nPlayerId);
					local szName = KGCPlayer.GetPlayerName(v.nPlayerId);
					StatLog:WriteStatLog("stat_info", "relationship", "remove", nPlayerId, szAccount, szName, v.nType, 0);
				end
			end
		end
		
		-- 把剩余时间的信息通知玩家
		local szPlayerName = KGCPlayer.GetPlayerName(v.nPlayerId);
		if (szPlayerName) then
			local tbTemp = {};
			tbTemp.szPlayerName = szPlayerName;
			tbTemp.nTime = v.nTime;
			tbTemp.nType = v.nType;
			table.insert(tbInfo, tbTemp);
		end
	end
	
	GlobalExcute{"Relation:GetCloseFriendTimeInfo_GS2", nPlayerId, tbInfo};
end

--===================================================

-- 亲密度等级提升之后的回调
function Relation:OnFavorLevelUp(nPlayerAppId, nPlayerDstId, nFavorLevel)
	if (not nPlayerAppId or not nPlayerDstId or not nFavorLevel or
		nPlayerAppId <= 0 or nPlayerDstId <= 0 or nFavorLevel <= 0) then
		return;
	end
	GlobalExcute{"Relation:OnFavorLevelUp_GS", nPlayerAppId, nPlayerDstId, nFavorLevel};
end

-- 增加人际关系之后的通用回调
function Relation:ProcessAfterAddRelation_GC(nType, nRole, nAppId, nDstId)
	if (not nType) then
		return;
	end
	
	-- 临时好友需要特殊处理，因为临时好友双方都同意后会自动换成普通好友关系
	if (nType == Player.emKPLAYERRELATION_TYPE_TMPFRIEND and 
		KRelation.HasRelation(nDstId, nAppId, 2) == 1) then
		nType = Player.emKPLAYERRELATION_TYPE_BIDFRIEND;
	end
	
	GlobalExcute{"Relation:ProcessAfterAddRelation_GS", nType, nRole, nAppId, nDstId};
	
	if (not self.tbClass[nType]) then
		return;
	end
	if (not self.tbClass[nType]["ProcessAfterAddRelation_GC"]) then
		return;
	end
	self.tbClass[nType]:ProcessAfterAddRelation_GC(nRole, nAppId, nDstId);
end

-- 删除人际关系之后的通用回调
function Relation:ProcessAfterDelRelation_GC(nType, nRole, nAppId, nDstId)
	if (not nType) then
		return;
	end
	
	GlobalExcute{"Relation:ProcessAfterDelRelation_GS", nType, nRole, nAppId, nDstId};
	
	if (not self.tbClass[nType]) then
		return;
	end
	if (not self.tbClass[nType]["ProcessAfterDelRelation_GC"]) then
		return;
	end
	self.tbClass[nType]:ProcessAfterDelRelation_GC(nRole, nAppId, nDstId);
end

--=============================================

-- 通用的人际gc调用gs的一个接口
-- 主要是给class下面的各种具体的人际关系调用
function Relation:CallServerScript_Relation(nType, szFunName, tbParam)
	if (not nType or not szFunName or type(szFunName) ~= "string") then
		return;
	end
	
	GlobalExcute{"Relation:ServerScript_Relation", nType, szFunName, tbParam};
end

-- 人际部分，通用的从gs调用的gc函数
function Relation:GCScript_Relation(nType, szFunName, tbParam)
	if (not nType or not szFunName or type(szFunName) ~= "string") then
		return;
	end
	
	if (not self.tbClass[nType]) then
		return;
	end
	if (not self.tbClass[nType][szFunName]) then
		return;
	end
	
	self.tbClass[nType][szFunName](self.tbClass[nType], tbParam);
end

function Relation:DelRelationGroupPlayer(nGroupId, szPlayerName, szDelPlayerName)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end

	if (nGroupId > self.DEF_MAX_RELATIONGROUP_COUNT) then
		return 0;
	end
	
	DelRelationGroupPlayer(nGroupId, szPlayerName, szDelPlayerName);
end

function Relation:CreateRelationGroup(nGroupId, szPlayerName, szRelationGroupName)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end
	
	if (nGroupId > self.DEF_MAX_RELATIONGROUP_COUNT) then
		return 0;
	end
	
	CreateRelationGroup(nGroupId, szPlayerName, szRelationGroupName, string.len(szRelationGroupName));
	self:ApplyPlayerRelationGroup(szPlayerName, nGroupId);
end

function Relation:RenameRelationGroup(nGroupId, szPlayerName, szRelationGroupName)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end

	if (nGroupId > self.DEF_MAX_RELATIONGROUP_COUNT) then
		return 0;
	end
	
	RenameRelationGroup(nGroupId, szPlayerName, szRelationGroupName);
	self:ApplyPlayerRelationGroup(szPlayerName, nGroupId);
end

function Relation:DelRelationGroup(nGroupId, szPlayerName)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end

	if (nGroupId > self.DEF_MAX_RELATIONGROUP_COUNT) then
		return 0;
	end
	
	DelRelationGroup(nGroupId, szPlayerName);
	local tbGroupExist = {};
	for i = 1, self.DEF_MAX_RELATIONGROUP_COUNT do
		local tbGroupList = GetPlayerRelationGroup(szPlayerName, i);
		tbGroupExist[i] = 0;
		if (tbGroupList) then
			tbGroupExist[i] = 1;
		end
	end
	GlobalExcute({"Relation:SyncRelationGroupState_GS", szPlayerName, tbGroupExist});
end

function Relation:ApplyPlayerRelationGroup(szPlayerName, nGroupId)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end
	
	if (nGroupId == -1) then
		for i = 1, self.DEF_MAX_RELATIONGROUP_COUNT do
			local tbGroupList = GetPlayerRelationGroup(szPlayerName, i);
			if (tbGroupList) then
				GlobalExcute({"Relation:SyncPlayerRelationGroup_GS", szPlayerName, i, tbGroupList});
			end
		end
		return 0;
	end
	local tbGroupList = GetPlayerRelationGroup(szPlayerName, nGroupId);
	if (tbGroupList) then
		GlobalExcute({"Relation:SyncPlayerRelationGroup_GS", szPlayerName, nGroupId, tbGroupList});
	end
	return 0;
end

function Relation:AddRelationGroupPlayer(nGroupId, szPlayerName, szAddPlayerName)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end

	if (nGroupId > self.DEF_MAX_RELATIONGROUP_COUNT) then
		return 0;
	end
	
	AddRelationGroupPlayer(nGroupId, szPlayerName, szAddPlayerName);
end

function Relation:SaveAllRelationGroup()
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end
	
	SaveAllRelationGroup()
end

function Relation:ProcessDelGroupFriend(nPlayerId, szDelPlayerName)
	local szPlayer = KGCPlayer.GetPlayerName(nPlayerId);
	if (not szPlayer) then
		return 0;
	end
	for i=1, self.DEF_MAX_RELATIONGROUP_COUNT do
		local nFlag = IsHaveRelationGroup(i, szPlayer);
		if (nFlag == 1) then
			self:DelRelationGroupPlayer(i, szPlayer, szDelPlayerName);
		end
	end
end

GCEvent:RegisterGCServerShutDownFunc(Relation.SaveAllRelationGroup, Relation);

