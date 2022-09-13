-------------------------------------------------------------------
--File: tonglogic_gs.lua
--Author: lbh
--Date: 2007-9-6 11:24
--Describe: Gameserver帮会逻辑
-------------------------------------------------------------------
if not Tong then --调试需要
	Tong = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
else
	if not MODULE_GAMESERVER then
		return
	end
end

Tong.c2sFun = {}
--注册能被客户端直接调用的函数
local function RegC2SFun(szName, fun)
	Tong.c2sFun[szName] = fun
end

function Tong:CreateTongApply_GS1(szTongName, nCamp)
	return self:DlgCreateTong(1, szTongName, nCamp)
end
RegC2SFun("CreateTong", Tong.CreateTongApply_GS1)

--GS1后缀表示申请逻辑，GS2后缀表示结果逻辑
--以列表的KinId创建帮会
if not Tong.aTongCreateApply then
	Tong.aTongCreateApply={}
end

function Tong:CreateTong_GS1(anKinId, szTongName, nCamp, nPlayerId)
	if self.aTongCreateApply[nPlayerId] then
		return 0;
	end
	--帮会名字合法性检查
	local nLen = GetNameShowLen(szTongName);
	if nLen < 6 or nLen > 12 then
		return -1
	end
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szTongName) ~= 1 then
		return -2
	end
	--是否包含敏感字串
	if IsNamePass(szTongName) ~= 1 then
		return -3
	end
	--检查帮会名是否已占用
	if KTong.FindTong(szTongName) ~= nil then
		return -4
	end
	--检查创建帮会的家族是否符合要求
	if self:CanCreateTong(anKinId) ~= 1 then
		return -5
	end
	_DbgOut("Tong:CreateTong_GS1")
	self.aTongCreateApply[nPlayerId] = {anKinId, szTongName, nCamp};
	return  GCExcute{"Tong:CreateTongApply_GC", nPlayerId, szTongName}
end

function Tong:OnTongNameResult_GS2(nPlayerId, nResult)
	local tbParam = self.aTongCreateApply[nPlayerId]
	if not tbParam then
		return;
	end
	Tong.aTongCreateApply[nPlayerId] = nil;
	
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not cPlayer) then
		return;
	end
	
	if nResult ~= 1 then
		cPlayer.Msg("帮会名字已存在，请更换其他名字");
		return;
	end
	-- by jiazhenwei  金牌网吧建立帮会80w
	local nMoneyCreat = self.CREATE_TONG_MONEY;
	if SpecialEvent.tbGoldBar:CheckPlayer(cPlayer) == 1 then
		nMoneyCreat = 800000;
	end	
	--end
	if cPlayer.CostMoney(nMoneyCreat, Player.emKPAY_CREATETONG) ~= 1 then
		return 0
	end
	--解散队伍
	KTeam.DisbandTeam(cPlayer.nTeamId)
	
	GCExcute{"Tong:CreateTong_GC", unpack(tbParam)}
end

function Tong:CreateTong_GS2(anKinId, szTongName, nCamp, nCreateTime)
	local cTong, nTongId = self:CreateTong(anKinId, szTongName, nCamp, nCreateTime)
	if not cTong then
		return 0
	end
	for _, nKinId in ipairs(anKinId) do
		Kin:JoinTong_GS2(nKinId, szTongName, nTongId, nCamp)
	end
	return KTongGs.TongClientExcute(nTongId, {"Tong:CreateTong_C2", szTongName, nCamp, anKinId[1]})
end

-- 重设首领和帮主
function Tong:ResetPresidentMaster_GS2(nJourNum, nTongId, nMasterKinId, nPresidentKinId, nPresidentMember)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	local nOrgMaster = cTong.GetMaster();
	local nOrgPresident = cTong.GetPresidentKin();
	cTong.SetTongDataVer(nJourNum);
	cTong.SetMaster(nMasterKinId);
	cTong.SetPresidentKin(nPresidentKinId);
	cTong.SetPresidentMember(nPresidentMember);
	if nMasterKinId ~= nOrgMaster then
		local cMasterKin = KKin.GetKin(nMasterKinId);
		if cMasterKin then
			cMasterKin.SetTongFigure(self.CAPTAIN_MASTER);
		end
		local cOrgMasterKin = KKin.GetKin(nOrgMaster);
		if cOrgMasterKin then
			cOrgMasterKin.SetTongFigure(self.CAPTAIN_NORMAL);
		end
	end
	if nMasterKinId > 0 and nOrgMaster ~= nMasterKinId then
		local nMasterId = self:GetMasterId(nTongId);
		local szName = KGCPlayer.GetPlayerName(nMasterId);
		KTong.Msg2Tong(nTongId, string.format("[%s]成为了帮主。", szName));
		KKinGs.UpdateKinInfo(nMasterId);
	end
	if nPresidentKinId > 0 and nPresidentKinId ~= nOrgPresident then
		local nPresidentId = self:GetPresidentId(nTongId);
		if nPresidentId > 0 then
			local szName = KGCPlayer.GetPlayerName(nPresidentId);
			KTong.Msg2Tong(nTongId, string.format("[%s]成为了首领。", szName));
			KKinGs.UpdateKinInfo(nPresidentId);
		end
	end
end
-- 申请解散帮会
function Tong:ApplyDisbandTong_GS1()
	self:ApplyDisbandTong();
end
RegC2SFun("ApplyDisbandTong", Tong.ApplyDisbandTong_GS1);

function Tong:ApplyDisbandTong(nSure)
	local nTongId = me.dwTongId;
	local nKinId, nMemberId = me.GetKinMember();
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end
	local nKinCount = cTong.GetKinCount();
	if nKinCount > 2 then -- 小于2个家族可以解散
		Dialog:Say("帮会家族数量小于3个才能解散帮会。");
		return 0;
	end
	if self:CheckSelfRight(nTongId, nKinId, nMemberId, self.POW_MASTER) ~= 1 then
		Dialog:Say("你不是帮主，没有这个权限！");
		return 0;
	end
	if not nSure then
		local tbOpt = {
			{"确定解散", self.ApplyDisbandTong, self, 1},
			{"Để ta suy nghĩ lại"},
		};
		local szMsg = string.format("解散帮会后所有家族将会脱离帮会并无法再加入该帮会，当前帮会资金<color=yellow>%s<color>，点击确定解散后<color=red>立即生效<color>，确定解散帮会？", cTong.GetMoneyFund());
		Dialog:Say(szMsg, tbOpt);	
		return 0;
	end
	return GCExcute{"Tong:ApplyDisbandTong_GC", nTongId, nKinId, nMemberId}
end

function Tong:DisbandTong_GS2(nTongId)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0
	end
	--选通知，再删除帮会
	KTongGs.TongClientExcute(nTongId, {"Tong:DisbandTong_C2"})
	--local cKinItor = cTong.GetKinItor()
	--local nKinId = cKinItor.GetCurKinId()
	--while nKinId ~= 0 do
	--	Kin:LeaveTong_GS2(nTongId, nKinId, )
	--	nKinId = cKinItor.NextKinId()
	--end
	KTong.DelTong(nTongId);
	return 1;
end

function Tong:ChangeMaster_GS2(nTongId, nKinId, nDataVer)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0
	end
	local nOrgMaster = cTong.GetMaster()
	local cKinOrg = KKin.GetKin(nOrgMaster)
	-- 回复原来的家族职位
	if cKinOrg then
		cKinOrg.SetTongFigure(self.CAPTAIN_NORMAL)
	end
	cTong.SetMaster(nKinId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	cKin.SetTongFigure(self.CAPTAIN_MASTER)
	-- 更新称号
	local cMemberOrg = cKinOrg.GetMember(cKinOrg.GetCaptain())
	if cMemberOrg then
		KKinGs.UpdateKinInfo(cMemberOrg.GetPlayerId())
	end
	local cMember = cKin.GetMember(cKin.GetCaptain())
	if cMember then
		KKinGs.UpdateKinInfo(cMember.GetPlayerId())
	end
	local szNewMaster = KGCPlayer.GetPlayerName(cMember.GetPlayerId());
	local szOldMaster = KGCPlayer.GetPlayerName(cMemberOrg.GetPlayerId());
	cTong.AddAffairChangeMaster(szNewMaster, szOldMaster);
	cTong.SetTongDataVer(nDataVer);
	return KTongGs.TongClientExcute(nTongId, {"Tong:ChangeMaster_C2", szNewMaster})
end

-- 罢免帮主
function Tong:FireMaster_GS1()
	local nTongId = me.dwTongId;
	local nKinId, nMemberId = me.GetKinMember();
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end
	
	if Tong:CheckPresidentRight(nTongId, nKinId, nMemberId) ~= 1 then
		me.Msg("你没有权限罢免帮主");
		return 0;
	end
	
	local nNowDay = tonumber(os.date("%y%m%d", GetTime()));
	local nFireMasterDate = tonumber(os.date("%y%m%d", cTong.GetFireMasterDate()));

	if nFireMasterDate == nNowDay then
		me.Msg("你今天已经罢免了一届帮主了，要等明天才能再罢免今届的帮主");
		return 0;
	end
	
	return GCExcute{"Tong:FireMaster_GC", nTongId, nKinId, nMemberId}
end
RegC2SFun("FireMaster", Tong.FireMaster_GS1);

function Tong:FireMaster_GS2(nTongId, nTime)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end
	
	cTong.SetMasterLockState(1);
	cTong.SetFireMasterDate(nTime);
	Tong:StartMasterVote_GS1(nTongId);
	
	local nMasterId = self:GetMasterId(nTongId);
	local szName = KGCPlayer.GetPlayerName(nMasterId);
	KTong.Msg2Tong(nTongId, string.format("<color=red>%s<color>帮主被罢免了。", szName));
end


--帮主竞选（启动单个帮会的竞选）
function Tong:StartMasterVote_GS1(nTongId)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 1
	end
	--竞选已启动，则不能再启动
	if cTong.GetVoteStartTime() ~= 0 then
		--me.Msg("本帮这次竞选没结束，不能再次开启竞选!");
		return 0
	end
	return GCExcute{"Tong:StartMasterVote_GC", nTongId}
end

function Tong:StartMasterVote_GS2(nTongId, nStartTime)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	cTong.SetVoteStartTime(nStartTime);
	KTong.Msg2Tong(nTongId, "帮主竞选启动！帮会长老现在可通过帮会界面投票！")
	return 1;
end

--停止单个帮会的竞选
function Tong:StopMasterVote_GS1(nTongId)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end
	if cTong.GetVoteStartTime() == 0 then
		return 0;
	end
	return GCExcute{"Tong:StopMasterVote_GC", nTongId}
end

function Tong:StopMasterVote_GS2(nTongId, nKinId, nMaxBallot)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	if cTong.GetVoteStartTime() == 0 then
		return 0;
	end
	cTong.SetVoteCounter(0);
	cTong.SetVoteStartTime(0);
	local itor = cTong.GetKinItor();
	local nCurKinId = itor.GetCurKinId();
	while nCurKinId ~= 0 do
		local cKin = KKin.GetKin(nCurKinId);
		if cKin then
			--清空投票数据
			cKin.SetTongVoteBallot(0);
			cKin.SetTongVoteJourNum(0);
			-- 清空各家族成员的投票状态
			local itor = cKin.GetMemberItor();
			local cMember = itor.GetCurMember();
			while cMember do
				cMember.SetTongVoteState(0);
				cMember = itor.NextMember();
			end	
		end
		nCurKinId = itor.NextKinId();
	end
	if nKinId == 0 or nMaxBallot == 0 then
		KTong.Msg2Tong(nTongId, "本届帮会竞选结束，由于无人投票，现任帮主继续留任！")
		--解除帮主锁定状态
		cTong.SetMasterLockState(0);
		return 1;
	end
	local cKinNewMaster = KKin.GetKin(nKinId)
	if cKinNewMaster then
		local nMasterId = Tong:GetMasterId(nTongId);
		local szName = KGCPlayer.GetPlayerName(nMasterId);
		KTong.Msg2Tong(nTongId, "本届帮会竞选结束，<color=white>"..cKinNewMaster.GetName()..
			"<color>家族的族长<color=green>"..szName.."<color>以<color=red>"..(nMaxBallot / 100).."%<color>的票数当选为新一任帮主！")
	end
	--解除帮主锁定状态
	cTong.SetMasterLockState(0);
	return 1;
end

-- 投票
function Tong:ElectMaster_GS1(nTagetKinId, nTagetMemberId)
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local cSelfKin = KKin.GetKin(nSelfKinId);
	if not cSelfKin then
		return 0;
	end
	local cMember = cSelfKin.GetMember(nSelfMemberId);

	local cTong = KTong.GetTong(nTongId);
	if not cTong or not cMember then 
		return 0;
	end
	
	if cTong.GetVoteStartTime() == 0 then 
		me.Msg("现在不是竞选期，不能投票!");
		return 0;
	end

	if cMember.GetTongVoteState() == 1 then
		me.Msg("你已经投过票了!");
		return 0;
	end

	local cTagetKin = KKin.GetKin(nTagetKinId);
	if not cTagetKin then
		return 0;
	end
	if nTagetMemberId ~= cTagetKin.GetCaptain() then
		me.Msg("对方不是长老!");
		return 0;
	end
	if nTongId ~= cTagetKin.GetBelongTong() then
		me.Msg("这家族不属于本帮会")
		return 0;
	end
	
	if cMember.GetPersonalStock() <= 0 then
		me.Msg("你不是股东，还不能投票")
		return 0;
	end

	return GCExcute{"Tong:ElectMaster_GC", nTongId, nTagetKinId, nTagetMemberId, nSelfKinId, nSelfMemberId}
end
RegC2SFun("ElectMaster", Tong.ElectMaster_GS1);


function Tong:ElectMaster_GS2(nTongId, nTagetKinId, nSelfKinId, nSelfMemberId, nVoteCount, nVote)
	local cSelfKin = KKin.GetKin(nSelfKinId);
	local cTagetKin = KKin.GetKin(nTagetKinId);
	if (not cSelfKin) or (not cTagetKin) then
		return 0;
	end

	cTagetKin.SetVoteCounter(nVoteCount);
	cTagetKin.SetTongVoteBallot(nVote);
	
	local nTagetCaptainId = cTagetKin.GetCaptain();
	local cSelfMember = cSelfKin.GetMember(nSelfMemberId);
	local cTagetMember = cTagetKin.GetMember(nTagetCaptainId);
	if (not cTagetMember) or (not cSelfMember) then
		return 0;
	end

	cSelfMember.SetTongVoteState(1); --	标志已经投票
	
	local szSelfName = KGCPlayer.GetPlayerName(cSelfMember.GetPlayerId());
	local szTagetName = KGCPlayer.GetPlayerName(cTagetMember.GetPlayerId());
	local pPlayer = KPlayer.GetPlayerObjById(cSelfMember.GetPlayerId());
	if pPlayer then
		pPlayer.Msg("你投票给<color=yellow>"..szTagetName.."<color>");
	end
	
--	if nVote >= 5000 then
--		GCExcute{"Tong:StopMasterVote_GC", nTongId};
--		return;
--	end
	
	return KTongGs.TongClientExcute(nTongId, {"Tong:ElectMaster_C2", szSelfName, szTagetName, nVote})
end

-- 申请加入帮会
function Tong:ApplyJoin_GS1(nPlayerId, bConfirm)
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not cPlayer) then
		return 0;
	end
	local nTongId = cPlayer.dwTongId;
	local nPlayerKinId, nPlayerMemberId = cPlayer.GetKinMember();
	if not nTongId or nTongId == 0 then
		me.Msg("对方没有帮会！");
		return 0;
	end
	if self:HaveFigure(nTongId, nPlayerKinId, nPlayerMemberId, self.POW_RECRUIT) ~= 1 then
		me.Msg("对方无权招收家族！")
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		me.Msg("你不是一个家族的族长或副族长！");
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if cKin.GetBelongTong() ~= 0 then
		me.Msg("你的家族已经有帮会！");
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	if cTong.GetKinCount() >= self.MAX_KIN_NUM then
		me.Msg("对方的帮会家族个数已达上限！")
		return 0;
	end
---------------------------------------------------------------------------------------------------
-- 需在此添加警告(警告帮会建设资金已经满了)
	local nBuildFund = cTong.GetBuildFund();
	local nKinFund = Kin:GetTotalKinStock(nKinId);

	nBuildFund = nBuildFund or 0;
	if (nBuildFund > self.MAX_BUILD_FUND) then
		nBuildFund = self.MAX_BUILD_FUND;
	end

	local nPercent = 1;
	if (not bConfirm or 1 ~= bConfirm) then
		if nKinFund > 0 and nKinFund > (self.MAX_BUILD_FUND - nBuildFund) then
			nPercent = (self.MAX_BUILD_FUND - nBuildFund) / nKinFund;
			local nTemp = math.floor(nPercent * 100);
			local szMsg = "你申请加入帮会<color=green>【"..cTong.GetName().."】<color>！\n";
			szMsg = szMsg .. "由于帮会的建设资金会在你的家族加入后超出上限，所以你家族将会获得的帮会股份将会只是平时普通情况下的 <color=yellow>" .. nTemp .. "%<color> ！";
			Dialog:Say(szMsg, 
				{
					{"Xác nhận", self.ApplyJoin_GS1, self, nPlayerId, 1},
					{"取消"},
				})
			return 0;
		end
	end
---------------------------------------------------------------------------------------------------
	me.Msg("你申请加入帮会["..cTong.GetName().."]！");
	return cPlayer.CallClientScript({"Tong:ApplyJoin_C2", nKinId, nMemberId, cKin.GetName(), me.szName});
end
RegC2SFun("JoinTong", Tong.ApplyJoin_GS1);

function Tong:JoinReply_GS1(nKinId, nMemberId, nAccept)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local nCaptainId = cKin.GetCaptain()
	local cCaptain = cKin.GetMember(nCaptainId);
	if not cCaptain then
		return 0
	end
	local cPlayer = KPlayer.GetPlayerObjById(cCaptain.GetPlayerId());
	if nAccept ~= 1 then
		if not cPlayer then
			return 0;
		end
		cPlayer.Msg("<color=white>"..me.szName.."<color>拒绝了你加入帮会的申请！");
		return 0;
	end
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local nRetCode, cMember = self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_RECRUIT);
	if nRetCode ~= 1 then
		me.Msg("你没有招收家族的权力！")
		return 0;
	end
	if Kin:HaveFigure(nKinId, nMemberId, 2) ~= 1 then
		me.Msg("对方不是家族族长或副族长！");
		return 0;
	end
	if not cMember then 
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	if cTong.GetKinCount() >= self.MAX_KIN_NUM then
		me.Msg("你的帮会家族个数已到达上限！");
		return 0;
	end
	GCExcute{"Tong:KinAdd_GC", nTongId, nKinId};
end
RegC2SFun("JoinReply", Tong.JoinReply_GS1);

--邀请家族加入
function Tong:InviteAdd_GS1(nPlayerId, bAccept)
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not cPlayer) then
		return 0
	end
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_RECRUIT) ~= 1 then
		me.Msg("你无权招收家族！");
		return 0;
	end
	local nKinId, nMemberId = cPlayer.GetKinMember();
	if Kin:HaveFigure(nKinId, nMemberId, 2) ~= 1 then
		me.Msg("对方不是家族族长或副族长！");
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then
		return 0;
	end
	if cKin.GetBelongTong() ~= 0 then
		me.Msg("对方已有帮会！");
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	if cTong.GetKinCount() >= self.MAX_KIN_NUM then
		me.Msg("你的帮会家族个数已达上限！")
		return 0;
	end

-----------------------------------------------------------------------------------------------------------
-- 需在此添加警告(警告帮会建设资金已经满了)
	local nBuildFund = cTong.GetBuildFund();
	local nKinFund = Kin:GetTotalKinStock(nKinId);
	nBuildFund = nBuildFund or 0;
	local nTemp = self.MAX_BUILD_FUND - nBuildFund;
	if nTemp < 0 then
		nTemp = 0;
	end
	local nPercent = 1;
	if nKinFund >0 and nKinFund > nTemp then
		nPercent = nTemp / nKinFund;
	end
	if (not bAccept or bAccept ~= 1) then
		if (nPercent  ~= 1) then
			local szMsg = "<color=green>【".. cTong.GetName() .. "】<color>帮会帮主<color=yellow>【".. me.szName .."】<color>邀请你的家族加入帮会\n"; 
			local nTemp = math.floor(nPercent * 100);
			szMsg = szMsg .. "由于你家族的加入，则该帮会的建设资金将会超过限制，所以你的家族将会获得的帮会股份只有平时普通情况下的<color=yellow> " .. nTemp .. "%<color> ！" ;
			local function SayWhat(nInvitor, nPlayerId, bAccept)
				local cInvitor = KPlayer.GetPlayerObjById(nInvitor)
				if not cInvitor then
					return;
				end
				if bAccept and bAccept == 1 then
					Setting:SetGlobalObj(cInvitor);
					Tong:InviteAdd_GS1(nPlayerId, bAccept);
					Setting:RestoreGlobalObj();
				else
					cInvitor.Msg(me.szName.."拒绝了你的邀请！");
					me.Msg("你拒绝了对方的加入帮会邀请！");
				end
			end
			local nInvitor = me.nId;
			Setting:SetGlobalObj(cPlayer);
			Dialog:Say(szMsg,
				{
					{"Xác nhận", SayWhat, nInvitor, nPlayerId, 1},
					{"拒绝", SayWhat, nInvitor, nPlayerId, 0},
				});
			Setting:RestoreGlobalObj();
			return 0;
		end
	end
-----------------------------------------------------------------------------------------------------------
	me.Msg("你邀请家族<color=white>"..cKin.GetName().."<color>加入帮会")
	return cPlayer.CallClientScript({"Tong:InviteAdd_C2", me.nId, cTong.GetName(), me.szName})
end
RegC2SFun("InviteAdd", Tong.InviteAdd_GS1);

-- 答复帮会邀请
function Tong:InviteAddReply_GS1(nPlayerId, bAccept)
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local nKinId, nMemberId = me.GetKinMember();
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		me.Msg("你不是族长或副族长，没有加入帮会的权力！");
		return 0;
	end
	if not cPlayer then
		me.Msg("对方不在线！")
		return 0;
	end
	local nTongId = cPlayer.dwTongId;
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0
	end
	if (bAccept ~= 1) then
		cPlayer.Msg("<color=white>"..me.szName.."<color>拒绝了您的帮会邀请！");
		return 0
	end
	local cTagetKin = KKin.GetKin(nKinId);
	if not cTagetKin then 
		return 0;
	end
	if cTong.GetKinCount() >= self.MAX_KIN_NUM then
		me.Msg("对方的帮会家族个数已达上限！")
		return 0;
	end
	return GCExcute{"Tong:KinAdd_GC", nTongId, nKinId};
end
RegC2SFun("InviteAddReply", Tong.InviteAddReply_GS1);

function Tong:KinAdd_GS2(nDataVer, nTongId, nKinId, nCreateTime)
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0;
	end
	local nRepute, nAddFund = self:_AddKin2Tong(nTongId, cTong, nKinId, nCreateTime, 0) -- 0 表示非创建帮会时加入帮会
	if not nRepute then
		return 0;
 	end
	-- 非创建帮会时加入帮会的要进行威望计算
	local nCurRepute = cTong.GetTotalRepute()
	if (nRepute > 0) then
		nCurRepute = nCurRepute + nRepute;
		cTong.SetTotalRepute(nCurRepute);
	end
	cTong.SetTongDataVer(nDataVer);
	local szKinName = cKin.GetName();
	cTong.AddHistoryKinJoin(szKinName);
	return KTongGs.TongClientExcute(nTongId, {"Tong:KinAdd_C2", szKinName, nRepute, nAddFund});
end

-- 开除家族
function Tong:FireKin_GS1(nTagetKinId)
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_MASTER) ~= 1 then
		me.Msg("你不是帮主，没有这个权限！");
		return 0;
	end
	local cTong = KTong.GetTong(me.dwTongId);
	if (not cTong) then
		me.Msg("你没有帮会，不能开除家族！");
		return 0;
	end
	
	if (nTagetKinId == cTong.GetPresidentKin()) then
		me.Msg("不能开除首领所在的家族！")
		return 0;
	end 
	
	if (nTagetKinId == cTong.GetMaster()) then
		me.Msg("不能开除帮主所在的家族，请先罢免帮主！")
		return 0;
	end 
	
	local cKin = KKin.GetKin(nTagetKinId);
	if (not cKin) then
		me.Msg("家族不存在!");
		return 0;
	end
	if (cKin.GetBelongTong() ~= nTongId) then
		me.Msg("该家族不属于本帮会!");
	end
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_KICK_KIN);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		me.Msg("不能同时发起两次开除家族，上次发起还没结束！")
		return 0
	end
	return GCExcute{"Tong:FireKin_GC", nTongId, nSelfKinId, nSelfMemberId, nTagetKinId};
end
RegC2SFun("FireKin", Tong.FireKin_GS1);

function Tong:FireKin_GS2(nTongId, nSelfKinId, nPlayerId, nTagetKinId)
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_KICK_KIN);
	tbData.nApplyEvent 	= 1;
	tbData.tbAccept 	= {};		-- 家族表态表
	tbData.nCount		= 0;
	if not tbData.ApplyRecord then
		tbData.ApplyRecord = {};
	end
	tbData.ApplyRecord.nTagetKinId = nTagetKinId;
	tbData.ApplyRecord.nSelfKinId = nSelfKinId;		-- 记录申请的家族，该家族响应无效
	tbData.ApplyRecord.nPlayerId = nPlayerId;
	tbData.ApplyRecord.nPow = 0;
	tbData.nTimerId = Timer:Register(
		self.FIREKIN_APPLY_LAST,
		self.CancelExclusiveEvent_GS,
		self,
		nTongId,
		nPlayerId,
		self.REQUEST_KICK_KIN
	)
	local cKin = KKin.GetKin(nTagetKinId);
	if not cKin then
		return 0;
	end
	local szKinName = cKin.GetName();
	local cTong = KTong.GetTong(nTongId);
	if not cTong then 
		return 0;
	end
	local pKinIt = cTong.GetKinItor();
	local nCurKinId = pKinIt.GetCurKinId()
	while(nCurKinId ~= 0) do
		local cKin = KKin.GetKin(nCurKinId);
		if cKin then
			local nCaptainId = cKin.GetCaptain();
			local nRetCode ,cMember = self:HaveFigure(nTongId, nCurKinId, nCaptainId, 0);
			if nRetCode == 1 then
				local nId = cMember.GetPlayerId();
				local pPlayer = KPlayer.GetPlayerObjById(nId);
				if nPlayerId ~= nId and pPlayer then	-- 非申请人本身
					pPlayer.CallClientScript({"Tong:GetApply_C2", szKinName, self.REQUEST_KICK_KIN, 0, 0});
				end
			end
		end		
		nCurKinId = pKinIt.NextKinId();
	end
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	KTongGs.TongClientExcute(nTongId, {"Tong:SendApply_C2", self.REQUEST_KICK_KIN, szPlayerName, 0, 0})
end

-- 从Tong里删除掉家族，有离开和开除两种形式
function Tong:KinDel_GS2(nDataVer, nTongId, nKinId, nMethod, nReduceFund) -- nMethod参照Tong:KinDel_GC
	if (nMethod == 1) then
		--开除事件要删除申请记录
		local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_KICK_KIN);
		if tbData.ApplyRecord and tbData.ApplyRecord.nTimerId then
			Timer:Close(tbData.ApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nTongId, self.REQUEST_KICK_KIN);
	end
	local cTong = KTong.GetTong(nTongId)
	if (not cTong) then
		return 0;
	end
	local nRet = cTong.DelKin(nKinId)
	if (nRet == nil or nRet ==0 ) then
		return 0
	end
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then
		return 0;
	end
	-- 威望处理
	local nKinRepute = cKin.GetTotalRepute();
	local nCurRepute = cTong.GetTotalRepute();
	if nKinRepute > 0 then
		nCurRepute = nCurRepute - nKinRepute;
		cTong.SetTotalRepute(nCurRepute);
	else
		nKinRepute = 0;
	end
	
	local szKinName = cKin.GetName();
	cTong.SetTongDataVer(nDataVer);
	cTong.AddHistoryKinLeave(cKin.GetName());
	cKin.AddHistoryLeaveTong(cTong.GetName());
	--Kin:LeaveTong_GS2(nKinId, nMethod, 1);
	return KTongGs.TongClientExcute(nTongId, {"Tong:KinDel_C2", szKinName, nKinRepute, nMethod, nReduceFund});
end

-- 删除家族失败回调，失败理由暂时只有家族为帮主家族，以后可能有需要扩展
function Tong:KinDelFailed_GS2(nTongId)
	--开除事件要删除申请记录(如果存在的话)
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_KICK_KIN);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		if tbData.ApplyRecord and tbData.ApplyRecord.nTimerId then
			Timer:Close(tbData.ApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nTongId, self.REQUEST_KICK_KIN);
	end
	return KTongGs.TongClientExcute(nTongId, {"Tong:KinDelFailed_C2"});
end

-- 任命长老
function Tong:ApointAssistant_GS1(nAssistantId, nKinId, nMemberId)
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_MASTER) ~= 1 then
		me.Msg("你不是帮主，无权任命长老");
		return 0;
	end
	if nSelfKinId == nKinId and nSelfMemberId == nMemberId then
		me.Msg("帮主不能任命为长老");
		return 0;
	end
	if self:HaveFigure(nTongId, nKinId, nMemberId, 0) ~= 1 then
		me.Msg("对方不是长老！不能任命");
		return 0;
	end
	return GCExcute{"Tong:ApointAssistant_GC", nTongId, nSelfKinId, nSelfMemberId, nAssistantId, nKinId, nMemberId};
end
RegC2SFun("ApointAssistant", Tong.ApointAssistant_GS1);

function Tong:ApointAssistant_GS2(nTongId, nAssistantId, nKinId, nMemberId, nOrgKinId)
	local cTong	= KTong.GetTong(nTongId);
	if (not cTong) then 
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	
	if (not cKin) then
		return 0;
	end
	local cOrgKin = KKin.GetKin(nOrgKinId);
	local szOrgPlayerName;
	if cOrgKin then		-- 原来职位已有家族占有
		cOrgKin.SetTongFigure(self.CAPTAIN_NORMAL)	-- 罢免，释放职位
		local nCaptainId = cOrgKin.GetCaptain()
		local cMember = cOrgKin.GetMember(nCaptainId);
		KKinGs.UpdateKinInfo(cMember.GetPlayerId());
		szOrgPlayerName = KGCPlayer.GetPlayerName(cMember.GetPlayerId());
	end
	cKin.SetTongFigure(nAssistantId);		--任命
	
	local szAssistant = cTong.GetCaptainTitle(nAssistantId);
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return 0;
	end
	local szPlayerName = KGCPlayer.GetPlayerName(cMember.GetPlayerId());
	KKinGs.UpdateKinInfo(cMember.GetPlayerId());
	KTongGs.TongClientExcute(nTongId, {"Tong:ApointAssistant_C2", nAssistantId, nOrgKinId, nKinId, szAssistant, szPlayerName, szOrgPlayerName});
end

-- 任命掌令使
function Tong:ApointEmissary_GS1(nTagetKinId, nTagetMemberId, nEmissaryId)
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_ENVOY) ~= 1 then
		me.Msg("你没有任命掌令使的权力！ ");
		return 0;
	end
	local cKin = KKin.GetKin(nTagetKinId);
	if (not cKin) then 
		return 0;
	end
	if (self:HaveFigure(nTongId, nTagetKinId, nTagetMemberId, 0) == 1) then
		me.Msg("长老不能被任命为掌令使！");
		return 0;
	end
	if (Kin:HaveFigure(nTagetKinId, nTagetMemberId, 4) ~= 1) then 
		me.Msg("荣誉成员不能被任命为掌令使！");
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	if not cTong.GetEnvoyTitle(nEmissaryId) then
		me.Msg("改掌令使未命名，不能任命");
		return 0;
	end
	if (nEmissaryId < 1 or nEmissaryId >14) then
		return 0;
	end
	return GCExcute{"Tong:ApointEmissary_GC", nTongId, nSelfKinId, nSelfMemberId, nTagetKinId, nTagetMemberId, nEmissaryId};
end
RegC2SFun("ApointEmissary", Tong.ApointEmissary_GS1);

function Tong:ApointEmissary_GS2(nTongId, nTagetKinId, nTagetMemberId, nEmissaryId)
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	local cKin = KKin.GetKin(nTagetKinId);
	if (not cKin) then 
		return 0;
	end
	local cMember = cKin.GetMember(nTagetMemberId);
	if not cMember then
		return 0;
	end
	cMember.SetEnvoyFigure(nEmissaryId);
	KKinGs.UpdateKinInfo(cMember.GetPlayerId());
	local szPlayerName = KGCPlayer.GetPlayerName(cMember.GetPlayerId());
	local szEmissaryName = cTong.GetEnvoyTitle(nEmissaryId);
	if not szEmissaryName then
		szEmissaryName = "未定义掌令使";
	end
	KTongGs.TongClientExcute(nTongId, {"Tong:ApointEmissary_C2", nTagetKinId, nTagetMemberId, nEmissaryId, szPlayerName, szEmissaryName});
end

-- 更改长老设置：名称、权限
function Tong:ChangeAssistant_GS1(nAssistantId, nPow, szTitle)
	if not szTitle then 
		return 0;
	end
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_MASTER) ~= 1 then
		me.Msg("你无权修改职位设置");
		return 0;
	end
	local nLen = GetNameShowLen(szTitle);
	if nLen > 12 then
		me.Msg("称号不能大于6汉字的长度");
		return 0
	end
	--称号名字合法性检查
	if KUnify.IsNameWordPass(szTitle) ~= 1 then
		me.Msg("称号只能包含中文简繁体字及· 【 】符号！");	
		return 0;
	end
	--名称过滤
	if IsNamePass(szTitle) ~= 1 then
		me.Msg("称号中包含敏感词汇！");		
		return 0;
	end
	return GCExcute{"Tong:ChangeAssistant_GC", nTongId, nSelfKinId, nSelfMemberId, nAssistantId, nPow, szTitle}
end
RegC2SFun("ChangeAssistant", Tong.ChangeAssistant_GS1);

function Tong:ChangeAssistant_GS2(nTongId, nDataVer, nAssistantId, nPow, szTitle)
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0
	end
	cTong.SetCaptainTitle(nAssistantId, szTitle);
	cTong.AssignCaptainPower(nAssistantId, nPow);
	cTong.SetTongFigureDataVer(nDataVer);
	KTongGs.UpdateTongTitle(nTongId, nAssistantId, 0); --更新称号，最后一个参数的含义：0为长老， 1为掌令使， 2为一般帮众
	KTongGs.TongClientExcute(nTongId, {"Tong:ChangeAssistant_C2", nAssistantId, szTitle, nPow});
end

-- 更改掌令使名称
function Tong:ChangeEmissary_GS1(nEmissaryId, szEmissary)
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(me.dwTongId, nSelfKinId, nSelfMemberId, self.POW_ENVOY) ~= 1 then
		me.Msg("你没有改变掌令使称谓的权力！ ");
		return 0;
	end
	local nLen = GetNameShowLen(szEmissary);
	if nLen > 12 then
		me.Msg("称号不能大于6汉字的长度");
		return 0
	end
	--称号名字合法性检查
	if KUnify.IsNameWordPass(szEmissary) ~= 1 then
		me.Msg("称号只能包含中文简繁体字及· 【 】符号！");	
		return 0;
	end
	--名称过滤
	if IsNamePass(szEmissary) ~= 1 then
		me.Msg("称号中包含敏感词汇！");		
		return 0
	end
	GCExcute{"Tong:ChangeEmissary_GC",me.dwTongId, nSelfKinId, nSelfMemberId, nEmissaryId, szEmissary};
end
RegC2SFun("ChangeEmissary", Tong.ChangeEmissary_GS1);

function Tong:ChangeEmissary_GS2(nTongId, nDataVer, nEmissaryId, szTitle)
	local cTong = KTong.GetTong(nTongId);
	local cTong = KTong.GetTong(nTongId);
	cTong.SetEnvoyTitle(nEmissaryId, szTitle);
	cTong.SetTongFigureDataVer(nDataVer);
	KTongGs.UpdateTongTitle(nTongId, nEmissaryId, 1);
	KTongGs.TongClientExcute(nTongId, {"Tong:ChangeEmissary_C2", nEmissaryId, szTitle});
end

-- 卸职单个掌令使
function Tong:FireEmissary_GS1(nKinId, nMemberId)
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(me.dwTongId, nSelfKinId, nSelfMemberId, self.POW_ENVOY) ~= 1 then
		me.Msg("你没有卸职掌令使的权力！");
		return 0;
	end
	GCExcute{"Tong:FireEmissary_GC", me.dwTongId, nSelfKinId, nSelfMemberId, nKinId, nMemberId, 1};
end
RegC2SFun("FireEmissary", Tong.FireEmissary_GS1);

function Tong:FireEmissary_GS2(nTongId, nKinId, nMemberId, nSync)
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then 
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId);
	if (not nMemberId) then
		return 0;
	end
	cMember.SetEnvoyFigure(0);
	KKinGs.UpdateKinInfo(cMember.GetPlayerId()); -- 更新称号
	if nSync then
		local szPlayerName = KGCPlayer.GetPlayerName(cMember.GetPlayerId());
		KTongGs.TongClientExcute(nTongId, {"Tong:FireEmissary_C2",nKinId, nMemberId, szPlayerName});
	end
end

-- 卸职全部掌令使
function Tong:FireAllEmissary_GS1(nEmissaryId)
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(me.dwTongId, nSelfKinId, nSelfMemberId, self.POW_ENVOY) ~= 1 then
		me.Msg("你没有卸职掌令使的权力！ "..self:CheckSelfRight(me.dwTongId, nSelfKinId, nSelfMemberId, self.POW_ENVOY));
		return 0;
	end
	GCExcute{"Tong:FireAllEmissary_GC", me.dwTongId, nSelfKinId, nSelfMemberId, nEmissaryId};
end
RegC2SFun("FireAllEmissary", Tong.FireAllEmissary_GS1)

function Tong:FireAllEmissary_GS2(nTongId, nEmissaryId)
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	local cKinItor = cTong.GetKinItor();
	local nKinId = cKinItor.GetCurKinId();
	while (nKinId ~= 0) do
		local cKin = KKin.GetKin(nKinId);
		if cKin then
			local cMemberItor = cKin.GetMemberItor();
			local cMember = cMemberItor.GetCurMember();
			while (cMember) do
				if (cMember.GetEnvoyFigure() == nEmissaryId) then
					cMember.SetEnvoyFigure(0);
					KKinGs.UpdateKinInfo(cMember.GetPlayerId()); -- 更新称号
				end
				cMember = cMemberItor.NextMember();
			end
		end 
		nKinId = cKinItor.NextKinId();
	end
	local szEmissary = cTong.GetEnvoyTitle(nEmissaryId);
	if (not szEmissary) then
		return 0;
	end
	KTongGs.TongClientExcute(nTongId, {"Tong:FireAllEmissary_C2", nEmissaryId ,szEmissary})
end

-- 保存更改公告
function Tong:SaveAnnounce_GS1(szAnnounce)
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(me.dwTongId, nSelfKinId, nSelfMemberId, self.POW_ANNOUNCE) ~= 1 then
		me.Msg("你没有更改公告的权力！ ");
		return 0;
	end
	if #szAnnounce > self.ANNOUNCE_MAX_LEN then
		me.Msg("公告字数大于允许的最大长度!")
		return 0;
	end
	return GCExcute{"Tong:SaveAnnounce_GC", me.dwTongId, nSelfKinId, nSelfMemberId, szAnnounce};
end
RegC2SFun("SaveAnnouce", Tong.SaveAnnounce_GS1);

function Tong:SaveAnnounce_GS2(nTongId, nDataVer, szAnnounce)
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	cTong.SetAnnounce(szAnnounce);
	cTong.SetTongAnnounceDataVer(nDataVer);
	KTongGs.TongClientExcute(nTongId, {"Tong:SaveAnnounce_C2"});
end

-- 调整分红比例
function Tong:ChangeTakeStock_GS1(nPercent)
	if (not nPercent or 0 == Lib:IsInteger(nPercent)) then
		return 0;
	end
	if (nPercent < 0 or nPercent > 100) then
		me.Msg("你设置的分红比例有误。");
		return 0;
	end
	local nTongId = me.dwTongId
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_WAGE) ~= 1 then
		me.Msg("你没有更改分红比例的权力！ ");
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	if cTong.GetEnergy() < 100 then
		me.Msg("帮会没有足够的行动力调整分红比例！")
		return 0;
	end
	return GCExcute{"Tong:ChangeTakeStock_GC", nTongId, nSelfKinId, nSelfMemberId, nPercent};
end
RegC2SFun("ChangeTakeStock", Tong.ChangeTakeStock_GS1);

function Tong:ChangeTakeStock_GS2(nTongId, nDataVer, nPercent, nCurEnergy)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then 
		return 0;
	end
	cTong.SetTakeStock(nPercent);
	cTong.SetEnergy(nCurEnergy);
	cTong.SetTongDataVer(nDataVer);
	KTongGs.TongClientExcute(nTongId, {"Tong:ChangeTakeStock_C2", nPercent, self.CHANGE_TAKESTOCK_ENERGY});
end

-- 申请发放资金
function Tong:ApplyDispenseFund_GS1(nType, nMoney)
	if (not nType or not nMoney or 0 == Lib:IsInteger(nType) or 0 == Lib:IsInteger(nMoney) or nMoney < 0 or nMoney > self.MAX_BUILD_FUND) then
		return 0;
	end
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_FUN) ~= 1 then
		me.Msg("你没有发放资金的权力！ ");
		return 0;
	end
	if (me.IsInPrison() == 1) then
		me.Msg("您在坐牢期间不能操作。");
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_DISPENSE_FUND);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then	-- 上次申请响应没结束
		me.Msg("已有发放资金的申请！不能再申请！")
		return 0;
	end
	if (tbData.nLastTime and tbData.nLastTime[nType] and GetTime() - tbData.nLastTime[nType] < self.DISPENSE_TIME) then
		me.Msg("对同一群体两次发放资金必须间隔6小时！")
		return 0;
	end
	GCExcute{"Tong:ApplyDispenseFund_GC", nTongId, nSelfKinId, nSelfMemberId, nType, nMoney};
end
--RegC2SFun("DispenseFund", Tong.ApplyDispenseFund_GS1);

-- 需要申请发放的回调（不需要申请则不直接发放，不回调此函数）
function Tong:ApplyDispense_GS2(nTongId, nKinId, nPlayerId, nType, nAmount, nRequset)
	local nPow;
	if nRequset == self.REQUEST_DISPENSE_FUND then
		nPow = self.POW_FUN;
	elseif nRequset == self.REQUEST_DISPENSE_OFFER then
		nPow = self.POW_STOREDOFFER;
	end
	local tbData = self:GetExclusiveEvent(nTongId, nRequset);
	if not tbData then
		return 0;
	end
	tbData.nApplyEvent = 1;
	if not tbData.ApplyRecord then
		tbData.ApplyRecord = {};
	end
	tbData.ApplyRecord.nPlayerId = nPlayerId;
	tbData.ApplyRecord.nKinId = nKinId
	tbData.ApplyRecord.nAmount = nAmount;
	tbData.ApplyRecord.nPow = nPow;
	-- 状态持10分钟
	tbData.ApplyRecord.nTimerId = Timer:Register(
		self.DISPENSE_APPLY_LAST, 
		self.CancelExclusiveEvent_GS, 
		self, 
		nTongId, 
		nPlayerId, 
		nRequset
	);
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	-- 寻找拥有资金权限的人员通知有申请
	local cTong = KTong.GetTong(nTongId);
	if not cTong then 
		return 0;
	end
	local pKinIt = cTong.GetKinItor();
	local nCurKinId = pKinIt.GetCurKinId()
	while(nCurKinId ~= 0) do
		local cKin = KKin.GetKin(nCurKinId);
		if cKin then
			local nCaptainId = cKin.GetCaptain();
			local nRetCode ,cMember = self:HaveFigure(nTongId, nCurKinId, nCaptainId, nPow);
			if nRetCode == 1 then
				local nId = cMember.GetPlayerId();
				local pPlayer = KPlayer.GetPlayerObjById(nId);
				if nPlayerId ~= nId and pPlayer then	-- 非申请人本身
					pPlayer.CallClientScript({"Tong:GetApply_C2", szPlayerName, nRequset, nType, nAmount})
				end
			end
		end		
		nCurKinId = pKinIt.NextKinId();
	end
	KTongGs.TongClientExcute(nTongId, {"Tong:SendApply_C2", nRequset, szPlayerName, nAmount, nType});
end

-- 超时删除唯一事件
function Tong:CancelExclusiveEvent_GS(nTongId, nPlayerId, nEventId)
	self:DelExclusiveEvent(nTongId, nEventId);
	-- 事件超时，暂时只通知申请人，如需求不满再改……
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	pPlayer.CallClientScript({"Tong:ApplyFailed_C2", nEventId})
	return 0
end

-- 程序调用，设置获得发资源以及发送获取信息
function Tong:GetDispense_GS2(nPlayerId, nType, nAmount)
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0
	end
	if nType == self.DISPENSE_FUND then
		local nMoney = TradeTax:TradeMoney(cPlayer, nAmount)
		cPlayer.Earn(nMoney, Player.emKEARN_TONG_DISPAND);
		Dbg:WriteLog("GetDispense_GS2", cPlayer.dwTongId, cPlayer.szName, cPlayer.szAccount, nMoney);
	elseif nType == self.DISPENSE_OFFER then
--		cPlayer.AddTongOffer(nAmount);
	else	-- 没定义的资源类型
		return 0;
	end	
	return cPlayer.CallClientScript({"Tong:GetDispense_C2", nType, nAmount})
end

-- 申请发放贡献度
--function Tong:ApplyDispenseOffer_GS1(nType, nAmount)
--	if (not nType or not nAmount or 0 == Lib:IsInteger(nType) or 0 == Lib:IsInteger(nAmount) or nAmount < 0 or nAmount > self.MAX_STORED_OFFER) then
--		return 0;
--	end
--	local nTongId = me.dwTongId;
--	local nSelfKinId, nSelfMemberId = me.GetKinMember()
--	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_STOREDOFFER) ~= 1 then
--		me.Msg("你没有操作储备贡献度的权力");
--		return 0;
--	end
--	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_DISPENSE_OFFER);
--	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
--		me.Msg("已经有发放贡献度的申请！不能再申请！");
--		return 0
--	end
--	if tbData.nLastTime and tbData.nLastTime[nType] and GetTime() - tbData.nLastTime[nType] < self.DISPENSE_APPLY_LAST then
--		me.Msg("对同一群体两次发放贡献度需要间隔6小时！");
--		return 0;
--	end
--	return GCExcute{"Tong:ApplyDispenseOffer_GC",nTongId, nSelfKinId, nSelfMemberId, nType, nAmount};
--end
-- 取消发放储备贡献接口
--RegC2SFun("DispenseOffer", Tong.ApplyDispenseOffer_GS1);

-- 同步发放帮会资源后的数据
function Tong:SyncDispense_GS2(nTongId, nCurData, nDataVer, nType, nCrowdType, nAmount, nPlayerId)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then 
		return 0;
	end
	local tbData;
	if nType == self.DISPENSE_OFFER then
		--[[
		cTong.SetStoredOffer(nCurData);
		tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_DISPENSE_OFFER);
		if tbData.nApplyEvent and tbData.nApplyEvent == 1 then  	--有开启申请
			if tbData.ApplyRecord and tbData.ApplyRecord.nTimerId then
				Timer:Close(tbData.ApplyRecord.nTimerId);		-- 关闭计时器，防止误删下次申请
			end
			self:DelExclusiveEvent(nTongId, self.REQUEST_DISPENSE_OFFER)
		end
		-- ]]
	elseif nType == self.DISPENSE_FUND then
		cTong.SetMoneyFund(nCurData);
		tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_DISPENSE_FUND);
		if tbData.nApplyEvent and tbData.nApplyEvent == 1 then  	--有开启申请
			if tbData.ApplyRecord and tbData.ApplyRecord.nTimerId then
				Timer:Close(tbData.ApplyRecord.nTimerId);		-- 关闭计时器，防止误删下次申请
			end	
			self:DelExclusiveEvent(nTongId, self.REQUEST_DISPENSE_FUND)
		end
		
		-- 记录事件
		if nPlayerId and nAmount >= self.DISPENSE_FUND_RECORD then
			local szSelfName = KGCPlayer.GetPlayerName(nPlayerId);
			cTong.AddAffairDispenseFund(szSelfName, tostring(nAmount), Tong.tbCrowdTitle[nCrowdType]);
		end
	end
	if not tbData.nLastTime then
		tbData.nLastTime = {};
	end
	tbData.nLastTime[nCrowdType] = GetTime();
	cTong.SetTongDataVer(nDataVer);

	KTongGs.TongClientExcute(nTongId, {"Tong:SyncDispense_C2", nType, nCrowdType, nAmount});
end

-- 由于资源不足造成发放资源失败！回调通知
function Tong:FailedDispense_GS2(nTongId, nType, nPlayerId)
	local tbData;
	if nType == self.DISPENSE_OFFER then
		tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_DISPENSE_OFFER);
		if tbData.nApplyEvent and tbData.nApplyEvent == 1 then  	--有开启申请
			if tbData.ApplyRecord and tbData.ApplyRecord.nTimerId then
				Timer:Close(tbData.ApplyRecord.nTimerId);		-- 关闭计时器，防止误删下次申请
			end
			self:DelExclusiveEvent(nTongId, self.REQUEST_DISPENSE_OFFER)
			-- 开启了申请通知全部成员
			KTongGs.TongClientExcute(nTongId, {"Tong:FailedDispense_C2", nType})
		else	-- 没开启申请只通知发放人失败
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.CallClientScript({"Tong:FailedDispense_C2", nType});
			end
		end
	elseif nType == self.DISPENSE_FUND then
		tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_DISPENSE_FUND);
		if tbData.nApplyEvent and tbData.nApplyEvent == 1 then  	--有开启申请
			if tbData.ApplyRecord and tbData.ApplyRecord.nTimerId then
				Timer:Close(tbData.ApplyRecord.nTimerId);		-- 关闭计时器，防止误删下次申请
			end	
			self:DelExclusiveEvent(nTongId, self.REQUEST_DISPENSE_FUND)
			-- 开启了申请通知全部成员
			KTongGs.TongClientExcute(nTongId, {"Tong:FailedDispense_C2", nType})
		else	-- 没开启申请只通知发放人失败
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.CallClientScript({"Tong:FailedDispense_C2", nType});
			end
		end
	end
	
end

function Tong:SyncMoney(nTongId, nMoney, nDataVer)
	local cTong =  KTong.GetTong(nTongId);
	if (cTong and nMoney >= 0) then
		cTong.SetMoneyFund(nMoney);
		cTong.SetTongDataVer(nDataVer);
	end
end

-- 响应只存在一个的申请，如：资金发放，贡献度发放，取资金，罢免帮主等
-- 存在一个BUG：有可能误接受第二次申请，前提是第一次申请终止响应没收到
-- 且第二次申请开始响应没收到，基本不可能，而且影响也不大，暂时忽略
function Tong:AcceptExclusiveEvent_GS1(nKey, nAccept)
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local tbData = self:GetExclusiveEvent(nTongId, nKey);
	if not tbData.nApplyEvent or tbData.nApplyEvent == 0 then	-- 事件已不存在
		me.Msg("该申请已结束！"); -- TODO:
		return 0
	end
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, tbData.ApplyRecord.nPow) ~= 1 then
		me.Msg("你无权响应这个申请！");
		return 0
	end
	if not tbData.tbAccept then
		tbData.tbAccept = {}		-- 已表态家族记录
	end
	if tbData.tbAccept[nSelfKinId] then
		me.Msg("你的家族已经表过态了！");
		return 0;
	end
	GCExcute{"Tong:AcceptExclusiveEvent_GC", nTongId, nSelfKinId, nSelfMemberId, nKey, nAccept};
end
RegC2SFun("AcceptExclusiveEvent", Tong.AcceptExclusiveEvent_GS1)

function Tong:AcceptExclusiveEvent_GS2(nTongId, nSelfKinId, nPlayerId, nKey, nAccept)
	local tbData = self:GetExclusiveEvent(nTongId, nKey);
	if not tbData.tbAccept then
		tbData.tbAccept = {}		-- 已表态家族记录
	end
	tbData.tbAccept[nSelfKinId] = nAccept;
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	return KTongGs.TongClientExcute(nTongId, {"Tong:AcceptExclusiveEvent_C2", szPlayerName, nKey, nAccept})
end

function Tong:HandUp_GS1()
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	GCExcute{"Tong:HandUp_GC", me.dwTongId, nSelfKinId, nSelfMemberId};
end
RegC2SFun("HandUp", Tong.HandUp_GS1);
	
function Tong:HandUp_GS2(nTongId, nSelfKinId, nSelfMemberId)
	return KTongGs.TongClientExcute(nTongId, {"Tong:HandUp_C2", nSelfKinId, nSelfMemberId});
end

function Tong:AddFund_GS1(nMoney)
	if (not nMoney or 0 == Lib:IsInteger(nMoney) or nMoney < 0 or nMoney > 2000000000) then
		return 0;
	end
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		return 0;
	end
	if not pTong then
		me.Msg("你没有帮会，不能存帮会资金");
		return 0;
	end
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return;
	end
	--- Add by zouying
	if (me.IsInPrison()  == 1)then
		me.Msg("您在坐牢期间不能存入帮会资金！");
		return 0;
	end
	
	if nMoney <= 0 then
		return 0;
	end
	
	local nCurMoney = me.nCashMoney
	
	if nMoney + pTong.GetMoneyFund() > self.MAX_TONG_FUND then
		me.Msg("您存入的金额将会使帮会资金超过存款上限，无法存入！")
		return 0;
	end
	
	local nRet = me.CostMoney(nMoney, Player.emKPAY_TONGFUND)
	if nRet ~= 1 then
		me.Msg("存入资金失败!")
		return 0
	end
	return GCExcute{"Tong:AddFund_GC", me.dwTongId, me.nId, nMoney};
end
RegC2SFun("AddFund", Tong.AddFund_GS1);

function Tong:AddFund_GS2(nTongId, nDataVer, nPlayerId, nCurFund, nFund)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	cTong.SetMoneyFund(nCurFund);
	cTong.SetTongDataVer(nDataVer);
	local szName = KGCPlayer.GetPlayerName(nPlayerId)
	if nFund >= self.TAKEFUND_APPLY then
		cTong.AddAffairSaveFund(szName, tostring(nFund));
	end
	KTongGs.TongClientExcute(nTongId, {"Tong:AddFund_C2", szName, nFund});
end

function Tong:AddBuildFund_GS1(nMoney, nTranceRate)
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		me.Msg("你没有帮会，不能存入建设资金");
		return 0;
	end
	local cKin = KKin.GetKin(nSelfKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nSelfMemberId);
	if not cMember then
		return 0;
	end
	local nBuildFund = cTong.GetBuildFund();
	if nBuildFund + nMoney > self.MAX_BUILD_FUND then
		me.Msg("建设资金将会超过最大存储额度，不允许再存入了！")
		return 0;
	end
	
	return GCExcute{"Tong:AddBuildFund_GC", nTongId, nKinId, nMemberId, nMoney, nTranceRate};
end
-- 删除客户端直接存建设资金接口
--RegC2SFun("AddBuildFund", Tong.AddBuildFund_GS1);

-- 取出帮会资金
function Tong:ApplyTakeFund_GS1(nMoney)
	if (not nMoney or 0 == Lib:IsInteger(nMoney) or nMoney < 0 or nMoney > 2000000000) then
		return 0;
	end
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_FUN) ~= 1 then
		me.Msg("你无权动用帮会资金!");
		return 0;
	end
	
	if (me.IsInPrison() == 1) then
		me.Msg("您在坐牢期间不能取帮会资金。");
		return 0;
	end
	
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	local tbDataStorageToKin = self:GetExclusiveEvent(nTongId, self.REQUEST_STORAGE_FUND_TO_KIN);
	if tbDataStorageToKin.nApplyEvent and tbDataStorageToKin.nApplyEvent == 1 then		-- 已经有申请转存家族 
		me.Msg("已经申请有帮会资金转存家族的申请！不能再申请！");
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_TAKE_FUND);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then		-- 已经有申请取钱 
		me.Msg("已经申请有取出帮会资金的申请！不能再申请！");
		return 0;
	end
	if tbData.nLastTime and GetTime() - tbData.nLastTime < self.TAKEFUND_TIME then
		me.Msg("两次取帮会资金需要间隔6小时!");
		return 0;
	end
	local nCurFund = cTong.GetMoneyFund();
	if (nMoney > nCurFund) then
		me.Msg("帮会没有足够的资金供你取出！");
		return 0;
	end
	if me.GetMaxCarryMoney() < me.nCashMoney + nMoney then
		me.Msg("你取出的资金额度将会使银两携带量超出上限！")
		return 0;
	end
	local nRet	= GCExcute{"Tong:ApplyTakeFund_GC", nTongId, nSelfKinId, nSelfMemberId, me.nId, nMoney};
	return nRet;
end
RegC2SFun("TakeFund", Tong.ApplyTakeFund_GS1);

-- 取钱的申请(需要申请的回调)
function Tong:ApplyTakeFund_GS2(nTongId, nKinId, nPlayerId, nMoney)
	
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_TAKE_FUND)
	tbData.nApplyEvent = 1;
	if not tbData.ApplyRecord then
		tbData.ApplyRecord = {};
	end
	tbData.ApplyRecord.nKinId = nKinId;
	tbData.ApplyRecord.nPow = self.POW_FUN;
	tbData.ApplyRecord.nAmount = nMoney;
	tbData.ApplyRecord.nTimerId = Timer:Register(
		self.TAKEFUND_APPLY_LAST,
		self.CancelExclusiveEvent_GS,
		self,
		nTongId,
		nPlayerId,
		self.REQUEST_TAKE_FUND
	);
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	-- 寻找拥有资金权限的人员通知有申请
	local cTong = KTong.GetTong(nTongId);
	if not cTong then 
		return 0;
	end
	local pKinIt = cTong.GetKinItor();
	local nCurKinId = pKinIt.GetCurKinId()
	while(nCurKinId ~= 0) do
		local cKin = KKin.GetKin(nCurKinId);
		if cKin then
			local nCaptainId = cKin.GetCaptain();
			local nRetCode ,cMember = self:HaveFigure(nTongId, nCurKinId, nCaptainId, self.POW_FUN);
			if nRetCode == 1 then
				local nId = cMember.GetPlayerId();
				local pPlayer = KPlayer.GetPlayerObjById(nId);
				if nPlayerId ~= nId and pPlayer then
					pPlayer.CallClientScript({"Tong:GetApply_C2", szPlayerName, self.REQUEST_TAKE_FUND, 0, nMoney})
				end
			end
		end		
		nCurKinId = pKinIt.NextKinId();
	end

	KTongGs.TongClientExcute(nTongId, {"Tong:SendApply_C2", self.REQUEST_TAKE_FUND, szPlayerName, nMoney, 0});
end

function Tong:TakeFund_GS2(nTongId, nPlayerId, nDataVer, nMoney, nCurFund)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	
	cTong.SetMoneyFund(nCurFund);
	cTong.SetTongDataVer(nDataVer);
	local szName = KGCPlayer.GetPlayerName(nPlayerId);
	if nMoney >= self.TAKEFUND_APPLY then
		cTong.AddAffairTakeFund(szName, tostring(nMoney));
	end
	
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_TAKE_FUND);
	tbData.nLastTime = GetTime();
	if (tbData.nApplyEvent == 1) then
		if tbData.ApplyRecord and tbData.ApplyRecord.nTimerId then
			Timer:Close(tbData.ApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nTongId, self.REQUEST_TAKE_FUND);
	end
	KTongGs.TongClientExcute(nTongId, {"Tong:TakeFund_C2", szName, nMoney});
	
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not cPlayer then
		return;
	end
	cPlayer.Earn(nMoney, Player.emKEARN_TONG_FUN);
	-- 还原锁定状态
	cPlayer.AddWaitGetItemNum(-1);
	Dbg:WriteLog("TakeFund_GS2", cTong.GetName(), nCurFund, cPlayer.szName, cPlayer.szAccount, nMoney);
	cPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_TONGPAYOFF, 
			string.format("玩家：%s, 帐号:%s, 从帮会：%s 领取了%d的资金,帮会还有%d的资金", 
			cPlayer.szName, cPlayer.szAccount, cTong.GetName(), nMoney, nCurFund));
end

function Tong:ChangeTitle_GS1(nTitleType, szTitle)
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_TITLE) ~= 1 then
		me.Msg("你没有变更称号的权力");
		return 0;
	end
	local nLen = GetNameShowLen(szTitle);
	if nLen > 8 then
		me.Msg("称号不能大于4汉字的长度");
		return 0
	end
	--称号名字合法性检查
	if KUnify.IsNameWordPass(szTitle) ~= 1 then
		me.Msg("称号只能包含中文简繁体字及· 【 】符号！");	
		return 0;
	end
	--名称过滤
	if IsNamePass(szTitle) ~= 1 then
		me.Msg("称号中包含敏感词汇！");		
		return 0
	end
	GCExcute{"Tong:ChangeTitle_GC", nTongId, nSelfKinId, nSelfMemberId, szTitle, nTitleType};
end
RegC2SFun("ChangeTitle", Tong.ChangeTitle_GS1);

function Tong:ChangeTitle_GS2(nTongId, szTitle, nTitleType)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then 
		return 0;
	end
	cTong.SetBufTask(nTitleType, szTitle);
	KTongGs.UpdateTongTitle(nTongId, nTitleType, 2);
	return KTongGs.TongClientExcute(nTongId, {"Tong:ChangeTitle_C2", nTitleType, szTitle});
end

function Tong:ChangeCamp_GS1(nCamp)
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_CAMP) ~= 1 then 
		me.Msg("你无权更改阵营！");
		return 0
	end
	local tbData = Tong:GetTongData(nTongId);
	if tbData.nLastCampTime and GetTime() - tbData.nLastCampTime < Tong.CHANGE_CAMP_TIME then
		me.Msg("两次修改阵营要间隔两小时！")
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	if cTong.GetCamp() == nCamp then
		me.Msg("你的帮会已经是该阵营，不需要修改！");
		return 0;
	end
	if self:CanCostedBuildFund(nTongId, nSelfKinId, nSelfMemberId, Tong.CHANGE_CAMP) ~= 1 then
		me.Msg("能使用建设资金额度不足！请让帮会的<color=yellow>首领<color>设置更高的周使用上限！");
		return 0;
	end
	return GCExcute{"Tong:ChangeCamp_GC", nTongId, nSelfKinId, nSelfMemberId, nCamp};
end
RegC2SFun("ChangeCamp", Tong.ChangeCamp_GS1);

function Tong:ChangeCamp_GS2(nTongId, nCamp, nDataVer)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	cTong.SetCamp(nCamp);
	local cKinItor = cTong.GetKinItor();
	local nCurKinId = cKinItor.GetCurKinId();
	while (nCurKinId ~= 0) do
		local cKin = KKin.GetKin(nCurKinId);
		if cKin then
			cKin.SetCamp(nCamp);
			KKinGs.UpdateKinMemberCamp(nCurKinId, nCamp);
		end
		nCurKinId = cKinItor.NextKinId();
	end
	cTong.SetTongDataVer(nDataVer);
	local tbData = Tong:GetTongData(nTongId);
	tbData.nLastCampTime = GetTime();
	return KTongGs.TongClientExcute(nTongId, {"Tong:ChangeCamp_C2", nCamp})
end

function Tong:InheritMaster_GS1(nKinId, nMemberId)
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local nRetCode, cMember = self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_MASTER);
	if nRetCode ~= 1 then
		me.Msg("你不是帮主！不能移交帮主！")
		return 0;
	end
	if self:HaveFigure(nTongId, nKinId, nMemberId, 0) ~= 1 then
		me.Msg("对方不是长老！不能移交帮主")
		return 0;
	end	
	if not cMember then
		return 0;
	end
	local nPlayerId = cMember.GetPlayerId();
	local nCurRepute = KGCPlayer.GetPlayerPrestige(nPlayerId);
	if nCurRepute < self.INHERIT_MASTER then
		me.Msg("威望不足，移交帮主需要"..self.INHERIT_MASTER.."江湖威望！")
		return 0;
	end
	return GCExcute{"Tong:InheritMaster_GC", nTongId, nSelfKinId, nSelfMemberId, nKinId, nMemberId};
end
RegC2SFun("InheritMaster", Tong.InheritMaster_GS1);

function Tong:InheritMaster_GS2(nTongId, nSelfKinId, nTagetKinId, nDateVer, nRepute)
	local cSelfKin = KKin.GetKin(nSelfKinId);
	if not cSelfKin then
		return 0;
	end
	local nMasterId = cSelfKin.GetCaptain();
	local cMember = cSelfKin.GetMember(nMasterId);
	if not cMember then 
		return 0;
	end
	self:ChangeMaster_GS2(nTongId, nTagetKinId, nDateVer);
	return 1
end

function Tong:AddEnergy(nEnergy)
	local nTongId = me.dwTongId;
	if nTongId == 0 then
		return 0;
	end
	return GCExcute{"Tong:AddEnergy_GC", nTongId, nEnergy};
end

function Tong:AddEnergy_GS2(nTongId, nCurEnergy, nDataVer)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then 
		return 0;
	end
	cTong.SetEnergy(nCurEnergy);
	cTong.SetTongDataVer(nDataVer);
	return 1
end

function Tong:SyncTongTotalRepute_GS2(nTongId, nRepute, nDataVer)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	pTong.SetTotalRepute(nRepute);
	pTong.SetTongDataVer(nDataVer);
end

-- 分红
function Tong:OpenGetWageLock_GS(nPlayerId)
	self.WAGE_LOCKSTATE[nPlayerId] = nil;
	return 0;
end

function Tong:TakeStock_GS2(nTongId, nKinId, nMemberId, nTotalFund, nTakeMoney, nTotalStock, nPersonalStock)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return 0;
	end
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	pTong.SetBuildFund(nTotalFund);
	pTong.SetTotalStock(nTotalStock);
	pMember.SetPersonalStock(nPersonalStock);
	
	local pPlayer = KPlayer.GetPlayerObjById(pMember.GetPlayerId());
	if pPlayer then
		pPlayer.AddBindMoney(nTakeMoney, Player.emKBINDMONEY_ADD_TONG_FUN);
		pPlayer.Msg(string.format("您成功领取了<color=yellow>%s<color>两分红。", nTakeMoney));
		Dbg:WriteLog("Tong", "TakeStock_GS2", pPlayer.szName, pPlayer.szAccount, nTakeMoney)
	end
end

function Tong: AddHistory(bIsHistory, nType, ...)
	local nTongId = me.dwTongId;
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	cTong.AddTongHistory(bIsHistory, nType, GetTime(), unpack(arg));
end

-- 找到玩家，然后再向gc取钱
function Tong:FindPlayer_GS(nTongId, nMoney, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer == nil then
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
	local nRet = GCExcute{"Tong:TakeFund_GC", nTongId, nMoney, nPlayerId};
	if (nRet == 1)then
		-- 申请获取资金时，锁定状态
		pPlayer.AddWaitGetItemNum(1);
		print("申请获取资金时，锁定状态");
	end
end

-- 设置主城
function Tong:SetCapital_GS1(nTongId, nDomainId, bConfirm)
	if Domain:GetBattleState() ~= Domain.NO_BATTLE then
		Dialog:Say("Tranh đoạt lãnh thổ đã bắt đầu, không thể thay đổi thành chính!");
		return 0;
	end
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end
	if cTong.GetCapital() == nDomainId then
		Dialog:Say("Lãnh thổ này đã là thành chính của bạn.");
		return 0;
	end
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local nRetCode, cMember = self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_MASTER);
	if nRetCode ~= 1 then
		Dialog:Say("Không phải thủ lĩnh, không thể thiết lập thành chính!");
		return 0;
	end

	-- 检查是否新手村
	if Domain:GetDomainType(nDomainId) == "village" then
		Dialog:Say("Không thể đặt thành chính là Tân thủ thôn!");
		return 0;
	end
	-- 是否已占领该领土
	if Domain:GetDomainOwner(nDomainId) ~= nTongId then
		Dialog:Say("Bang hội không chiếm lĩnh lãnh thổ này, không thể đặt thành chính!");
		return 0;
	end
	local szCapital = Domain:GetDomainName(nDomainId);
	local nCost, nChangeCount = self:CalcChangeCapital(nTongId);
	if self:CanCostedBuildFund(nTongId, nSelfKinId, nSelfMemberId, nCost) ~= 1 then
		Dialog:Say("Quỹ xây dựng không đủ! Yêu cầu <color=yellow>Thủ lĩnh<color> tăng giới hạn sử dụng cao hơn!");
		return 0;			
	end
	if bConfirm == 1 then
		return GCExcute{"Tong:SetCapital_GC", nTongId, nSelfKinId, nSelfMemberId, nDomainId};
	else
		local szMsg = string.format("Thay đổi <color=green>%s<color> làm thành chính, đây là  <color=green>lần thứ %d<color> thay đổi, tiêu hao <color=green>%d<color> quỹ xây dựng bang hội.",
			szCapital, nChangeCount, nCost);
		Dialog:Say(szMsg, 
			{
				{"Xác nhận", self.SetCapital_GS1, self, nTongId, nDomainId, 1},
				{"Để ta suy nghĩ thêm"},
			});
	end
end

-- 设置主城
function Tong:SetCapital_GS2(nTongId, nDomainId, nCost, nChangeCount, nDataVer)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end
	cTong.SetCapital(nDomainId);
	cTong.SetCapitalChangeCount(nChangeCount); -- 记录主城变更次数
	Domain.nDataVer = nDataVer;
	local szCapital = Domain:GetDomainName(nDomainId)
	if szCapital then
		cTong.AddAffairCapital(szCapital);
		KTong.Msg2Tong(nTongId, 
			string.format("Bang hội trích <color=green>%d<color> quỹ xây dựng, thiết lập <color=green>%s<color>。",
			nCost, szCapital));
	end
end

-- 设置主城区域战编号
function Tong:SetDomainBattleNo_GS1(nTongId, nDomainBattleNo)
	return GCExcute{"Tong:SetDomainBattleNo_GC", nTongId, nDomainBattleNo};
end

-- 同步合并股结果
function Tong:SyncAllMemberStock_GS2(nTongId, nTotalStock, tbRet)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	pTong.SetTotalStock(nTotalStock);
	for nKinId, tbKinRet in pairs(tbRet) do
		local pKin = KKin.GetKin(nKinId);
		if pKin then
			for nMemberId, nStock in pairs(tbKinRet) do
				local pMember = pKin.GetMember(nMemberId);
				if pMember then
					pMember.SetPersonalStock(nStock);
				end
			end
		end
	end
end

function Tong:PresidentConfirm_GS2(nTongId, tbResult, nDataVer, nKinDataVer)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local nPresidentKin_Old = pTong.GetPresidentKin();
	local nPresidentMember_Old = pTong.GetPresidentMember();
	self:PresidentConfirm(nTongId, tbResult);
	pTong.SetTongDataVer(nDataVer);
	local nPresidentKin = pTong.GetPresidentKin();
	local nPresidentMember = pTong.GetPresidentMember();
	local pItor = pTong.GetKinItor()
	local nCurKinId = pItor.GetCurKinId()
	local pCurKin = KKin.GetKin(nCurKinId);
	while pCurKin do
		pCurKin.SetKinDataVer(nKinDataVer);		-- 更换家族数据版本号
		nCurKinId = pItor.NextKinId()
		pCurKin = KKin.GetKin(nCurKinId);
	end
	local pKin = KKin.GetKin(nPresidentKin);
	if not pKin then
		return 0;
	end
	local pMember = pKin.GetMember(nPresidentMember);
	if not pMember then
		return 0;
	end
	local szName = KGCPlayer.GetPlayerName(pMember.GetPlayerId());
	local szType = "trở thành"
	if nPresidentKin_Old == nPresidentKin and nPresidentMember_Old == nPresidentMember then
		szType = "được bầu lại thành"
	end
	if szName then
		KTong.Msg2Tong(nTongId, string.format("<color=green>%s<color> %s thủ lĩnh mới.", szName, szType))
	end
end

function Tong:PresidentCandidateConfirm_GS2(nTongId, nKinId, nMemberId, nDataVer, nKinDataVer)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	pMember.SetStockFigure(self.PRESIDENT_CANDIDATE);
	pTong.SetTongDataVer(nDataVer);
	pKin.SetKinDataVer(nKinDataVer);
	local szName = KGCPlayer.GetPlayerName(pMember.GetPlayerId());
	if szName then
		KTong.Msg2Tong(nTongId, string.format("<color=green>%s<color> được đề cử làm thủ lĩnh mới, nếu cổ phần bang hội vẫn đạt vị trí đầu tiên, thứ Hai tới sẽ trở thành thủ lĩnh mới.", szName))
	end
end

-- 消费帮会建设资金
function Tong:ConsumeBuildFund_GS2(nTongId, nCurMoney)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return 0;
	end
	pTong.SetBuildFund(nCurMoney);			-- 消耗资金
	local nCurTotalStock = pTong.GetTotalStock()	-- 股份总数
	if nCurMoney == 0 or nCurTotalStock == 0 then
		self:ClearAllStock(nTongId);
	end
end

function Tong:_AddTongBuildFund_GS2(nTongId, nKinId, nMemberId, nBuildFund, nTotalStock, nPersonalStock, bClear)
	if bClear == 1 then
		self:ClearAllStock(nTongId);
	end
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		pMember.SetPersonalStock(nPersonalStock);
		return 1;
	end
	pTong.SetBuildFund(nBuildFund);
	pTong.SetTotalStock(nTotalStock);
	pMember.SetPersonalStock(nPersonalStock);
end

function Tong:AddBuildFund_GS2(nKinId, nMemberId, nMoney, bTongShow, bSelfShow)
	bSelfShow = bSelfShow or 1;
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local nTongId = pKin.GetBelongTong()
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	local pTong = KTong.GetTong(nTongId);
	if pTong then
		local szPlayerName = KGCPlayer.GetPlayerName(pMember.GetPlayerId());
		if nMoney >= self.TAKEFUND_APPLY then
			pTong.AddAffairBuildFund(szPlayerName, tostring(nMoney));
		end
	end
	local nPlayerId = pMember.GetPlayerId()
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer and bSelfShow == 1 then
		pPlayer.Msg(string.format("Tài sản cá nhân tăng <color=yellow>%d<color>", nMoney))
	end
	if nTongId ~= 0 and bTongShow == 1 then
		KTong.Msg2Tong(nTongId, string.format("<color=white>%s<color> tăng quỹ xây dựng Bang hội thêm <color=green>%d<color>", KGCPlayer.GetPlayerName(nPlayerId), nMoney))	
	end
end

function Tong:AddBuildFund2_GS2(nTongId, nMoney)
	local pTong = KTong.GetTong(nTongId);	
	if 0 == nMoney then
		return 0;
	end 
	if pTong then
		pTong.AddBuildFund(nMoney);
		KTong.Msg2Tong(nTongId, string.format("Quỹ xây dựng Bang hội tăng <color=green>%d<color>", nMoney));
	end
end

function Tong:DealTakeStock_GS2(nTongId, nTake)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return 0
	end
	pTong.SetLastTakeStock(nTake);
end

function Tong:SyncStock_GS2(nTongId, nBuildFund, nTotalStock)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	pTong.SetBuildFund(nBuildFund);
	pTong.SetTotalStock(nTotalStock);
end

function Tong:TongStockChaging_GS2(nTongId, nCurBuildFund, nTotalStock, nMasterStock, nCaptainStock, nMemberStock)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	pTong.SetBuildFund(nCurBuildFund);
	pTong.SetTotalStock(nTotalStock)
	pTong.SetStoredOffer(0);
	local pKinItor = pTong.GetKinItor();
	local nKinId = pKinItor.GetCurKinId();
	local pKin = KKin.GetKin(nKinId);
	while pKin do
		local pMemberItor = pKin.GetMemberItor()
		local pMember = pMemberItor.GetCurMember();
		while pMember do
			local nStock = 0;
			if pMember.GetFigure() == Kin.FIGURE_CAPTAIN then
				if pKin.GetTongFigure() == self.CAPTAIN_MASTER then
					nStock = nMasterStock;
				else
					nStock = nCaptainStock;
				end
			else
				nStock = nMemberStock;
			end
			pMember.SetPersonalStock(nStock)
			pMember = pMemberItor.NextMember()
		end
		nKinId = pKinItor.NextKinId();
		pKin = KKin.GetKin(nKinId);
	end
end

-- 使用帮会建设资金GS2
function Tong:CostBuildFund_GS2(nTongId, nCostedBuildFund, nMoney, bNeedMsg)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	pTong.SetCostedBuildFund(nCostedBuildFund); -- 记录本周总共消耗的建设资金
	local nLimit = pTong.GetBuildFundLimit();
	local nRest = nLimit - nCostedBuildFund;
	if nRest < 0 then
		nRest = 0;
	end
	
	if bNeedMsg >= 1 then
		KTong.Msg2Tong(nTongId, string.format("使用了<color=green>%d<color>帮会建设资金， 本周使用建设资金额度剩余<color=green>%d。", 
			nMoney, nRest));
	end
end


-- 设置帮会建设资金使用上限
function Tong:SetBuildFundLimit_GS1(nTongId, nKinId, nMemberId, nMoneyLimit)
	if (not nTongId or not nKinId or not nMemberId or not nMoneyLimit or
		0 == Lib:IsInteger(nTongId) or 0 == Lib:IsInteger(nKinId) or
		0 == Lib:IsInteger(nMemberId) or 0 == Lib:IsInteger(nMoneyLimit)
		or nMoneyLimit < 0 or nMoneyLimit > self.MAX_BUILD_FUND) then
			return 0;
	end
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end

	if Tong:CheckPresidentRight(nTongId, nKinId, nMemberId) ~= 1 then
		me.Msg("你不是首领，不能设置建设资金使用上限");
		return 0;
	end
	
	return GCExcute{"Tong:SetBuildFundLimit_GC", nTongId, nKinId, nMemberId, nMoneyLimit};
end
RegC2SFun("SetBuildFundLimit", Tong.SetBuildFundLimit_GS1)


-- 设置帮会建设资金上限GS2
function Tong:SetBuildFundLimit_GS2(nTongId, nMoneyLimit)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	
	pTong.SetBuildFundLimit(nMoneyLimit);
	
	KTong.Msg2Tong(nTongId, string.format("帮会的建设资金使用上限设置为<color=green>%d<color>。", nMoneyLimit));
end

-- 玩家登陆资金增加  TODO: 临时转换代码 将来要删除的 zhengyuhua
function Tong:ChangingStockOnLogin()
	local nOffer = me.nTongOffer
	if nOffer <= 0 then
		return 0;
	end
	me.AddTongOffer(-nOffer);
	local nKinId, nMemberId = me.GetKinMember();
	GCExcute{"Tong:AddBuildFund_GC", me.dwTongId, nKinId, nMemberId, nOffer*me.GetProductivity(), 1, 0};
end
PlayerEvent:RegisterOnLoginEvent(Tong.ChangingStockOnLogin, Tong)

-- 增加帮会建设资金和帮主、族长、副族长、个人的股份 
function Tong:AddStockBaseCount_GS1(nPlayerId, nStockBaseCount, nPersonalRate, nTongRate, nCaptainRate, nAssistantRate, nMasterRate, nType)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer or not nStockBaseCount or nStockBaseCount <= 0 then 
		return;
	end
	
	if not nPersonalRate or nPersonalRate < 0 then nPersonalRate = 0 end
	if not nTongRate or nTongRate < 0 then nTongRate = 0 end
	if not nCaptainRate or nCaptainRate < 0 then nCaptainRate = 0 end
	if not nAssistantRate or nAssistantRate < 0 then nAssistantRate = 0 end
	if not nMasterRate or nMasterRate < 0 then nMasterRate = 0 end

	local nKinId, nMemberId = pPlayer.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if Kin:HaveFigure(nKinId, nMemberId, Kin.FIGURE_REGULAR) ~= 1 then
		return 0;
	end
	if pKin then 	
		local nCaptainId = pKin.GetCaptain();	-- 族长ID
		local nAssistantId = pKin.GetAssistant(); -- 副族长ID
		local nCaptainMoney = math.floor(nStockBaseCount * pPlayer.GetProductivity() * nCaptainRate);	
		local nAssistantMoney = math.floor(nStockBaseCount * pPlayer.GetProductivity() * nAssistantRate);
		local nPersonalMoney = math.floor(nStockBaseCount * pPlayer.GetProductivity() * nPersonalRate);
		local nTongMoney = math.floor(nStockBaseCount * pPlayer.GetProductivity() * nTongRate);	
		if nCaptainMoney > 0 then
			GCExcute{"Tong:AddBuildFund_GC", pPlayer.dwTongId, nKinId, nCaptainId, nCaptainMoney, 1, 0, 0};
		end
		if nAssistantMoney > 0 then
			GCExcute{"Tong:AddBuildFund_GC", pPlayer.dwTongId, nKinId, nAssistantId, nAssistantMoney, 1, 0, 0};
		end
		if nPersonalMoney > 0 then
			GCExcute{"Tong:AddBuildFund_GC", pPlayer.dwTongId, nKinId, nMemberId, nPersonalMoney, 1, 0, 1};
		end
		if nTongMoney > 0 then
			GCExcute{"Tong:AddGreatBonus_GC", pPlayer.dwTongId, nTongMoney, nPlayerId};
--			GCExcute{"Tong:AddBuildFund_GC", pPlayer.dwTongId, nKinId, nMemberId, nTongMoney, 0, 0, 0};
		end
		
		local nMasterId = Tong:GetMasterId(pPlayer.dwTongId); -- 帮主ID
		if nMasterId ~= 0 then
			local nMasterMoney = math.floor(nStockBaseCount * pPlayer.GetProductivity() * nMasterRate);
			local pMaster = KPlayer.GetPlayerObjById(nMasterId);
			if not pMaster then 
				return;
			end
			local nMasterKinId, nMasterMemberId = pMaster.GetKinMember();
			if nMasterMoney > 0 then
				GCExcute{"Tong:AddBuildFund_GC", pPlayer.dwTongId, nMasterKinId, nMasterMemberId, nMasterMoney, 1, 0, 0};
			end
		end
	end
end

function Tong:UpDateOfficialMaintain_GS2(nTongId, nTongOfficialLevel, tbResult, nDataVer)	
	local pTong = KTong.GetTong(nTongId);
	if pTong then
		pTong.SetTongFigureDataVer(nDataVer);
		pTong.SetPreOfficialLevel(nTongOfficialLevel);
		for i = 1, Tong.MAX_TONG_OFFICIAL_NUM do
			if tbResult[i] then
				local nOfficialKinId = tbResult[i].nKinId;
				local nOfficialMemberId = tbResult[i].nMemberId;
				pTong.SetOfficialKin(i, nOfficialKinId);
				pTong.SetOfficialMember(i, nOfficialMemberId);	
			end
		end
	end
end
	
-- 申请帮会官衔晋级
function Tong:IncreaseOfficialLevel_GS2(nTongId, nLevel, nIncreaseNo, nDataVer)
	local pTong = KTong.GetTong(nTongId);
	if pTong and nLevel then
		-- 设置帮会官衔水平
		pTong.SetIncreaseOfficialNo(nIncreaseNo);
		pTong.SetOfficialMaxLevel(nLevel);
		pTong.SetOfficialLevel(nLevel);
		pTong.SetTongFigureDataVer(nDataVer);
		KTong.Msg2Tong(nTongId, "帮会官衔晋级为<color=green>"..nLevel.."级<color>。按F7打开帮会面板，可以在帮会信息官衔分页查下周各官衔的维护费用。");
	end
end
	
-- 选择帮会官衔水平
function Tong:ChoseOfficialLevel_GS2(nTongId, nLevel, nDataVer)
	local pTong = KTong.GetTong(nTongId);
	if pTong and nLevel then
		-- 设置帮会官衔水平
		pTong.SetOfficialLevel(nLevel);
		pTong.SetTongFigureDataVer(nDataVer);
		KTong.Msg2Tong(nTongId, "首领已将下周帮会官衔等级设为<color=green>"..nLevel.."级<color>。按F7打开帮会面板，可以在帮会信息官衔分页查下周各官衔的维护费用。");
	end
end

-- 个人官衔维护成功
function Tong:OfficialMaintain_GS2(nTongId, nKinId, nMemberId, nPlayerId, 
								   nPersonalStock, nTotalStock, nMaintainNo, nOfficialLevel, nDataVer)	
								   
	KGCPlayer.OptSetTask(nPlayerId, KGCPlayer.TSK_TONGSTOCK, nPersonalStock);
	KGCPlayer.OptSetTask(nPlayerId, KGCPlayer.TSK_MAINTAIN_OFFICIAL_NO, nMaintainNo);  --记录维护流水号
	KGCPlayer.OptSetTask(nPlayerId, KGCPlayer.TSK_OFFICIAL_LEVEL, nOfficialLevel);
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		Tong:AddOfficialTitle(nPlayerId, nOfficialLevel);
		pPlayer.Msg("官衔维护成功,您已经重新获得了官衔。");
	end

	local pKin = KKin.GetKin(nKinId);
	if pKin then
		local pMember = pKin.GetMember(nMemberId);
		if pMember then
			pMember.SetPersonalStock(nPersonalStock);
		end
	end
	
	-- 更新版本号
	local pTong = KTong.GetTong(nTongId);
	if pTong then
		pTong.SetTongFigureDataVer(nDataVer);
		pTong.SetTotalStock(nTotalStock);
	end
end	

-- 个人官衔维护失败
function Tong:OfficialMaintainFail_GS2(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbTitles = pPlayer.GetAllTitle();
	if tbTitles then
		for _, pTitle in ipairs(tbTitles) do
			if pTitle.byTitleGenre == Tong.OFFICIAL_TITLE_GENRE then
				pPlayer.RemoveTitle(pTitle.byTitleGenre,
								    pTitle.byTitleDetailType, 
								    pTitle.byTitleLevel, 0)
			end
		end
	end
	return 1;
end 

-- 根据领土数量调整帮会官衔水平
function Tong:AdjustOfficialMaxLevel_GS2(nTongId, nLevel, nChoseLevel, nDataVer)
	local pTong = KTong.GetTong(nTongId);
	if pTong then
		pTong.SetOfficialMaxLevel(nLevel);
		pTong.SetOfficialLevel(nChoseLevel);
		-- 更新版本号
		pTong.SetTongFigureDataVer(nDataVer);
	end
end

-- 给予相应的官衔
function Tong:AddOfficialTitle(nPlayerId, nPersonalLevel)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer or not nPersonalLevel then
		return 0;
	end
	
	local tbTitles = pPlayer.GetAllTitle();
	if tbTitles then
		for _, pTitle in ipairs(tbTitles) do
			if pTitle.byTitleGenre == Tong.OFFICIAL_TITLE_GENRE then
				pPlayer.RemoveTitle(pTitle.byTitleGenre,
								    pTitle.byTitleDetailType, 
								    pTitle.byTitleLevel, 0)
			end
		end
	end
	                                 
	pPlayer.SyncOfficialLevel(nPersonalLevel);
	local nOfficialDetail = Tong:GetPlayerOfficialDetail(nPlayerId);
	pPlayer.AddTitle(Tong.OFFICIAL_TITLE_GENRE, nOfficialDetail, nPersonalLevel, 0, 0);
	
	local nSelfGenre, nSelfDetail, nSelfLevel = pPlayer.GetCurTitle();
	if nSelfGenre == 0 or nSelfGenre == Tong.OFFICIAL_TITLE_GENRE then
		pPlayer.SetCurTitle(Tong.OFFICIAL_TITLE_GENRE , nOfficialDetail, nPersonalLevel, 0);
	end
	return 1;
end

-- 玩家上线给予相应的官衔
function Tong:AddOfficialTitleOnLogin()
	local nOfficialLevel = Tong:GetPlayerOfficialLevel(me.nId);
	if nOfficialLevel and nOfficialLevel > 0 then
		Tong:AddOfficialTitle(me.nId, nOfficialLevel);
	end
end
PlayerEvent:RegisterOnLoginEvent(Tong.AddOfficialTitleOnLogin, Tong)

-- 开始评选优秀成员GS2
function Tong:StartGreatMemberVote_GS2(nTongId, nSucess)
	local pTong = KTong.GetTong(nTongId);
	if pTong then
		Tong:ClearGreatMemberVote(nTongId);
		if nSucess == 1 then
			pTong.SetGreatMemberVoteState(1);
			KTong.Msg2Tong(nTongId, "帮会优秀成员竞选开始");
		else
			KTong.Msg2Tong(nTongId, "上周帮会优秀成员竞选没正常关闭,请重新投票");
		end
		
		return 1;
	end
	return 0;
end

-- 结束评选优秀成员GS2
function Tong:EndGreatMemberVote_GS2(nTongId, nWeekGreatBonus, tbGreatMemberInfo)
	local tbGreatMemberName = {}
	local nGreatMemberCount = 0;
	local pTong = KTong.GetTong(nTongId);

	if pTong then 
		pTong.SetWeekGreatBonus(nWeekGreatBonus);
		pTong.SetGreatMemberVoteState(0);		
		KTong.Msg2Tong(nTongId, "帮会优秀成员竞选结束");
		if tbGreatMemberInfo then
			for i = 1, self.GREAT_MEMBER_COUNT do
				local szPlayerName = "";
				if tbGreatMemberInfo[i] then
					pTong.SetGreatMemberId(i, tbGreatMemberInfo[i][2]);
					pTong.SetGreatKinId(i, tbGreatMemberInfo[i][1]);
					local pKin = KKin.GetKin(tbGreatMemberInfo[i][1]);
					if pKin then
						local pMember = pKin.GetMember(tbGreatMemberInfo[i][2])
						if pMember then
							nGreatMemberCount = nGreatMemberCount + 1;
							szPlayerName = KGCPlayer.GetPlayerName(pMember.GetPlayerId());
						end
					end
				else
					pTong.SetGreatMemberId(i, 0);
					pTong.SetGreatKinId(i, 0);
				end
				table.insert(tbGreatMemberName, szPlayerName);
			end
			if nGreatMemberCount > 0 then
				pTong.AddAffairGreatMember(unpack(tbGreatMemberName));
			end
			return 1;
		end
	end
	return 0;
end

-- 优秀成员投票GS1
function Tong:ElectGreatMember_GS1(nTagetKinId, nTagetMemberId)
	local nTongId = me.dwTongId;
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		me.Msg("Không có bang hội, không thể thao tác")
		return 0;
	end	
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local pSelfKin = KKin.GetKin(nSelfKinId);
	if not pSelfKin then
		return 0;
	end	
	local pSelfMember = pSelfKin.GetMember(nSelfMemberId);
	if not pSelfMember then 
		return 0;
	end

	local nSuccess, nErrCase = Tong:CanElectGreatMember(nTongId, nSelfKinId, nSelfMemberId, nTagetKinId, nTagetMemberId)
	if nSuccess  == 0 then
		if nErrCase == 1 then
			me.Msg("Dữ liệu không chính xác");
		elseif nErrCase == 2 then
			me.Msg("Bầu cử chưa bắt đầu");
		elseif nErrCase == 3 then
			me.Msg("Không thể bỏ phiếu cho Thủ lĩnh.");
--		elseif nErrCase == 4 then
--			me.Msg("你还不是正式成员，还不能投票");
		elseif nErrCase == 5 then
			me.Msg("Bạn đã bỏ phiếu rồi.");
		elseif nErrCase == 6 then
			me.Msg("Người được chọn không phải thành viên chính thức.");
		end
		return 0;
	end
	local nMemberVoteNo = KGblTask.SCGetDbTaskInt(DBTASK_GREAT_MEMBER_VOTE_NO);
	pSelfMember.SetMemberVoteNo(nMemberVoteNo); --	标志已经投票
	
	local pTagetKin = KKin.GetKin(nTagetKinId);
	local pTagetMember = pTagetKin.GetMember(nTagetMemberId);
	local szTagetName = KGCPlayer.GetPlayerName(pTagetMember.GetPlayerId());
	Dbg:WriteLog("ElectGreatMember", "优秀成员投票申请", "投票者："..me.szName, "受票者："..szTagetName, "流水号："..nMemberVoteNo)
	
	return GCExcute{"Tong:ElectGreatMember_GC", nTongId, nSelfKinId, nSelfMemberId, nTagetKinId, nTagetMemberId, nMemberVoteNo};
end
RegC2SFun("ElectGreatMember", Tong.ElectGreatMember_GS1);

-- 优秀成员投票GS2
function Tong:ElectGreatMember_GS2(nSelfPlayerId, nTagetKinId, nTagetMemberId, nVote)	
	local pPlayer = KPlayer.GetPlayerObjById(nSelfPlayerId);
	local pTagetKin = KKin.GetKin(nTagetKinId);
	local pTagetMember = pTagetKin.GetMember(nTagetMemberId);
	local szTagetName = KGCPlayer.GetPlayerName(pTagetMember.GetPlayerId());
	if pPlayer and szTagetName then
		pPlayer.Msg("Đã bỏ phiếu cho <color=yellow>"..szTagetName.."<color>");
	end
	if pTagetMember then
		pTagetMember.SetGreatMemberVote(nVote);
		local szSelfName = KGCPlayer.GetPlayerName(nSelfPlayerId);
		local nMemberVoteNo = KGblTask.SCGetDbTaskInt(DBTASK_GREAT_MEMBER_VOTE_NO);
		Dbg:WriteLog("ElectGreatMember", "优秀成员投票成功", "投票者："..szSelfName,
					 "受票者："..szTagetName, "票数："..nVote, "流水号"..nMemberVoteNo)
	end
--	return KTongGs.TongClientExcute(nTongId, {"Tong:ElectGreatMember_C2", szTagetName, nVote})
end

-- 接受优秀成员奖励GS1
function Tong:ReceiveGreatBonus(nChoose, bConfirm)
	local nTongId = me.dwTongId;
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		Dialog:Say("Ngươi không có bang hội");
		return 0;
	end
	local nWeekBonus = pTong.GetWeekGreatBonus();
	-- 选择&领取奖励
	local tbAwardMode = {0, 20, 40, 60, 80, 100} -- 奖励模式百分比表（以银两占的百分比为基准）
	local tbOpt = {};
	local szMsg = "Những thành viên Ưu tú tuần này gồm:\n";
		
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	local pSelfKin = KKin.GetKin(nSelfKinId);
	local pSelfMember = pSelfKin.GetMember(nSelfMemberId);
	local bIsGreatMember = 0;
	for i = 1, self.GREAT_MEMBER_COUNT do	
		local nGreatKinId = pTong.GetGreatKinId(i);
		local nGreatMemberId = pTong.GetGreatMemberId(i);
		local pGreatKin = KKin.GetKin(nGreatKinId);
		if pGreatKin and pGreatKin.GetBelongTong() == nTongId then	
			local pGreatMember = pGreatKin.GetMember(nGreatMemberId);
			if pGreatMember then	
				local nPlayerId = pGreatMember.GetPlayerId();
				local szTagetName = KGCPlayer.GetPlayerName(nPlayerId);
				if szTagetName then
					szMsg = szMsg.."     <color=green>"..szTagetName.."<color>\n";
				end
				if pTong.GetGreatMemberId(i) == nSelfMemberId and pTong.GetGreatKinId(i) == nSelfKinId then
					bIsGreatMember = 1;
				end
			end
		end		
	end
	
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_GREAT_MEMBER_VOTE_NO);

	if pSelfMember.GetReceiveGreatBonusNo() == nCurNo then
		szMsg = szMsg.."Tuần này ngươi đã nhận thưởng rồi!";
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end

	if bIsGreatMember ~= 1 then
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	if not nChoose and nWeekBonus > 0 then
		local szSay = "";
		-- 选择奖励方式
		for nIdex = 1, #tbAwardMode do
			local nItemLevel, nItemNum, nMoney = Domain:CalculateTongAward(nWeekBonus, tbAwardMode[nIdex]);		
			-- 取整
			if (nItemNum == nil or nItemLevel == nil) then 
				szSay = string.format("Phần thưởng %d:<color=green>%d bạc khóa<color>", nIdex, nMoney);	
			elseif (nMoney == nil) then 
				szSay = string.format("Phần thưởng %d:<color=green>%d huyền tinh %d<color>", nIdex, nItemNum, nItemLevel);
			else
				szSay = string.format("Phần thưởng %d:<color=green>%d huyền tinh %d, %d bạc khóa<color>", nIdex, nItemNum, nItemLevel, nMoney);
			end
			table.insert(tbOpt, { szSay, self.ReceiveGreatBonus, self, nIdex, 1 })
		end
		table.insert(tbOpt, {"Kết thúc đối thoại"});
		szMsg = szMsg.."<color=yellow>Xin chúc mừng ngươi nhận nhận tư cách Ưu tú bang.<color>\nHãy lựa chọn phần thưởng cho mình:";
		Dialog:Say(szMsg, tbOpt);		
		return 0;
		
	elseif nWeekBonus <= 0 then
		Dialog:Say("Quỹ thưởng tuần này là <color=yellow>0<color>");
		return 0;
	end
	
	if bConfirm == 1 then
		local nBonus = pTong.GetGreatBonus() - nWeekBonus;
		if nBonus < 0 then
			Dialog:Say("Quỹ thưởng bang hội không đủ.");
			return 0;
		end
		local nLevel, nItemNum, nResMoney = Domain:CalculateTongAward(nWeekBonus, tbAwardMode[nChoose]);
		if me.GetBindMoney() + nResMoney > me.GetMaxCarryMoney() then
			Dialog:Say("Bang trong người đã đặt mức tối đa.");
			return 0;
		end
		if nItemNum and nLevel and nLevel > 0 then
			if (nItemNum > me.CountFreeBagCell()) then
				Dialog:Say("Hành trang không đủ chỗ trống.");
				return 0;
			end
		end		
				
		GCExcute{"Tong:ReceiveGreatBonus_GC", nTongId, nSelfKinId, nSelfMemberId, nWeekBonus, tbAwardMode[nChoose]}
		return 1;
	end
end

-- 接受优秀成员奖励GS2
function Tong:ReceiveGreatBonus_GS2(nTongId, nSelfKinId, nSelfMemberId, nBonus, nMoney, nAwardMode)
	local pTong = KTong.GetTong(nTongId);
	if not pTong or not nBonus or nBonus < 0 then
		return 0;
	end
	
	pTong.SetGreatBonus(nBonus);
	
	local pSelfKin = KKin.GetKin(nSelfKinId);
	local pSelfMember = pSelfKin.GetMember(nSelfMemberId);
	if not pSelfKin or not pSelfMember then
		return 0;
	end

	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_GREAT_MEMBER_VOTE_NO);
	pSelfMember.SetReceiveGreatBonusNo(nCurNo); 
	
	local nPlayerId = pSelfMember.GetPlayerId();
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	
	if self:ReceiveAward(nMoney, nPlayerId, nAwardMode, "Tong") == 1 then
		if pPlayer then
  			pPlayer.Msg("Nhận thưởng thành công.");
  			KTong.Msg2Tong(nTongId, "<color=green>"..pPlayer.szName.."<color>đã nhận phần thưởng Ưu tú Bang hội");
  		end
  		return 1;
  	end
  	if pPlayer then
		pPlayer.Msg("Nhận thưởng thất bại.");
	end
	return 0;
end

-- 给予玩家nPersonalAwardValue价值量的nMoneyPercent钱和（1 - nMoneyPercent）的玄晶
function Tong:ReceiveAward(nPersonalAwardValue, nPlayerId, nMoneyPercent, szLogName)
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0;
	end
	local cTong = KTong.GetTong(cPlayer.dwTongId);
	if not cTong then
		return 0;
	end

	local nMoney = nPersonalAwardValue * nMoneyPercent / 100;
	local nValue = nPersonalAwardValue * (100 - nMoneyPercent) / 100;
	local tbItem = {}; 
	local nLevel = 0; 
	local nResValue = 0;
	
	if (nValue > 0) then
		tbItem, nLevel, nResValue = Item:ValueToItemAndMoney(nValue);
			if tbItem and nLevel and nLevel > 0 then
				if (tbItem[nLevel] > cPlayer.CountFreeBagCell()) then
				cPlayer.Msg("Hành trang không đủ ");
					return 0;
				end
	
				for nNum = tbItem[nLevel], 1, -1 do			
					cPlayer.AddItem(18, 1, 114, nLevel);
				end
				Item:CheckXJRecord(Item.emITEM_XJRECORD_EVENT, "领土帮会奖励", {18, 1, 114, nLevel, 1, tbItem[nLevel]});
			end
	end
	if not nResValue then
		nResValue = 0;
	end
	nMoney = nResValue + nMoney;
	-- 取整
	nMoney = math.floor(nMoney);
	cPlayer.AddBindMoney(nMoney, Player.emKBINDMONEY_ADD_TONG_FUN);
	local nItemSum = tbItem[nLevel] or 0;
	cPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("玩家获得帮会奖励价值%s，物品数量:%s\t物品等级:%s\t获得价值:%s\t获得绑定银两:%s",nPersonalAwardValue,nItemSum,nLevel,nResValue,nMoney));	
	Dbg:WriteLog(szLogName or "DomainBattle", "玩家获得帮会奖励价值", cPlayer.szAccount, cPlayer.szName, nPersonalAwardValue);
	KStatLog.ModifyAdd("bindjxb", "[产出]领土战", "总量", nMoney);
	return 1;
end

-- 设置帮会奖励基金比例
function Tong:AdjustGreatBonusPercent(nPercent, bConfirm)
	local nTongId = me.dwTongId;
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		Dialog:Say("你还没有帮会");
		return 0;
	end
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if Tong:CheckPresidentRight(nTongId, nSelfKinId, nSelfMemberId) ~= 1 then
		Dialog:Say("你不是首领，没有权限设置帮会的奖励基金比列");
		return 0;
	end
	local tbOpt = {};
	local szMsg = "";
	local nBonus = pTong.GetGreatBonus();
	local nGreatBonusPercent =  pTong.GetGreatBonusPercent();
	local tbAwardMode = {50, 75, 100}; -- 奖励模式百分比表（以银两占的百分比为基准）
	if not nPercent then
		local szSay = "";
		-- 选择奖励方式
		for nIdex = 1, #tbAwardMode do		
			szSay = string.format("百分之<color=green>%d<color>", tbAwardMode[nIdex]);		
			table.insert(tbOpt, { szSay, self.AdjustGreatBonusPercent, self, tbAwardMode[nIdex]})
		end
		table.insert(tbOpt, {"Kết thúc đối thoại"});
		szMsg = "当前的奖励基金总值为：<color=green>"..nBonus.."<color> \n奖励比例为：<color=green>"..nGreatBonusPercent.."<color> \n您可以选择领取如下中的一种比例为本周发放的奖励：";
		
		Dialog:Say(szMsg, tbOpt);		
		return 0;
	end
	
	if nPercent and not bConfirm then
		szMsg = "您确定将奖励比例设为<color=green>"..nPercent.."<color>？新设置将在下周一生效。";
		table.insert(tbOpt, { "Xác nhận", self.AdjustGreatBonusPercent, self, nPercent, 1 });
		table.insert(tbOpt, {"Kết thúc đối thoại"});
		Dialog:Say(szMsg, tbOpt);
		return 0;	
	end
	
	if bConfirm == 1 then
		local nWeekBonus = nBonus * nPercent / 100;
		szMsg = "您设置本周帮会奖励基金为<color=green>"..nWeekBonus.."<color> \n";
		return GCExcute{"Tong:AdjustGreatBonusPercent_GC", nTongId,  nSelfKinId, nSelfMemberId, nPercent}
	end
	
	Dialog:Say(szMsg, tbOpt);		
	return 0;
end

-- 设置帮会奖励基金比例GS2
function Tong:AdjustGreatBonusPercent_GS2(nTongId, nPercent, nDataVer)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	pTong.SetGreatBonusPercent(nPercent);
	pTong.SetTongDataVer(nDataVer);
	KTong.Msg2Tong(nTongId, "设置帮会奖励基金比例为<color=yellow>"..nPercent.."%<color>");	
end

-- 增加奖励基金GS1
function Tong:AddGreatBonus_GS(nTongId, nMoney, nPlayerId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	if nMoney + pTong.GetGreatBonus() > 2000000000 then
		return 0;
	end
	return GCExcute{"Tong:AddGreatBonus_GC", nTongId, nMoney, nPlayerId}
end

-- 增加奖励基金GS2
function Tong:AddGreatBonus_GS2(nTongId, nBonus, nPlayerId, nMoney)
	local pTong = KTong.GetTong(nTongId);
	if not pTong or nBonus < 0 then
		return 0;
	end
	
	pTong.SetGreatBonus(nBonus);
	
	if nPlayerId then
		local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if cPlayer and nMoney and nMoney > 0 then
			cPlayer.Msg("Quỹ thưởng Bang hội tăng <color=yellow>"..nMoney.."<color>");
			return 0;
		end
	end
end

-- 加入联盟_GS2
function Tong:JoinUnion_GS2(nTongId, szUnionName, nUnionId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	pTong.SetBelongUnion(nUnionId);
	local nDataVer = pTong.GetTongDataVer(nDataVer);
	pTong.SetTongDataVer(nDataVer + 1);
	KTongGs.TongAttachUnion(nTongId, nUnionId);
	KTong.Msg2Tong(nTongId, string.format("本帮加入了联盟[%s]", szUnionName));
end

-- 离开联盟_GS2
function Tong:LeaveUnion_GS2(nTongId, szUnionName, nLeaveTime, nMethod)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return 0;
	end

	--清空帮会相关数据
	pTong.SetBelongUnion(0);
	KTongGs.TongDetachUnion(nTongId);
	local szMsg = "";	
--	if nMethod ~= 1 then
--		szMsg = string.format("[%s]帮会离开联盟[%s]", pTong.GetName(), szUnionName);
--	else
--		szMsg = string.format("[%s]帮会被联盟[%s]开除了", pTong.GetName(), szUnionName);
--	end
--	KTong.Msg2Tong(nTongId, szMsg);	
	local nDataVer = pTong.GetTongDataVer(nDataVer);
	pTong.SetTongDataVer(nDataVer + 1);
	pTong.SetLeaveUnionTime(nLeaveTime);
	return 1;
end

-- 帮会公告_GS1
function Tong:TongAnnounce_GS1(nTongId, nTimes, nDistance, szMsg)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		me.Msg("你没有帮会，不能发送帮会公告。");
		return 0;
	end
	--是否包含敏感字串
	if IsNamePass(szMsg) ~= 1 then
		me.Msg("对不起，您输入的帮会公告包含敏感字词，请重新设定");
		return 0;
	end
	
	local nKinId, nMemberId = me.GetKinMember();

	if Tong:CheckSelfRight(nTongId, nKinId, nMemberId, 0) ~= 1 then
		me.Msg("你没有权限发送公告。");
		return 0;
	end
	if nTimes < self.TONGANNOUNCE_MIN_TIMES or nTimes > self.TONGANNOUNCE_MAX_TIMES then
	 	me.Msg("你发送帮会公告的次数超过规定次数。");
		return 0;
	end
	if nDistance < self.TONGANNOUNCE_MIN_DISTANCE or nDistance > self.TONGANNOUNCE_MAX_DISTANCE then
	   	me.Msg("你发送帮会公告的次数超过规定间隔。");
		return 0;
	end
	if pTong.GetAnnounceTimes() > 0 then
		me.Msg("你之前的帮会公告正在发送，同一时间只能发送一条帮会公告。");
		return 0;
	end
	
	GCExcute{"Tong:RegisterTongAnnounce_GC", nTongId, nKinId, nMemberId, nTimes, nDistance, szMsg};
end
RegC2SFun("TongAnnounce", Tong.TongAnnounce_GS1);

-- 帮会公告_GS2
function Tong:TongAnnounce_GS2(nTongId, szMsg, nTimes)
	local pTong = KTong.GetTong(nTongId);
	if pTong then
		pTong.SetAnnounceTimes(nTimes);
		if szMsg ~= "" then
			return KTong.Msg2Tong(nTongId, "[帮会公告]"..szMsg);
		end	
	end
end

--往家族转存资金
function Tong:ApplyStorageFundToKin_GS1(nMoney, nTargetKinId)
	if EventManager.IVER_bOpenkinMoney ~= 1 then
		Dialog:SendBlackBoardMsg(me, "该功能暂未开放！");
		return;
	end
	if (not nMoney or 0 == Lib:IsInteger(nMoney) or nMoney <= 0 or nMoney > 2000000000) then
		return 0;
	end
	local nTongId = me.dwTongId;
	local nSelfKinId, nSelfMemberId = me.GetKinMember();
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_FUN) ~= 1 then
		Dialog:SendInfoBoardMsg(me, "您无权动用帮会资金！");
		me.Msg("您无权动用帮会资金！");
		return 0;
	end
	
	if (me.IsInPrison() == 1) then
		me.Msg("您在坐牢期间不能动用帮会资金。");
		return 0;
	end
	
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	local tbDataTakeFund = self:GetExclusiveEvent(nTongId, self.REQUEST_TAKE_FUND);
	if tbDataTakeFund.nApplyEvent and tbDataTakeFund.nApplyEvent == 1 then		-- 已经有申请取钱 
		Dialog:SendInfoBoardMsg(me, "已经有取出帮会资金的申请！");
		me.Msg("已经有取出帮会资金的申请！不能再申请！");
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_STORAGE_FUND_TO_KIN);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then		-- 已经有申请转存家族 
		Dialog:SendInfoBoardMsg(me, "已经有帮会资金转存家族的申请！");
		me.Msg("已经有帮会资金转存家族的申请！不能再申请！");
		return 0;
	end
	if not tbData.tbKinLastTimeList then
		tbData.tbKinLastTimeList = {};
	end
	if tbData.tbKinLastTimeList[nTargetKinId] and GetTime() - tbData.tbKinLastTimeList[nTargetKinId] < self.STORAGEFUND_TO_KIN_TIME then
		Dialog:SendInfoBoardMsg(me, "对同一家族转存至少需要间隔6小时！");
		me.Msg("对同一家族转存至少需要间隔6小时！");
		return 0;
	end
	local nCurFund = cTong.GetMoneyFund();
	if (nMoney > nCurFund) then
		Dialog:SendInfoBoardMsg(me, "转存资金不能大于帮会资金，请您重新设置金额！");
		me.Msg("转存资金不能大于帮会资金，请您重新设置金额！");
		return 0;
	end
	local cTargetKin = KKin.GetKin(nTargetKinId)
	if not cTargetKin then
		Dialog:SendInfoBoardMsg(me, "资金转存的目标家族不存在！");
		me.Msg("资金转存的目标家族不存在！");
		return 0;
	end
	--验证是否是帮会里的家族
	if cTargetKin.GetBelongTong() ~= nTongId then
		Dialog:SendInfoBoardMsg(me, "资金转存的目标家族不属于帮会！");
		me.Msg("资金转存的目标家族不属于帮会！");
		return 0;
	end
	--验证是否超过家族资金上限
	if nMoney + cTargetKin.GetMoneyFund() > Kin.MAX_KIN_FUND then
		Dialog:SendInfoBoardMsg(me, "转存资金将会使目标家族的资金超过上限！");
		me.Msg("转存资金将会使目标家族的资金超过上限！");
		return 0;
	end
	return GCExcute{"Tong:ApplyStorageFundToKin_GC", nTongId, nSelfKinId, nSelfMemberId, me.nId, nMoney, nTargetKinId};
end
RegC2SFun("StorageFundToKin", Tong.ApplyStorageFundToKin_GS1);

-- 帮会资金转存家族的申请(需要申请的回调)
function Tong:ApplyStorageFundToKin_GS2(nTongId, nKinId, nPlayerId, nMoney, nTargetKinId)
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_STORAGE_FUND_TO_KIN)
	tbData.nApplyEvent = 1;
	if not tbData.ApplyRecord then
		tbData.ApplyRecord = {};
	end
	tbData.ApplyRecord.nKinId = nKinId;
	tbData.ApplyRecord.nPow = self.POW_FUN;
	tbData.ApplyRecord.nAmount = nMoney;
	tbData.ApplyRecord.nTargetKinId = nTargetKinId;
	tbData.ApplyRecord.nTimerId = Timer:Register(
		self.TAKEFUND_APPLY_LAST,
		self.CancelExclusiveEvent_GS,
		self,
		nTongId,
		nPlayerId,
		self.REQUEST_STORAGE_FUND_TO_KIN
	);
	local cApplyPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if cApplyPlayer then
		cApplyPlayer.CallClientScript({"Tong:NotifApplyStorageFund_C2"});
	end
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	local cTargetKin = KKin.GetKin(nTargetKinId);
	if not cTargetKin then
		return 0;
	end
	local szTargetKinName = cTargetKin.GetName();
	-- 寻找拥有资金权限的人员通知有申请
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	local pKinIt = cTong.GetKinItor();
	local nCurKinId = pKinIt.GetCurKinId();
	while(nCurKinId ~= 0) do
		local cKin = KKin.GetKin(nCurKinId);
		if cKin then
			local nCaptainId = cKin.GetCaptain();
			local nRetCode, cMember = self:HaveFigure(nTongId, nCurKinId, nCaptainId, self.POW_FUN);
			if nRetCode == 1 then
				local nId = cMember.GetPlayerId();
				local pPlayer = KPlayer.GetPlayerObjById(nId);
				if nPlayerId ~= nId and pPlayer then
					pPlayer.CallClientScript({"Tong:GetApply_C2", szTargetKinName, self.REQUEST_STORAGE_FUND_TO_KIN, 0, nMoney})
				end
			end
		end
		nCurKinId = pKinIt.NextKinId();
	end
	KTongGs.TongClientExcute(nTongId, {"Tong:SendApply_C2", self.REQUEST_STORAGE_FUND_TO_KIN, szPlayerName, nMoney, 0, szTargetKinName});
end

function Tong:StorageFundToKin_GS2(nTongId, nPlayerId, nTongDataVer, nKinDataVer, nMoney, nCurTongFund, nCurKinFund, nTargetKinId)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	local cTargetKin = KKin.GetKin(nTargetKinId);
	if not cTargetKin then 
		return 0;
	end
	cTong.SetMoneyFund(nCurTongFund);
	cTong.SetTongDataVer(nTongDataVer);
	cTargetKin.SetMoneyFund(nCurKinFund);
	cTargetKin.SetKinDataVer(nKinDataVer);
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	local szTongName = cTong.GetName();
	local szTargetKinName = cTargetKin.GetName();
	if nMoney >= self.STORAGE_FUND_TO_KIN_APPLY then
		cTong.AddAffairStorageFundToKin(szPlayerName, szTargetKinName, tostring(nMoney));
		cTargetKin.AddAffairGetFundFromTong(szTongName, tostring(nMoney));
	end
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_STORAGE_FUND_TO_KIN);
	if not tbData.tbKinLastTimeList then
		tbData.tbKinLastTimeList = {};
	end
	tbData.tbKinLastTimeList[nTargetKinId] = GetTime();
	if (tbData.nApplyEvent == 1) then
		if tbData.ApplyRecord and tbData.ApplyRecord.nTimerId then
			Timer:Close(tbData.ApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nTongId, self.REQUEST_STORAGE_FUND_TO_KIN);
	end
	KTongGs.TongClientExcute(nTongId, {"Tong:StorageFundToKin_C2", szPlayerName, szTargetKinName, nMoney});
end

function Tong:KinFundOverFlow(nPlayerId)
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0;
	end
	Dialog:SendInfoBoardMsg(cPlayer, "转存失败！您转存的帮会资金会使目标家族资金超过上限！");
	cPlayer.Msg("转存失败！您转存的帮会资金会使目标家族资金超过上限！");
end

--操作失败解锁
function Tong:FailureToUnLock(nPlayerId)
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not cPlayer then
		return 0;
	end
	-- 还原锁定状态
	cPlayer.AddWaitGetItemNum(-1);
	cPlayer.Msg("操作失败！");
end