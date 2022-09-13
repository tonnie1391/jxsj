-- 文件名　：gril_vote_gs.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-06-05 11:36:22
-- 描  述  ：
if (MODULE_GC_SERVER) then
	return 0;
end
SpecialEvent.Girl_Vote = SpecialEvent.Girl_Vote or {};
local tbGirl = SpecialEvent.Girl_Vote;

function tbGirl:OnRecConnectMsgZList(szGateWayId , tbInfo)
	if not self.tbGblBuf2 then
		self.tbGblBuf2 = {};
	end
	if not self.tbGblBuf2.tZList then
		self.tbGblBuf2.tZList = {};
	end
	self.tbGblBuf2.tZList[szGateWayId] = tbInfo;
end

function tbGirl:OnRecConnectMsgGList(ZoneName, tbInfo)
	if not self.tbGblBuf2 then
		self.tbGblBuf2 = {};
	end
	if not self.tbGblBuf2.tGList then
		self.tbGblBuf2.tGList = {};
	end
	self.tbGblBuf2.tGList[ZoneName] = tbInfo;
end

function tbGirl:OnRecConnectMsgGateWay(szGateWay, tbInfo)
	if not self.tbGblBuf2 then
		self.tbGblBuf2 = {};
	end
	if not self.tbGblBuf2.tPList then
		self.tbGblBuf2.tPList = {};
	end
	self.tbGblBuf2.tPList[szGateWay] = tbInfo;
end

--每日美女投票情况
function tbGirl:LoadGblBuf()
	self.tbGblBuf3 = self.tbGblBuf3 or {};
	local tbBuf3 = GetGblIntBuf(GBLINTBUF_GIRL_VOTE3, 0);
	if tbBuf3 and type(tbBuf3)=="table"  then
		self.tbGblBuf3 = tbBuf3;
	end
end

function tbGirl:State2VoteTickets1(szGateWay, szName, nExTicket)
	--if szName == me.szName then
	--	Dialog:Say("不能自己给自己投票哦!");
	--	return 0;
	--end
	if self:CheckState(5, 6) ~= 1 then
		Dialog:Say("3月5日至3月16日是初选投票，3月19日至3月31日0点是决赛投票，现在不在投票期间。");
		return 0;
	end
	local tbBuf = self:GetGblBuf2();
	if not tbBuf.tPList or not tbBuf.tPList[szGateWay] or not tbBuf.tPList[szGateWay][szName] then
		Dialog:Say("好像这个美女呀。");
		return 0;
	end	
	local tbRole = tbBuf.tPList[szGateWay][szName];
	local nUseTask, nNews = self:GetTaskGirlVoteId2(szGateWay, szName);
	if nUseTask == 0 then
		Dialog:Say("你已经给25个美女投过票了，不能再给其他美女投票。去投给你自己的那25个美女吧。");	
		return 0;
	end
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("需要2格背包空间，才能进行投票！");
		return 0;
	end	
	local szInput = string.format("输入票数", szName);
	
	if nExTicket == 1 then
		szInput =  "输入票数<color=yellow>(+20%)<color>";
	elseif nExTicket == 2 then
		szInput =  "输入票数<color=yellow>(+20%)<color>";
	end
	local nCount = tonumber(me.GetItemCountInBags(unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI))) or 0;
	local nCount_K = tonumber(me.GetItemCountInBags(unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI_KING))) or 0;
	Dialog:AskNumber(szInput, nCount + nCount_K, self.State2VoteTickets2, self, szGateWay, szName, (nExTicket or 0), nCount);
end

function tbGirl:State2VoteTickets2(szGateWay, szName, nExTicket, nCount_S, nTickets)
	if nTickets <= 0 then
		return 0;
	end
	if self:CheckState(5, 6) ~= 1 then
		Dialog:Say("3月5日至3月16日是初选投票，3月19日至3月31日0点是决赛投票，现在不在投票期间。");
		return 0;
	end
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("需要2格背包空间，才能进行投票！");
		return 0;
	end
	--判断身上的玫瑰数够不够；
	local nCount = me.GetItemCountInBags(unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI));
	local nCount_K = tonumber(me.GetItemCountInBags(unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI_KING))) or 0;
	if nCount + nCount_K < nTickets then
		Dialog:Say("你身上没有那么多玫瑰。");
		return 0;
	end
	
	local nUseTask, nNews = self:GetTaskGirlVoteId2(szGateWay, szName);
	if nUseTask == 0 then
		Dialog:Say("你已经给25个美女投过票了，不能再给其他美女投票。去投给你自己的那25个美女吧。");	
		return 0;
	end
	local nConsumeCount = math.min(nCount_S, nTickets);
	local nConsumeCount_K = nTickets - nConsumeCount;
	--扣除玫瑰；
	local bRet = 1;
	if nConsumeCount > 0 then
		bRet = me.ConsumeItemInBags(nConsumeCount, unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI));
	end
	local bRet_K = 1;
	if nConsumeCount_K > 0 then
		bRet_K = me.ConsumeItemInBags(nConsumeCount_K, unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI_KING));
	end
	--增加投票
	if bRet ~= 0 and bRet_K ~= 0 then
		me.Msg("扣除玫瑰失败，投票失败");
		return 0;
	end
	
	for i=1, nTickets do
		local nCurR = 0;
		if i <= nConsumeCount then
			nCurR = MathRandom(1,100);
		else
			nCurR = MathRandom(1,1000);	--扣除内部的时候概率1/1000
		end
		if nCurR == 1 then
			if TimeFrame:GetState("OpenLevel150") == 0 then
				me.AddItem(unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI_REBACK));
			else
				me.AddItem(unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI_REBACK_Old));
			end
		end
	end
	local nServer = tonumber(string.sub(szGateWay, 5, -1)) or 0;
	local nGroupId = SpecialEvent.Girl_Vote.TSK_GROUP;
	local nTotleTickets = me.GetTask(nGroupId, (nUseTask + (SpecialEvent.Girl_Vote.DEF_TASK_SAVE_FANS - 1)));
	if nNews == 1 then
		me.SetTaskStr(nGroupId, nUseTask, szName);
		me.SetTask(nGroupId, (nUseTask + self.DEF_TASK_OFFSET), nServer)
	end
	--组队送：加特效，小仙子送：特殊奖励
	
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if pPlayer and nTickets >= 9 then
		if nExTicket == 1 then
			pPlayer.CastSkill(self.nSkillVote, 1, 1, 1);
		end
		if nTickets < self.nMinWorldMsg then
			Player:SendMsgToKinOrTong(pPlayer, "收到了<color=yellow>神秘人物<color>赠送的一束玫瑰。", 1);
			Player:SendMsgToKinOrTong(pPlayer, "收到了<color=yellow>神秘人物<color>赠送的一束玫瑰。", 0);
			pPlayer.SendMsgToFriend("Hảo hữu ["..pPlayer.szName.."]收到了<color=yellow>神秘人物<color>赠送的一束玫瑰。");
		end
	end
	--每次送超过99朵，又一次发送世界公告的机会
	if nTickets >= self.nMinWorldMsg then
		self:RandSendMsgWorld(szName, me.szName, 1, nTickets);
	end
	local nOldnTickets = nTickets;	
	--票数加成
	if nExTicket == 1 or nExTicket == 2 then
		nTickets = math.floor(nTickets * 1.2);
	end
	me.SetTask(nGroupId, (nUseTask + (SpecialEvent.Girl_Vote.DEF_TASK_SAVE_FANS - 1)), (nTotleTickets + nTickets));
	local tbFans = {
		szFansName = me.szName, 
		nFansSex   = me.nSex, 
		nTotleTickets = nTotleTickets,
	};
	GCExcute({"SpecialEvent.Girl_Vote:BufVoteTicket2", szGateWay, szName, nTickets, tbFans});
	StatLog:WriteStatLog("stat_info", "prety_lady", "vote_rose", me.nId, szGateWay, szName, nOldnTickets, nTickets);
	Dialog:Say(string.format("你成功给%s投了%s票。", szName, nTickets));
end

function tbGirl:GetTaskGirlVoteId2(szGateWay, szName)
	local nServer = tonumber(string.sub(szGateWay, 5, -1)) or 0;
	local nGroupId = SpecialEvent.Girl_Vote.TSK_GROUP;
	local nUseTask = nil;
	local nNew = 0;
	if me.GetTask(nGroupId, self.TSK_FANS_CLEAR) == 0 then
		for nTask = self.TSKSTR_FANS_NAME[1], self.TSKSTR_FANS_NAME[2] do
			me.SetTask(nGroupId, nTask, 0);
		end
		me.SetTask(nGroupId, self.TSK_FANS_CLEAR, 1);
	end
	for nTask = self.TSKSTR_FANS_NAME[1], self.TSKSTR_FANS_NAME[2], SpecialEvent.Girl_Vote.DEF_TASK_SAVE_FANS do
		if me.GetTaskStr(nGroupId, nTask) == szName and me.GetTask(nGroupId, (nTask + self.DEF_TASK_OFFSET)) == nServer then
			nUseTask = nTask;
			break;
		end
		if me.GetTaskStr(nGroupId, nTask) == "" then
			nUseTask = nUseTask or nTask;
			nNew = 1;
		end
	end
	return (nUseTask or 0), nNew;
end

function tbGirl:LoadFinishFile(szPath)
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return 0;
	end
	SpecialEvent.Girl_Vote.tbFinishWinList = {};
	
	for _, tbRole in pairs(tbFile) do
		local szRoleGateWay = string.sub(tbRole.GatewayId, 5, 6);
		SpecialEvent.Girl_Vote.tbFinishWinList[szRoleGateWay] = SpecialEvent.Girl_Vote.tbFinishWinList[szRoleGateWay] or {};
		SpecialEvent.Girl_Vote.tbFinishWinList[szRoleGateWay][tbRole.RoleName] = SpecialEvent.Girl_Vote.tbFinishWinList[szRoleGateWay][tbRole.RoleName] or {};
		local tbInfo = SpecialEvent.Girl_Vote.tbFinishWinList[szRoleGateWay][tbRole.RoleName];
		tbInfo.nRank = tonumber(tbRole.Rank) or 0;
		tbInfo.szFansName = tbRole.FansName;
		tbInfo.szFansGateWay = string.sub(tbRole.FansGateway, 5, 6);
	end
end

function tbGirl:OnLogin()
	if me.nSex ~= Env.SEX_FEMALE then
		return 0;
	end
	
	--上线加美女认证logo
	local nLogoTime = me.GetTask(self.TSK_GROUP, self.TSK_Renzheng_Buff);
	if nLogoTime > 0 and self.nGirlLogoTime + nLogoTime > GetTime() then
		me.SetNpcSpeTitleImage(1, self.nGirlLogoTime + nLogoTime);	--设置美女认证图标
	end
	
	if self:CheckState(5, 6) == 1 then
		if me.FindTitle(unpack(self.DEF_FINISH_MATCH_TITLE)) == 1 then
			return 0;
		end
		local tbBuf = self:GetGblBuf2();
		local szGateWay = GetGatewayName();
		if self.GATEWAY_TRANS[szGateWay] then
			szGateWay = self.GATEWAY_TRANS[szGateWay][1];
		end
		if tbBuf and tbBuf.tPList and tbBuf.tPList[szGateWay] and tbBuf.tPList[szGateWay][me.szName] then
			me.AddTitle(unpack(self.DEF_FINISH_MATCH_TITLE));
			me.SetCurTitle(unpack(self.DEF_FINISH_MATCH_TITLE));
		end
	end
end

function tbGirl:LoadMyGirlFile(szPath)
	local tbFile = Lib:LoadTabFile(szPath)
	if not tbFile then
		return 
	end
	self.tbGirlKinTong = {tbKin={},tbTong={}};
	for _, tbTemp in pairs(tbFile) do
		local szGateWay = tbTemp.GatewayId;
		local nRank 	= tonumber(tbTemp.Rank) or 0;
		local szKin 	= tbTemp.Kin;
		local szTong 	= tbTemp.Tong;
		if self.GATEWAY_TRANS[szGateWay] then
			szGateWay = self.GATEWAY_TRANS[szGateWay][1];
		end		
		if szGateWay == GetGatewayName() then
			if nRank > 0 and nRank <= 20 then
				self.tbGirlKinTong.tbKin[szKin] = self.tbGirlKinTong.tbKin[szKin] or {};
				self.tbGirlKinTong.tbKin[szKin].nGirl = self.tbGirlKinTong.tbKin[szKin].nGirl or 0;
				self.tbGirlKinTong.tbKin[szKin].nGirl = self.tbGirlKinTong.tbKin[szKin].nGirl + 1;
				
				self.tbGirlKinTong.tbTong[szTong] = self.tbGirlKinTong.tbTong[szTong] or {};
				self.tbGirlKinTong.tbTong[szTong].nGirl = self.tbGirlKinTong.tbTong[szTong].nGirl or 0;
				self.tbGirlKinTong.tbTong[szTong].nGirl = self.tbGirlKinTong.tbTong[szTong].nGirl + 1;
			end
			if nRank == 1 then
				self.tbGirlKinTong.tbTong[szTong].nNO1Girl = 1;
			end
		end
	end
end

function tbGirl:TongGetGirl()
	local nTongId = me.dwTongId;
	if nTongId == nil or nTongId <= 0 then
		return 0;
	end
	
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end
	
	local szTongName = cTong.GetName();
	
	local nKinId, nKinMemId = me.GetKinMember();
	if nKinId == nil or nKinId <= 0 then
		return 0;
	end
	
	if Kin:HaveFigure(nKinId, nKinMemId, 4) ~= 1 then
		return 0;
	end
	
	if not self.tbGirlKinTong or not self.tbGirlKinTong.tbTong then
		return 0;
	end
	
	if not self.tbGirlKinTong.tbTong[szTongName] then
		return 0;
	end
	return self.tbGirlKinTong.tbTong[szTongName].nGirl or 0;
end

function tbGirl:KinGetGirl()
	local nKinId, nKinMemId = me.GetKinMember();
	if nKinId == nil or nKinId <= 0 then
		return 0;
	end
	
	if Kin:HaveFigure(nKinId, nKinMemId, 4) ~= 1 then
		return 0;
	end	
	local cKin = KKin.GetKin(nKinId);
	local szKinName = cKin.GetName();
	
	if not self.tbGirlKinTong or not self.tbGirlKinTong.tbKin then
		return 0;
	end
	
	if not self.tbGirlKinTong.tbKin[szKinName] then
		return 0;
	end
	return self.tbGirlKinTong.tbKin[szKinName].nGirl or 0;
end

function tbGirl:TongIsNO1Girl()
	local nTongId = me.dwTongId;
	if nTongId == nil or nTongId <= 0 then
		return 0;
	end
	
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end
	
	local szTongName = cTong.GetName();
	
	local nKinId, nKinMemId = me.GetKinMember();
	if nKinId == nil or nKinId <= 0 then
		return 0;
	end
	
	if Kin:HaveFigure(nKinId, nKinMemId, 4) ~= 1 then
		return 0;
	end
	
	if not self.tbGirlKinTong or not self.tbGirlKinTong.tbTong then
		return 0;
	end
	
	if not self.tbGirlKinTong.tbTong[szTongName] then
		return 0;
	end
	return self.tbGirlKinTong.tbTong[szTongName].nNO1Girl or 0;
end

function tbGirl:CastSkill(dwId)	
	local pNpc = KNpc.GetById(dwId)
	if pNpc then
		pNpc.CastSkill(2579, 1,  -1, pNpc.nIndex);
		return;
	end
	return 0;
end

PlayerEvent:RegisterGlobal("OnLogin", SpecialEvent.Girl_Vote.OnLogin, SpecialEvent.Girl_Vote);
ServerEvent:RegisterServerStartFunc(SpecialEvent.Girl_Vote.LoadGblBuf, SpecialEvent.Girl_Vote);
