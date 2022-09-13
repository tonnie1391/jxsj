  --
-- FileName: invite_gs.lua
-- Author: hanruofei
-- Time: 2011/5/10 14:42
-- Comment: VIP邀请玩家加盟，GS脚本
--


Require("\\script\\event\\vipinvite\\invite_def.lua");
local tbVipInvite = SpecialEvent.tbVipInvite;

-- 任务变量
tbVipInvite.TASK_GROUPID = 2164;
tbVipInvite.INVITE = 1; -- 是否邀请过人
tbVipInvite.INVITED = 2; -- 是否被邀请过(修改为登陆马上获得资格)
tbVipInvite.LEVEL_UP = 3; -- 是否使用过此功能升级过
tbVipInvite.EQUIP_BUY = 4; -- 是否使用此功能获取过装备
tbVipInvite.NAME = 5; --(邀请人的名字，5-12)
tbVipInvite.INVITED_VIP = 13; -- 被邀请的，打折

tbVipInvite.tbValidMaps = {["city"]=true, ["village"] = true,["village_mini"]=true,["taoxizhen"]=true};

function tbVipInvite:Open()
	self.bOpened = true;
end

function tbVipInvite:Close()
	self.bOpened = false;
end

function tbVipInvite:LoadConfig(szFile)
	local tbData = Lib:LoadTabFile(szFile);
	if not tbData then
		return 0, "读取配置文件" .. tostring(szFile) .. "失败。";
	end
	
	local tbConfig = {};
	for i, v in ipairs(tbData) do
		local tbItem = {};
		local bHasError = false;
		for k1, v1 in pairs(v) do
			tbItem[k1] = tonumber(v1);
			if not tbItem[k1] then
				bHasError = true;
				break;
			end
		end
		if bHasError then
			return 0, tostring(szFile) ..  "第" .. i .. "行出错了，数据无法转换为数字。";
		end
		table.insert(tbConfig, tbItem);
	end
	
	self.tbConfig = tbConfig;
	return 1;
end

-- 玩家各个级别升级所需要的经验
function tbVipInvite:LoadLevelData(szFile)
	local tbData	= Lib:LoadTabFile(szFile);
	if not tbData then
		return 0, "Load " .. tostring(szFile) .. "失败。";
	end
	
	local tbLevelData	= {};
	for i, tbRow in ipairs(tbData) do
		local nLevel	= tonumber(tbRow.LEVEL);
		local nUpExp	= tonumber(tbRow.EXP_UPGRADE);
		if not nLevel or not nUpExp then
			return 0, tostring(szFile) .. "的第" .. i .. "行出错了，数据无法转换为数字。"
		end
		tbLevelData[nLevel] = nUpExp;
	end
	
	self.tbLevelData = tbLevelData;
	return 1;
end

function tbVipInvite:LoadBuffer()
	local tbData = GetGblIntBuf(GBLINTBUF_VIP_INVITE, 0);
	if type(tbData) == "table" then
		self.tbData = tbData;
	end
end

function tbVipInvite:TryOpen()
	local nOpenTime = GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	if nOpenTime >= self.nDaysFromServerStart * 60 * 60 * 24  then
		self:Open();
	end
end

function tbVipInvite:Init()
	local bOk, szError = self:LoadConfig("\\setting\\event\\vipinvite\\levelupsetting.txt");
	if bOk == 0 then
		print("加载VIP邀请配置文件失败，原因：" .. szError);
		return;
	end
	
	bOk, szError = self:LoadLevelData("\\setting\\player\\attrib_level.txt");
	if bOk == 0 then
		print("加载等级经验配置文件失败，原因：" .. szError);
		return;
	end
	
	
	self.tbDialogItem =	{"<color=yellow>新玩家加盟<color>", self.OnInviteDialogItem, self}; -- 与古枫霞对话时增加的一级选项
	-- 与古枫霞对话时的二级选项
	self.tbDialog = 
	{
		"服务器财富荣誉排名前60名的玩家有一次邀请朋友的资格，被邀请人可获得一次优惠8折提升等级和购买一套100级强化+6稀有装备的权利。",
		{
			{"<color=yellow>我要邀请朋友<color>", self.OnInvitorDialog, self},
			{"<color=yellow>我被朋友邀请了<color>",self.OnBeInvitorDialog, self},
			{"<color=yellow>我来领取消费返还<color>",self.OnGetFanhuan, self},
			{"<color=yellow>申请再次被邀请（仅限升级）<color>",self.RequireOtherUpLevel, self},
			{"Ta hiểu rồi"},
		},
	};
	
	-- 被邀请人选择功能的对话框(开放100级上限后)
	self.tbBeInvitedDialog =
	{
		"您现在拥有立刻提升等级和获得极品装备的机会。\n\n立刻升级后，如果你是新建角色，可以在换线专员处离开灵秀村。\n你可以不受50级主线任务限制，可参加官府通缉和商会任务。",
		{
			{"<color=yellow>我要马上提升等级<color>", self.LevelUp, self},
			{"<color=yellow>我要马上获得极品装备<color>", self.BuyEquip, self},
			{"Để ta suy nghĩ thêm"},
		},
	};
	
	-- 被邀请人选择功能的对话框(开放100级上限前)
	self.tbBeInvitedDialog2 =
	{
		"您现在拥有立刻提升等级的机会。\n立刻升级后，如果你是新建角色，可以在换线专员处离开灵秀村。你可以不受50级主线任务限制，可参加官府通缉和商会任务。",
		{
			{"<color=yellow>我要马上提升等级<color>", self.LevelUp, self},
			{"Để ta suy nghĩ thêm"},
		},
	};	
	self.tbDialogBuyEquip = 
	{
		"您确定要花费<color=yellow>35000金币<color>购买一套100级强化+6稀有装备礼包吗？",
		{
			{"Xác nhận", self.DoBuyEquip, self},
			{"我在想想"},
		},
	};
	self:LoadBuffer();
	self:TryOpen();
end

--申请可以再次被邀请升级
function tbVipInvite:RequireOtherUpLevel(nFlag)
	local bInvited = me.GetTask(self.TASK_GROUPID, self.INVITED_VIP);
	local bUpLevel = me.GetTask(self.TASK_GROUPID, self.LEVEL_UP);
	local bBuyEquip = me.GetTask(self.TASK_GROUPID, self.EQUIP_BUY);
	local szMsg = "您确定要申请再次被邀请权限（仅限升级功能）。";
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("您的账号处于锁定状态，请先解锁。"); 
		return;		
	end
	if bInvited ~= 1 then
		Dialog:Say("您暂时没有被好友邀请，不需要重新申请了，快去请您的好友邀请你吧。"); 
		return;
	end
	if bUpLevel ~= 1 then
		Dialog:Say("您之前被邀请的升级功能还没有使用，再次申请会浪费的。"); 
		return;
	end
	if self:CanRequire() == 0 then
		Dialog:Say("您的等级不满足被邀请资 ô."); 
		return;
	end
	
	if bBuyEquip ~= 1 then
		szMsg = szMsg .. "\n<color=red>注：您的购买装备权限还没有使用，再次被邀请时同样会有购买装备权限。<color>"
	end
	if not nFlag then
		Dialog:Say(szMsg, {{"Xác nhận", self.RequireOtherUpLevel, self, 1}, {"Để ta suy nghĩ thêm"}});
		return;
	end
	me.SetTask(self.TASK_GROUPID, self.INVITED_VIP, 0);
	me.SetTask(self.TASK_GROUPID, self.LEVEL_UP, 0);
	Dialog:SendBlackBoardMsg(me, "恭喜您可以再次被邀请，快去请您的好友邀请你吧。");
	me.Msg("恭喜您可以再次被邀请，快去请您的好友邀请你吧。");
end

function tbVipInvite:CanRequire()	
	local nType = Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_LEVEL, 0);
	for _, v in ipairs(self.tbConfig) do
		-- 看一下服务器到达指定等级的人数是否满足条件了
		local tbRet = GetHonorLadderInfoByRank(nType, v.nGlobalCountCondition);
		if tbRet then
			-- 等级数值是乘了100的
			if tbRet.nHonor / 100 >= v.nGlobalLevelCondition then
				if me.nLevel < v.nSelfLevelCondition then
					print(tbRet.nHonor, v.nGlobalLevelCondition, v.nSelfLevelCondition)
					return 1;
				end
			end
		end
	end
	return 0;
end

-- 跟NPC古枫霞对话时的选项内容
-- 外部调用，如果当前功能开放，则返回相关对话选项，否则返回nil
function tbVipInvite:TryGetDialogItem()
	if self:IsMenuItemVisibleTo(me) then
		return self.tbDialogItem;
	end
end

-- 当玩家点击了邀请新玩家加盟的对话选项后进入该函数
function tbVipInvite:OnInviteDialogItem()
	-- 判断玩家是否有邀请别人的资格
	Dialog:Say(unpack(self.tbDialog));
end

-- 判断pPlayer是否有邀请别人的资格
function tbVipInvite:CanInvite(pPlayer, nItemId)
	if pPlayer.IsAccountLock() ~= 0 then
		return false, "您的账号处于锁定状态，请先解锁。";
	end
	if nItemId then
		return true;
	end
	local nHonorRank = PlayerHonor:GetPlayerHonorRankByName(pPlayer.szName, PlayerHonor.HONOR_CLASS_MONEY, 0);
	if not nHonorRank or nHonorRank <= 0 or nHonorRank > self.nWealthOrder then
		return false, "只有财富荣誉排名前60的的玩家才有邀请资 ô.";
	end
	local nValue = me.GetTask(self.TASK_GROUPID, self.INVITE);
	if nValue ~= 0 then
		return false, "您已经邀请过朋友了。";
	end
	
	return true;
end

-- 判断菜单项对于pPlayer是否可见
function tbVipInvite:IsMenuItemVisibleTo(pPlayer)
	if not self.bOpened then
		return false;
	end
	if not pPlayer then
		return false;
	end
	
	local nHonorRank = PlayerHonor:GetPlayerHonorRankByName(pPlayer.szName, PlayerHonor.HONOR_CLASS_MONEY, 0);
	if nHonorRank and nHonorRank > 0 and nHonorRank <= self.nWealthOrder then
		return true;
	end
	
	if me.GetTask(self.TASK_GROUPID, self.INVITE) ~= 0 then
		return true;
	end
	
	if me.GetTask(self.TASK_GROUPID,  self.INVITED_VIP) ~= 0 then
		return true;
	end
	
	if self.tbData and self.tbData[me.szName] then
		return true;
	end
	
	return false;
end

-- 判断pPlayer是否可以被别人邀请
function tbVipInvite:CanBeInvited(pPlayer)
	if pPlayer.IsAccountLock() ~= 0 then
		return false, pPlayer.szName .. "的账号处于锁定状态，请先解锁。";
	end
	--local nValue = pPlayer.GetTask(self.TASK_GROUPID, self.INVITED);
	local nValue = pPlayer.GetTask(self.TASK_GROUPID, self.INVITED_VIP);
	if nValue ~= 0 then
		return false, "该玩家已经被邀请过了。";
	end
	return true;
end

-- 提升两个玩家的友好度到6级
-- 仅供内部调用，未做参数有效性判断
-- 如果两个玩家不是好友关系，则先加好友
function tbVipInvite:IncreaseRelationLevel(pPlayerA, pPlayerB)
	local nPlayerIdA, nPlayerIdB = pPlayerA.nId, pPlayerB.nId;
	local szPlayerNameA, szPlayerNameB = pPlayerA.szName, pPlayerB.szName;
	local nFavor = 2501; -- 6级亲密度
	if KPlayer.CheckRelation(szPlayerNameA, szPlayerNameB, Player.emKPLAYERRELATION_TYPE_BIDFRIEND, 1) == 0 then
		Relation:AddRelation_GS(szPlayerNameA, szPlayerNameB, Player.emKPLAYERRELATION_TYPE_BIDFRIEND);
	else
		nFavor = nFavor - pPlayerA.GetFriendFavor(szPlayerNameB);
	end
	if nFavor > 0 then
		GCExcute{"Relation:AddFriendFavor_GC", szPlayerNameA, szPlayerNameB, nFavor, 0, 1};
	end
	return 1;
end


-- me邀请某人
-- nItemId, 是否是使用道具邀请， 不指定则为不使用道具的邀请
-- 如果是使用道具的邀请，则要指定nItemId非false
function tbVipInvite:DoInvite(nTargetPlayerId, nItemId)
	local bOk, szErrorMsg = self:CanInvite(me, nItemId);
	if not bOk then
		Dialog:Say(szErrorMsg);
		return;
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nTargetPlayerId);
	if not pPlayer then
		Dialog:Say("您所邀请的玩家不存在或者不在您的周围。");
		return;
	end
	
	-- pPlayer可以被邀请吗？
	bOk, szErrorMsg = self:CanBeInvited(pPlayer)
	if not bOk then
		pPlayer.Msg("您被别人邀请失败，如果您想再次被邀请可以到活动推广员-古枫霞处申请再次被邀请资格（仅限升级资格）。")
		Dialog:Say(szErrorMsg);
		return;
	end
	
	self:IncreaseRelationLevel(me, pPlayer);-- 加好友，提升亲密度到6级
	
	if not nItemId then
		me.SetTask(self.TASK_GROUPID, self.INVITE, 1); -- 记录，已经邀请过人了
	else
		local pItem = KItem.GetObjById(nItemId);
		if pItem then
			pItem.Delete(me);
		else
			print("出错了");
		end
	end
	pPlayer.SetTask(self.TASK_GROUPID, self.INVITED, 1); -- 记录，已经被邀请过了
	pPlayer.SetTaskStr(self.TASK_GROUPID, self.NAME, me.szName);-- 记录下是被谁邀请的
	pPlayer.SetTask(self.TASK_GROUPID, self.INVITED_VIP, 1);
	-- 记LOG
	local szAccount, szName = StatLog:__WriteStatLog_GetAccName(pPlayer.nId);
	local szInfo = string.format("%s,%s", szAccount, szName);
	StatLog:WriteStatLog("stat_info", "yaoqingtequan", "active", me.nId, szInfo);
	
	-- 邀请方消息
	local szMsgToInvitor = "您已经成功邀请" .. pPlayer.szName .. "加盟剑侠世界，希望您游戏开心！";
	me.Msg(szMsgToInvitor);
	Dialog:SendBlackBoardMsg(me, szMsgToInvitor);
	
	-- 被邀请方消息
	local szMsgToBeInvited = me.szName .. "邀请您加盟剑侠世界，希望您游戏开心！";
	pPlayer.Msg(szMsgToBeInvited);
	Dialog:SendBlackBoardMsg(pPlayer, szMsgToBeInvited);
end

-- 邀请人的对话
function tbVipInvite:OnInvitorDialog(nItemId)
	if not self.bOpened then
		Dialog:Say("该功能还没有开放！");
		return;
	end
	
	local bOk, szErrorMsg = self:CanInvite(me, nItemId);
	if not bOk then
		Dialog:Say(szErrorMsg);
		return;
	end

	local tbTeammeberList = me.GetTeamMemberList() or {};
	local tbAroundPlayerList = KNpc.GetAroundPlayerList(me.GetNpc().dwId, 20) or {};
	local tbAroundTeammember = {};
	for _, v in ipairs(tbTeammeberList) do
		if v.nId ~= me.nId then
			for _, v1 in ipairs(tbAroundPlayerList) do 
				if v.nId == v1.nId then
					table.insert(tbAroundTeammember, v);		
				end
			end
		end
	end
	
	if #tbAroundTeammember == 0 then
		local szMsg = "您的队友都没在您周围，请让您要邀请的玩家跟您一起来吧。";
		Dialog:Say(szMsg, {"Ta hiểu rồi"});
	else
		local tbOpt = {};
		for _, v in ipairs(tbAroundTeammember) do
			table.insert(tbOpt, {"<color=yellow>" .. v.szName .. "<color>", self.DoInvite, self, v.nId, nItemId})
		end
		local szMsg = "请选择您要邀请的对象。";
		table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
		Dialog:Say(szMsg, tbOpt);
	end
end


-- 可是使用该升级功能吗？
function tbVipInvite:CanDoLevelUp(pPlayer)
	-- 野外地图不能使用
	local nMapId = pPlayer.GetWorldPos();
	local szMapType = GetMapType(nMapId);
	if not self.tbValidMaps[szMapType] then
		return false, "当前地图禁用该功能";
	end
	
	if pPlayer.IsAccountLock() ~= 0 then
		return false, "您的账号现在处于锁定状态，请先解锁。";
	end

	if pPlayer.GetTask(self.TASK_GROUPID, self.INVITED) == 0 then
		return false, "您还没有收到任何加盟邀请。";
	end
	if pPlayer.GetTask(self.TASK_GROUPID, self.LEVEL_UP) == 1 then
		return false, "您已经提升过等级了。";
	end
	return true;
end

tbVipInvite.szMsgNoLevel = "现在没有合适的可到达等级。";
tbVipInvite.szMsgChooseLevel = "请选择您要提升到的等级。<enter><color=red>注意：您只有一次这样的机会，请慎重选择！<color>";

-- 被邀请玩家使用升级功能
function tbVipInvite:LevelUp()
	local bOk, szErrorMsg = self:CanDoLevelUp(me);
	if not bOk then
		Dialog:Say(szErrorMsg);
		return;
	end

	local tbOpt = {};
	-- 生成菜单
	local nType = Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_LEVEL, 0);
	for _, v in ipairs(self.tbConfig) do
		-- 看一下服务器到达指定等级的人数是否满足条件了
		local tbRet = GetHonorLadderInfoByRank(nType, v.nGlobalCountCondition);
		if tbRet then
			-- 等级数值是乘了100的
			if tbRet.nHonor / 100 >= v.nGlobalLevelCondition then
				if me.nLevel < v.nSelfLevelCondition then
					table.insert(tbOpt, {"升级到" .. v.nDestLevel, self.DoLevelUp, self, v.nDestLevel});
				end
			end
		end
	end
	
	if #tbOpt == 0 then
		Dialog:Say(self.szMsgNoLevel);
	else
		table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
		Dialog:Say(self.szMsgChooseLevel, tbOpt);
	end
end

function tbVipInvite:CanUseLevelUp(pPlayer)
	if pPlayer.GetTask(self.TASK_GROUPID, self.LEVEL_UP) == 1 then
		return 0;
	end

	local nType = Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_LEVEL, 0);
	for _, v in ipairs(self.tbConfig) do
		-- 看一下服务器到达指定等级的人数是否满足条件了
		local tbRet = GetHonorLadderInfoByRank(nType, v.nGlobalCountCondition);
		if tbRet then
			-- 等级数值是乘了100的
			if tbRet.nHonor / 100 >= v.nGlobalLevelCondition then
				if pPlayer.nLevel < v.nSelfLevelCondition then
					return 1;
				end
			end
		end
	end
	return 0;
end

function tbVipInvite:CalcExp(nCurLevel, nDestLevel, nCurExp)
	local nExp = 0;
	for i = nCurLevel, nDestLevel - 1 do
		nExp = nExp + self.tbLevelData[i];
	end
	return nExp - nCurExp;
end

-- 获得指定级别段的经验基数和单次金币消耗数量
-- 未做出错处理，仅供本类内部调用
function tbVipInvite:GetExpAndCoinSetting(nLevel)
	for _, v in pairs(self.tbConfig) do
		if nLevel == v.nDestLevel then
			return v.nCoinAtom, v.nExpPerAtom;
		end
	end
end

-- 计算pPlayer升到nDestLevel需要多少金币
function tbVipInvite:CalcCoinAndExp(pPlayer, nDestLevel)
	local nCoin = 0;
	local nTotalExp = 0;
	local nCurLevel = pPlayer.nLevel;
	local nCurExp = pPlayer.GetExp();
	for _, v in ipairs(self.tbConfig) do
		if nCurLevel >= nDestLevel then
			break;
		end
		if  nCurLevel < v.nDestLevel then
			local nExp = self:CalcExp(nCurLevel, v.nDestLevel, nCurExp);
			local nCoinAtom, nExpPerAtom = self:GetExpAndCoinSetting(v.nDestLevel);
			local nAtomCount = math.floor(nExp / nExpPerAtom);
			nCoin = nCoin + nAtomCount * nCoinAtom;
			nTotalExp = nTotalExp + nExp;
			
			nCurLevel = v.nDestLevel;
			nCurExp = 0;
		end
	end
	return nCoin, nTotalExp;
end

function tbVipInvite:JoinFactionDialog(nDestLevel)
	local tbOpt	= {};
	for nFactionId, tbFaction in ipairs(Player.tbFactions) do
		local nSexLimit	= tbFaction.nSexLimit;
		local nIsCanShow = 1;
		if (nFactionId == Player.FACTION_GUMU and Faction:IsOpenGumuZhuxiu() ~= 1) then
			nIsCanShow = 0;
		end
		if nIsCanShow == 1 and (nSexLimit < 0 or nSexLimit == me.nSex) then
			table.insert(tbOpt, {tbFaction.szName, self.DoLevelUp, self, nDestLevel, nFactionId});
		end
	end
	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
	Dialog:Say("您现在没有门派，请再选择你要加入的门派。", tbOpt)
end


-- 做升级操作
-- 扣金币，给邀请者加绑金
tbVipInvite.tbNotEnoughCoinDialog =
{
	"您的金币不足。",
	{{"我要充值",c2s.ApplyOpenOnlinePay, c2s}, {"Ta hiểu rồi"}},
};
function tbVipInvite:DoLevelUp(nDestLevel, nFactionId, bConfirmed, nCoin)
	if not nFactionId and me.nFaction <= 0 then
		self:JoinFactionDialog(nDestLevel)
		return;
	end
	local nVip = me.GetTask(self.TASK_GROUPID, self.INVITED_VIP);
	local nRate = 1;
	if nVip == 1 then
		nRate = 0.8;
	end
	if not bConfirmed then
		 
		nCoin = math.floor(self:CalcCoinAndExp(me, nDestLevel) * nRate);
		local szMsg = "您确定要消耗<color=yellow>" .. nCoin .. "金币<color>提升等级到<color=yellow>" .. nDestLevel .. "级<color>吗？";
		if nFactionId then
			szMsg = szMsg .. "<enter>升级后会自动加入<color=yellow>" .. Player.tbFactions[nFactionId].szName .. "门派<color>。";
		end
		Dialog:Say(szMsg, {{"Xác nhận", self.DoLevelUp, self, nDestLevel, nFactionId, true, nCoin}, {"Để ta suy nghĩ thêm"}});
		return;
	end
	
	if me.nCoin < nCoin then
		Dialog:Say(unpack(self.tbNotEnoughCoinDialog));
		return;
	end
	
	-- 修改价格并锁定状态
	local nServerId = GetServerId();
	GCExcute{"SpecialEvent.tbVipInvite:Lock", me.szName, nCoin, nDestLevel, nFactionId, nServerId};
end

tbVipInvite.tbTempData = tbVipInvite.tbTempData  or {};

function tbVipInvite:LockSuccess(szName, nCoin, nDestLevel, nFactionId, nServerId)
	if GetServerId() ~= nServerId then
		return;
	end
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if pPlayer then
		self.tbTempData[pPlayer.szName] = {};
		self.tbTempData[pPlayer.szName].nDestLevel = nDestLevel;
		self.tbTempData[pPlayer.szName].nCoin = nCoin;
		self.tbTempData[pPlayer.szName].nFactionId = nFactionId;
		if pPlayer.ApplyAutoBuyAndUse(self.nIndexOfLevelUpItem, 1) == 0 then
			GCExcute{"SpecialEvent.tbVipInvite:Unlock"};
		end
	else
		GCExcute{"SpecialEvent.tbVipInvite:Unlock"};
	end
end

tbVipInvite.szMsgSomeoneIsBuying = "使用该功能的人过多，请稍后再试。";
function tbVipInvite:LockFailed(szName, nServerId)
	if GetServerId() ~= nServerId then
		return;
	end
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if pPlayer then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say(self.szMsgSomeoneIsBuying);
		Setting:RestoreGlobalObj();
	end
end
tbVipInvite.nAddedPrestige = 50; -- 升级后，顺便给加点威望，以便于可以做统大盗任务和商会任务
tbVipInvite.szLevelUpFanhuanMailTitle = "消费返还领取提醒";
tbVipInvite.szLevelUpFanhuanMailContent = "您邀请的玩家<color=yellow>%s<color>使用了等级提升功能，您获得<color=yellow>%s绑金<color>返还，请到推广员处领取。";
function tbVipInvite:AfterLevelUp()
	GCExcute{"SpecialEvent.tbVipInvite:Unlock"};

	local tbTempData = self.tbTempData[me.szName];
	if not tbTempData then
		return;
	end   
	
	self.tbTempData[me.szName] = nil;
	
	local nDestLevel = tbTempData.nDestLevel;
	local nCoin = tbTempData.nCoin;
	if not nDestLevel or not nCoin then
		return;
	end
	
	me.SetTask(self.TASK_GROUPID, self.LEVEL_UP, 1); -- 加标记，记录该功能已经使用过了

	-- 提升等级
	local nDeltaLevel = nDestLevel - me.nLevel;
	if nDeltaLevel > 0 then
		me.AddLevel(nDeltaLevel);
	end
	-- 加入门派
	local nFactionId = tbTempData.nFactionId;
	if nFactionId then
		me.LeaveTeam();
		me.JoinFaction(nFactionId);
		Npc.tbMenPaiNpc:AddAngerMagic(me);
	end
	
	me.SetTask(2027,230,1);	  --设置可出新手村
	me.SetTask(1022, 107, 1); -- 设置50级主线任务变量
	me.AddKinReputeEntry(self.nAddedPrestige); -- 加江湖威望
	
	-- 如果有邀请人，则给邀请人发邮件，并记录可以领返还绑金
	local szInvitorName = me.GetTaskStr(self.TASK_GROUPID, self.NAME);
	if szInvitorName and szInvitorName ~= "" then
		local szContent = string.format(self.szLevelUpFanhuanMailContent, me.szName, nCoin);
		KPlayer.SendMail(szInvitorName, self.szLevelUpFanhuanMailTitle, szContent);
		GCExcute{"SpecialEvent.tbVipInvite:RecordFanhuan", szInvitorName, nCoin};
	end

	-- 记LOG
	local szInfo = string.format("%s,%s", nDestLevel, nCoin);
	StatLog:WriteStatLog("stat_info", "yaoqingtequan", "levelup", me.nId, szInfo);
	
end


tbVipInvite.tbEquipLibaoGDPL = {18, 1, 1209,2};
tbVipInvite.nPrice = 35000;
function tbVipInvite:DoBuyEquip()
	-- 检查空间
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống，请整理出1格空间来再来购买。");
		return;
	end
	
	if me.nCoin < self.nPrice then
		Dialog:Say(unpack(self.tbNotEnoughCoinDialog));
		return;
	end
	-- 扣金币
	me.ApplyAutoBuyAndUse(440, 1);
end

tbVipInvite.szBuyEquipFanhuanMailTitle = "消费返还领取提醒";
tbVipInvite.szBuyEquipFanhuanMailContent = "您邀请的玩家<color=yellow>%s<color>购买了100级稀有装备礼包，您获得了<color=yellow>35000绑金<color>返还， 请到推广员处领取。";

function tbVipInvite:AfterBuyEquip()
	-- 给邀请者加绑金
	local szInvitorName = me.GetTaskStr(self.TASK_GROUPID, self.NAME);
	if szInvitorName and szInvitorName ~= "" then
		local szContent = string.format(self.szBuyEquipFanhuanMailContent, me.szName);
		KPlayer.SendMail(szInvitorName, self.szBuyEquipFanhuanMailTitle, szContent);
		GCExcute{"SpecialEvent.tbVipInvite:RecordFanhuan", szInvitorName, self.nPrice};
	end
	me.SetTask(self.TASK_GROUPID, self.EQUIP_BUY, 1);	-- 设置变量（标记改玩家已经购买过）
	local pItem = me.AddItem(unpack(self.tbEquipLibaoGDPL));-- 加装备礼包
	if pItem then
		pItem.Bind(1);
	end
	
	-- 记LOG
	local szInfo = string.format("%s", self.nPrice);
	StatLog:WriteStatLog("stat_info", "yaoqingtequan", "abilityup", me.nId, szInfo);
end

-- 被邀请玩家是否买过装备礼包？
tbVipInvite.nCountCondition = 500; -- 服务器混天玩家数量的条件
function tbVipInvite:CanBuyEquip(pPlayer)
	local nMapId = pPlayer.GetWorldPos();
	local szMapType = GetMapType(nMapId);
	if not self.tbValidMaps[szMapType] then
		return false, "当前地图禁用该功能";
	end
	
	if pPlayer.IsAccountLock() ~= 0 then
		return false, "您的账号现在处于锁定状态，请先解锁。";
	end
	
	if pPlayer.GetTask(self.TASK_GROUPID, self.INVITED) == 0 then
		return false, "您还没有收到任何加盟邀请。";
	end
	if pPlayer.GetTask(self.TASK_GROUPID, self.EQUIP_BUY) == 1 then
		return false, "您已经购买过100级稀有装备礼包了。"
	end
	local nType = Ladder:GetType(0, Ladder.LADDER_CLASS_MONEY, Ladder.LADDER_TYPE_MONEY_HONOR_MONEY, 0);
	local tbRet = GetHonorLadderInfoByRank(nType, self.nCountCondition);
	if not tbRet or tbRet.nHonor < 15000 then
		return false, "服务器财富荣誉到达混天的玩家不足" ..  self.nCountCondition .. "个，不能使用该功能。";
	end
	return true;
end

-- 被邀请玩家使用获取装备功能
function tbVipInvite:BuyEquip()
	local bOk, szMsg = self:CanBuyEquip(me);
	if not bOk then
		Dialog:Say(szMsg);
		return;
	end
	Dialog:Say(unpack(self.tbDialogBuyEquip));
end

-- 判断指定玩家是否被邀请了
function tbVipInvite:IsInvited(pPlayer)
	local nValue = pPlayer.GetTask(self.TASK_GROUPID, self.INVITED);
	if nValue ~= 0 then
		return true;
	end
	return false;
end

-- 被邀请人的对话
tbVipInvite.szMsgNotInvited = "您还没有收到任何加盟邀请。";
function tbVipInvite:OnBeInvitorDialog()
	local bOk = self:IsInvited(me)
	if not bOk then
		Dialog:Say(self.szMsgNotInvited);
		return;
	end
	if TimeFrame:GetState("OpenLevel150") == 1 then
		Dialog:Say(unpack(self.tbBeInvitedDialog));
	else
		Dialog:Say(unpack(self.tbBeInvitedDialog2));
	end
end

-- 领返还
tbVipInvite.tbDialogNoFanhuan =
{
	"您没有返还绑金可以领取。",
	{{"Ta hiểu rồi"}},
};

function tbVipInvite:TryGetFanhuan()
	local nBindCoin = self.tbData[me.szName]
	if not nBindCoin then
		return false;
	end
	-- 锁住玩家
	me.AddWaitGetItemNum(1);
	
	GCExcute{"SpecialEvent.tbVipInvite:TryGetFanhuan", me.szName}; --清除返还记录	
	return true;
end

function tbVipInvite:DoGetFanhuan(szName, nBindCoin)
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if not pPlayer then
		return;
	end
	-- 解锁
	pPlayer.AddWaitGetItemNum(-1);
	if nBindCoin and nBindCoin > 0 then
		pPlayer.AddBindCoin(nBindCoin);
	end
end

function tbVipInvite:OnGetFanhuan()
	if not self:TryGetFanhuan() then
		Dialog:Say(unpack(self.tbDialogNoFanhuan));
	end
end

function tbVipInvite:OnLogin()
	self:TryGetFanhuan();
end

function tbVipInvite:SynDataItem(szName, nBindCoin)
	self.tbData[szName] =  nBindCoin;
end

--登陆根据，玩家状态获得直升资格。
function tbVipInvite:SetCanLevelUp_OnLogin(nExchange)
	if nExchange == 1 then
		return 0;
	end
	
	--9月5日后才开放该功能。
	if tonumber(GetLocalDate("%Y%m%d")) <= 20120904 then
		return 0;
	end
	if TimeFrame:GetState("OpenLevel79") == 1 then
		if me.GetTask(self.TASK_GROUPID,  self.INVITED) == 0 and self:CanUseLevelUp(me) == 1 then
			me.SetTask(self.TASK_GROUPID,  self.INVITED, 1);
			local szMsg = "    恭喜您获得了秒升等级资格，您可以在打开<color=yellow>角色面板(F1)<color>，点击等级旁的按钮，花费一定金币，选择秒升到您合适的等级。\n\n祝您游戏愉快！";
			me.Msg(szMsg);
			KPlayer.SendMail(me.szName, "恭喜您获得秒升机会", szMsg);
		end
	end
end

ServerEvent:RegisterServerStartFunc(tbVipInvite.Init, tbVipInvite)
PlayerEvent:RegisterGlobal("OnLogin",  SpecialEvent.tbVipInvite.SetCanLevelUp_OnLogin,  SpecialEvent.tbVipInvite);

--- c2scall
function c2s:BeInvitor()
	tbVipInvite:OnBeInvitorDialog();
end



