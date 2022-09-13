-------------------------------------------------------------------
--File: kinlogic_gs.lua
--Author: lbh
--Date: 2007-6-26 14:57
--Describe: Gameserver家族逻辑
-------------------------------------------------------------------
if not Kin then --调试需要
	Kin = {}
	print(GetLocalDate("%Y/%m/%d/%H/%M/%S").." build ok ..")
else
	if not MODULE_GAMESERVER then
		return
	end
end

Kin.c2sFun = {}
--注册能被客户端直接调用的函数
local function RegC2SFun(szName, fun)
	Kin.c2sFun[szName] = fun
end

--nType:类型，1为判断正式+记名成员， 0或nil为判断家族所有人员满足 并且 正式+记名同时满足
function Kin:_CheckMemberCount(nKinId, nType)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then 
		return nil;
	end
	local nRegular, nSigned, nRetire = cKin.GetMemberCount();
	local nMemberLimit, nRetireLimit = self:GetKinMemberLimit(nKinId);
	if nType ~= 1 then
		if (nRegular + nSigned + nRetire) >= (nMemberLimit + nRetireLimit) then
			return nil;
		end
	end
	if nRegular + nSigned >= nMemberLimit then
		return nil;
	end
	return 1
end

function Kin:CreateKinApply_GS1(szKinName, nCamp)
	return self:DlgCreateKin(szKinName, nCamp)
end
RegC2SFun("CreateKin", Kin.CreateKinApply_GS1)


if not Kin.aKinCreateApply then
	Kin.aKinCreateApply={}
end

--GS1后缀表示申请逻辑，GS2后缀表示结果逻辑
--以列表的PlayerId创建家族
function Kin:CreateKin_GS1(anPlayerId, anStoredRepute, szKinName, nCamp, nPlayerId, bGoldLogo)
	if self.aKinCreateApply[nPlayerId] then
		return 0;
	end
	--家族名字合法性检查
	local nLen = GetNameShowLen(szKinName);
	if nLen < 6 or nLen > 12 then
		return -1;
	end
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szKinName) ~= 1 then
		return -2;
	end
	--是否包含敏感字串
	if IsNamePass(szKinName) ~= 1 then
		return -3;
	end
	--检查家族名是否已占用
	if KKin.FindKin(szKinName) ~= nil then
		return -4;
	end
	--检查创建家族的成员是否符合要求
	if self:CanCreateKin(anPlayerId) ~= 1 then
		return -5;
	end
	
	self.aKinCreateApply[nPlayerId] = {anPlayerId, anStoredRepute, szKinName, nCamp, bGoldLogo};
	return  GCExcute{"Kin:CreateKinApply_GC", nPlayerId, szKinName}
end

function Kin:OnKinNameResult_GS2(nPlayerId, nResult)
	local tbParam = self.aKinCreateApply[nPlayerId]
	if not tbParam then
		return;
	end
	local bGoldLogo = tbParam[5];
	Kin.aKinCreateApply[nPlayerId] = nil;
	
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not cPlayer) then
		return 0;
	end
	
	if nResult ~= 1 then
		cPlayer.Msg("Tên gia tộc đã tồn tại, hãy thử tên khác");
		return;
	end	
	
	-- by jiazhenwei  金牌网吧建立家族5w
	local nMoneyCreat = self.CREATE_KIN_MONEY;
	if SpecialEvent.tbGoldBar:CheckPlayer(cPlayer) == 1 then
		nMoneyCreat = math.min(nMoneyCreat, 50000);
	end
	--end
	
	--by jiazhenwei 有该物品建立家族只需15w
	local nFlag = 0;
	if #cPlayer.FindItemInBags(18,1,994,1) >= 1 then
		nFlag = 1;
		nMoneyCreat = math.min(nMoneyCreat, 150000);
	end
	--end
	
	--by jiazhenwei 某个日期之前建立家族折扣(不可以和物品及金牌网吧的叠加，取最小值)
	local tbBuffer = GetGblIntBuf(GBLINTBUF_LOGIN_AWARD, 0);
	if not tbBuffer or type(tbBuffer) ~= "table" then
		tbBuffer = {};
	end
	local nMoneyDiscount = 0;
	if tbBuffer[2] and tbBuffer[2][1] and Lib:GetDate2Time(tbBuffer[2][1]) > GetTime() then
		nMoneyDiscount = math.floor(self.CREATE_KIN_MONEY * tbBuffer[2][2] /10000);
		nMoneyCreat = math.min(nMoneyCreat, nMoneyDiscount);
	end
	--end
	
	--用家族建立卡建立的家族，不收钱，只扣东西
	if bGoldLogo then
		cPlayer.ConsumeItemInBags(1, 18,1,1697,1,0);
	else
		if cPlayer.CostMoney(nMoneyCreat, Player.emKPAY_CREATEKIN) ~= 1 then
			return 0;
		end
		--真实价格和折扣价格一样的默认为折扣价格
		if nMoneyDiscount == nMoneyCreat and nMoneyDiscount ~= self.CREATE_KIN_MONEY then
			nFlag = 0;
			cPlayer.Msg(string.format("Đang trong thời gian khuyến mãi, chỉ cần %s là có thể lập Gia tộc", nMoneyCreat));
			Dialog:SendBlackBoardMsg(cPlayer, string.format("Đang trong thời gian khuyến mãi, chỉ cần %s là có thể lập Gia tộc", nMoneyCreat));
		end
	
		--by jiazhenwei 有该物品建立家族只需15w
		if nFlag == 1 then
			cPlayer.ConsumeItemInBags(1, 18,1,994,1,0);
		end
		--end
	end	
	GCExcute{"Kin:CreateKin_GC", unpack(tbParam)}
	
	--解散队伍
	if (cPlayer.nTeamId > 0) then
		KTeam.DisbandTeam(cPlayer.nTeamId);
	end
end

function Kin:CreateKin_GS2(anPlayerId, anStoredRepute, szKinName, nCamp, nCreateTime, tbStock, bGoldLogo)
	local cKin, nKinId = self:CreateKin(anPlayerId, anStoredRepute, szKinName, nCamp, nCreateTime, tbStock)
	if not cKin then
		return 0
	end
	
	--金牌家族标志
	if bGoldLogo then
		cKin.SetGoldLogo(1);
	end
	
	for i, nPlayerId in ipairs(anPlayerId) do
		KKinGs.UpdateKinInfo(nPlayerId)
		
		-- 创建家族的时候增加师徒成就（加入家族）
		Achievement_ST:FinishAchievement(nPlayerId, Achievement_ST.ENTER_KIN);
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if (pPlayer) then
			
			if pPlayer.GetTask(Player.TSKGROUP_NEWPLAYER_GUIDE, Player.TSKID_NEWPLAYER_KIN) ~= 1 then
				local nYinding = pPlayer.GetTask(Kinsalary.TASK_GID, Kinsalary.TASK_YINDING);
				pPlayer.SetTask(Kinsalary.TASK_GID, Kinsalary.TASK_YINDING, nYinding + 1000);
			end
			
			pPlayer.SetTask(Player.TSKGROUP_NEWPLAYER_GUIDE, Player.TSKID_NEWPLAYER_KIN, 1);
			
			-- 成就，加入家族
			Achievement:FinishAchievement(pPlayer, 26);
			
			-- 家族创始人称号
			pPlayer.AddSpeTitle(szKinName .. "-Người sáng lập", GetTime() + 30 * 60 * 60 * 24, "gold");
		end
	end
	return KKinGs.KinClientExcute(nKinId, {"Kin:CreateKin_C2", szKinName, nCamp})
end

--增加成员
function Kin:MemberAdd_GS1(nKinId, nExcutorId, nPlayerId, bCanJoinKinImmediately)
	if self:CheckSelfRight(nKinId, nExcutorId, 2) ~= 1 then
		return 0
	end
	if self:CheckMemberCanAdd(nKinId, nPlayerId) ~= 1 then
		return 0
	end
	return GCExcute{"Kin:MemberAdd_GC", nKinId, nExcutorId, nPlayerId, bCanJoinKinImmediately}
end

function Kin:MemberAdd_GS2(nDataVer, nKinId, nPlayerId, nMemberId, nJoinTime, nStoredRepute, nPersonalStock, bCanJoinKinImmediately)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then 
		return 0
	end
	local cMember = cKin.AddMember(nMemberId)
	if not cMember then
		return 0
	end

	cMember.SetJoinTime(nJoinTime)
	cMember.SetPlayerId(nPlayerId)
	if (EventManager.IVER_bOpenTiFu == 1) then
		cMember.SetFigure(self.FIGURE_REGULAR)-- TEMP:2008-11-13,xiewen修改（为了方便玩家进入体服参加领土战）
	else
		cMember.SetFigure(self.FIGURE_SIGNED);
	end
	if (bCanJoinKinImmediately == 1) then
		cMember.SetFigure(self.FIGURE_REGULAR);
	end
	cMember.SetPersonalStock(nPersonalStock)
	if nStoredRepute > 0 then
		cKin.AddTotalRepute(nStoredRepute);
	end
	KKinGs.UpdateKinInfo(nPlayerId)
	cKin.SetKinDataVer(nDataVer)
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId)
	cKin.AddHistoryPlayerJoin(szPlayerName);
	KKin.DelKinInductee(nKinId, szPlayerName);
	
	-- 加入家族的师徒成就
	Achievement_ST:FinishAchievement(nPlayerId, Achievement_ST.ENTER_KIN);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (pPlayer) then
		--技能贡献点
		local nSkillOffer = pPlayer.GetTask(self.TASK_GROUP, self.TASK_SKILLOFFER);
		local nSkillOfferLost= math.floor(nSkillOffer*0.2);
		if nSkillOfferLost > self.nLostMaxPoint then
			nSkillOfferLost = self.nLostMaxPoint;
		end
		if nSkillOffer > 0 and nSkillOfferLost > 0 then
			pPlayer.SetTask(self.TASK_GROUP, self.TASK_SKILLOFFER, nSkillOffer - nSkillOfferLost);
			pPlayer.Msg("Chúc mừng bạn gia nhập Gia tộc, điểm cống hiến kỹ năng giảm "..nSkillOfferLost);
		end
		
		if pPlayer.GetTask(Player.TSKGROUP_NEWPLAYER_GUIDE, Player.TSKID_NEWPLAYER_KIN) ~= 1 then
			local nYinding = pPlayer.GetTask(Kinsalary.TASK_GID, Kinsalary.TASK_YINDING);
			pPlayer.SetTask(Kinsalary.TASK_GID, Kinsalary.TASK_YINDING, nYinding + 1000);
		end
			
		pPlayer.SetTask(Player.TSKGROUP_NEWPLAYER_GUIDE, Player.TSKID_NEWPLAYER_KIN, 1);
		
		-- 成就，加入家族
		Achievement:FinishAchievement(pPlayer, 26);
	end
	
	local nRegular, nSigned, nRetire = cKin.GetMemberCount();
	local nMemberCount = nRegular + nSigned;
	local nMemberLimit, nRetireLimit = self:GetKinMemberLimit(nKinId);
	if cKin.GetRecruitmentPublish() == 1 and (nMemberCount >= nMemberLimit or ((nRegular + nSigned + nRetire) >= (nMemberLimit+nRetireLimit))  )then
		cKin.SetRecruitmentPublish(0);
		KKin.Msg2Kin(nKinId, "Gia tộc đã đủ người, kết thúc chiêu mộ.");
	end
	return KKinGs.KinClientExcute(nKinId, {"Kin:MemberAdd_C2", nDataVer, nPlayerId, 
		nMemberId, nJoinTime, szPlayerName, nStoredRepute})
end

--邀请成员加入
function Kin:InviteAdd_GS1(nPlayerId, bAccept)
	if not nPlayerId then
		return 0;
	end
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not cPlayer then
		return 0
	end
	local nKinId, nExcutorId = me.GetKinMember()
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 2)
	if nRet ~= 1 then
		return 0
	end
	if not self:_CheckMemberCount(nKinId) then
		me.Msg("Số lượng thành viên đã đạt tối đa.")
		return 0
	end
	if cPlayer.GetCamp() == 0 then
		me.Msg("Người chữ trắng không thể vào Gia tộc")
		return 0
	end
	if cPlayer.nLevel < 10 then
		me.Msg("Nhân vật dưới cấp 10 không thể vào Gia tộc")
		return 0
	end
	local nPlayerKinId = cPlayer.GetKinMember();
	
	if nPlayerKinId == nKinId then
		me.Msg("Đối phương đã là thành viên của Gia tộc");
		return 0;
	end
	
	if nPlayerKinId and nPlayerKinId ~= 0 then
		me.Msg("Đối phương đã gia nhập Gia tộc khác");
		return 0;
	end
--	if me.GetFriendFavor(cPlayer.szName) < self.INVITE_FAVOR then
--		me.Msg("你与对方的亲密度小于2级，不能邀请！")
--		return 0
--	end
	if GetTime() - KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_LEAVE_KIN_TIME) < 1800 then
		me.Msg("Đối phương rời Gia tộc cũ chưa đầy 30 phút")
		return 0
	end
-----------------------------------------------------------------------------------------------------------
-- 需在此添加警告(警告帮会建设资金已经满了)
	local nStockPercent = 1;
	local nTongId = cKin.GetBelongTong()
	if (nTongId) then
		local pTong = KTong.GetTong(nTongId);
		if pTong then
			local nBuildFund = pTong.GetBuildFund() or 0;
			local nPersonalStock = KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_TONGSTOCK);		-- 个人资产;
			if (nBuildFund > Tong.MAX_BUILD_FUND) then
				nBuildFund = Tong.MAX_BUILD_FUND;
			end
			if nPersonalStock > 0 and nPersonalStock > (Tong.MAX_BUILD_FUND - nBuildFund) then
				nStockPercent = (Tong.MAX_BUILD_FUND - nBuildFund) / nPersonalStock;
			end
		end
	end
	
	if not bAccept or bAccept ~= 1 then
		if (1 ~= nStockPercent) then
			local nTemp = math.floor(nStockPercent * 100);
			local szMsg = "<color=green>[" .. cKin.GetName().."]<color>-<color=yellow>["..me.szName.."]<color> mời bạn gia nhập.\n";
			szMsg = szMsg .. "Nếu gia nhập, cổ phần trong Bang hội sẽ chỉ đạt <color=yellow> " .. nTemp .. "%<color>" ;

			local function SayWhat(nInvitor, nPlayerId, bAccept)
				local cInvitor = KPlayer.GetPlayerObjById(nInvitor);
				if not cInvitor then
					return;
				end
				if (bAccept and bAccept ==  1) then
					Setting:SetGlobalObj(cInvitor);
					Kin:InviteAdd_GS1(nPlayerId, bAccept);
					Setting:RestoreGlobalObj();
				else
					cInvitor.Msg(me.szName .. " đã từ chối!")
					me.Msg("Đã từ chối yêu cầu gia nhập Gia tộc.");
				end
			end
			local nInvitor = me.nId;
			Setting:SetGlobalObj(cPlayer);
			Dialog:Say(szMsg,
					{
						{"Đồng ý", SayWhat, nInvitor, nPlayerId, 1},
						{"Từ chối", SayWhat, nInvitor, nPlayerId, 0},
					});

			Setting:RestoreGlobalObj();
			return 0;
		end
	end
-----------------------------------------------------------------------------------------------------------
	local aInviteEvent = self:GetKinData(nKinId).aInviteEvent
	aInviteEvent[nPlayerId] = 1
	--5分钟后超时（可能造成本次定时器误删下一次同一玩家推荐事件的bug，但影响不大）
	Timer:Register(5*60*18, self.InviteCancel_GS, self, nKinId, nPlayerId)
	return cPlayer.CallClientScript({"Kin:InviteAdd_C2", nKinId, nExcutorId, cKin.GetName(), me.szName, nStockPercent})
end
RegC2SFun("InviteAdd", Kin.InviteAdd_GS1)

--时间到取消邀请
function Kin:InviteCancel_GS(nKinId, nPlayerId)
	local aInviteEvent = self:GetKinData(nKinId).aInviteEvent
	aInviteEvent[nPlayerId] = nil
	return 0
end

--回答邀请
function Kin:InviteAddReply_GS1(nKinId, nInvitorId, bAccept)
	local nPlayerId = me.nId
	local aInviteEvent = self:GetKinData(nKinId).aInviteEvent
	if bAccept ~= 1 then
		local cKin = KKin.GetKin(nKinId)
		if not cKin then
			return 0
		end
		local cMember = cKin.GetMember(nInvitorId)
		if not cMember then
			return 0
		end
		local cPlayer = KPlayer.GetPlayerObjById(cMember.GetPlayerId())
		if cPlayer then
			cPlayer.Msg("<color=white>"..me.szName.."<color> từ chối lời mời từ gia tộc bạn!")
		end
		return 0
	end
	if not aInviteEvent[nPlayerId] then
		me.Msg("Thời gian trả lời đã hết hạn!")
		return 0
	end
	aInviteEvent[nPlayerId] = nil
	local bCanJoinKinImmediately = me.CanJoinKinImmediately();	-- 用来判断是否可以立即加入家族并且转正
	return self:MemberAdd_GS1(nKinId, nInvitorId, nPlayerId, bCanJoinKinImmediately)
end
RegC2SFun("InviteAddReply", Kin.InviteAddReply_GS1)

--删除成员，nMethod = 0自己退出，nMethod = 1开除
function Kin:MemberDel_GS1(nKinId, nMemberId, nMethod)
	return GCExcute{"Kin:MemberDel_GC", nKinId, nMemberId, nMethod}
end

function Kin:MemberDel_GS2(nDataVer, nKinId, nMemberId, nPlayerId, nMethod, nReputeLeft, nRepute)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then 
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	if cMember.GetFigure() == self.FIGURE_ASSISTANT then
		cKin.SetAssistant(0)
	end
	--退出时的时间
	KGCPlayer.OptSetTask(nPlayerId, KGCPlayer.TSK_LEAVE_KIN_TIME, GetTime())
	cKin.DelMember(nMemberId)
	cKin.SetKinDataVer(nDataVer)
	cKin.AddTotalRepute(-nRepute)
	KKinGs.PlayerLeaveKin(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		local szMsg = "Đã rời khỏi Gia tộc.";
		pPlayer.Msg(szMsg);
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
	return KKinGs.KinClientExcute(nKinId, {"Kin:MemberDel_C2", nDataVer, nMemberId, KGCPlayer.GetPlayerName(nPlayerId), nMethod, nRepute})
end

function Kin:DisbandKin_GS2(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	-- 把家族成员全部剔除家族
	local itor = cKin.GetMemberItor();
	local cMember = itor.GetCurMember();
	while cMember do
		local nMemberId = itor.GetCurMemberId();
		local cTmpMember = itor.NextMember();
		local nPlayerId = cMember.GetPlayerId()
		if nPlayerId > 0 then
			KGCPlayer.OptSetTask(nPlayerId, KGCPlayer.TSK_LEAVE_KIN_TIME, GetTime())
			KKinGs.PlayerLeaveKin(nPlayerId)
		end
		cKin.DelMember(nMemberId);
		cMember = cTmpMember;
	end
	KKin.DelKin(nKinId);
end

function Kin:MemberLeave_GS1(nType)
	local nKinId, nExcutorId = me.GetKinMember()
	if nKinId == 0 or nExcutorId == 0 then
		return 0
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cMember = cKin.GetMember(nExcutorId)
	if not cMember then
		return 0
	end
	if nType and nType == 1 then
		local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
		if tbData.nApplyEvent and tbData.nApplyEvent == 1 and tbData.tbApplyRecord and tbData.tbApplyRecord.nMemberId == nExcutorId then
			me.CallClientScript({"Ui:ServerCall", "UI_KIN", "MemberLeavePromt_C2"});-- 提示客户端确认是否叛离
			return 0;
		end
	end
	local nFigure = cMember.GetFigure()
	if nFigure == self.FIGURE_CAPTAIN then
		me.Msg("Tộc trưởng không thể rời khỏi Gia tộc.")
		return 0
	end
	if nFigure ~= self.FIGURE_SIGNED and nFigure > 0 then
		local nTime = cMember.GetLeaveInitTime()
		local bCanLeaveKinImmediately = me.CanLeaveKinImmediately();
		if nTime == 0 then
			if (bCanLeaveKinImmediately == 0) then
				Dialog:Say("Thành viên chính thức muốn tự ý rời khỏi gia tộc, ba ngày sau mới có thể rời, bạn có muốn rời khỏi gia tộc?", {"Rời khỏi", self.LeaveApply_GS1, self, 1}, {"Đóng"})
			elseif (bCanLeaveKinImmediately == 1) then
				Dialog:Say("Bạn chưa là thành viên chính thức, có thể rời khỏi gia tộc ngay bây giờ, bạn có muốn rời khỏi gia tộc?", {"Rời khỏi", self.LeaveApply_GS1, self, 1, 1}, {"Đóng"})
			end
		else
			Dialog:Say("Bạn đã xin rời gia tộc, ba ngày sau vào lúc 18 giờ bạn sẽ chính thức rời khỏi tộc, trước lúc đó bạn có thể hủy xin rút khỏi gia tộc!", {"Hủy bỏ rời khỏi", self.LeaveApply_GS1, self, 0}, {"Đóng"})
		end
		return 1
	end
	return self:MemberDel_GS1(nKinId, nExcutorId, 0)
end
RegC2SFun("MemberLeave", Kin.MemberLeave_GS1)


function Kin:LeaveApply_GS1(bLeave, bCanLeaveKinImmediately)
	local nKinId, nExcutorId = me.GetKinMember()
	if nKinId == 0 or nExcutorId == 0 then
		return 0
	end
	if bLeave == 1 then
		if (not bCanLeaveKinImmediately or bCanLeaveKinImmediately == 0) then
			me.Msg("Bạn đã xin rời gia tộc, ba ngày sau vào lúc 18 giờ bạn sẽ chính thức rời khỏi tộc, trước lúc đó bạn có thể hủy xin rút khỏi gia tộc!")
		elseif (bCanLeaveKinImmediately and bCanLeaveKinImmediately == 1) then
			GCExcute{"Kin:MemberDel_GC", nKinId, nExcutorId, 0}
			me.Msg("Bạn đã chính thức rời khỏi gia tộc.");
		end
	else
		me.Msg("Bạn đã hủy bỏ xin rút khỏi gia tộc!")	
	end
	Dbg:WriteLog("Kin", "ApplyLeave", me.szName, bLeave, nKinId, nExcutorId);
	return GCExcute{"Kin:LeaveApply_GC", nKinId, nExcutorId, bLeave}
end

function Kin:LeaveApply_GS2(nKinId, nExcutorId, nTime)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cMember = cKin.GetMember(nExcutorId)
	if not cMember then
		return 0
	end
	cMember.SetLeaveInitTime(nTime)
	return 1
end

--发起开除成员
function Kin:MemberKickInit_GS1(nMemberId)
	local nKinId, nExcutorId = me.GetKinMember()
	if nExcutorId == nMemberId then
		me.Msg("Bạn không thể khai trừ chính mình!")
		return 0
	end
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 2)
	if nRet ~= 1 then
		me.Msg("Chỉ có Tộc trưởng hoặc Tộc phó mới có quyền trục xuất!")
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	local nFigure = cMember.GetFigure()
	if nFigure <= self.FIGURE_ASSISTANT then
		me.Msg("Chỉ có Tộc trưởng hoặc Tộc phó mới có quyền khai trừ!")
		return 0
	end
	
	-- 首领不能开除
	local nTongId = cKin.GetBelongTong();
	if Tong:IsPresident(nTongId, nKinId, nMemberId) == 1 then
		me.Msg("Thủ lĩnh không thể trực tiếp khai trừ!")
		return 0;
	end
	
	--记名成员直接开除
	if nFigure == self.FIGURE_SIGNED then
		return self:MemberDel_GS1(nKinId, nMemberId, 1)
	end
	local aThisKickEvent = self:GetKinData(nKinId).aKickEvent
	if aThisKickEvent[nMemberId] then
		me.Msg("Việc khởi xướng trục xuất thành viên chưa được định trước!")
		return 0
	end
	local szName = KGCPlayer.GetPlayerName(cMember.GetPlayerId());
	me.Msg(string.format("Bạn đã tán thành trục xuất \"%s\", trong thời gian 10 phút các thành viên khác trong gia tộc phải đồng ý mới có thể chính thức trục xuất.", szName))
	return GCExcute{"Kin:MemberKickInit_GC", nKinId, nExcutorId, nMemberId}
end
RegC2SFun("MemberKickInit", Kin.MemberKickInit_GS1)

function Kin:MemberKickInit_GS2(nKinId, nExcutorId, nMemberId)
	local aThisKickEvent = self:GetKinData(nKinId).aKickEvent
	aThisKickEvent[nMemberId] = nExcutorId
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return;
	end
	local cMember = cKin.GetMember(nMemberId)
	return KKinGs.KinClientExcute(nKinId, {"Kin:MemberKickInit_C2", nMemberId, KGCPlayer.GetPlayerName(cMember.GetPlayerId())})
end

--开除成员的响应
function Kin:MemberKickRespond_GS1(nMemberId, nAccept)
	local nKinId, nExcutorId = me.GetKinMember()
	if self:HaveFigure(nKinId, nExcutorId, 3) ~= 1 then
		me.Msg("Không phải thành viên chính thức không thể bỏ phiếu!")
		return 0
	end
	local aThisKickEvent = self:GetKinData(nKinId).aKickEvent
	if not aThisKickEvent[nMemberId] then
		me.Msg("Thời gian tán thành trục xuất đã quá hạn!")
		return 0
	end
	if nExcutorId == aThisKickEvent[nMemberId] then
		me.Msg("Người khởi xướng bỏ phiếu không hợp lệ!")
		return 0
	end
	if nAccept == 1 then
		me.Msg("Bạn đồng ý trục xuất thành viên gia tộc!")
		return GCExcute{"Kin:MemberKickRespond_GC", nKinId, nExcutorId, nMemberId}
	else
		me.Msg("Bạn không tán thành trục xuất thành viên rời khỏi gia tộc!")
		return 1;
	end
end
RegC2SFun("MemberKickRespond", Kin.MemberKickRespond_GS1)

function Kin:MemberKickRespond_GS2(nKinId, nMemberId, nEventId)
end

-- 退隐
function Kin:MemberRetire_GS1(nMemberId)
	local nKinId, nExcutorId = me.GetKinMember()
	if not nMemberId then
		nMemberId = nExcutorId
	end
	
	local cKin, cMember
	if nMemberId ~= nExcutorId then
		local nRet
		nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 2)
		if nRet ~= 1 then
			return 0
		end
		cMember = cKin.GetMember(nMemberId)
	else
		cKin = KKin.GetKin(nKinId)
		if not cKin then
			return 0
		end
		cMember = cKin.GetMember(nExcutorId)
	end
	if not cMember then
		return 0
	end
	
	local nFigure = cMember.GetFigure()
	if nFigure == self.FIGURE_CAPTAIN then
		me.Msg("Tộc trưởng không thể ẩn danh!")
		return 0
	end
	if cMember.GetFigure() > self.FIGURE_REGULAR then
		me.Msg("Thành viên chính thức ẩn danh!")
		return 0
	end
	
	-- 首领不能退隐
	local nTongId = cKin.GetBelongTong();
	if Tong:IsPresident(nTongId, nKinId, nMemberId) == 1 then
		me.Msg("Thủ lĩnh không thể ẩn danh!");
		return 0;
	end
	local nRegular, nSigned, nRetireCount = cKin.GetMemberCount();
	local nMember, nRetire = self:GetKinMemberLimit(nKinId);
	if nRetireCount >= nRetire then
			me.Msg("Thời gian ẩn danh đã hết, bạn không thể ẩn danh!")
			return 0;		
	end
	
	return GCExcute{"Kin:MemberRetire_GC", nKinId, nMemberId}
end
RegC2SFun("MemberRetire", Kin.MemberRetire_GS1)

function Kin:MemberRetire_GS2(nKinId, nMemberId, nTime)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	local nFigure = cMember.GetFigure()
	if nFigure == self.FIGURE_ASSISTANT then
		cKin.SetAssistant(0); 			-- 副族长退隐
	end
	cMember.SetRepAuthority(0);
	cMember.SetFigure(self.FIGURE_RETIRE)
	cMember.SetEnvoyFigure(0);			-- 退隐删除掌令使职位
	cMember.SetBitExcellent(0);			-- 退隐删除精英
	cMember.SetRetireTime(nTime);		-- 记录退隐时间	
	local nPlayerId = cMember.GetPlayerId()
	KKinGs.UpdateKinInfo(nPlayerId)
	return KKinGs.KinClientExcute(nKinId, {"Kin:MemberRetire_C2", nMemberId, KGCPlayer.GetPlayerName(nPlayerId)})
end

-- 取消退隐
function Kin:CancelRetire_GS1()
	local nKinId, nMemberId = me.GetKinMember();
	if nKinId == 0 or nMemberId == 0 then
		me.Msg("Bạn không có gia tộc");
		return 0;
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	local nFigure = cMember.GetFigure()
	if nFigure ~= self.FIGURE_RETIRE then
		me.Msg("Bạn không phải thành viên ẩn danh! Không thể hủy thoái ẩn!");
		return 0;
	end
	if not self:_CheckMemberCount(nKinId, 1) then		-- 到达人数上限，取消退隐失败
		me.Msg("Thành viên ẩn danh trong gia tộc đã tối đa! Không thể thêm!");
		return 0;
	end
	if GetTime() - cMember.GetRetireTime() < self.CANCEL_RETIRE_TIME then
		me.Msg("Hủy bỏ ẩn danh phải hơn 7 ngày!");
		return 0;
	end
	GCExcute{"Kin:CancelRetire_GC", nKinId, nMemberId}
end
RegC2SFun("CancelRetire", Kin.CancelRetire_GS1);

function Kin:CancelRetire_GS2(nKinId, nMemberId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return 0
	end
	cMember.SetFigure(self.FIGURE_REGULAR);
	local nPlayerId = cMember.GetPlayerId()
	KKinGs.UpdateKinInfo(nPlayerId)
	
	local nRegular, nSign, nRetire = cKin.GetMemberCount();
	local nMemberLimit, nRetireLimit = self:GetKinMemberLimit(nKinId);
	local nMemberCount = nRegular + nSign + 1;
	if cKin.GetRecruitmentPublish() == 1 and (nMemberCount >= nMemberLimit or (nRegular + nSign + nRetire) >= (nMemberLimit+nRetireLimit)) then
		cKin.SetRecruitmentPublish(0);
		KKin.Msg2Kin(nKinId, "Gia tộc đã đầy, kết thúc chiêu mộ gia tộc.");
	end
	
	return KKinGs.KinClientExcute(nKinId, {"Kin:CancelRetire_C2", nMemberId, KGCPlayer.GetPlayerName(nPlayerId)});
end

-- 拥有转正资格
function Kin:SetCan2Regular_GS2(nKinId, nMemberId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0;
	end
	cMember.SetCan2Regular(1);
	return 1;
end

-- 试用转正GS1
function Kin:Member2Regular_GS1(nKinId, nMemberId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0;
	end
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if Kin:HaveFigure(nSelfKinId, nSelfMemberId, Kin.FIGURE_REGULAR) ~= 1 then
		me.Msg("Bạn không có quyền chuyển người chơi thành thành viên chính thức");
		return 0;
	end
	if cMember.GetFigure() ~= self.FIGURE_SIGNED then
		me.Msg("Người chơi đã là thành viên chính thức");
		return 0;
	end
	-- if cMember.GetCan2Regular() ~= 1 then
		-- me.Msg("该玩家还没过家族试用期");
		-- return 0;
	-- end
	local szName =KGCPlayer.GetPlayerName(cMember.GetPlayerId());
	if not szName or not me.GetFriendFavor(szName) or me.GetFriendFavor(szName) < self.INVITE_FAVOR then
		me.Msg("Độ thân mật giữa bạn và người này chưa đủ, bạn không thể chuyển người này thành thành viên chính thức");
		return 0;
	end
	return GCExcute{"Kin:Member2Regular_GC", nKinId, nMemberId};
end
RegC2SFun("Member2Regular", Kin.Member2Regular_GS1)

-- 试用转正GS2
function Kin:Member2Regular_GS2(nKinId, nMemberId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	cMember.SetFigure(self.FIGURE_REGULAR)
	
	local pPlayer = KPlayer.GetPlayerObjById(cMember.GetPlayerId());
	if (pPlayer) then
		pPlayer.nKinFigure = self.FIGURE_REGULAR;
	end

	return KKinGs.KinClientExcute(nKinId, {"Kin:Member2Regular_C2", nMemberId, KGCPlayer.GetPlayerName(cMember.GetPlayerId())})
end

--踢人事件取消
function Kin:MemberKickCancel_GS2(nKinId, nMemberId)
	local aThisKickEvent = self:GetKinData(nKinId).aKickEvent
	aThisKickEvent[nMemberId] = nil
	return 0
end

function Kin:MemberIntroduce_GS1(nPlayerId, bAccept)
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not cPlayer then
		return 0
	end
	local nKinId, nExcutorId = me.GetKinMember()
	local bRet, cKin = self:HaveFigure(nKinId, nExcutorId, 3)
	if bRet ~= 1 then
		me.Msg("Không thể đề cử thành viên chính thức!")
		return 0
	end
	if cPlayer.GetCamp() == 0 then
		me.Msg("Người chơi mới không thể vào gia tộc!")
		return 0
	end
	if cPlayer.nLevel < 10 then
		me.Msg("Người chơi cấp nhỏ hơn 10, không thể vào gia tộc!")
		return 0
	end
	if KKin.GetPlayerKinMember(nPlayerId) ~= 0 then
		me.Msg("Người chơi đã có gia tộc!")
		return 0
	end
	if not self:_CheckMemberCount(nKinId) then
		me.Msg("Gia tộc đã đầy!")
		return 0;
	end
	
	if (EventManager.IVER_bOpenTiFu ~= 1) then
		if me.GetFriendFavor(cPlayer.szName) < self.INVITE_FAVOR then
			me.Msg("Thân mật của bạn và người chơi chưa đạt cấp 2, không nên mời!")
			return 0
		end
	end
	
	if GetTime() - KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_LEAVE_KIN_TIME) <  1800 then
		me.Msg("Người chơi rời khỏi gia tộc khác chưa đầy 30 phút!")
		return 0
	end
	local aThisIntroEvent = self:GetKinData(nKinId).aIntroduceEvent
	--如果推荐已经发起过，返回
	if aThisIntroEvent[nPlayerId] then
		me.Msg("Người chơi đã được tiến cử bởi thành viên khác, chờ tộc trưởng trả lời!")
		return 0
	end
-----------------------------------------------------------------------------------------------------------
-- 需在此添加警告(警告帮会建设资金已经满了)
	local nTongId = cKin.GetBelongTong()
	local nStockPercent = 1;
	if (nTongId) then
		local pTong = KTong.GetTong(nTongId);
		if pTong then
			local nBuildFund = pTong.GetBuildFund();
			local nKinFund = KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_TONGSTOCK);--Kin:GetTotalKinStock(nKinId);
			nBuildFund = nBuildFund or 0;
			if (nBuildFund > Tong.MAX_BUILD_FUND) then
				nBuildFund = Tong.MAX_BUILD_FUND;
			end

			if nKinFund > 0 and nKinFund > Tong.MAX_BUILD_FUND - nBuildFund then
				nStockPercent = (Tong.MAX_BUILD_FUND - nBuildFund) / nKinFund;
			end
		end
	end
	if not bAccept or bAccept ~= 1 then
		if (1 ~= nStockPercent) then
			local szMsg = "Thành viên <color=yellow>"..me.szName.."<color> giới thiệu bạn vào gia tộc <color=green>[".. cKin.GetName() .."]<color>\n";
			local nTemp = math.floor(nStockPercent * 100);
			szMsg = szMsg.."Quỹ xây dựng Bang hội của Gia tộc vượt quá giới hạn, chỉ nhận được <color=yellow> " .. nTemp .. "%<color>！" ;
			local function SayWhat(nIntra, nPlayerId, bAccept)
				local cIntra = KPlayer.GetPlayerObjById(nIntra);
				if not cIntra then
					return;
				end
				if (1 == bAccept) then
					Setting:SetGlobalObj(cIntra);
					Kin:MemberIntroduce_GS1(nPlayerId, bAccept);
					Setting:RestoreGlobalObj();
				else
					cIntra.Msg(me.szName .. " từ chối lời đề nghị!");
					me.Msg("Từ chối lời mời gia tộc!")
				end
			end
			local nIntra = me.nId;
			Setting:SetGlobalObj(cPlayer);
			Dialog:Say(szMsg,
					{
						{"Xác nhận", SayWhat, nIntra, nPlayerId, 1},
						{"Từ chối", SayWhat, nIntra, nPlayerId, 0},
					});
			Setting:RestoreGlobalObj();
			return 0;
		end
	end
-----------------------------------------------------------------------------------------------------------
	--未确认前先设为0
	aThisIntroEvent[nPlayerId] = 0
	--5分钟后删除（可能会造成删除下一个同一nPlayerId事件的bug，但影响很小，忽略）
	Timer:Register(5*60*18, self.IntroduceCancel_GS, self, nKinId, nPlayerId)
	--转发到被推荐人
	cPlayer.CallClientScript({"Kin:MemberIntroduceMe_C2", nKinId, nExcutorId, cKin.GetName(), me.szName})
	--return GCExcute{"Kin:MemberIntroduce_GC", nKinId, nExcutorId, nPlayerId}
end
RegC2SFun("MemberIntroduce", Kin.MemberIntroduce_GS1)

function Kin:MemberIntroduce_GS2(nKinId, nExcutorId, nPlayerId)
	local aThisIntroEvent = self:GetKinData(nKinId).aIntroduceEvent
	--若之前未设过删除定时器，设置一个
	if not aThisIntroEvent[nPlayerId] then
		Timer:Register(5*60*18, self.IntroduceCancel_GS, self, nKinId, nPlayerId)
	end
	aThisIntroEvent[nPlayerId] = nExcutorId
	--发送到副族长以上领导层
	return KKinGs.KinClientExcute(nKinId, {"Kin:MemberIntroduce_C2", nExcutorId, nPlayerId, KGCPlayer.GetPlayerName(nPlayerId)}, self.FIGURE_ASSISTANT)
end

--被推荐人确认推荐
function Kin:MemberIntroduceConfirm_GS1(nKinId, nIntroducerId, bAccept)
	local nPlayerId = me.nId
	local aThisIntroEvent = self:GetKinData(nKinId).aIntroduceEvent
	--如果推荐事件不存在，返回
	if not aThisIntroEvent[nPlayerId] then
		return 0
	end
	if bAccept ~= 1 then
		aThisIntroEvent[nPlayerId] = nil
		local cKin = KKin.GetKin(nKinId)
		if not cKin then
			return 0
		end
		local cMember = cKin.GetMember(nIntroducerId)
		if not cMember then
			return 0
		end
		local cPlayer = KPlayer.GetPlayerObjById(cMember.GetPlayerId())
		if cPlayer then
			cPlayer.Msg("<color=white>"..me.szName.."<color> từ chối đề nghị vào gia tộc!")
		end
		return 0
	end
	return GCExcute{"Kin:MemberIntroduce_GC", nKinId, nIntroducerId, nPlayerId, me.nPrestige}
end
RegC2SFun("MemberIntroduceConfirm", Kin.MemberIntroduceConfirm_GS1)


--时间到取消推荐事件
function Kin:IntroduceCancel_GS(nKinId, nPlayerId)
	local aThisIntroEvent = self:GetKinData(nKinId).aIntroduceEvent
	aThisIntroEvent[nPlayerId] = nil
	return 0
end

--接受或拒绝推荐申请
function Kin:AcceptIntroduce_GS1(nPlayerId, bAccept)
	local nKinId, nExcutorId = me.GetKinMember()
	if self:CheckSelfRight(nKinId, nExcutorId, 2) ~= 1 then
		return 0
	end
	local aThisIntroEvent = self:GetKinData(nKinId).aIntroduceEvent
	--如果推荐事件已不存在或未得到被推荐人确认
	if not aThisIntroEvent[nPlayerId] or aThisIntroEvent[nPlayerId] == 0 then
		return 0
	end
	return GCExcute{"Kin:AcceptIntroduce_GC", nKinId, nExcutorId, nPlayerId, bAccept}
end
RegC2SFun("AcceptIntroduce", Kin.AcceptIntroduce_GS1)

function Kin:AcceptIntroduce_GS2(nKinId, nPlayerId)
	local aThisIntroEvent = self:GetKinData(nKinId).aIntroduceEvent
	--如果推荐事件已不存在
	if aThisIntroEvent[nPlayerId] then
		aThisIntroEvent[nPlayerId] = nil
	end
	return 1
end

--更换称号
function Kin:ChangeTitle_GS1(nTitleType, szTitle)
	local nKinId, nExcutorId = me.GetKinMember()
	if self:CheckSelfRight(nKinId, nExcutorId, 2) ~= 1 then
		return 0
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local nLen = GetNameShowLen(szTitle);
	if nLen > 8 then
		me.Msg("Tiêu đề không quá 4 ký tự");
		return 0
	end
	--称号名字合法性检查
	if KUnify.IsNameWordPass(szTitle) ~= 1 then
		me.Msg("Tiêu đề chỉ chứa các chữ cái và ký tự []!");	
		return 0;
	end	
	--名称过滤
	if IsNamePass(szTitle) ~= 1 then
		me.Msg("Tiêu đề không hợp lệ!");
		return 0;
	end
	--nTitleType + 1即为称号ID
	if cKin.SetBufTask(nTitleType + 1, szTitle) ~= 1 then
		return 0
	end
	return GCExcute{"Kin:ChangeTitle_GC", nKinId, nExcutorId, nTitleType, szTitle}
end
RegC2SFun("ChangeTitle", Kin.ChangeTitle_GS1)

function Kin:ChangeTitle_GS2(nKinId, nTitleType, szTitle)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	--nTitleType + 1即为称号ID
	if cKin.SetBufTask(nTitleType + 1, szTitle) ~= 1 then
		return 0
	end
	if cKin.GetBelongTong() == 0 then
		KKinGs.UpdateKinTitle(nKinId, nTitleType, szTitle)
	end
	return KKinGs.KinClientExcute(nKinId, {"Kin:ChangeTitle_C2", nTitleType, szTitle})
end

--更换阵营
function Kin:ChangeCamp_GS2(nDataVer, nKinId, nCamp, nDate)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local nLastCamp = cKin.GetCamp()
	if cKin.SetCamp(nCamp) ~= 1 then
		return 0
	end
	--更新所有成员阵营
	if nLastCamp ~= nCamp then
		KKinGs.UpdateKinMemberCamp(nKinId, nCamp)
	end
	cKin.SetKinDataVer(nDataVer);
	cKin.SetChangeCampDate(nDate);
	return KKinGs.KinClientExcute(nKinId, {"Kin:ChangeCamp_C2", nDataVer, nCamp})
end

--设置副族长
function Kin:SetAssistant_GS1(nMemberId)
	local nKinId, nExcutorId = me.GetKinMember()
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 1)
	if nRet ~= 1 then
		return 0
	end
	if nExcutorId == nMemberId then
		me.Msg("Không thể thực hiện thao tác!")
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	if cMember.GetFigure() ~= self.FIGURE_REGULAR then
		me.Msg("Thành viên chính thức mới có thể được bổ nhiệm!")
		return 0
	end
	local aKinData = self:GetKinData(nKinId)
	if aKinData.nLastSetAssistantTime and GetTime() - aKinData.nLastSetAssistantTime < self.CHANGE_ASSISTANT_TIME then
		me.Msg("Hai lần thay thế Tộc phó phải cách nhau 24 giờ!")
		return 0
	end
	return GCExcute{"Kin:SetAssistant_GC", nKinId, nExcutorId, nMemberId}
end
RegC2SFun("SetAssistant", Kin.SetAssistant_GS1)

function Kin:SetAssistant_GS2(nDataVer, nKinId, nMemberId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	local aKinData = self:GetKinData(nKinId)
	aKinData.nLastSetAssistantTime = GetTime()
	--旧的副族长变为普通成员
	local nOldAssistant = cKin.GetAssistant()
	if nOldAssistant ~= 0 then
		local cOldAssistant = cKin.GetMember(nOldAssistant)
		if cOldAssistant then
			cOldAssistant.SetFigure(self.FIGURE_REGULAR)
			KKinGs.UpdateKinInfo(cOldAssistant.GetPlayerId())
		end
	end
	--设置并更新新副族长信息
	cKin.SetAssistant(nMemberId)
	cMember.SetFigure(self.FIGURE_ASSISTANT)
	KKinGs.UpdateKinInfo(cMember.GetPlayerId())
	cKin.SetKinDataVer(nDataVer)
	return KKinGs.KinClientExcute(nKinId, {"Kin:SetAssistant_C2", nDataVer, nMemberId, KGCPlayer.GetPlayerName(cMember.GetPlayerId())})
end

--免除副族长
function Kin:FireAssistant_GS1(nMemberId)
	local nKinId, nExcutorId = me.GetKinMember()
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 1)
	if nRet ~= 1 then
		return 0
	end
	if cKin.GetAssistant() ~= nMemberId then
		return 0
	end
	return GCExcute{"Kin:FireAssistant_GC", nKinId, nExcutorId, nMemberId}
end
RegC2SFun("FireAssistant", Kin.FireAssistant_GS1)

function Kin:FireAssistant_GS2(nKinId, nMemberId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	cMember.SetFigure(self.FIGURE_REGULAR)
	KKinGs.UpdateKinInfo(cMember.GetPlayerId())
	cKin.SetAssistant(0)
	return KKinGs.KinClientExcute(nKinId, {"Kin:FireAssistant_C2", nMemberId, KGCPlayer.GetPlayerName(cMember.GetPlayerId())})
end

--更换族长
function Kin:ChangeCaptain_GS1(nMemberId)
	local nKinId, nExcutorId = me.GetKinMember()
	local nRet, cKin, cExcutor = self:CheckSelfRight(nKinId, nExcutorId, 1)
	if nRet ~= 1 then
		return 0
	end
	local nPlayerId = cExcutor.GetPlayerId();
	if KGCPlayer.GetPlayerPrestige(nPlayerId) < 10 then
		me.Msg("Uy danh giang hồ phải lớn hơn 10 mới có thể chuyển Tộc trưởng!")
		return 0
	end
	if nExcutorId == nMemberId then
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	if cMember.GetFigure() > self.FIGURE_REGULAR then
		me.Msg("Không phải thành viên chính thức không thể chuyển giao!")
		return 0
	end
	return GCExcute{"Kin:ChangeCaptain_GC", nKinId, nExcutorId, nMemberId}
end
RegC2SFun("ChangeCaptain", Kin.ChangeCaptain_GS1)

function Kin:ChangeCaptain_GS2(nDataVer, nKinId, nExcutorId, nMemberId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	if cKin.GetAssistant() == nMemberId then
		cKin.SetAssistant(0)
	end
	local cExcutor = cKin.GetMember(nExcutorId)
	if cExcutor then
		cExcutor.SetFigure(self.FIGURE_REGULAR)
	end
	
	-- 如果族长是帮主，也记录到帮会事件上
	local nTongId = cKin.GetBelongTong();
	local szNewCaptain = KGCPlayer.GetPlayerName(cMember.GetPlayerId());
	local szOldCaptain = KGCPlayer.GetPlayerName(cExcutor.GetPlayerId());
	if nTongId then
		local pTong = KTong.GetTong(nTongId);
		if pTong then
			if pTong.GetMaster() == nKinId then
				pTong.AddAffairChangeMaster(szNewCaptain, szOldCaptain);
			end
		end
	end
	
	cKin.SetCaptain(nMemberId)
	cMember.SetFigure(self.FIGURE_CAPTAIN)

	KKinGs.UpdateKinInfo(cMember.GetPlayerId())
	KKinGs.UpdateKinInfo(cExcutor.GetPlayerId())
	cKin.AddAffairChangeCaptain(szNewCaptain, szOldCaptain);
	cKin.SetKinDataVer(nDataVer)
	-- 移交仓库权限
	cMember.SetRepAuthority(KinRepository.AUTHORITY_FIGURE_CAPTAIN);
	cExcutor.SetRepAuthority(0);
	local pPlayer = KPlayer.GetPlayerObjById(cMember.GetPlayerId());
	if (pPlayer) then
		Achievement:FinishAchievement(pPlayer, 33);	-- 成就，成为族长
	end

	return KKinGs.KinClientExcute(nKinId, {"Kin:ChangeCaptain_C2", nDataVer, nMemberId, KGCPlayer.GetPlayerName(cMember.GetPlayerId())})
end

--发起罢免族长
function Kin:FireCaptain_Init_GS1()
	local nKinId, nExcutorId = me.GetKinMember()
	local nRet, cKin, cExcutor = self:CheckSelfRight(nKinId, nExcutorId, 3)
	if nRet ~= 1 then
		return 0
	end
	local aKinData = self:GetKinData(nKinId)
	if aKinData.eveFireCaptain0 then
		me.Msg("上次罢免族长的申请尚未结束！")
		return 0
	end
	return GCExcute{"Kin:FireCaptain_Init_GC", nKinId, nExcutorId}
end
RegC2SFun("FireCaptainInit", Kin.FireCaptain_Init_GS1)

function Kin:FireCaptain_Init_GS2(nKinId, nExcutorId)
	local aKinData = self:GetKinData(nKinId)
	aKinData.eveFireCaptain0 = nExcutorId
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cMember = cKin.GetMember(nExcutorId)
	if not cMember then
		return 0
	end
	return KKinGs.KinClientExcute(nKinId, {"Kin:FireCaptain_Init_C2", nExcutorId, KGCPlayer.GetPlayerName(cMember.GetPlayerId())})
end

function Kin:FireCaptain_Vote_GS1()
	local nKinId, nExcutorId = me.GetKinMember()
	local nRet, cKin, cExcutor = self:HaveFigure(nKinId, nExcutorId, 3)
	if nRet ~= 1 then
		return 0
	end
	local aKinData = self:GetKinData(nKinId)
	if not aKinData.eveFireCaptain0 then
		me.Msg("Đơn xin bãi miễn Tộc trưởng đã thu hồi hoặc đã hết hạn!")
		return 0
	end
	--已经表决过
	if aKinData.eveFireCaptain0 == nExcutorId or aKinData.eveFireCaptain1 == nExcutorId then
		return 0
	end
	return GCExcute{"Kin:FireCaptain_Vote_GC", nKinId, nExcutorId}
end
RegC2SFun("FireCaptainVote", Kin.FireCaptain_Vote_GS1)

function Kin:FireCaptain_Cancel_GS2(nKinId)
	local aKinData = self:GetKinData(nKinId)
	aKinData.eveFireCaptain0 = nil
	aKinData.eveFireCaptain1 = nil
end

function Kin:FireCaptain_Vote_GS2(nKinId, nExcutorId, bLock)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cMember = cKin.GetMember(nExcutorId)
	if not cMember then
		return 0
	end
	local aKinData = self:GetKinData(nKinId)
	if bLock and bLock == 1 then
		aKinData.eveFireCaptain0 = nil
		aKinData.eveFireCaptain1 = nil
		cKin.SetCaptainLockState(1)
	else
		aKinData.eveFireCaptain1 = nExcutorId
	end
	return KKinGs.KinClientExcute(nKinId, {"Kin:FireCaptain_Vote_C2", nExcutorId, KGCPlayer.GetPlayerName(cMember.GetPlayerId()), bLock})
end

--编辑公告
function Kin:SetAnnounce_GS1(szAnnounce)
	local nKinId, nExcutorId = me.GetKinMember()
	if self:CheckSelfRight(nKinId, nExcutorId, 2) ~= 1 then
		return 0
	end
	if #szAnnounce > self.ANNOUNCE_MAX_LEN then
		me.Msg("Số lượng từ lớn hơn chiều dài cho phép!")
		return 0;
	end
	return GCExcute{"Kin:SetAnnounce_GC", nKinId, nExcutorId, szAnnounce}
end
RegC2SFun("SetAnnounce", Kin.SetAnnounce_GS1)

-- 编辑家园描述
function Kin:SetHomeLandDesc_GS1(szHomeLandDesc)
	local nKinId, nExcutorId = me.GetKinMember()
	if self:CheckSelfRight(nKinId, nExcutorId, 2) ~= 1 then
		return 0
	end
	if #szHomeLandDesc > self.HOMELANDDESC_MAX_LEN then
		me.Msg("家园描述字数大于允许的最大长度!")
		return 0;
	end
	return GCExcute{"Kin:SetHomeLandDesc_GC", nKinId, nExcutorId, szHomeLandDesc}
end
--RegC2SFun("SetHomeLandDesc", Kin.SetHomeLandDesc_GS1) -- 暂时不允许玩家编辑

function Kin:SetHomeLandDesc_GS2(nDataVer, nKinId, szHomeLandDesc)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	if cKin.SetHomeLandDesc(szHomeLandDesc) ~= 1 then
		return 0
	end
	cKin.SetKinDataVer(nDataVer)
	return KKinGs.KinClientExcute(nKinId, {"Kin:SetHomeLandDesc_C2", nDataVer, szHomeLandDesc})
end

function Kin:SetAnnounce_GS2(nDataVer, nKinId, szAnnounce)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	if cKin.SetAnnounce(szAnnounce) ~= 1 then
		return 0
	end
	cKin.SetKinDataVer(nDataVer)
	return KKinGs.KinClientExcute(nKinId, {"Kin:SetAnnounce_C2", nDataVer, szAnnounce})
end

-- 招募公告
function Kin:SetRecAnnounce_GS1(szRecAnnounce)
	local nKinId, nExcutorId = me.GetKinMember()
	if self:CheckSelfRight(nKinId, nExcutorId, 2) ~= 1 then
		return 0
	end
	if #szRecAnnounce > self.REC_ANNOUNCE_MAX_LEN then
		me.Msg("招募公告字数大于允许的最大长度!")
		return 0;
	end
	return GCExcute{"Kin:SetRecAnnounce_GC", nKinId, nExcutorId, szRecAnnounce}
end
RegC2SFun("SetRecAnnounce", Kin.SetRecAnnounce_GS1)

function Kin:SetRecAnnounce_GS2(nDataVer, nKinId, szRecAnnounce)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	if cKin.SetRecAnnounce(szRecAnnounce) ~= 1 then
		return 0
	end
	cKin.SetKinDataVer(nDataVer)
	return KKinGs.KinClientExcute(nKinId, {"Kin:SetRecAnnounce_C2", nDataVer, szRecAnnounce})
end

function Kin:StartCaptainVote_GS2(nKinId, nStartTime)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	cKin.SetVoteStartTime(nStartTime)
	KKin.Msg2Kin(nKinId, "Bỏ phiếu Tộc trưởng bắt đầu, thành viên chính thức bỏ phiếu tại giao diện gia tộc!")
	return 1
end

--停止单个家族的竞选
function Kin:StopCaptainVote_GS1(nKinId)
	return GCExcute{"Kin:StopCaptainVote_GC", nKinId}
end

function Kin:StopCaptainVote_GS2(nKinId, nMember, nMaxBallot)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	cKin.SetVoteCounter(0)
	cKin.SetVoteStartTime(0)
	local itor = cKin.GetMemberItor()
	local cMember = itor.GetCurMember()
	while cMember do
		--清空投票数据
		cMember.SetBallot(0)
		cMember.SetVoteState(0)
		cMember.SetVoteJourNum(0)
		
		cMember = itor.NextMember()
	end
	--解除族长锁定状态
	cKin.SetCaptainLockState(0)
	if nMember == 0 or nMaxBallot == 0 then
		KKin.Msg2Kin(nKinId, "Thời gian bỏ phiếu bầu Tộc trưởng kết thúc, không có biểu quyết, chức Tộc trưởng được giữ nguyên!")
		return 1
	end
	local cMemberNewCaptain = cKin.GetMember(nMember)
	if cMemberNewCaptain then
		KKin.Msg2Kin(nKinId, "Thời gian bỏ phiếu bầu Tộc trưởng kết thúc, <color=white>"..KGCPlayer.GetPlayerName(cMemberNewCaptain.GetPlayerId())..
			"<color>以<color=yellow>"..nMaxBallot.."<color> có số phiếu cao nhất được chon làm Tộc trưởng!")
	end
	return 1
end

--族长竞选投票
function Kin:CaptainVoteBallot_GS1(nMemberId)
	local nKinId, nExcutorId = me.GetKinMember()
	local nRet, cKin, cMemberExcutor = self:HaveFigure(nKinId, nExcutorId, 3)
	if nRet ~= 1 then
		return 0
	end
	local nVoteStartTime = cKin.GetVoteStartTime()
	if nVoteStartTime == 0 then
		me.Msg("Không phải thời gian bỏ phiếu bầu Tộc trưởng!")
		return 0
	end
	if cMemberExcutor.GetFigure() > self.FIGURE_REGULAR then
		me.Msg("Thành viên chính thức mới có thể bầu!")
		return 0
	end
	if cMemberExcutor.GetVoteState() == nVoteStartTime then
		me.Msg("Bạn đã bỏ phiếu bầu rồi!")
		return 0
	end
	local nPlayerId = cMemberExcutor.GetPlayerId();
	local nBallot = KGCPlayer.GetPlayerPrestige(nPlayerId);
	if nBallot <= 0 then
		me.Msg("Uy danh giang hồ phải lớn hơn 0 mới có thể bỏ phiếu bầu!")
		return 0
	end
	local cMemberTarget = cKin.GetMember(nMemberId)
	if not cMemberTarget or cMemberTarget.GetFigure() > self.FIGURE_REGULAR then
		me.Msg("Chỉ có thể bầu thành viên chính thức trong gia tộc!")
		return 0
	end
	me.Msg("Bỏ phiếu bầu thành công!")
	cMemberExcutor.SetVoteState(nVoteStartTime)
	return GCExcute{"Kin:CaptainVoteBallot_GC", nKinId, nExcutorId, nMemberId}
end
RegC2SFun("CaptainVoteBallot", Kin.CaptainVoteBallot_GS1)

function Kin:CaptainVoteBallot_GS2(nKinId, nExcutorId, nMemberId, nBallot, nVoteCounter)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cExcutor = cKin.GetMember(nExcutorId)
	local cMember = cKin.GetMember(nMemberId)
	if not cExcutor or not cMember then
		return 0
	end
	cExcutor.SetVoteState(cKin.GetVoteStartTime())
	cMember.AddBallot(nBallot)
	cMember.SetVoteJourNum(nVoteCounter)
	return KKinGs.KinClientExcute(nKinId, {"Kin:CaptainVoteBallot_C2", nExcutorId, nMemberId, nBallot})
end

function Kin:JoinTong_GS2(nKinId, szTong, nTongId, nCamp)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local nLastCamp = cKin.GetCamp()
	cKin.SetLastCamp(nLastCamp)
	cKin.SetBelongTong(nTongId)
	cKin.SetCamp(nCamp)
	KKinGs.KinAttachTong(nKinId, nTongId)
	cKin.AddHistoryJoinTong(szTong);
	return KKinGs.KinClientExcute(nKinId, {"Kin:JoinTong_C2", szTong})
end

function Kin:ApplyQuiitTong_GS1(nType)
	local nKinId, nExcutorId = me.GetKinMember();
	if self:CheckSelfRight(nKinId, nExcutorId, 1) ~= 1 then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then
		return 0;
	end
	if cKin.GetApplyQuitTime() ~= 0 then
		me.Msg("Đã xin rút khỏi bang, không thể hủy bỏ!")
		return 0;
	end
	local nTongId = cKin.GetBelongTong();
	if nTongId == 0 then 
		return 0;
	end
	if nType and nType == 1 then
		local tbData = Tong:GetExclusiveEvent(nTongId, Tong.REQUEST_STORAGE_FUND_TO_KIN);
		if tbData.nApplyEvent and tbData.nApplyEvent == 1 and tbData.ApplyRecord and tbData.ApplyRecord.nTargetKinId == nKinId then 
			me.CallClientScript({"Ui:ServerCall", "UI_KIN", "LeaveTongPromt_C2"});-- 提示客户端确认是否叛离
			return 0;
		end
	end
	if cKin.GetTongFigure() == 1 then
		me.Msg("Bang chủ thuộc gia tộc không thể rời khỏi bang!");
		return 0;
	end
	return GCExcute{"Kin:ApplyQuitTong_GC", nTongId, nKinId, nExcutorId};
end
RegC2SFun("LeaveTong", Kin.ApplyQuiitTong_GS1);

function Kin:ApplyQuitTong_GS2(nKinId, nApplyQuitTime)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetApplyQuitTime(nApplyQuitTime);
	return KKinGs.KinClientExcute(nKinId, {"Kin:ApplyQuitTong_C2", nApplyQuitTime});
end

function Kin:QuitTongVote_GS1(nAccept)
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		return 0;
	end
	if cKin.GetApplyQuitTime() == 0 then
		me.Msg("Không có đề nghị trục xuất gia tộc hoặc việc biểu quyết đã kết thúc");
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then 
		return 0;
	end
	if cMember.GetQuitVoteState() ~= 0 then
		me.Msg("Bạn đã biểu quyết");
		return 0;
	end
	return GCExcute{"Kin:QuitTongVote_GC", nKinId, nMemberId, nAccept};
end
RegC2SFun("QuitTongVote", Kin.QuitTongVote_GS1);

function Kin:QuitTongVote_GS2(nKinId, nMemberId, nAccept)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return 0;
	end
	cMember.SetQuitVoteState((nAccept == 1) and 1 or 2);
	local nPlayerId = cMember.GetPlayerId();
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	return pPlayer.CallClientScript({"Kin:QuitTongVote_C2", nAccept});
end

-- 主动取消离开帮会
function Kin:CloseQuitTong_GS1()
	local nKinId, nMemberId = me.GetKinMember() 
	if self:CheckSelfRight(nKinId, nMemberId, 1) ~= 1 then
		me.Msg("Bạn không có quyền trục xuất gia tộc rời khỏi bang");
		return 0;
	end
	return GCExcute{"Kin:CloseQuitTong_GC", nKinId, 2};
end
RegC2SFun("CloseQuitTong", Kin.CloseQuitTong_GS1);

--关闭退出帮会的投票状态, bSuccess为  0为时间到失败;1表示时间到达成功退出帮会;2为族长取消;3为帮主家族不可退出
function Kin:CloseQuitTong_GS2(nKinId, nSuccess)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		return 0;
	end
	local cMemberItor = cKin.GetMemberItor();
	local cCurMember = cMemberItor.GetCurMember();
	while cCurMember do
		cCurMember.SetQuitVoteState(0);			-- 清空各个成员的投票状态
		cCurMember = cMemberItor.NextMember()
	end
	cKin.SetApplyQuitTime(0);
	return KKinGs.KinClientExcute(nKinId, {"Kin:CloseQuitTong_C2", nSuccess});
end

function Kin:LeaveTong_GS2(nTongId, nKinId, nMethod, nBuildFund, nTotalStock, tbResult, bSync)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local pTong = KTong.GetTong(nTongId);
	if pTong then		-- 帮会不存在的话应该是解散了~不用管
		pTong.SetBuildFund(nBuildFund);
		pTong.SetTotalStock(nTotalStock);
	end
--	local nLastCamp = cKin.GetLastCamp()
--	if nLastCamp ~= 0 and cKin.GetCamp() ~= nLastCamp then
--		cKin.SetCamp(nLastCamp)
--		KKinGs.UpdateKinMemberCamp(nKinId, nLastCamp)
--	end
	--清空帮会相关数据
	cKin.SetBelongTong(0)
	cKin.SetTongFigure(0)
	cKin.SetTongVoteBallot(0)
	cKin.SetTongVoteJourNum(0)
	cKin.SetTongVoteState(0)
	if cKin.GetApplyQuitTime() ~= 0 then
		self:CloseQuitTong_GS2(nKinId, 1);
	end
	KKinGs.KinDetachTong(nKinId)
	--清空成员帮会相关数据
	local cMemberItor = cKin.GetMemberItor()
	local cMember = cMemberItor.GetCurMember()
	while cMember do
		cMember.SetTongFlag(0);
		cMember.SetEnvoyFigure(0);
		cMember.SetWageFigure(0);
		cMember.SetWageValue(0);
		local nMember = cMemberItor.GetCurMemberId();
		if tbResult[nMember] then
			cMember.SetPersonalStock(tbResult[nMember]);		-- 同步成员数据
		else
			cMember.SetPersonalStock(0)
		end
		cMember = cMemberItor.NextMember();
	end
	if bSync == 1 then
		return KKinGs.KinClientExcute(nKinId, {"Kin:LeaveTong_C2", nMethod})
	end
	return 1
end

function Kin:SetSelfQuitVoteState(nVoteState)
	local nKinId, nMemberId = me.GetKinMember()
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return 0; 
	end
	cMember.SetQuitVoteState(nVoteState);
	return GCExcute{"Kin:SetSelfQuitVoteState_GC", nKinId, nMemberId, nVoteState};
end

function Kin:AddKinTotalRepute_GS2(nKinId, nMemberId, nPlayerId, nRepute, nDataVer)
	local pKin = KKin.GetKin(nKinId);
	if pKin then
		pKin.AddTotalRepute(nRepute);
		pKin.SetKinDataVer(nDataVer);
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.Msg(string.format("Bạn nhận được %d Uy danh", nRepute));
	end
end

function Kin: AddHistory(bIsHistory, nType, ...)
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.AddKinHistory(bIsHistory, nType, GetTime(), unpack(arg));
end

-- TODO:测试用临时指令，完整的历史功能后删除
function Kin:GetHistoryPage_GS1(nIsHistory, nPage)
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local tbHistory = cKin.GetKinHistory(nIsHistory, nPage);
	me.Msg("page"..nPage);
	for i, tbRecord in pairs(tbHistory) do
		local szMsg = self:ParseHistory(tbRecord);
		me.Msg(szMsg);
	end
end

function Kin:AddGuYinBi_GS2(nKinId, nCurGuYinBi, nAddGuYinBi)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	pKin.SetKinGuYinBi(nCurGuYinBi);
	return KKinGs.KinClientExcute(nKinId, {"Kin:AddGuYinBi_C2", nAddGuYinBi});
end

-- 检测、设置家族插旗时间和地点
function Kin:CheckBuildFlagOrderTime(nHour, nMin, nPlayerId, nKinId)
	if not nPlayerId then
		return 0;
	end
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0;
	end
	local cSelfNpc = cPlayer.GetNpc();
	local nMapId, nMapX, nMapY = cSelfNpc.GetWorldPos();
	
-- 判断时间是否正确
	local nTime = nHour * 60 + nMin;	
	local nBeginTime = 19 * 60 + 30;	-- 允许使用的开始时间
	local nEndTime = 23 * 60 + 30;	-- 允许使用的结束时间
	if nTime < nBeginTime or nTime > nEndTime then
		--返回界面并通知玩家设置不正确
		cPlayer.Msg("Thời gian không chính xác");
		cPlayer.CallClientScript({"UiManager:OpenWindow", "UI_KINBUILDFLAG"});
		return 0;
 	end
 	
 -- 判断地点是否正确	
	if GetMapType(nMapId) ~= "village" and GetMapType(nMapId) ~= "city" then
		cPlayer.Msg("Thông báo gia tộc chỉ có thể sử dụng ở thành hoặc tân thủ thôn!");
		cPlayer.CallClientScript({"UiManager:OpenWindow", "UI_KINBUILDFLAG"});
		return 0;
	end	
	
-- 扣除掉令牌
	local tbItem = cPlayer.FindItemInBags(18, 1, 47, 1, 0);
	if not tbItem[1] then
		return 0;
	end

	cPlayer.DelItem(tbItem[1].pItem);
	
	return GCExcute{"Kin:SaveBuildFlagSetting_GC", nPlayerId, nKinId, nTime, nMapId, nMapX, nMapY};
end
RegC2SFun("CheckBuildFlagOrderTime", Kin.CheckBuildFlagOrderTime); 
-- 注册客户端到服务器的回调

-- 所有服务器保存插旗的时间，用于客户端显示
function Kin:SaveBuildFlagSetting_GS2(nPlayerId, nKinId, nTime, nMapId, nMapX, nMapY)
		local cKin = KKin.GetKin(nKinId);
		if cKin then			
			-- 记录插旗时间
			cKin.SetKinBuildFlagOrderTime(nTime);
			cKin.SetKinBuildFlagMapId(nMapId);
			cKin.SetKinBuildFlagMapX(nMapX);
			cKin.SetKinBuildFlagMapY(nMapY);
		
			-- 插旗
			local nNowDay = tonumber(os.date("%m%d", GetTime()));
			local nPreDay = cKin.GetTogetherTime(); 
			local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if (nNowDay ~= nPreDay) then
				Kin:KinBuildFlag_GS2(nKinId);
				if cPlayer then
					cPlayer.Msg("Xác định thời gian cắm cờ gia tộc thành công");
				end
			else
				if cPlayer then
					cPlayer.Msg("Xác định thời gian cắm cờ gia tộc thành công, hôm nay đã quá thời gian, ngày mai hoạt động cắm cờ tự động bắt đầu");
				end
			end
		end
		
end

-- 有指定插旗的地图的服务器开始插旗，在所有服务器都公告一次
function Kin:KinBuildFlag_GS2(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	
	KKin.Msg2Kin(nKinId,"Hoạt động cắm cờ gia tộc bắt đầu, các thành viên gia tộc chú ý tập trung.");
	
	-- 记录今天已经插旗
	local nNowDay = tonumber(os.date("%m%d", GetTime()));
	cKin.SetTogetherTime(nNowDay);
	local nMapId = cKin.GetKinBuildFlagMapId();
	if not nMapId then
		return 0;
	end
	
	if IsMapLoaded(nMapId) then
		local nMapX = cKin.GetKinBuildFlagMapX();
		local nMapY = cKin.GetKinBuildFlagMapY();
		local tbNpc	= Npc:GetClass("jiazulingpainpc");	
		tbNpc:StartToWork(nKinId, nMapId, nMapX, nMapY);
	end
end

-- 修改家族令牌的KinExpstate,使玩家能再领家族令牌
function Kin:ChangeKinExpState_GS2(nPlayerId, nKinId)	
	local cKin = KKin.GetKin(nKinId);
	if cKin then
		local nNowDay = tonumber(os.date("%m%d", GetTime()));
		cKin.SetGainExpState(nNowDay);
		cKin.SetKinBuildFlagOrderTime(0);
	end	
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if  cPlayer then
		cPlayer.Msg("Hoạt động cắm cờ gia tộc bạn đã bị xóa, bạn có thể thiết lập lại thời gian và địa điểm cắm cờ.");
		local cLingPai = cPlayer.AddItemEx(Item.SCRIPTITEM, 1, 47, 1, {bTimeOut = 1});	-- 获得家族令牌
		if cLingPai then
			cPlayer.SetItemTimeout(cLingPai,os.date("%Y/%m/%d/00/00/00", GetTime() + 3600 * 24)); -- 领取当天有效
			cLingPai.Sync();
		end
		cPlayer.Msg("Nhận lệnh bài gia tộc");
		Dbg:WriteLog("Kin","PlayerID:"..cPlayer.nId,"Account:"..cPlayer.szAccount.."Get a JiaZuLingPai");
	end
	return 1;
end

-- 领取家族令牌
function Kin:GetKinLingPai_GS2(nKinId, nPlayerId)
	if not nKinId or not nPlayerId then
		return 0;
	end
	
	local nTime = GetTime();
	local nNowDay = tonumber(os.date("%m%d", nTime));
		
	local cKin = KKin.GetKin(nKinId);	
	cKin.SetGainExpState(nNowDay);	
	
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0
	end
	local cLingPai = cPlayer.AddItemEx(Item.SCRIPTITEM, 1, 47, 1, {bTimeOut = 1});	-- 获得家族令牌
	if cLingPai then
		cPlayer.SetItemTimeout(cLingPai,os.date("%Y/%m/%d/00/00/00", GetTime() + 3600 * 24)); -- 领取当天有效
		cLingPai.Sync();
	end
	cPlayer.Msg("Nhận lệnh bài gia tộc");
	return 1;
end

-- 帮会频道提示插旗
function Kin:NoticeKinBuildFlag_GS2(nKinId, nLeftTime)
	if not nKinId then
		return 0;
	end
	KKin.Msg2Kin(nKinId, nLeftTime.." nữa cắm cờ gia tộc.");
end

function Kin:SetRecuitmentAutoAgree_GS1(nAutoAgree)
	local nKinId, nMemberId = me.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		return 0;
	end
	return GCExcute{"Kin:SetRecuitmentAutoAgree_GC", nKinId, nMemberId, nAutoAgree};
end
RegC2SFun("SetRecuitmentAutoAgree", Kin.SetRecuitmentAutoAgree_GS1)

function Kin:SetRecuitmentAutoAgree_GS2(nKinId, nAutoAgree)
	local pKin = KKin.GetKin(nKinId);
	if pKin and nAutoAgree then
		pKin.SetRecruitmentAutoAgree(nAutoAgree);
		local nPublish = pKin.GetRecruitmentPublish();
		local nLevel = pKin.GetRecruitmentLevel();
		local nHonor = pKin.GetRecruitmentHonour();
		return KKinGs.KinClientExcute(nKinId, {"Kin:ProcessRecruitmentPublish", nPublish, nLevel, nHonor, nAutoAgree});
	end
end

-- 发布\取消招募
function Kin:RecruitmentPublish_GS1(nPublish, nLevel, nHonour, nAutoAgree)
	local nKinId, nMemberId = me.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		me.Msg("Bạn không có gia tộc, không thể chiêu mộ.");
		return 0;
	end
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		me.Msg("Tộc trưởng và Tộc phó mới có quyền này.");
		return 0;
	end
	if nPublish == 1 and nLevel > Kin.KIN_RECRUITMENT_MAX_LEVEL then
		me.Msg("Chiêu mộ vượt quá phạm vi");
		return 0;
	end
	if nPublish == 1 and nLevel < Kin.KIN_RECRUITMENT_MIN_LEVEL then
		me.Msg("Yêu cầu tối thiểu cấp "..Kin.KIN_RECRUITMENT_MIN_LEVEL..".");
		nLevel = 10;
	end
	local nMemberLimit, nRetireLimit = self:GetKinMemberLimit(nKinId);
	local nRegular, nSigned, nRetire = pKin.GetMemberCount();
	local nMemberCount = nRegular + nSigned;
	
	if (nRegular + nSigned + nRetire) >= (nMemberLimit + nRetireLimit) then
		me.Msg("Gia tộc đã đầy, không thể chiêu mộ.");
		return 0;
	end
	if nMemberCount >= nMemberLimit then
		me.Msg("Gia tộc đã đầy, không thể chiêu mộ.");
		return 0;
	end

	return GCExcute{"Kin:RecruitmentPublish_GC", nKinId, nMemberId, nPublish, nLevel, nHonour, nAutoAgree};
end
RegC2SFun("RecruitmentPublish", Kin.RecruitmentPublish_GS1)

function Kin:RecruitmentPublish_GS2(nKinId, nPublish, nLevel, nHonour, nAutoAgree)
	local pKin = KKin.GetKin(nKinId);
	if pKin and nPublish then
		pKin.SetRecruitmentPublish(nPublish);
		if nPublish == 1 then
			if nLevel then
				pKin.SetRecruitmentLevel(nLevel);
			end
			if nHonour then
	 			pKin.SetRecruitmentHonour(nHonour);
	 		end
	 		if nAutoAgree then
	 			pKin.SetRecruitmentAutoAgree(nAutoAgree);
	 		end
			KKin.Msg2Kin(nKinId, "Bắt đầu chiêu mộ thành viên!");
		else
			KKin.Msg2Kin(nKinId, "Kết thúc chiêu mộ thành viên!");
		end
		return KKinGs.KinClientExcute(nKinId, {"Kin:ProcessRecruitmentPublish", nPublish, nLevel, nHonour, nAutoAgree});
	end
end

-- 同意招募
function Kin:RecruitmentAgree_GS1(szName)
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local pSelfKin = KKin.GetKin(nSelfKinId);
	if not pSelfKin then
		me.Msg("Không có gia tộc, không thể chiêu mộ.");
		return 0;
	end
	
	if Kin:CheckSelfRight(nSelfKinId, nSelfMemberId, 2) ~= 1 then
		me.Msg("Tộc trưởng và Tộc phó mới có quyền này.");
		return 0;
	end
	local nMemberLimit, nRetireLimit = self:GetKinMemberLimit(nSelfKinId);
	local nRegular, nSigned, nRetire = pSelfKin.GetMemberCount();
	local nMemberCount = nRegular + nSigned;
	if (nRegular + nSigned + nRetire) >= (nMemberLimit + nRetireLimit) then
		me.Msg("Gia tộc đã đầy, không thể chiêu mộ.");
		return 0;
	end
	if nMemberCount >= nMemberLimit then
		me.Msg("Gia tộc đã đầy, không thể chiêu mộ.");
		return 0;
	end
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
	if not nPlayerId or nPlayerId <= 0 then
		me.Msg("Nhân vật không tồn tại.");
		return 0;
	end
	local nKinId  = KGCPlayer.GetKinId(nPlayerId)
	local pKin = KKin.GetKin(nKinId);
	if pKin then
		me.Msg("Người chơi đã vào Gia tộc khác.");
		return 0;
	end
	if GetTime() - KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_LEAVE_KIN_TIME) < 1800 then
		me.Msg("Người chơi vừa rồi gia tộc khác chưa đầy 30 phút.")
		return 0
	end

	return GCExcute{"Kin:RecruitmentAgree_GC", nSelfKinId, nSelfMemberId, szName, nKinId};
end
RegC2SFun("RecruitmentAgree", Kin.RecruitmentAgree_GS1)

function Kin:RecruitmentAgree_GS2(nKinId, nSelfMemberId, szName, nPlayerId)
	local pKin = KKin.GetKin(nKinId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pKin and pPlayer then
		StatLog:WriteStatLog("stat_info", "join_kin", "join_in", nPlayerId, pKin.GetName());
	end
	self:MemberAdd_GS1(nKinId, nSelfMemberId, nPlayerId, 0);
	KKin.DelKinInductee(nKinId, szName);
--	return KKinGs.KinClientExcute(nKinId, {"Kin:ProcessRecruitment"});
end

-- 拒绝招募
function Kin:RecruitmentReject_GS1(szName)
	local nKinId, nMemberId = me.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		me.Msg("Không có gia tộc không thể chiêu mộ.");
		return 0;
	end
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		me.Msg("Tộc trưởng và Tộc phó mới có quyền này.");
		return 0;
	end
	
	return GCExcute{"Kin:RecruitmentReject_GC", szName, nKinId, nMemberId};
end
RegC2SFun("RecruitmentReject", Kin.RecruitmentReject_GS1)

function Kin:RecruitmentReject_GS2(szName, nKinId, nMemberId)
	local pKin = KKin.GetKin(nKinId);
	if pKin then
		KKin.DelKinInductee(nKinId, szName);
		local pMember = pKin.GetMember(nMemberId);
		if pMember then
			local pPlayer = KPlayer.GetPlayerObjById(pMember.GetPlayerId());
			if pPlayer then
				pPlayer.Msg("Từ chối "..szName.." yêu cầu");
			end
			
			local nTagetPlayerId = KGCPlayer.GetPlayerIdByName(szName);
			local pTagetPlayer = KPlayer.GetPlayerObjById(nTagetPlayerId);
			if pTagetPlayer then
				pTagetPlayer.Msg(pKin.GetName().." từ chối yêu cầu gia nhập");
			end
		end	
	end
--	return KKinGs.KinClientExcute(nKinId, {"Kin:ProcessRecruitment"});
end

-- 加入招募
function Kin:JoinRecruitment_GS1(nKinId)
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local pSelfKin = KKin.GetKin(nSelfKinId);
	if pSelfKin then
		me.Msg("Ngươi đã có gia tộc rồi.");
		return 0;
	end
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		me.Msg("Gia tộc không tồn tại.");
		return 0;
	end
	if pKin.GetRecruitmentPublish() == 0 then
		me.Msg("Gia tộc đã kết thúc chiêu mộ.");
		return 0;
	end
	local pKin = KKin.GetKin(nKinId);
	if KKin.GetInducteeCount(nKinId) >= self.INDUCTEE_LIMITED then
		me.Msg("Danh sách chiêu mộ đã đầy.");
		return 0;
	end
	if KKin.GetKinInducteeJoinTime(nKinId, me.szName) then
		me.Msg("Bạn đã trong gia tộc rồi");
		return 0;
	end
	
	local nNeedLevel = pKin.GetRecruitmentLevel();
	local nNeedHonour = pKin.GetRecruitmentHonour();

	if me.nFaction <= 0 then
		me.Msg("Chưa có môn phái");
		return 0;
	end
	
	if me.nLevel < nNeedLevel then
		me.Msg("Đẳng cấp yêu cầu không đủ.");
		return 0;
	end
	
	local nHonour = PlayerHonor:GetHonorLevel(me, PlayerHonor.HONOR_CLASS_MONEY);
	if nHonour < nNeedHonour then
		me.Msg("Tài phú yêu cầu không đủ.");
		return 0;
	end
	
	if GetTime() - KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_LEAVE_KIN_TIME) < 1800 then
		me.Msg("Vừa rời gia tộc cũ chưa đầy 30 phút!")
		return 0
	end
	
	if pKin.GetRecruitmentAutoAgree() == 1 then
		StatLog:WriteStatLog("stat_info", "join_kin", "join_ask", me.nId, pKin.GetName());
		StatLog:WriteStatLog("stat_info", "join_kin", "join_in", me.nId, pKin.GetName());
		return Kin:MemberAdd_GS1(nKinId, pKin.GetCaptain(), me.nId, 0);
	end
	
	local nJoinTimes = me.GetTask(self.KIN_RECRUITMENT_TASK_GROUP_ID, self.TSK_JOIN_RECRUITMENT_TIMES);
	local nJoinTime = me.GetTask(self.KIN_RECRUITMENT_TASK_GROUP_ID, self.TSK_JOIN_RECRUITMENT_DAY);
	local nJoinDay =  tonumber(os.date("%Y%m%d", nJoinTime));
	local nNowTime = GetTime();
	local nNowDay = tonumber(os.date("%Y%m%d", nNowTime));
	if nJoinTimes >= self.KIN_JOIN_RECRUITMENT_MAXTIMES and nJoinDay == nNowDay then
		me.Msg("Chỉ có 10 cơ hội nộp đơn chiêu mộ vào gia tộc mỗi ngày.");
		return 0;
	elseif nJoinDay ~= nNowDay then
		nJoinTimes = 0;
	end
	me.Msg("Lần "..(nJoinTimes + 1).." nộp đơn chiêu mộ, chỉ có 10 cơ hội nộp đơn chiêu mộ vào gia tộc mỗi ngày.")
	me.SetTask(self.KIN_RECRUITMENT_TASK_GROUP_ID, self.TSK_JOIN_RECRUITMENT_TIMES, nJoinTimes + 1);
	me.SetTask(self.KIN_RECRUITMENT_TASK_GROUP_ID, self.TSK_JOIN_RECRUITMENT_DAY, nNowTime);

	if KKin.GetInducteeCount(nKinId) >= self.INDUCTEE_LIMITED - 1 then
		KKin.Msg2Kin(nKinId, "Danh sách chiêu mộ đã đầy.");
	end
	return GCExcute{"Kin:JoinRecruitment_GC", nKinId, me.nId};
end
RegC2SFun("JoinRecruitment", Kin.JoinRecruitment_GS1)

function Kin:JoinRecruitment_GS2(nKinId, nPlayerId, nTime, szName)
	local pKin = KKin.GetKin(nKinId);
	if pKin then
		KKin.AddKinInductee(nKinId, nTime, szName);	
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.Msg("Đã nộp đơn vào gia tộc "..pKin.GetName());
			StatLog:WriteStatLog("stat_info", "join_kin", "join_ask", nPlayerId, pKin.GetName());
		end
		-- add 管理者提示
		local szMsg = string.format("<color=yellow>%s<color>申请加入家族，请查看招募列表！", szName);
		local nCaptainId = Kin:GetPlayerIdByMemberId(nKinId, pKin.GetCaptain());
		local pCaptain = KPlayer.GetPlayerObjById(nCaptainId);
		if pCaptain then
			Dialog:SendBlackBoardMsg(pCaptain, szMsg);
		end
		local nAssistantId = Kin:GetPlayerIdByMemberId(nKinId, pKin.GetAssistant());
		local pAssistant = KPlayer.GetPlayerObjById(nAssistantId);
		if pAssistant then
			Dialog:SendBlackBoardMsg(pAssistant, szMsg);
		end
	end
end

-- 清理已经有家族的应召者
function Kin:KinRecruitmenClean_GS1(nKinId)
	return GCExcute{"Kin:KinInducteeClean_GC", nKinId};
end
RegC2SFun("KinRecruitmenClean", Kin.KinRecruitmenClean_GS1)

function Kin:KinRecruitmenClean_GS2(nKinId, tbDelKinInducteeList)
--	print("KinRecruitmenClean_GS2")
--	Lib:ShowTB(tbDelKinInducteeList)
	for i, szName in ipairs(tbDelKinInducteeList) do		
		KKin.DelKinInductee(nKinId, szName);
	end
--	return KKinGs.KinClientExcute(nKinId, {"Kin:ProcessRecruitment"});
end

-- 申请招募信息：招募状态、要求等级和荣誉
function Kin:ApplyRecruitmentPublishInfo()
	local nKinId, nMemberId = me.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local nPublish = pKin.GetRecruitmentPublish();
	local nNeedLevel = pKin.GetRecruitmentLevel();
	local nNeedHonour = pKin.GetRecruitmentHonour();
	local nAutoAgree = pKin.GetRecruitmentAutoAgree();
	return KKinGs.KinClientExcute(nKinId, {"Kin:ProcessRecruitmentPublish", nPublish, nNeedLevel, nNeedHonour, nAutoAgree});
end
RegC2SFun("ApplyRecruitmentPublishInfo", Kin.ApplyRecruitmentPublishInfo)

-- 每周清理家族招募榜
function Kin:CleanKinRecruitmenPublish_GS2(nKinId)
	local pCurKin = KKin.GetKin(nKinId);
	if not pCurKin then
		return;
	end
	pCurKin.SetRecruitmentPublish(0);
	KKin.Msg2Kin(nKinId, "您的家族招募到达了发布期限(七天以后)，家族招募结束了，请重新发布招募。");
end

-- 家族已完成成就的修复
function Kin:RepairAchievement()
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId)
	if (not cMember) then
		return 0;
	end
	
	Achievement:FinishAchievement(me, 26);	-- 修复已有成就，加入家族
	if (self.FIGURE_CAPTAIN == cMember.GetFigure()) then
		Achievement:FinishAchievement(me, 33);	-- 修复已有成就，才成为族长
	end
end

--家族资金转存帮会
function Kin:StorageFundToTong_GS1(nMoney)
	if EventManager.IVER_bOpenkinMoney ~= 1 then
		Dialog:SendBlackBoardMsg(me, "该功能暂未开放！");
		return;
	end
	if (not nMoney or 0 == Lib:IsInteger(nMoney) or nMoney <= 0 or nMoney > self.MAX_KIN_FUND) then
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then
		Dialog:SendInfoBoardMsg(me, "你没有家族，不能转存家族资金到帮会！");
		me.Msg("你没有家族，不能转存家族资金到帮会！");
		return 0;
	end
	local cTong = KTong.GetTong(me.dwTongId);
	if not cTong then
		Dialog:SendInfoBoardMsg(me, "你没有帮会，不能转存家族资金到帮会！");
		me.Msg("你没有帮会，不能转存家族资金到帮会！");
		return 0;
	end
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return 0;
	end
	if (Kin:CheckSelfRight(nKinId, nMemberId, 1) ~= 1) then
		Dialog:SendInfoBoardMsg(me, "只有族长才能转存家族资金到帮会！");
		me.Msg("只有族长才能转存家族资金到帮会！");
		return 0;
	end
	if (me.IsInPrison()  == 1)then
		me.Msg("您在坐牢期间不能转存家族资金到帮会！");
		return 0;
	end
	local tbSalaryData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	if tbSalaryData.nApplyEvent and tbSalaryData.nApplyEvent == 1 then
		Dialog:SendInfoBoardMsg(me, "已经有发放出勤奖励的申请！");
		me.Msg("已经有发放出勤奖励的申请！请先处理后再转存帮会！");
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		Dialog:SendInfoBoardMsg(me, "已经有取出家族资金的申请！");
		me.Msg("已经有取出家族资金的申请！请先处理申请后再转存帮会！");
		return 0;
	end
	if tbData.nLastStorageTime and GetTime() - tbData.nLastStorageTime < self.STORAGE_FUND_TIME then
		Dialog:SendInfoBoardMsg(me, "两次转存帮会时间间隔需要一分钟！");
		me.Msg("两次转存帮会时间间隔需要一分钟！");
		return 0;
	end
	local nKinFund = cKin.GetMoneyFund();
	local nTongFund = cTong.GetMoneyFund();
	if nMoney > nKinFund then
		Dialog:SendInfoBoardMsg(me, "没有足够的家族资金让你转存帮会！");
		me.Msg("没有足够的家族资金让你转存帮会！");
		return 0;
	end
	if nMoney + nTongFund > Tong.MAX_TONG_FUND then
		Dialog:SendInfoBoardMsg(me, "您转存帮会的金额将会使帮会资金超过存款上限！");
		me.Msg("您转存帮会的金额将会使帮会资金超过存款上限，无法存入！");
		return 0;
	end
	return GCExcute{"Kin:StorageFundToTong_GC", me.nId, nKinId, nMemberId, me.dwTongId, nMoney};
end
RegC2SFun("StorageFundToTong", Kin.StorageFundToTong_GS1)

function Kin:StorageFundToTong_GS2(nPlayerId, nKinId, nTongId, nKinDataVer, nTongDataVer, nKinFund, nTongFund, nMoney)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetKinDataVer(nKinDataVer);
	cKin.SetMoneyFund(nKinFund);
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	cTong.SetTongDataVer(nTongDataVer);
	cTong.SetMoneyFund(nTongFund);
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	local szKinName = cKin.GetName();
	local szTongName = cTong.GetName();
	if nMoney >= self.STORAGE_FUND_TO_TONG then
		cTong.AddAffairGetFundFromKin(szKinName, tostring(nMoney));
		cKin.AddAffairStorageFundToTong(szPlayerName, szTongName, tostring(nMoney));
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	tbData.nLastStorageTime = GetTime();
	KKinGs.KinClientExcute(nKinId, {"Kin:StorageFundToTong_C2", szPlayerName, szTongName, nMoney});
	KTongGs.TongClientExcute(nTongId, {"Tong:GetFundFromKin_C2", szKinName, nMoney});
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0;
	end
	cPlayer.Msg("成功转存帮会" .. nMoney .. "两家族资金！");
	cPlayer.CallClientScript({"Ui:ServerCall", "UI_KIN", "RefreshFund_C2", nKinFund});
end

function Kin:AddFund_GS1(nMoney)
	if EventManager.IVER_bOpenkinMoney ~= 1 then
		Dialog:SendBlackBoardMsg(me, "该功能暂未开放！");
		return;
	end
	if (not nMoney or 0 == Lib:IsInteger(nMoney) or nMoney <= 0 or nMoney > 2000000000) then
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		me.Msg("你没有家族，不能存家族资金");
		return 0;
	end
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return 0 ;
	end
	if (me.IsInPrison()  == 1)then
		me.Msg("您在坐牢期间不能存入家族资金！");
		return 0;
	end
	
	local nCurMoney = me.nCashMoney;
	if nMoney > nCurMoney then
		Dialog:SendInfoBoardMsg(me, "你的身上没有足够的银两！");
		me.Msg("你的身上没有足够的银两！");
		return 0;
	end
	local nKinMoney = cKin.GetMoneyFund();
	if nMoney + nKinMoney > self.MAX_KIN_FUND then
		Dialog:SendInfoBoardMsg(me, "您存入的金额将会使家族资金超过存款上限！");
		me.Msg("您存入的金额将会使家族资金超过存款上限，无法存入！");
		return 0;
	end
	local nRet = me.CostMoney(nMoney, Player.emKPAY_KIN_FUND);
	if nRet ~= 1 then
		me.Msg("存入资金失败！");
		return 0;
	end
	return GCExcute{"Kin:AddFund_GC", nKinId, me.nId, nMoney};
end
RegC2SFun("AddFund", Kin.AddFund_GS1)

--系统存钱，有可能会失败
function Kin:AddFundGM_GS(nKinId, nMoney)
	GCExcute{"Kin:AddFund_GC", nKinId, -1, nMoney};
end

function Kin:AddFund_GS2(nKinId, nDataVer, nPlayerId, nKinFund, nMoney)	
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetMoneyFund(nKinFund);
	cKin.SetKinDataVer(nDataVer);
	local szPlayerName = "系统奖励"
	if nPlayerId > 0 then
		szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	end
	if nMoney >= self.TAKE_FUND_APPLY then
		cKin.AddAffairSaveFund(szPlayerName, tostring(nMoney));
	end
	KKinGs.KinClientExcute(nKinId, {"Kin:AddFund_C2", szPlayerName, nMoney});
	if nPlayerId <= 0 then
		return;
	end
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return;
	end
	cPlayer.Msg("成功存入" .. nMoney .. "两家族资金！");
	cPlayer.CallClientScript({"Ui:ServerCall", "UI_KIN", "RefreshFund_C2", nKinFund});
end

function Kin:ApplyTakeFund_GS1(nMoney)
	if EventManager.IVER_bOpenkinMoney ~= 1 then
		Dialog:SendBlackBoardMsg(me, "该功能暂未开放！");
		return;
	end
	if (not nMoney or 0 == Lib:IsInteger(nMoney) or nMoney <= 0 or nMoney > 2000000000) then
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		Dialog:SendInfoBoardMsg(me, "你没有家族，不能取家族资金！");
		me.Msg("你没有家族，不能取家族资金");
		return 0;
	end
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return;
	end
	if (me.IsInPrison() == 1) then
		me.Msg("您在坐牢期间不能取帮会资金。");
		return 0;
	end
	local tbSalaryData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	if tbSalaryData.nApplyEvent and tbSalaryData.nApplyEvent == 1 then
		Dialog:SendInfoBoardMsg(me, "已经有发放出勤奖励的申请！不能再申请！");
		me.Msg("已经有发放出勤奖励的申请！不能再申请！");
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		Dialog:SendInfoBoardMsg(me, "已经有取出家族资金的申请！不能再申请！");
		me.Msg("已经有取出家族资金的申请！不能再申请！");
		return 0;
	end
	
	if tbData.nLastTime and GetTime() - tbData.nLastTime < self.TAKE_FUND_TIME then
		Dialog:SendInfoBoardMsg(me, "两次取家族资金需要间隔5分钟！");
		me.Msg("两次取家族资金需要间隔5分钟");
		return 0;
	end
	local nCurFund = cKin.GetMoneyFund();
	if (nMoney > nCurFund) then
		Dialog:SendInfoBoardMsg(me, "家族没有足够的资金供你取出！");
		me.Msg("家族没有足够的资金供你取出！");
		return 0;
	end
	if me.GetMaxCarryMoney() < me.nCashMoney + nMoney then
		Dialog:SendInfoBoardMsg(me, "你取出的资金额度将会使银两携带量超出上限！");
		me.Msg("你取出的资金额度将会使银两携带量超出上限！");
		return 0;
	end
	return GCExcute{"Kin:ApplyTakeFund_GC", nKinId, nMemberId, me.nId, nMoney};
end
RegC2SFun("TakeFund", Kin.ApplyTakeFund_GS1)

function Kin:ApplyTakeFund_GS2(nType, nKinId, nMemberId, nPlayerId, nMoney)
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	tbData.nApplyEvent = 1;
	if not tbData.tbApplyRecord then
		tbData.tbApplyRecord = {};
	end
	tbData.tbApplyRecord.nMemberId = nMemberId;
	tbData.tbApplyRecord.nAmount = nMoney;
	tbData.tbAccept = {};
	if nType == 1 then
		tbData.tbApplyRecord.nPow = self.FIGURE_REGULAR;
		tbData.nAgreeCount = 2;
	else
		tbData.tbApplyRecord.nPow = self.FIGURE_CAPTAIN;
		tbData.nAgreeCount = 1;
	end
	tbData.tbApplyRecord.nTimerId = Timer:Register(
		self.TAKE_FUND_APPLY_LAST,
		self.CancelExclusiveEvent_GS,
		self,
		nKinId,
		self.KIN_EVENT_TAKE_FUND,
		nPlayerId
		);
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cApplyPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if cApplyPlayer then
		cApplyPlayer.CallClientScript({"Kin:NotifApplyTakeFundPlayer_C2", nMoney, nType});
	end
	KKinGs.KinClientExcute(nKinId, {"Kin:SendTakeFundApply_C2", szPlayerName, nMoney, nType});
	if nType == 1 then
		return KKinGs.KinClientExcute(nKinId, {"Kin:GetTakeFundApply_C2",self.KIN_EVENT_TAKE_FUND, nMemberId, szPlayerName, nMoney});
	else
		-- 寻找族长通知有申请
		local nCaptainId = cKin.GetCaptain();
		local cCatainIdMember = cKin.GetMember(nCaptainId);
		if not cCatainIdMember then
			return 0;
		end
		local nId = cCatainIdMember.GetPlayerId();
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if not pPlayer then
			return 0;
		end
		pPlayer.CallClientScript({"Kin:GetTakeFundApply_C2",self.KIN_EVENT_TAKE_FUND, nMemberId, szPlayerName, nMoney});
	end
end



function Kin:AcceptExclusiveEvent_GS1(nKey, nAccept, nAppleyMemberId)
	if EventManager.IVER_bOpenkinMoney ~= 1 then
		Dialog:SendBlackBoardMsg(me, "该功能暂未开放！");
		return;
	end
	if me.IsAccountLock() ~= 0 then
		Dialog:SendBlackBoardMsg(me,"Tài khoản đang bị khóa, không thể thao tác!");
		return;
	end
	if not nKey or Lib:IsInteger(nKey) == 0 or not nAccept or Lib:IsInteger(nAccept) == 0 or not nAppleyMemberId or  Lib:IsInteger(nAppleyMemberId) == 0 then
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nKinId, nKey);
	 if not tbData.nApplyEvent or tbData.nApplyEvent == 0 then
		me.Msg("该申请已结束！");
		return 0;
	end
	if tbData.tbApplyRecord.nMemberId ~= nAppleyMemberId then
		me.Msg("该申请不存在！");
		return 0;
	end
	local cMember = cKin.GetMember(nAppleyMemberId); 
	if not cMember then
		me.Msg("该成员已经不是家族成员！");
		return 0;
	end
	if nKey == self.KIN_EVENT_TAKE_REPOSITORY then -- 家族仓库的权限判断
		if KinRepository:CheckRepAuthority(nKinId, nMemberId, tbData.tbApplyRecord.nPow) ~= 1 then
			me.Msg("对不起，您没有权限响应这个申请！");
			return 0;
		end
	else
		if (Kin:CheckSelfRight(nKinId, nMemberId, tbData.tbApplyRecord.nPow) ~= 1) then
			me.Msg("对不起，您没有权限响应这个申请！");
			return 0;
		end
	end
	if tbData.tbApplyRecord.nMemberId == nMemberId then --表决人是发起人不需要表决
		me.Msg("申请人表决无效！");
		return 0;
	end
	if not tbData.tbAccept then
		tbData.tbAccept = {};	-- 已表态的成员记录
	end
	if tbData.tbAccept[nMemberId] then
		me.Msg("你已经表过态了！");
		return 0;
	end
	GCExcute{"Kin:AcceptExclusiveEvent_GC", nKey, me.nId, nKinId, nMemberId, nAccept, nAppleyMemberId};
end
RegC2SFun("AcceptExclusiveEvent", Kin.AcceptExclusiveEvent_GS1)

function Kin:AcceptExclusiveEvent_GS2(nKey, nPlayerId, nKinId, nMemberId, nAccept)
	local tbData = self:GetExclusiveEvent(nKinId, nKey);
	if not tbData.tbAccept then
		tbData.tbAccept = {};
	end
	tbData.tbAccept[nMemberId] = nAccept;
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	KKinGs.KinClientExcute(nKinId, {"Kin:AcceptExclusiveEvent_C2", szPlayerName, nKey, nAccept});
	if not tbData.tbApplyRecord then
		return 0;
	end
	local nApplyMemberId = tbData.tbApplyRecord.nMemberId;
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nApplyMemberId);
	if not cMember then
		return 0;
	end
	local nApplyPlayerId = cMember.GetPlayerId();
	local cApplyPlayer = KPlayer.GetPlayerObjById(nApplyPlayerId);
	if cApplyPlayer then
		cApplyPlayer.CallClientScript({"Kin:AcceptExclusiveEventNotify_C2", szPlayerName, nKey, nAccept});
	end
	
end

function Kin:CanCelMemberTakeFund_GS2(nKinId, nPlayerId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	tbData.nLastTime = GetTime();
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	end
end

--找到玩家，然后向gc取钱
function Kin:FindPlayerAddMoney_GS( nKinId, nMoney, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if pPlayer.GetMaxCarryMoney() < pPlayer.nCashMoney + nMoney then
		pPlayer.Msg("你携带的银两将会超出携带上限！取出资金失败！")
		return 0;
	end
	-- 玩家准备跨服或下线，当不在线处理
	if pPlayer.nIsExchangingOrLogout == 1 then
		return 0;
	end
	local nRet = GCExcute{"Kin:TakeFund_GC", nKinId, nMoney, nPlayerId};
	if (nRet == 1)then
		-- 申请获取资金时，锁定状态
		pPlayer.AddWaitGetItemNum(1);
	end
end

function Kin:TakeFund_GS2(nKinId, nPlayerId, nDataVer, nMoney, nCurFund)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		return 0;
	end
	cKin.SetMoneyFund(nCurFund);
	cKin.SetKinDataVer(nDataVer);
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	if nMoney >= self.TAKE_FUND_APPLY then
		cKin.AddAffairTakeFund(szPlayerName, tostring(nMoney));
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	tbData.nLastTime = GetTime();
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	end
	KKinGs.KinClientExcute(nKinId, {"Kin:TakeFund_C2", szPlayerName, nMoney});
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0;
	end
	local nTrueMoney = TradeTax:TradeMoney(cPlayer, nMoney)
	cPlayer.Earn(nTrueMoney, Player.emKEARN_KIN_FUND);
	-- 还原锁定状态
	cPlayer.AddWaitGetItemNum(-1);
	Dbg:WriteLog("Kin:TakeFund_GS2", cKin.GetName(), nCurFund, cPlayer.szName, cPlayer.szAccount, nMoney);
	cPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_KINPAYOFF, 
			string.format("玩家：%s, 帐号:%s, 从家族：%s 领取了%d的资金,家族还有%d的资金", 
			cPlayer.szName, cPlayer.szAccount, cKin.GetName(), nMoney, nCurFund));
				local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	cPlayer.Msg("成功取出" .. nMoney .. "两家族资金！");
	cPlayer.CallClientScript({"Ui:ServerCall", "UI_KIN", "RefreshFund_C2", nCurFund});
end

-- 超时删除申请资金事件
function Kin:CancelExclusiveEvent_GS(nKinId, nEventId, nPlayerId)
	self:DelExclusiveEvent(nKinId, nEventId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	pPlayer.CallClientScript({"Kin:ApplyFailed_C2", nEventId})
	return 0;
end

function Kin:SaveSalaryCount_GS1(tbMember)
	if EventManager.IVER_bOpenkinMoney ~= 1 then
		Dialog:SendBlackBoardMsg(me, "该功能暂未开放！");
		return;
	end
	if not tbMember or type(tbMember) ~= "table" then
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		Dialog:SendInfoBoardMsg(me, "你没有家族，不能修改家族出勤统计！");
		me.Msg("你没有家族，不能修改家族出勤统计！");
		return 0;
	end
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return;
	end
	if (Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1) then
		Dialog:SendInfoBoardMsg(me, "只有族长和副族长才能修改家族出勤统计！");
		me.Msg("只有族长和副族长才能修改家族出勤统计！");
		return 0;
	end	
	if self:CheckMemberSalary(nKinId, tbMember) ~= 1 then
		Dialog:SendInfoBoardMsg(me, "保存失败！请刷新数据后重新修改再保存！");
		me.Msg("保存失败！请刷新数据后重新修改再保存！");
		return 0;
	end
	local tbSalaryData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	if tbSalaryData.nApplyEvent and tbSalaryData.nApplyEvent == 1 then
		Dialog:SendInfoBoardMsg(me, "有发放出勤奖励的申请！暂不能修改数据！");
		me.Msg("有发放出勤奖励的申请！暂不能修改出勤数据！");
		return 0;
	end
	local tbKinData = self:GetKinData(nKinId); 
	if not tbKinData.nLastSaveSalaryTime then
		tbKinData.nLastSaveSalaryTime = 0;
	end
	if GetTime() - tbKinData.nLastSaveSalaryTime < 1 then --防止客户端频繁保存以及连按两下保存所引发的错误
		Dialog:SendInfoBoardMsg(me, "你保存的太频繁了，请稍后再试！");
		me.Msg("你保存的太频繁了，请稍后再试！");
		return 0;
	end
	tbKinData.nLastSaveSalaryTime = GetTime();
	GCExcute{"Kin:SaveSalaryCount_GC", me.nId, nKinId, nMemberId, tbMember};
end
RegC2SFun("SaveSalaryCount", Kin.SaveSalaryCount_GS1)

function Kin:CheckMemberSalary(nKinId, tbClientMember)
	local nAttendanceCount = 0;
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0, -1;
	end
	local cMemberIt = cKin.GetMemberItor();
	local cMember = cMemberIt.GetCurMember();
	local nMemberId = cMemberIt.GetCurMemberId();
	while cMember do
		local nAttendance = tbClientMember[nMemberId];
		if (not nAttendance or 0 == Lib:IsInteger(nAttendance) or nAttendance < 0 or nAttendance > 1000000) then
			return 0, -1;
		end
		cMember = cMemberIt.NextMember();
		nMemberId = cMemberIt.GetCurMemberId();
		nAttendanceCount = nAttendanceCount + nAttendance;
	end
		
	return 1, nAttendanceCount;
end



function Kin:SaveSalaryCount_GS2(nPlayerId, nKinId, tbMember)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	for nId, nAttendance in pairs(tbMember) do
		local cMember = cKin.GetMember(nId);
		if cMember then
			cMember.SetAttendance(nAttendance);
		end
	end
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0;
	end
	cPlayer.Msg("家族出勤统计保存成功！");
	cPlayer.CallClientScript({"Ui:ServerCall", "UI_KIN", "SaveSuccess_C2"});
end

function Kin:ClearSalaryCount_GS1()
	if EventManager.IVER_bOpenkinMoney ~= 1 then
		Dialog:SendBlackBoardMsg(me, "该功能暂未开放！");
		return;
	end
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		me.Msg("你没有家族，不能修改家族出勤统计！");
		return 0;
	end
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return;
	end
	if (Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1) then
		Dialog:SendInfoBoardMsg(me, "只有族长和副族长才能修改家族出勤统计！");
		me.Msg("只有族长和副族长才能修改家族出勤统计！");
		return 0;
	end	
	local tbSalaryData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	if tbSalaryData.nApplyEvent and tbSalaryData.nApplyEvent == 1 then
		Dialog:SendInfoBoardMsg(me, "有发放出勤奖励的申请！暂不能修改数据！");
		me.Msg("有发放出勤奖励的申请！暂不能修改出勤数据！");
		return 0;
	end
	GCExcute{"Kin:ClearSalaryCount_GC", me.nId, nKinId, nMemberId};
end
RegC2SFun("ClearSalaryCount", Kin.ClearSalaryCount_GS1)

function Kin:ClearSalaryCount_GS2(nPlayerId, nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMemberIt = cKin.GetMemberItor();
	local cMember = cMemberIt.GetCurMember();
	while cMember do
		cMember.SetAttendance(0);
		cMember = cMemberIt.NextMember();
	end
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0;
	end
	cPlayer.Msg("家族出勤统计清零成功！");
	cPlayer.CallClientScript({"Ui:ServerCall", "UI_KIN", "SaveSuccess_C2"});
end

function Kin:ApplySendSalary_GS1(nAttendanceAward, tbMember)
	if EventManager.IVER_bOpenkinMoney ~= 1 then
		Dialog:SendBlackBoardMsg(me, "该功能暂未开放！");
		return;
	end
	if (not nAttendanceAward or 0 == Lib:IsInteger(nAttendanceAward) or nAttendanceAward < 0 or nAttendanceAward > 2000000000) then
		return 0;
	end
	if not tbMember or type(tbMember) ~= "table" then
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		Dialog:SendInfoBoardMsg(me, "你没有家族，不能发放家族出勤奖励！");
		me.Msg("你没有家族，不能发放家族出勤奖励！");
		return 0;
	end
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return;
	end
	if (Kin:CheckSelfRight(nKinId, nMemberId, 1) ~= 1) then
		Dialog:SendInfoBoardMsg(me, "只有族长才能发放家族出勤奖励!");
		me.Msg("只有族长才能发放家族出勤奖励!");
		return 0;
	end	
	if (me.IsInPrison() == 1) then
		me.Msg("您在坐牢期间不能发放家族出勤奖励！");
		return 0;
	end
	local tbSalaryData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	if tbSalaryData.nApplyEvent and tbSalaryData.nApplyEvent == 1 then
		Dialog:SendInfoBoardMsg(me, "已经有发放出勤奖励的申请！不能再申请！");
		me.Msg("已经有发放出勤奖励的申请！不能再申请！");
		return 0;
	end
	local nLastSalaryTime = cKin.GetLastSalaryTime();
	if GetTime() - nLastSalaryTime < self.SEND_SALARY_TIME then
		Dialog:SendInfoBoardMsg(me, "发放出勤奖励至少需要间隔24小时！");
		me.Msg("发放出勤奖励至少需要间隔24小时！");
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		Dialog:SendInfoBoardMsg(me, "有取出家族资金的申请！请先处理再发放出勤奖励！");
		me.Msg("有取出家族资金的申请！请先处理再发放出勤奖励！");
		return 0;
	end
	local nCheck, nAttendanceCount = self:CheckMemberSalary(nKinId, tbMember);
	if nCheck ~= 1 then
		Dialog:SendInfoBoardMsg(me, "发放出勤奖励失败！请刷新数据后重新发放奖励！");
		me.Msg("发放出勤奖励失败！请刷新数据后重新发放奖励！");
		return 0;
	end
	if self:CheckClientMember(nKinId, tbMember) ~= 1 then
		Dialog:SendInfoBoardMsg(me, "出勤统计已被修改，请保存或者刷新后再发放！");
		me.Msg("出勤统计已被修改，请保存或者刷新后再发放！");
		return 0;
	end
	if nAttendanceCount == 0 then
		Dialog:SendInfoBoardMsg(me, "总人次为0，不能发放！");
		me.Msg("总人次为0，不能发放！");
		return 0;
	end
	local nTotalSalary = nAttendanceCount * nAttendanceAward;
	local nFund = cKin.GetMoneyFund();
	if nTotalSalary > nFund then
		Dialog:SendInfoBoardMsg(me, "家族资金不足，发放失败！");
		me.Msg("家族资金不足，发放失败！");
		return 0;
	end
	GCExcute{"Kin:ApplySendSalary_GC", me.nId, nKinId, nMemberId, tbMember, nAttendanceAward};
end
RegC2SFun("ApplySendSalary", Kin.ApplySendSalary_GS1)

function Kin:ApplySendSalary_GS2(nPlayerId, nKinId, nMemberId, nMoney, nAttendanceAward)
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	tbData.nApplyEvent = 1;
	if not tbData.tbApplyRecord then
		tbData.tbApplyRecord = {};
	end
	tbData.tbApplyRecord.nMemberId = nMemberId;
	tbData.tbApplyRecord.nAmount = nMoney;
	tbData.tbApplyRecord.nAttendanceAward = nAttendanceAward;
	tbData.tbApplyRecord.nPow = self.FIGURE_REGULAR;
	tbData.tbAccept = {};
	tbData.nAgreeCount = 2;
	tbData.tbApplyRecord.nTimerId = Timer:Register(
		self.TAKE_FUND_APPLY_LAST,
		self.CancelExclusiveEvent_GS,
		self,
		nKinId,
		self.KIN_EVENT_SALARY,
		nPlayerId
		);
	local cApplyPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if cApplyPlayer then
		cApplyPlayer.CallClientScript({"Kin:NotifApplySalaryPlayer_C2", nMoney});
	end
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	KKinGs.KinClientExcute(nKinId, {"Kin:SendSalaryApply_C2", szPlayerName, nMoney, nAttendanceAward});
	return KKinGs.KinClientExcute(nKinId, {"Kin:SalaryRequestApply_C2",self.KIN_EVENT_SALARY, nMemberId, szPlayerName, nMoney});
	
end

function Kin:SendSalary_GS2(nDataVer, nPlayerId, nKinId, nCurFund, nTotalSalary, nLastSalaryTime, tbSalary)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		return 0;
	end
	if not tbSalary then
		return 0;
	end
	cKin.SetKinDataVer(nDataVer);
	cKin.SetMoneyFund(nCurFund);
	cKin.SetLastSalaryTime(nLastSalaryTime);
	for nMemberId, tbMember in pairs(tbSalary) do
		local cMember = cKin.GetMember(nMemberId);
		if cMember then
			cMember.SetAttendance(tbMember.nAttendance);
		end
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	end
	KKinGs.KinClientExcute(nKinId, {"Kin:SendSalary_C2", nTotalSalary});
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0;
	end
	cPlayer.Msg("出勤奖励发放成功！");
	cPlayer.CallClientScript({"Ui:ServerCall", "UI_KIN", "ClearPromt_C2"});
end

function Kin:CheckClientMember(nKinId, tbClientMember)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0, -1;
	end
	local cMemberIt = cKin.GetMemberItor();
	local cMember = cMemberIt.GetCurMember();
	local nMemberId = cMemberIt.GetCurMemberId();
	while cMember do
		local nAttendance = cMember.GetAttendance();
		if not tbClientMember[nMemberId] or tbClientMember[nMemberId] ~= nAttendance then
			return 0;
		end
		cMember = cMemberIt.NextMember();
		nMemberId = cMemberIt.GetCurMemberId();
	end
	return 1;
end

--操作失败解锁
function Kin:FailureToUnLock(nPlayerId)
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not cPlayer then
		return 0;
	end
	-- 还原锁定状态
	cPlayer.AddWaitGetItemNum(-1);
	cPlayer.Msg("操作失败！");
end

function Kin:AddKinKillBaiHuTangCount(nPlayerId, nCount)
	if (not nPlayerId or not nCount or nPlayerId <= 0) then
		return 0;
	end
	GCExcute({"Kin:AddKinKillBaiHuTangCount_GC", nPlayerId, nCount});
end

function Kin:AddKinKillBaiHuTangCount_GS(nPlayerId, nNum)
	-- 杀死boss会给家族增加一次本日击杀boss个数
	local dwKinId, nMemberId = KKin.GetPlayerKinMember(nPlayerId);
	if (dwKinId > 0) then
		local pKin = KKin.GetKin(dwKinId);
		if (pKin) then
			local nCount = pKin.GetBaiHuTangKillNum();
			pKin.SetBaiHuTangKillNum(nCount + nNum);
		end		
	end

end

function Kin:ClearGoldDate_GS(dwKinId)
	if (dwKinId > 0) then
		local pKin = KKin.GetKin(dwKinId);
		if (pKin) then
			local itor = pKin.GetMemberItor();
			local cMember = itor.GetCurMember();
			while cMember do
				cMember.SetGoldLS(0);
				cMember = itor.NextMember();
			end
		end
	end
	return 1;
end

-- 家族列表
function Kin:ShowKinDetail_GS(nKinId)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		me.Msg("该家族不存在了。");
		return 0;
	end
	local tbDetail = {};
	local pMemberItor = pKin.GetMemberItor();
	local pMember = pMemberItor.GetCurMember();
	while pMember do
		local szName = KGCPlayer.GetPlayerName(pMember.GetPlayerId());
		local tbInfo = GetPlayerInfoForLadderGC(szName);
		local nSex = tbInfo and tbInfo.nSex or 0;
		local nFigure = pMember.GetFigure();
		local nHonor = PlayerHonor:GetPlayerMoneyHonorLevel(pMember.GetPlayerId());
		table.insert(tbDetail, {szName, nSex, nFigure, nHonor});
		pMember = pMemberItor.NextMember();
	end
	table.sort(tbDetail, function(a, b) return a[3] < b[3] end);
 	me.CallClientScript({"UiManager:OpenWindow", "UI_KIN_RECRUIT_PLAYERS"});
	me.CallClientScript({"Ui:ServerCall", "UI_KIN_RECRUIT_PLAYERS", "OnRecvData", tbDetail});
end
RegC2SFun("ShowKinDetail", Kin.ShowKinDetail_GS)

-- 设置yy号
function Kin:SetYYNumber_GS1(nYYNumber)
	local nKinId, nExcutorId = me.GetKinMember();
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 2);
	if nRet ~= 1 then
		return 0;
	end
	return GCExcute{"Kin:SetYYNumber_GC", nKinId, nExcutorId, nYYNumber};
end
RegC2SFun("SetYYNumber", Kin.SetYYNumber_GS1)

function Kin:SetYYNumber_GS2(nKinId, nYYNumber)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0;
	end
	cKin.SetYYNumber(nYYNumber);
	return KKinGs.KinClientExcute(nKinId, {"Kin:SetYYNumber_C2", nYYNumber});
end

function Kin:AddGoldLSTask(nKinId, nExcutorId, nPoint)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nExcutorId);
	if not cMember then
		return 0
	end
	local nTotalPoint = cMember.GetGoldLS();
	cMember.SetGoldLS(nTotalPoint + nPoint);
end

function Kin:SetGoldFlag(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetGoldLogo(1);
	KKin.Msg2Kin(nKinId, "族长标记家族为金牌家族。");
end

function Kin:ApplyRepTakeAuthority_GS()
	local nKinId, nExcutorId = me.GetKinMember();
	KinRepository:ApplyTakeAuthority(me, nKinId);
end
RegC2SFun("ApplyRepTakeAuthority", Kin.ApplyRepTakeAuthority_GS)

-- 申请仓库信息
function Kin:RefreshRepositoryInfo_GS()
	KinRepository:SyncRepositoryInfo(me);
end
RegC2SFun("RefreshRepositoryInfo", Kin.RefreshRepositoryInfo_GS)

-- 申请查看仓库记录
function Kin:ApplyViewRecord_GS(nRoomType, nPage)
	if not nRoomType or Lib:IsInteger(nRoomType) == 0 or not nPage or Lib:IsInteger(nPage) == 0 then
		return;
	end
	KinRepository:ApplyViewRecord_GS(me, nRoomType, nPage);
end
RegC2SFun("ApplyViewRecord", Kin.ApplyViewRecord_GS)

-- 申请扩仓库
function Kin:ApplyExtendRep_GS()
	local dwKinId, nExcutorId = me.GetKinMember();
	if dwKinId == 0 then
		return;
	end

	local cKin = KKin.GetKin(dwKinId)
--	local nRet, cKin = self:CheckSelfRight(dwKinId, nExcutorId, 1)
--	if nRet ~= 1 then
--		Dialog:Say("只有家族族长才能操作");
--		return;
--	end
	if cKin.GetIsOpenRepository() == 0 then
		return;
	end
	local tbOpt = 
	{
		{"扩展公共仓库", KinRepository.ExtendRep, KinRepository, KinRepository.REPTYPE_FREE},
		{"扩展权限仓库", KinRepository.ExtendRep, KinRepository, KinRepository.REPTYPE_LIMIT},	
		{"Để ta suy nghĩ lại"},
	};
	local nFreeLevel = cKin.GetFreeRepBuildLevel();
	local nLimitLevel = cKin.GetLimitRepBuildLevel();
	local szMsg = string.format("<color=green>[仓库信息]<color><enter>公共仓库：已扩展%s/18次<enter>权限仓库：已扩展%s/18次<enter><enter><color=green>[当前建设度]<color><enter>家族当前建设度：<color=yellow>%s点<color><enter><color=yellow>通过家族总工资数发放仓库建设度。<color><enter><enter><color=green>[扩展信息]<color>\n", 
		nFreeLevel, nLimitLevel, cKin.GetRepBuildValue());
	if nFreeLevel >= #KinRepository.BUILD_VALUE[KinRepository.REPTYPE_FREE] then
		szMsg = szMsg .. "家族公共仓库已扩展到最高级<enter>"
	else
		local nExtendMoney = KinRepository:GetExtendMoney(KinRepository.REPTYPE_FREE, nFreeLevel + 1);
		szMsg = szMsg .. string.format("公共仓库下级扩展需仓库建设度%s点，银两%s两<enter>", KinRepository.BUILD_VALUE[KinRepository.REPTYPE_FREE][nFreeLevel+1][1], nExtendMoney);
	end
	if nLimitLevel >= #KinRepository.BUILD_VALUE[KinRepository.REPTYPE_LIMIT] then
		szMsg = szMsg .. "家族权限仓库已扩展到最高级<enter>";
	else
		local nExtendMoney = KinRepository:GetExtendMoney(KinRepository.REPTYPE_LIMIT, nLimitLevel + 1);
		szMsg = szMsg .. string.format("权限仓库下级扩展需仓库建设度%s点，银两%s两<enter>", KinRepository.BUILD_VALUE[KinRepository.REPTYPE_LIMIT][nLimitLevel+1][1], nExtendMoney);
	end
	Dialog:Say(szMsg, tbOpt);
end
RegC2SFun("ApplyExtendRep", Kin.ApplyExtendRep_GS)

-- 更改权限
function Kin:ApplySetMemberRepAuthority_GS(nMemberId)
	if not nMemberId or 0 == Lib:IsInteger(nMemberId) then
		Dialog:Say("请先选择所要操作的家族成员。");
		return;
	end
	local nKinId, nExcutorId = me.GetKinMember();
	if nMemberId == nExcutorId then
		Dialog:Say("族长是默认管理员，不需要再设置。");
		return;
	end
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 1)
	if nRet ~= 1 then
		Dialog:Say("只有族长才可以更改权限。");
		return;
	end
	if cKin.GetIsOpenRepository() == 0 then
		Dialog:Say("请开启家族仓库再设置权限。");
		return;
	end
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return;
	end
	local nRepAuthority = cMember.GetRepAuthority();
	local nPlayerId = cMember.GetPlayerId();
	local szMemberName = KGCPlayer.GetPlayerName(nPlayerId);
	local tbOpt = {};
	local szMsg = string.format("家族成员[%s]", szMemberName);
	if nRepAuthority < 0 then
		szMsg = szMsg .. "操作家族仓库的权限已被禁止，是否恢复？";
		tbOpt[1] = {"恢复权限", KinRepository.SetMemberRepAuthority, KinRepository, nMemberId, nRepAuthority, 0};
	elseif nRepAuthority == 0 then
		szMsg = szMsg .. "不是本家族的仓库管理员，你想对他怎样设置？<enter>设置为管理员后，该成员即可申请操作家族的<color=green>权限仓库<color>。禁止操作后，该成员操作<color=green>所有仓库<color>的权限将被禁止。";
		tbOpt[1] = {"设置为管理员", KinRepository.SetMemberRepAuthority, KinRepository, nMemberId, nRepAuthority, KinRepository.AUTHORITY_ASSISTANT};
		tbOpt[2] = {"禁止操作", KinRepository.SetMemberRepAuthority, KinRepository, nMemberId, nRepAuthority, -1};
	else
		szMsg = szMsg .. "是本家族的仓库管理员，你想对他怎样设置？<enter>撤销管理员后，该成员将不能再申请操作家族的<color=green>权限仓库<color>。禁止操作后，该成员操作<color=green>所有仓库<color>的权限将被禁止";
		tbOpt[1] = {"撤销管理员", KinRepository.SetMemberRepAuthority, KinRepository, nMemberId, nRepAuthority, 0};
		tbOpt[2] = {"禁止操作", KinRepository.SetMemberRepAuthority, KinRepository, nMemberId, nRepAuthority, -1};
	end
	tbOpt[#tbOpt+1] = {"Để ta suy nghĩ lại"}; 
	Dialog:Say(szMsg, tbOpt);
end
RegC2SFun("ApplySetMemberRepAuthority", Kin.ApplySetMemberRepAuthority_GS)


-- 设置家族徽章
function Kin:SetKinBadge_GS1(nSelectBadge, nType)
	local nKinId, nExcutorId = me.GetKinMember();
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 2);
	if nRet ~= 1 then
		return 0;
	end
	local nRecord = 0;
	local nRegular, nSigned, nRetire = cKin.GetMemberCount()
	if nType == 1 then
		nRecord = cKin.GetBadgeRecord1();
	elseif nType == 2 then
		nRecord = cKin.GetBadgeRecord2();
		if nRegular < self.nBuyLimitPlayerCount2 then
			Dialog:Say(string.format("使用2级徽章需要家族正式成员数达到%s人，请扩充您的家族。", self.nBuyLimitPlayerCount2));
			return;
		end
	elseif nType == 3 then
		nRecord = cKin.GetBadgeRecord3();
		if nRegular < self.nBuyLimitPlayerCount3 then
			Dialog:Say(string.format("使用3级徽章需要家族正式成员数达到%s人，请扩充您的家族。", self.nBuyLimitPlayerCount3));
			return;
		end
	end
	if nType ~= 1 or nSelectBadge ~=1 then
		if Lib:LoadBits(nRecord,nSelectBadge - 1,nSelectBadge - 1) ~= 1 then
			Dialog:Say("您还没购买这个徽章，请先购买。");
			return 0;
		end
	end
	
	return GCExcute{"Kin:SetKinBadge_GC", nKinId, nExcutorId, me.nId, nSelectBadge, nType};
end

RegC2SFun("SetKinBadge", Kin.SetKinBadge_GS1);

function Kin:SetKinBadge_GS2(nKinId, nPlayerId, nSelectBadge, nType)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0;
	end
	cKin.SetKinBadge(nType * 10000 + nSelectBadge);
	
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	KKinGs.KinClientExcute(nKinId, {"Kin:SetKinBadge_C2", szPlayerName, nSelectBadge, nType});
end

-- 购买家族徽章
function Kin:ApplyBuyBadge_GS1(nRecord, nRate)
	if nRate <= 0 or nRate >= 4 or nRecord <= 0 or nRecord > 30 then
		return 0;
	end
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return;
	end
	if (me.IsInPrison() == 1) then
		me.Msg("您在坐牢期间不能使用家族资金。");
		return 0;
	end
	local nKinId, nExcutorId = me.GetKinMember();
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 1);
	if nRet ~= 1 then
		Dialog:Say("您没有权限购买族徽，请你们的族长来购买吧。");
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		Dialog:Say("你没有家族，不能使用家族资金。");
		return 0;
	end
	--购买条件
	local nRecordEx = 0;
	local nRegular, nSigned, nRetire = cKin.GetMemberCount()
	if nRate == 1 then
		nRecordEx = cKin.GetBadgeRecord1();
	elseif nRate == 2 then
		nRecordEx = cKin.GetBadgeRecord2();
		if nRegular < self.nBuyLimitPlayerCount2 then
			Dialog:Say("购买2级徽章需要家族正式成员数达到30人，请扩充您的家族。");
			return;
		end
	elseif nRate == 3 then
		nRecordEx = cKin.GetBadgeRecord3();
		if nRegular < self.nBuyLimitPlayerCount3 then
			Dialog:Say("购买3级徽章需要家族正式成员数达到50人，请扩充您的家族。");
			return;
		end
	end
	
	if Lib:LoadBits(nRecordEx, nRecord - 1, nRecord - 1) == 1 or (nRecord == 1 and nRate == 1) then
		Dialog:Say("你们家族已经拥有这个徽章了。");
		return 0;
	end
	
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_BUYBADGE);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		Dialog:SendInfoBoardMsg(me, "已经有购买徽章的申请！不能再申请！");
		me.Msg("已经有购买徽章的申请！不能再申请！");
		return 0;
	end
	
	if tbData.nLastTime and GetTime() - tbData.nLastTime < self.TAKE_FUND_TIME then
		Dialog:SendInfoBoardMsg(me, "两次使用家族资金购买徽章需要间隔5分钟！");
		me.Msg("两次使用家族资金购买徽章需要间隔5分钟");
		return 0;
	end
	
	local nMoney = self.BADGE_LEVEL_PRICE[nRate];
	local nCurFund = cKin.GetMoneyFund();
	if (nMoney > nCurFund) then
		Dialog:SendInfoBoardMsg(me, "家族没有足够的资金供你购买徽章！");
		me.Msg("家族没有足够的资金供你购买徽章！");
		return 0;
	end
	return GCExcute{"Kin:ApplyBuyBadge_GC", nKinId, nMemberId, me.nId, nRecord, nRate};
end
RegC2SFun("BuyBadge", Kin.ApplyBuyBadge_GS1);

function Kin:ApplyBuyBadge_GS2( nKinId, nMemberId, nPlayerId, nRecord, nRate)
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_BUYBADGE);
	tbData.nApplyEvent = 1;
	if not tbData.tbApplyRecord then
		tbData.tbApplyRecord = {};
	end
	local nMoney	= self.BADGE_LEVEL_PRICE[nRate];
	tbData.tbApplyRecord.nMemberId = nMemberId;
	tbData.tbApplyRecord.nPlayerId = nPlayerId;
	tbData.tbApplyRecord.nAmount   = nMoney;
	tbData.tbApplyRecord.nRate     = nRate;
	tbData.tbApplyRecord.nRecord   = nRecord;
	tbData.tbAccept = {};
	-- 族长取钱买徽章，需两名正式成员同意
	tbData.tbApplyRecord.nPow = self.FIGURE_REGULAR;
	tbData.nAgreeCount = 2;
	tbData.tbApplyRecord.nTimerId = Timer:Register(
		self.TAKE_FUND_APPLY_LAST,
		self.CancelExclusiveEvent_GS,
		self,
		nKinId,
		self.KIN_EVENT_BUYBADGE,
		nPlayerId
		);
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	KKinGs.KinClientExcute(nKinId, {"Kin:GetBuyBadgeApply_C2",self.KIN_EVENT_BUYBADGE, nMemberId, szPlayerName, nMoney, nRate});
end

function Kin:BuyBadge_GS2(nKinId, nMemberId, nPlayerId, nMoney, nRecord, nRate)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not cPlayer) then
		return 0;
	end
	local nCurMoney = cKin.GetMoneyFund() - nMoney;
	cKin.SetMoneyFund(nCurMoney); -- 取钱
	-- 记录购买徽章
	if nRate == 1 then
		local nRecordEx = cKin.GetBadgeRecord1();
		cKin.SetBadgeRecord1(Lib:SetBits(nRecordEx, 1, nRecord - 1, nRecord - 1));
	elseif nRate == 2 then
		local nRecordEx = cKin.GetBadgeRecord2();
		cKin.SetBadgeRecord2(Lib:SetBits(nRecordEx, 1, nRecord - 1, nRecord - 1));
	else
		local nRecordEx = cKin.GetBadgeRecord3();
		cKin.SetBadgeRecord3(Lib:SetBits(nRecordEx, 1, nRecord - 1, nRecord - 1));
	end
	
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_BUYBADGE);
	tbData.nLastTime = GetTime();
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nKinId, self.KIN_EVENT_BUYBADGE);
	end
	KKinGs.KinClientExcute(nKinId, {"Kin:BuyBadge_C2", szPlayerName, nMoney, nRecord, nRate});
	Dbg:WriteLog("Kin:BuyBadge_GS2", cKin.GetName(), nCurMoney, cPlayer.szName, cPlayer.szAccount, nMoney);
end

function Kin:SysChangeKinBadge(nKinId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0;
	end
	local tbLimit = {[2] = Kin.nBuyLimitPlayerCount2, [3] = Kin.nBuyLimitPlayerCount3};
	local nSelectBadge = cKin.GetKinBadge();
	local nLevel = math.floor(nSelectBadge / 10000);
	cKin.SetKinBadge(10001);	--默认降级为第一等级第一个
	local nCaptainId = Kin:GetPlayerIdByMemberId(nKinId, cKin.GetCaptain());
	local szCaptainIdName = "";
	if nCaptainId then
		szCaptainIdName = KGCPlayer.GetPlayerName(nCaptainId);
	end	
	if szCaptainIdName ~= "" and (GetServerId() == 1) then	--只用1号服务器发邮件
		KPlayer.SendMail(szCaptainIdName, "家族族徽降级通知", 
			string.format("由于您的家族启用的家族族徽等级为%s，需满足家族正式成员%s个，现在由于人员不足，您的家族族徽被剥夺使用权限降级为1级徽章，请您招揽人员扩充家族，方可再次使用%s级徽章。", nLevel, tbLimit[nLevel], nLevel));
	end
	return KKinGs.KinClientExcute(nKinId, {"Kin:SysChangeKinBadge"});
end

-- 记录玩家下线时间
function Kin:SetLastLogOutTime_GS(nKinId, nMemberId, nTime)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	
	if nTime < 0 then
		return 0;
	end
	cMember.SetLastLogOutTime(nTime);
end