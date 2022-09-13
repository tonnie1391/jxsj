-------------------------------------------------------------------
--File: unionnpc.lua
--Author: fenghewen
--Date: 2008-6-10 
--Describe: 联盟相关npc对话逻辑
-------------------------------------------------------------------
if not Union then --调试需要
	Union = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
end

-- 创建联盟
function Union:DlgCreateUnion(szUnionName, bConfirm)
	
	if GetTime() < KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME) + 7 * 24 * 60 * 60 then
		Dialog:Say("合服7天内不能参与创建联盟。")
		return 0
	end
	
	if me.IsCaptain() ~= 1 then
		Dialog:Say("你不是队长，必须由队长来创建联盟。")
		return 0;
	end	
	
	local nTeamId = me.nTeamId
	local anPlayerId, nPlayerNum = KTeam.GetTeamMemberList(nTeamId)
	if not anPlayerId or not nPlayerNum or nPlayerNum < 1 then 
		Dialog:Say("取队伍数据出错");
		return 0;
	end
	if nPlayerNum < 2 then
		Dialog:Say("必须有两个或两个以上没有被罢免的帮会帮主组队，才能到我这里报名创建联盟。")
		return 0;
	end
	if nPlayerNum > self.MAX_TONG_NUM then 
		Dialog:Say("联盟成员帮会不能超过五个。")
		return 0;
	end
		
	-- 检测队员资格
	local tbPlayerInfo = {};
	for _, nPlayerId in ipairs(anPlayerId) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		--判断队员是否在周围
		if pPlayer and pPlayer.nMapId == me.nMapId then
			local nTeamKinId, nTeamMemberId = pPlayer.GetKinMember();
			table.insert(tbPlayerInfo, {dwTongId = pPlayer.dwTongId, nKinId = nTeamKinId, nMemberId = nTeamMemberId});
		else
			Dialog:Say("队伍里所有人必须一同前来，才能创建联盟！");
			return 0;
		end
	end
	
	-- 检查创建联盟的帮会是否符合要求
	local nRet, szMsg = self:CheckTong(tbPlayerInfo);
	if nRet ~= 1 then		
		Dialog:Say(szMsg);
		return 0;
	end
	
	if Domain:GetBattleState() == Domain.PRE_BATTLE_STATE or Domain:GetBattleState() == Domain.BATTLE_STATE then
		Dialog:Say("宣战期和征战期不能创建联盟");
		return 0;
	end
		
	-- 确定联盟名
	if not szUnionName or szUnionName == "" then
		Dialog:AskString("请输入联盟名：", 12, self.DlgCreateUnion, self);
		return 0;
	end
	
	--创建确认
	if bConfirm ~= 1 then
		Dialog:Say("创建联盟，你确定要创建吗？", 
			{{"是的，我要创建", self.DlgCreateUnion, self, szUnionName, 1}, {"Hãy để ta suy nghĩ lại"}})
		return 0
	end

 	return self:ApplyCreateUnion_GS1(tbPlayerInfo, szUnionName, me.nId);
end

-- 加入联盟
function Union:DlgTongJoin(bConfirm)
	if Domain:GetBattleState() == Domain.PRE_BATTLE_STATE or Domain:GetBattleState() == Domain.BATTLE_STATE then
		Dialog:Say("宣战期和征战期不能加入联盟");
		return 0;
	end
	
	if me.IsCaptain() ~= 1 then
		Dialog:Say("你不是队长，必须由队长来加入！");
		return 0;
	end	
	
	local pMyUnion = KUnion.GetUnion(me.dwUnionId);
	if not pMyUnion or Union:GetUnionMasterId(me.dwUnionId) ~= me.nId then							
		Dialog:Say("你不是盟主");
		return 0;
	end
	
	local nMyKinId, nMyMemberId = me.GetKinMember();
	if Tong:CheckSelfRight(me.dwTongId, nMyKinId, nMyMemberId, Tong.POW_MASTER) ~= 1 then
		me.Msg("你不是帮主(或权限被冻结)，不能把队友加入联盟。");
		return 0;
	end
	
	if pMyUnion.GetTongCount() >= self.MAX_TONG_NUM then 
		Dialog:Say("你的联盟帮会成员已满");
		return 0;		
	end		
	
	local nTeamId = me.nTeamId;
	local anPlayerId, nPlayerNum = KTeam.GetTeamMemberList(nTeamId);
	if not anPlayerId or not nPlayerNum or nPlayerNum < 2 then
		Dialog:Say("请组上想加入联盟的帮会帮主。（每次只能加入一个帮会）");
		return 0;
	end
	if nPlayerNum >= 3 then
		Dialog:Say("每次只能有一个帮会加入联盟，请让多余的队员退出队伍。");
		return 0;
	end

	--判断是否有盟主和要加入的联盟帮会成员是否满员
	local nJoinTongId = 0;
	local nJoinKinId = 0;
	local nJoinMemberId = 0;
	local nTime = GetTime();
	for _, nPlayerId in ipairs(anPlayerId) do
		local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		--判断队员是否在周围
		if not cPlayer or cPlayer.nMapId ~= me.nMapId then
			Dialog:Say("队伍里所有人必须一同前来，才能加入联盟！");
			return 0;
		end
			
		
		if cPlayer.nId ~= me.nId then
			if cPlayer.dwTongId then
				local pCurTong = KTong.GetTong(cPlayer.dwTongId);
				if pCurTong then
					if nTime - pCurTong.GetLeaveUnionTime() < Tong.TONG_LEVE_UNION_LAST then
						Dialog:Say("对方帮会退出联盟没满24小时，不能再加入联盟。")
						return 0;
					end
					local nBelongUnionId = pCurTong.GetBelongUnion();
					if nBelongUnionId and nBelongUnionId ~= 0 then
						Dialog:Say("对方帮会已经有所属联盟。");
						return 0;
					end
					-- 占有领土的数量不能>1
					if pCurTong.GetDomainCount() > self.MAX_TONG_DOMAIN_NUM then
						Dialog:Say("对方帮会领土数不能超过"..self.MAX_TONG_DOMAIN_NUM.."块。");
						return 0;
					end
					local nKinId, nMemberId = cPlayer.GetKinMember();
					if Tong:CheckSelfRight(cPlayer.dwTongId, nKinId, nMemberId, Tong.POW_MASTER) ~= 1 then
						me.Msg("对方不是帮主(或权限被冻结)，不能加入联盟。");
						return 0;
					end
					nJoinTongId = cPlayer.dwTongId;
					nJoinKinId = nKinId;
					nJoinMemberId = nMemberId;
				else
					Dialog:Say("对方不是帮主(或权限被冻结)，不能加入联盟。");
					return 0;
				end
			end
		end
	end
	
	if bConfirm ~= 1 then
		Dialog:Say("你确定要把队员的帮会加入联盟吗？", 
			{{"是的，把队员的帮会加入联盟", self.DlgTongJoin, self, 1}, {"Hãy để ta suy nghĩ lại"}})
		return 0;
	end

	return GCExcute{"Union:ApplyTongJoin_GC", me.dwUnionId, nJoinTongId, nJoinKinId, nJoinMemberId, me.dwTongId, nMyKinId, nMyMemberId};
end

-- 退出联盟
function Union:DlgTongLeave(bConfirm)
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		Dialog:Say("你没有帮会，不能退出联盟。");
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	if Tong:CheckSelfRight(me.dwTongId, nKinId, nMemberId, Tong.POW_MASTER) ~= 1 then
		me.Msg("你不是帮主(或权限被冻结)，不能决定退出联盟。");
		return 0;
	end
	local nUnionId = pTong.GetBelongUnion();
	if  not nUnionId or nUnionId == 0 then
		Dialog:Say("你的帮会没有联盟。不需要退出");
		return 0;
	end
	if Domain:GetBattleState() == Domain.PRE_BATTLE_STATE or Domain:GetBattleState() == Domain.BATTLE_STATE then
		Dialog:Say("宣战期和征战期不能退出联盟");
		return 0;
	end
	
	if bConfirm ~= 1 then
		Dialog:Say("你的帮会确定要退出联盟吗？", 
			{{"是的，我要退出", self.DlgTongLeave, self, 1}, {"Hãy để ta suy nghĩ lại"}})
		return 0;
	end
	
	return GCExcute{"Union:ApplyTongLeave_GC", me.dwTongId, nKinId, nMemberId};
end

-- 移交盟主
function Union:DlgChangeUnionMaster(nChoose, bConfirm)
	print("DlgChangeUnionMaster");
	local nKinId, nMemberId = me.GetKinMember();
	if Tong:CheckSelfRight(me.dwTongId, nKinId, nMemberId, 1) ~= 1 then
		Dialog:Say("你不是帮主或者帮主权限被冻结，不能移交盟主。");
		return 0;
	end
	
	local pUnion = KUnion.GetUnion(me.dwUnionId);
	if not pUnion then
		Dialog:Say("你没有联盟，不能移交盟主。");
		return 0;
	end
	
	if Union:GetUnionMasterId(me.dwUnionId) ~= me.nId then
		Dialog:Say("你不是盟主，不能移交盟主。");
		return 0;
	end
	
	if Domain:GetBattleState() == Domain.PRE_BATTLE_STATE or Domain:GetBattleState() == Domain.BATTLE_STATE then
		Dialog:Say("宣战期和征战期不能移交盟主");
		return 0;
	end

	local tbMasterTongList = {};
	local tbMasterNameList = {};
	local pTongItor = pUnion.GetTongItor();
	local nCurTongId = pTongItor.GetCurTongId();
	while nCurTongId ~= 0 do
		local nPlayerId = Tong:GetMasterId(nCurTongId);
		if nPlayerId and nPlayerId ~= 0 then
			local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
			if szPlayerName and me.nId ~= nPlayerId then
				table.insert(tbMasterTongList, nCurTongId)
				table.insert(tbMasterNameList, szPlayerName)
			end
		end
		nCurTongId = pTongItor.NextTongId();
	end
	
	if #tbMasterNameList < 1 then
		Dialog:Say("联盟中没有其他帮主，不可以移交盟主");
		return 0;
	end
	
	local tbOpt = {};
	if not nChoose then
		local szSay = "";
		for nIdex = 1, #tbMasterNameList do		
			szSay = string.format("移交盟主给:<color=green>%s<color>", tbMasterNameList[nIdex]);
			table.insert(tbOpt, { szSay, self.DlgChangeUnionMaster, self, nIdex})
		end
		table.insert(tbOpt, {"Kết thúc đối thoại"});
		Dialog:Say("选择移交盟主的人选",tbOpt);
		return 0;
	end
	if bConfirm ~= 1 then
		Dialog:Say("你的帮会确定要移交盟主吗？", 
			{{"是的，我要移交", self.DlgChangeUnionMaster, self, nChoose, 1}, 
			 {"Hãy để ta suy nghĩ lại"}
			})
		return 0;
	end

	return GCExcute{"Union:ApplyChangeUnionMaster", me.dwUnionId, tbMasterTongList[nChoose], me.nId};
end

-- 分配领土
function Union:DlgDispenseDomain(nTargetDomainId, nTargetTongId, bConfirm)
	local nKinId, nMemberId = me.GetKinMember();
	if Tong:CheckSelfRight(me.dwTongId, nKinId, nMemberId, 1) ~= 1 then
		Dialog:Say("你不是帮主或者帮主权限被冻结，不能分配领土。");
		return 0;
	end
	
	local pUnion = KUnion.GetUnion(me.dwUnionId);
	if not pUnion then
		Dialog:Say("你没有联盟，不能分配领土。");
		return 0;
	end
	if Union:GetUnionMasterId(me.dwUnionId) ~= me.nId then
		Dialog:Say("你不是盟主，不能分配领土。");
		return 0;
	end
	if Domain:GetBattleState() == Domain.BATTLE_STATE then
		Dialog:Say("征战期不能分配领土");
		return 0;
	end
	if pUnion.GetDomainCount() < 1 then
		Dialog:Say("您的联盟没有领土可分配");
		return 0;
	end
	
	local tbOpt = {};
	if not nTargetDomainId then
		local pDomainItor = pUnion.GetDomainItor();
		local nDomainId = pDomainItor.GetCurDomainId();
		while nDomainId ~= 0 do
			local szDomainName = Domain:GetDomainName(nDomainId);
			local szSay = string.format("<color=green>%s<color>", szDomainName);
			table.insert(tbOpt, { szSay, self.DlgDispenseDomain, self, nDomainId})
			nDomainId = pDomainItor.NextDomainId();
		end
		table.insert(tbOpt, {"Kết thúc đối thoại"});
		Dialog:Say("选择分配哪个领土",tbOpt);
		return 0;
	end
	
	local tbNoDomain = {};
	local tbHasDomain = {};
	if not nTargetTongId then
		local szDomainName = Domain:GetDomainName(nTargetDomainId);
		local pTongItor =  pUnion.GetTongItor();
		local nCurTongId = pTongItor.GetCurTongId();
		while nCurTongId ~= 0 do
			local pCurTong = KTong.GetTong(nCurTongId);
			if pCurTong.GetDomainCount() == 0 then
				table.insert(tbNoDomain, nCurTongId);
			else
				table.insert(tbHasDomain, nCurTongId)			
			end
			nCurTongId = pTongItor.NextTongId();
		end
		if #tbNoDomain ~= 0 then
			for i = 1, #tbNoDomain do
				local pTong = KTong.GetTong(tbNoDomain[i]);
				local szSay = string.format("<color=green>%s<color>", pTong.GetName());
				table.insert(tbOpt, { szSay, self.DlgDispenseDomain, self, nTargetDomainId, tbNoDomain[i]});
			end
			table.insert(tbOpt, {"Kết thúc đối thoại"});
			Dialog:Say("选择把领土<color=green>"..szDomainName.."<color>分配给哪个帮会",tbOpt);
			return 0;
		else
			for i = 1, #tbHasDomain do
				local pTong = KTong.GetTong(tbHasDomain[i]);
				local szSay = string.format("<color=green>%s<color>", pTong.GetName());
				table.insert(tbOpt, { szSay, self.DlgDispenseDomain, self, nTargetDomainId, tbHasDomain[i]});
			end
			table.insert(tbOpt, {"Kết thúc đối thoại"});
			Dialog:Say("选择把领土<color=green>"..szDomainName.."<color>分配给哪个帮会, 被分配的帮会会自动退出联盟",tbOpt);
			return 0;
		end
	end
	
	if not bConfirm then
		local szDomainName = Domain:GetDomainName(nTargetDomainId);
		local pTargetTong = KTong.GetTong(nTargetTongId);

		Dialog:Say("你确定把"..szDomainName.."要分配给"..pTargetTong.GetName().."吗？", 
			{{"Xác nhận", self.DlgDispenseDomain, self, nTargetDomainId, nTargetTongId, 1}, 
			 {"Hãy để ta suy nghĩ lại"}
			})
		return 0;
	end

	return GCExcute{"Union:ApplyDispenseDomain_GC", me.dwUnionId, nTargetTongId, nTargetDomainId, me.nId};
end