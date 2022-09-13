-----------------------------------------------------
--文件名		：	relation_gs.lua
--创建者		：	zouying@kingsoft.net
--创建时间		：	2008-11-06
--功能描述		：	人际关系服务器脚本
------------------------------------------------------
if (not MODULE_GAMESERVER) then
	return;
end

Relation.tbc2sFun = {}
Relation.tbGroupPlayerNum = {};

function Relation:AddAwared(pPlayerApp, szDstName, tbData)
	
	if (not tbData or not szDstName or not pPlayerApp) then
		return 0;
	end
	local nBindCoin = 0;
	local szMsg = "";
	if (tbData.nAwardApp == 1) then
		szMsg = self:GetShowMsg(szDstName, tbData.nLevel, tbData.nAwardCoin, tbData.nAppGiveCount, tbData.nAppLeftCount, tbData.nAppHaveCount);
		pPlayerApp.Msg(szMsg);
		nBindCoin = (tbData.nAppGiveCount + 1)* tbData.nAwardCoin;		
		pPlayerApp.AddBindCoin(nBindCoin, Player.emKBINDCOIN_ADD_RELATION);
	end
	
	return 1;
end

function Relation:GetShowMsg(szDstName, nLevel, nAward, nGiveCount, nLeftCount, nHaveCount)
	local szMsg = string.format("Bạn và <color=yellow>%s<color> độ thân mật đạt cấp %d, nhận được %d %s khóa.", szDstName, nLevel, nAward, IVER_g_szCoinName);
									
	local szMsgInfo = string.format("Ngoài ra, bạn nhận được phần thưởng thân mật cấp 1 của hảo hữu lần thứ %d, số lượng còn có thể nhận <color=yellow>%d lần<color>.", nGiveCount, nLeftCount);
	local szMsgOtherInfo = string.format("Bạn đã nhận thưởng cấp %d %d lần, phần thưởng cấp %d còn lại <color=yellow>%d lần<color>.", nLevel, nHaveCount, nLevel, nLeftCount);
	local szLastMsg = "";					
	if (nGiveCount == 0) then
		szLastMsg = szMsg ..szMsgOtherInfo;
	else
		szLastMsg = szMsg .. szMsgInfo;
	end
	return szLastMsg;
end



function Relation:CanDoRelationOpt(szAppName)
	local szErrMsg = "";
	if (not szAppName) then
		return 0, szErrMsg;
	end
	local pAppPlayer = KPlayer.GetPlayerByName(szAppName);
	if (pAppPlayer.IsAccountLock() ~= 0) then
		szErrMsg = "Tài khoản đang bị khóa, không thể sử dụng chức năng này.";
		return 0, szErrMsg;
	end
	return 1;
end

-- 添加人际关系
-- 参数分别为申请人姓名，对方姓名，关系类型，是否是主位（0表示次位，1表示主位，默认为1）
function Relation:AddRelation_GS(szAppName, szDstName, nType, nRole)
	if (not szAppName or not szDstName or not nType or szAppName == szDstName or
		0 == self:CheckRelationType(nType)) then
		return;
	end
	local pAppPlayer = KPlayer.GetPlayerByName(szAppName);
	if (not pAppPlayer) then
		return;
	end
	local nCanOpt, szErrMsg = self:CanDoRelationOpt(szAppName);
	if (0 == nCanOpt) then
		if ("" ~= szErrMsg) then
			pAppPlayer.Msg(szErrMsg);
		end
		return;
	end
	nRole = nRole or 1;
	if (0 ~= nRole and 1 ~= nRole) then
		nRole = 1;
	end
	if (KPlayer.CheckRelation(szAppName, szDstName, nType) == 1) then
		pAppPlayer.Msg(string.format("Thêm bạn thất bại, bạn và [%s] đã có mối quan hệ với nhau, cần xóa quan hệ hiện tại, mới có thể thêm lần nữa.", szDstName));
		return;
	end
	
	GCExcute{"Relation:AddRelation_GC", szAppName, szDstName, nType, nRole};
end

function Relation:AddRelation_C2S(szDstName, nType, nRole)
	if (0 ~= nType and 1 ~= nType) then
		return;
	end
	-- 跨服状态加好友，将调用加大区好友
	if (IsGlobalServer() and nType == Player.emKPLAYERRELATION_TYPE_TMPFRIEND) then
		Player.tbGlobalFriends:gs_ApplyAddFriend(me.szName, szDstName);
		return;
	end
	local szAppName = me.szName;
	if (not szAppName or not szDstName or not nType or szAppName == szDstName or
		0 == self:CheckRelationType(nType)) then
		return;
	end
	nRole = nRole or 1;
	if (0 ~= nRole and 1 ~= nRole) then
		nRole = 1;
	end
	self:AddRelation_GS(szAppName, szDstName, nType, nRole);
end
Relation.tbc2sFun["AddRelation_C2S"] = Relation.AddRelation_C2S;

-- 删除人际关系
-- 参数分别为申请人姓名，对方姓名，关系类型，是否是主位（0表示次位，1表示主位，默认为1）
function Relation:DelRelation_GS(szAppName, szDstName, nType, nRole)
	if (not szAppName or not szDstName or not nType or szAppName == szDstName or
		0 == self:CheckRelationType(nType)) then
		return;
	end
	local pAppPlayer = KPlayer.GetPlayerByName(szAppName);
	if (not pAppPlayer) then
		return;
	end
	local nCanOpt, szErrMsg = self:CanDoRelationOpt(szAppName);
	if (0 == nCanOpt) then
		if ("" ~= szErrMsg) then
			pAppPlayer.Msg(szErrMsg);
		end
		return;
	end
	nRole = nRole or 1;
	if (0 ~= nRole and 1 ~= nRole) then
		nRole = 1;
	end
	if (KPlayer.CheckRelation(szAppName, szDstName, nType) == 0) then
		return;
	end
	
	GCExcute{"Relation:DelRelation_GC", pAppPlayer.nId, szDstName, nType, nRole};
	
end

function Relation:DelRelation_C2S(szDstName, nType, nRole)
	local szAppName = me.szName;
	if (not szAppName or not szDstName or not nType or szAppName == szDstName or
		0 == self:CheckRelationType(nType)) then
		return;
	end
	nRole = nRole or 1;
	if (0 ~= nRole and 1 ~= nRole) then
		nRole = 1;
	end
	
	-- 某些特殊的关系，不允许通过客户端发送指令来删除
	if (nType == Player.emKPLAYERRELATION_TYPE_COUPLE or
		nType == Player.emKPLAYERRELATION_TYPE_TRAINED or
		nType == Player.emKPLAYERRELATION_TYPE_TRAINING or
		nType == Player.emKPLAYERRELATION_TYPE_BUDDY) then
		return;
	end
	
	self:DelRelation_GS(szAppName, szDstName, nType, nRole);
end
Relation.tbc2sFun["DelRelation_C2S"] = Relation.DelRelation_C2S;

function Relation:ApplyAddRelationGroupPlayer_C2S(nGroupId, szAddPlayerName)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end

	if (nGroupId > self.DEF_MAX_RELATIONGROUP_COUNT) then
		return 0;
	end	
	
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szAddPlayerName);
	if (not nPlayerId or nPlayerId <= 0) then
		me.Msg(string.format("%s không tồn tại"));
		return 0;
	end

	if (IsHaveRelationGroup(nGroupId, me.szName) == 0) then
		Dialog:Say("Chưa tạo nhóm!");
		return 0;
	end	
	
	local tbMyGroup = self.tbGroupPlayerNum[me.szName];
	if (not tbMyGroup) then
		tbMyGroup = {};
		self.tbGroupPlayerNum[me.szName] = tbMyGroup;
	end
	
	local nNum = tbMyGroup[nGroupId] or 0;
	if (nNum >= self.DEF_MAX_RELATIONGROUP_MAX_PLAYER) then
		Dialog:Say("Đã đạt số lượng tối đa.");
		return 0;
	end

	GCExcute{"Relation:AddRelationGroupPlayer", nGroupId, me.szName, szAddPlayerName};
	
	self.tbGroupPlayerNum[me.szName][nGroupId] = nNum + 1;
	me.CallClientScript({"Relation:AddGroupPlayer_Client", nGroupId, szAddPlayerName});
end
Relation.tbc2sFun["ApplyAddRelationGroupPlayer_C2S"] = Relation.ApplyAddRelationGroupPlayer_C2S;

function Relation:DelRelationGroupPlayer_C2S(nGroupId, szDelPlayerName)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end

	if (nGroupId > self.DEF_MAX_RELATIONGROUP_COUNT) then
		return 0;
	end	
	
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szDelPlayerName);
	if (not nPlayerId or nPlayerId <= 0) then
		me.Msg(string.format("%s không tồn tại"));
		return 0;
	end
	local nNum = 0;

	if (IsHaveRelationGroup(nGroupId, me.szName) == 0) then
		Dialog:Say("Chưa tạo nhóm!");
		return 0;
	end

	GCExcute({"DelRelationGroupPlayer", nGroupId, me.szName, szDelPlayerName});

	local tbMyGroup = self.tbGroupPlayerNum[me.szName];
	if (tbMyGroup) then
		nNum = tbMyGroup[nGroupId] or 0;
		nNum = nNum - 1;
		if (nNum < 0) then
			nNum = 0;
		end
		self.tbGroupPlayerNum[me.szName][nGroupId] = nNum;
	end
	me.CallClientScript({"Relation:DelRelationGroupPlayer_Client", nGroupId, szDelPlayerName});
	
	return 0;
end
Relation.tbc2sFun["DelRelationGroupPlayer_C2S"] = Relation.DelRelationGroupPlayer_C2S;

function Relation:ApplyCreateRelationGroup_C2S(nGroupId)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end
	
	if (IsHaveRelationGroup(nGroupId, me.szName) == 1) then
		Dialog:Say("Đã có nhóm, không thể tạo nhóm mới!");
		return 0;
	end
	Dialog:AskString("Hãy nhập tên:", 4, self.OnSureCreateRelationGroup, self, me.szName, nGroupId);
end
Relation.tbc2sFun["ApplyCreateRelationGroup_C2S"] = Relation.ApplyCreateRelationGroup_C2S;

function Relation:OnSureCreateRelationGroup(szPlayerName, nGroupId, szRelationGroupName)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end
	
	if (not szPlayerName or me.szName ~= szPlayerName) then
		return 0;
	end

	if (nGroupId > self.DEF_MAX_RELATIONGROUP_COUNT) then
		return 0;
	end

	if (IsHaveRelationGroup(nGroupId, me.szName) == 1) then
		Dialog:Say("Đã có nhóm không thể tạo nhóm khác!");
		return 0;
	end
	
	local nLen = GetNameShowLen(szRelationGroupName);
	if nLen < 3 or nLen > 8 then
		Dialog:Say("Số lượng ký tự không hợp lệ.");
		return 0;
	end
	
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szRelationGroupName) ~= 1 then
		Dialog:Say("Tên nhóm không hợp lệ");
		return 0;
	end
	
	--是否包含敏感字串
	if IsNamePass(szRelationGroupName) ~= 1 then
		Dialog:Say("Tên nhóm không hợp lệ");
		return 0;
	end
	
	GCExcute({"Relation:CreateRelationGroup", nGroupId, szPlayerName, szRelationGroupName});
end

function Relation:ApplyRenameRelationGroup_C2S(nGroupId)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end

	if (nGroupId > self.DEF_MAX_RELATIONGROUP_COUNT) then
		return 0;
	end
	
	Dialog:AskString("Hãy nhập tên nhóm:", 4, self.OnSureRenameRelationGroup, self, me.szName, nGroupId);
end
Relation.tbc2sFun["ApplyRenameRelationGroup_C2S"] = Relation.ApplyRenameRelationGroup_C2S;

function Relation:OnSureRenameRelationGroup(szPlayerName, nGroupId, szRelationGroupName)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end
	
	if (not szPlayerName or me.szName ~= szPlayerName) then
		return 0;
	end

	if (nGroupId > self.DEF_MAX_RELATIONGROUP_COUNT) then
		return 0;
	end

	if (IsHaveRelationGroup(nGroupId, me.szName) ~= 1) then
		Dialog:Say("Hãy tạo nhóm trước!");
		return 0;
	end
	
	local nLen = GetNameShowLen(szRelationGroupName);
	if nLen < 3 or nLen > 8 then
		Dialog:Say("Số lượng ký tự không hợp lệ.");
		return 0;
	end
	
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szRelationGroupName) ~= 1 then
		Dialog:Say("Tên nhóm không hợp lệ");
		return 0;
	end
	
	--是否包含敏感字串
	if IsNamePass(szRelationGroupName) ~= 1 then
		Dialog:Say("Tên nhóm không hợp lệ");
		return 0;
	end
	
	
	GCExcute({"Relation:RenameRelationGroup", nGroupId, szPlayerName, szRelationGroupName});
end

function Relation:ApplyDelRelationGroup_C2S(nGroupId)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end

	if (nGroupId > self.DEF_MAX_RELATIONGROUP_COUNT) then
		return 0;
	end

	if (IsHaveRelationGroup(nGroupId, me.szName) ~= 1) then
		Dialog:Say("Chưa tùy chỉnh không thể xóa!");
		return 0;
	end	
	
	Dialog:Say("Ngươi chắc chắn chứ?", {
			{"Đồng ý", self.OnSureDelRelationGroup, self, nGroupId, me.szName},
			{"Để ta suy nghĩ thêm"},
		});
	
end
Relation.tbc2sFun["ApplyDelRelationGroup_C2S"] = Relation.ApplyDelRelationGroup_C2S;

function Relation:OnSureDelRelationGroup(nGroupId, szPlayerName)
	if (self:IsCloseRelationGroup() == 1) then
		return 0;
	end
	
	if (not szPlayerName or me.szName ~= szPlayerName) then
		return 0;
	end

	if (IsHaveRelationGroup(nGroupId, me.szName) ~= 1) then
		Dialog:Say("Hãy tạo nhóm trước!");
		return 0;
	end

	if (nGroupId > self.DEF_MAX_RELATIONGROUP_COUNT) then
		return 0;
	end
	
	GCExcute({"Relation:DelRelationGroup", nGroupId, szPlayerName});
end

-- 增加亲密度
-- nMethod 增加亲密度途径 0正常途径，1通过ib道具（默认是0）
function Relation:AddFriendFavor(szAppName, szDstName, nFavor, nMethod)
	nMethod = nMethod or 0;
	if (nMethod ~= 0 and nMethod ~= 1) then
		nMethod = 1;
	end
	if (not szAppName or not szDstName or szAppName == szDstName or nFavor <= 0) then
		return;
	end
	local pAppPlayer = KPlayer.GetPlayerByName(szAppName);
	if (not pAppPlayer) then
		return;
	end
	
	-- 不是好友关系，不添加亲密度
	if (KPlayer.CheckRelation(szAppName, szDstName, Player.emKPLAYERRELATION_TYPE_BIDFRIEND, 1) == 0) then
		return;
	end
	
	GCExcute{"Relation:AddFriendFavor_GC", szAppName, szDstName, nFavor, nMethod};
end

function Relation:GetMsgById(nPlayerId, szDstName, nType, nMsgId)
	if (nMsgId < 0) then
		return;
	end
	
	local szMsg = "";
	if (nMsgId == self.emKEADDRELATION_SUCCESS) then
		if (nType == Player.emKPLAYERRELATION_TYPE_ENEMEY) then
			szMsg = string.format("Người chơi [%s] thêm vào danh sách kẻ thù.", szDstName);
		elseif (nType == Player.emKPLAYERRELATION_TYPE_BLACKLIST) then
			szMsg = string.format("Người chơi [%s] thêm vào danh sách đen.", szDstName);
		elseif (nType == Player.emKPLAYERRELATION_TYPE_TMPFRIEND) then
			szMsg = string.format("Bạn và [%s] trở thành mật hữu.", szDstName);
		end
	elseif (nMsgId == self.emKEHAVE_RELATION) then
		szMsg = string.format("Thêm bạn thất bại, bạn và [%s] đã có mối quan hệ với nhau, cần xóa quan hệ hiện tại, mới có thể thêm lần nữa.", szDstName);
	elseif (nMsgId == self.emKEPLAYER_NOTONLINE) then
		szMsg = "Thêm bạn thất bại, người chơi hiện không online.";
	else
		if (nType == Player.emKPLAYERRELATION_TYPE_BINDFRIEND or
			nType == Player.emKPLAYERRELATION_TYPE_SIBLING) then
			szMsg = string.format("Thêm [%s] vào danh sách bạn bè thất bại, tên người chơi không tồn tại.", szDstName);
		else
			szMsg = "Thêm bạn thất bại, người chơi không tồn tại hoặc không đủ điều kiện để kết bạn.";
		end
	end
	
	return szMsg;
end

function Relation:TellPlayerMsg_GS(nPlayerId, szMsg)
	if (not nPlayerId or not szMsg or nPlayerId <= 0 or "" == szMsg) then
		return;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (pPlayer) then
		pPlayer.Msg(szMsg);
	end
end

-- 在玩家上线的时候获取密友关系即将一年到期的信息，并且给出玩家提示
function Relation:GetCloseFriendTimeInfo_GS(bExchangeServerComing)
	if (not bExchangeServerComing or 1 == bExchangeServerComing) then
		return;
	end
	
	local nPlayerId = me.nId;
	if (nPlayerId <= 0) then
		return;
	end
	
	local tbCloseFrientList = me.GetRelationList(Player.emKPLAYERRELATION_TYPE_BUDDY);
	local tbTrainedList = me.GetRelationList(Player.emKPLAYERRELATION_TYPE_TRAINED, 1);
	local tbIntroduceList = me.GetRelationList(Player.emKPLAYERRELATION_TYPE_INTRODUCTION, 1);
	if (#tbCloseFrientList == 0 and #tbTrainedList == 0 and #tbIntroduceList == 0) then
		return;
	end
	
	GCExcute{"Relation:GetCloseFriendTimeInfo_GC", nPlayerId};
end

-- tbTimeInfo = {{"nPlayerId" = XXX, "nTime" = XXX}, {}, ...}
function Relation:GetCloseFriendTimeInfo_GS2(nPlayerId, tbTimeInfo)
	if (Lib:CountTB(tbTimeInfo) == 0 or nPlayerId <= 0) then
		return;
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	local tbRelationName = {
		[Player.emKPLAYERRELATION_TYPE_BUDDY] = "Quan hệ mật hữu",
		[Player.emKPLAYERRELATION_TYPE_INTRODUCTION] = "Quan hệ người giới thiệu",
		[Player.emKPLAYERRELATION_TYPE_TRAINED] = "Quan hệ sư đồ"
		};
	
	local szMsg = "";
	for _, tbInfo in pairs(tbTimeInfo) do
		local nTime = tbInfo.nTime;
		local nRemainDay = math.floor(nTime / (24 * 3600));
		if (nTime >= 0 and nRemainDay >= 0 and nRemainDay < self.TIME_NOTIFYONEYEAR and
			tbRelationName[tbInfo.nType]) then
			szMsg = szMsg .. string.format("Bạn và <color=yellow>%s<color> sẽ hết hạn %s trong vòng 1 tuần.", tbInfo.szPlayerName,
				tbRelationName[tbInfo.nType]);
			pPlayer.Msg(szMsg);
			szMsg = "";
		end
	end
end

-- 开除当前弟子
function Relation:DelTrainingStudent(szStudentName)
	local tbNpc	= Npc:GetClass("renji");
	tbNpc:DelTrainingStudent1(szStudentName);
end
Relation.tbc2sFun["DelTrainingStudent"] = Relation.DelTrainingStudent;

-- 成就
function Relation:__FinishAchievement(nPlayerId)
	if (not nPlayerId or nPlayerId <= 0) then
		return;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	-- 好友
	local tbFriend = pPlayer.GetRelationList(Player.emKPLAYERRELATION_TYPE_BIDFRIEND, 1);
	local nFriendNum = #tbFriend;
	if (nFriendNum >= 1) then
		Achievement:FinishAchievement(pPlayer, 1);
	end
	if (nFriendNum >= 10) then
		Achievement:SetFinishNum(pPlayer, 2, nFriendNum);
		Achievement:FinishAchievement(pPlayer, 2);
	end
	if (nFriendNum >= 20) then
		Achievement:SetFinishNum(pPlayer, 3, nFriendNum);
		Achievement:FinishAchievement(pPlayer, 3);
	end
	if (nFriendNum >= 50) then
		Achievement:SetFinishNum(pPlayer, 4, nFriendNum);
		Achievement:FinishAchievement(pPlayer, 4);
	end
		
	-- 密友
	local tbBuddy = pPlayer.GetRelationList(Player.emKPLAYERRELATION_TYPE_BUDDY, 1);
	local tbTrained = pPlayer.GetRelationList(Player.emKPLAYERRELATION_TYPE_TRAINED, 1);
	local tbIntroduction = pPlayer.GetRelationList(Player.emKPLAYERRELATION_TYPE_INTRODUCTION, 1);
	local nTrainedTaskNum = pPlayer.GetTask(self.TASK_GROUP, self.TASKID_TRAINED_NUM);
	local nBuddyNum = #tbBuddy;
	local nTrainedNum = #tbTrained;
	local nIntroduction = #tbIntroduction;
	local nMiyouNum = nBuddyNum + nTrainedNum + nIntroduction;
	if (nMiyouNum >= 1) then
		Achievement:FinishAchievement(pPlayer, 11);
	end
	if (nMiyouNum >= 2) then
		Achievement:SetFinishNum(pPlayer, 12, nMiyouNum);
		Achievement:FinishAchievement(pPlayer, 12);
	end
	if (nMiyouNum >= 4) then
		Achievement:SetFinishNum(pPlayer, 13, nMiyouNum);
		Achievement:FinishAchievement(pPlayer, 13);
	end
	
	if (nTrainedTaskNum < nTrainedNum) then
		nTrainedTaskNum = nTrainedNum;
		pPlayer.SetTask(self.TASK_GROUP, self.TASKID_TRAINED_NUM, nTrainedTaskNum);
	end
	
	-- 出师弟子
	if (nTrainedTaskNum >= 1) then
		Achievement:FinishAchievement(pPlayer, 22);
	end
	if (nTrainedTaskNum >= 3) then
		Achievement:SetFinishNum(pPlayer, 23, nTrainedNum);
		Achievement:FinishAchievement(pPlayer, 23);
	end
	if (nTrainedTaskNum >= 10) then
		Achievement:SetFinishNum(pPlayer, 24, nTrainedNum);
		Achievement:FinishAchievement(pPlayer, 24);
	end
	if (nTrainedTaskNum >= 20) then
		Achievement:SetFinishNum(pPlayer, 25, nTrainedNum);
		Achievement:FinishAchievement(pPlayer, 25);
	end
	
	-- 未出师师徒
	local tbTraining = pPlayer.GetRelationList(Player.emKPLAYERRELATION_TYPE_TRAINING, 1);
	local nTrainingNum = #tbTraining;
	if (nTrainingNum >= 1) then
		Achievement:FinishAchievement(pPlayer, 15);
	end
	if (nTrainingNum >= 3) then
		Achievement:SetFinishNum(pPlayer, 16, nTrainingNum);
		Achievement:FinishAchievement(pPlayer, 16);
	end
end

function Relation:AfterAddRelation_GS(nAppId, nDstId, nType)
	-- 如果是出师的徒弟，那么就加1
	if (nType == Player.emKPLAYERRELATION_TYPE_TRAINED) then
		if (nAppId and nAppId > 0) then
			local pPlayer = KPlayer.GetPlayerObjById(nAppId);
			if (pPlayer) then
				local nTaskNum = pPlayer.GetTask(self.TASK_GROUP, self.TASKID_TRAINED_NUM);
				local tbTrained = pPlayer.GetRelationList(Player.emKPLAYERRELATION_TYPE_TRAINED, 1);
				local nTrainedNum = #tbTrained;
				if (nTaskNum < nTrainedNum) then
					nTaskNum = nTrainedNum;
				else
					nTaskNum = nTaskNum + 1;
				end
				pPlayer.SetTask(self.TASK_GROUP, self.TASKID_TRAINED_NUM, nTaskNum);
			end			
		end
	end
	self:__FinishAchievement(nAppId);
	self:__FinishAchievement(nDstId);
end

-- 修复成就
function Relation:RepairAchievement()
	-- 修复好友数量的成就
	self:__FinishAchievement(me.nId);
	
	-- 修复亲密度等级的成就
	local nMaxFavor = 0;
	local tbFavorLevel_Achieve = {[2] = 5, [3] = 6, [4] = 7, [5] = 8, [6] = 9, [7] = 10,};
	local tbFriend = me.GetRelationList(Player.emKPLAYERRELATION_TYPE_BIDFRIEND, 1);
	if (not tbFriend or #tbFriend <= 0) then
		return;
	end
	for _, szName in pairs(tbFriend) do
		local nFavor = me.GetFriendFavor(szName);
		nMaxFavor = nMaxFavor > nFavor and nMaxFavor or nFavor;
	end
	local nFavorLevel = math.ceil(math.sqrt(math.ceil(nMaxFavor/100)));
	if (nFavorLevel < 2) then
		return;
	end
	for i = 2, nFavorLevel do
		if (tbFavorLevel_Achieve[i]) then
			Achievement:FinishAchievement(me, tbFavorLevel_Achieve[i]);
		end
	end
end

function Relation:__FinishAchievement_FavorLevel(pPlayer, nFavorLevel)
	if (not pPlayer or not nFavorLevel or nFavorLevel < 1) then
		return;
	end
	
	-- 成就，亲密度等级提升
	if (nFavorLevel >= 2) then
		Achievement:FinishAchievement(pPlayer, 5);
	end
	if (nFavorLevel >= 3) then
		Achievement:FinishAchievement(pPlayer, 6);
	end
	if (nFavorLevel >= 4) then
		Achievement:FinishAchievement(pPlayer, 7);
	end
	if (nFavorLevel >= 5) then
		Achievement:FinishAchievement(pPlayer, 8);
	end
	if (nFavorLevel >= 6) then
		Achievement:FinishAchievement(pPlayer, 9);
	end
	if (nFavorLevel >= 7) then
		Achievement:FinishAchievement(pPlayer, 10);
	end
end

-- 拜师或收徒的应答
function Relation:TrainingResponse_C2S(nTOrSFlag, szPlayerName, bAnswer)
	if (not self.tbClass or not self.tbClass[Player.emKPLAYERRELATION_TYPE_TRAINING]) then
		return;
	end
	if (self.tbClass[Player.emKPLAYERRELATION_TYPE_TRAINING].TrainingResponse) then
		self.tbClass[Player.emKPLAYERRELATION_TYPE_TRAINING]:TrainingResponse(nTOrSFlag, szPlayerName, bAnswer);
	end
end
Relation.tbc2sFun["TrainingResponse_C2S"] = Relation.TrainingResponse_C2S;

--==============================================

-- 亲密度等级提升之后gs的回调
function Relation:OnFavorLevelUp_GS(nPlayerAppId, nPlayerDstId, nFavorLevel)
	if (not nPlayerAppId or not nPlayerDstId or not nFavorLevel or
		nPlayerAppId <= 0 or nPlayerDstId <= 0 or nFavorLevel <= 0) then
		return;
	end
	local pPlayerApp = KPlayer.GetPlayerObjById(nPlayerAppId);
	local pPlayerDst = KPlayer.GetPlayerObjById(nPlayerDstId);
	if (pPlayerApp) then
		self:__FinishAchievement_FavorLevel(pPlayerApp, nFavorLevel);
	end
	if (pPlayerDst) then
		self:__FinishAchievement_FavorLevel(pPlayerDst, nFavorLevel);
	end
end

-- 添加人际关系之后gs的回调
function Relation:ProcessAfterAddRelation_GS(nType, nRole, nAppId, nDstId)
	if (not nType) then
		return;
	end
	
	-- 增加人际关系记录log
	Relation:WriteRelationLog(self.LOG_TYPE_ADDRELATION, nType, nAppId, nDstId);
	
	if (not self.tbClass[nType]) then
		return;
	end
	if (not self.tbClass[nType]["ProcessAfterAddRelation_GS"]) then
		return;
	end
	self.tbClass[nType]:ProcessAfterAddRelation_GS(nRole, nAppId, nDstId);
end

-- 删除人际关系之后gs的回调
function Relation:ProcessAfterDelRelation_GS(nType, nRole, nAppId, nDstId)
	if (not nType) then
		return;
	end
	
	-- 删除人际关系记录log
	Relation:WriteRelationLog(self.LOG_TYPE_DELRELATION, nType, nAppId, nDstId);
	
	if (not self.tbClass[nType]) then
		return;
	end
	if (not self.tbClass[nType]["ProcessAfterDelRelation_GS"]) then
		return;
	end
	self.tbClass[nType]:ProcessAfterDelRelation_GS(nRole, nAppId, nDstId);
end

--==============================================

-- 人际部分，通用的从从gc调用的gs函数
function Relation:ServerScript_Relation(nType, szFunName, tbParam)
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

-- 通用的人际gs调用gc的一个接口
-- 主要是给class下面的各种具体的人际关系调用
function Relation:CallGCScript_Relation(nType, szFunName, tbParam)
	if (not nType or not szFunName or type(szFunName) ~= "string") then
		return;
	end
	
	GCExcute{"Relation:GCScript_Relation", nType, szFunName, tbParam};
end

function Relation:OnLogin_PlayerRelationGroup()
	GCExcute({"Relation:ApplyPlayerRelationGroup", me.szName, -1});
end

function Relation:SyncPlayerRelationGroup_GS(szPlayerName, nGroupId, tbGroupList)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if (not pPlayer) then
		return 0;
	end
	if (not self.tbGroupPlayerNum) then
		self.tbGroupPlayerNum = {};
	end
	
	if (not self.tbGroupPlayerNum[szPlayerName]) then
		self.tbGroupPlayerNum[szPlayerName] = {};
		self.tbGroupPlayerNum[szPlayerName][nGroupId] = 0;
	end
	if (tbGroupList and tbGroupList.tbGroup) then
		self.tbGroupPlayerNum[szPlayerName][nGroupId] = #tbGroupList.tbGroup;
	end
	pPlayer.CallClientScript({"Relation:ReceivePlayerRelationGroup_Client", nGroupId, tbGroupList});
end

function Relation:SyncRelationGroupState_GS(szPlayerName, tbGroupState)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if (not pPlayer) then
		return 0;
	end
	pPlayer.CallClientScript({"Relation:SyncRelationGroupState_Client", tbGroupState});
end

PlayerEvent:RegisterGlobal("OnLogin", Relation.OnLogin_PlayerRelationGroup, Relation);

--==============================================

-- 注册通用上线事件
PlayerEvent:RegisterGlobal("OnLogin", Relation.GetCloseFriendTimeInfo_GS, Relation);
