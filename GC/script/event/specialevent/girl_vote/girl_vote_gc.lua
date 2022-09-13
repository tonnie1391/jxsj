-- 文件名　：girl_vote_gc.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-06-04 17:49:23
-- 描  述  ：

if (not MODULE_GC_SERVER) then
	return 0;
end

SpecialEvent.Girl_Vote = SpecialEvent.Girl_Vote or {};
local tbGirl = SpecialEvent.Girl_Vote;

function tbGirl:StartEvent()
	if tonumber(GetLocalDate("%Y%m%d")) > self.STATE_AWARD[5] then
		SetGblIntBuf(GBLINTBUF_GIRL_VOTE, 0, 1, {});
		SetGblIntBuf(GBLINTBUF_GIRL_VOTE2, 0, 1, {});
		return 0;
	end
	
	self.tbGblBuf = {};
	local tbBuf = GetGblIntBuf(GBLINTBUF_GIRL_VOTE, 0);
	if tbBuf and type(tbBuf)=="table"  then
		self.tbGblBuf = tbBuf;
	end
	
	self.tbGblBuf2 = {};
	local tbBuf2 = GetGblIntBuf(GBLINTBUF_GIRL_VOTE2, 0);
	if tbBuf2 and type(tbBuf2)=="table"  then
		self.tbGblBuf2 = tbBuf2;
	end	
	
	--存储每日本服票情况
	self.tbGblBuf3 = {};
	local tbBuf3 = GetGblIntBuf(GBLINTBUF_GIRL_VOTE3, 0);
	if tbBuf3 and type(tbBuf3)=="table"  then
		self.tbGblBuf3 = tbBuf3;
	end	
	
	--注册0点事件，保存每日投票数据
	if tonumber(GetLocalDate("%Y%m%d")) <= self.STATE[6] then
		self:RegisterScheduleTask_GC();
	end
end

--GC数据同步给GS
function tbGirl:OnRecConnectEvent(nConnectId)
	
	if self.tbGblBuf then
		for szName, tbInfo in pairs(self.tbGblBuf) do
			GSExcute(nConnectId, {"SpecialEvent.Girl_Vote:OnRecConnectMsg", szName, tbInfo});
		end
	end
	
	if self.tbGblBuf2 then
		if self.tbGblBuf2.tZList then
			for szGateWayId, tbInfo in pairs(self.tbGblBuf2.tZList) do
				GSExcute(nConnectId, {"SpecialEvent.Girl_Vote:OnRecConnectMsgZList", szGateWayId, tbInfo});
			end
		end
		
		if self.tbGblBuf2.tGList then
			for szZone, tbInfo in pairs(self.tbGblBuf2.tGList) do
				GSExcute(nConnectId, {"SpecialEvent.Girl_Vote:OnRecConnectMsgGList", szZone, tbInfo});
			end
		end
		
		if self.tbGblBuf2.tPList then
			for szGateWayId, tbInfo in pairs(self.tbGblBuf2.tPList) do
				GSExcute(nConnectId, {"SpecialEvent.Girl_Vote:OnRecConnectMsgGateWay", szGateWayId, tbInfo});
			end
		end
	end
end

function tbGirl:RankAndWriteFile()
	-- 初赛结束后就不重拍了
	local nState = SpecialEvent.Girl_Vote:CheckState(2, 4);
	if (nState ~= 1) then
		return 0;
	end
	local tbBuf = self:GetGblBuf();
	SetGblIntBuf(GBLINTBUF_GIRL_VOTE, 0, 1, tbBuf);
	PlayerHonor:OnSchemeUpdatePrettygirlHonorLadder();
	local szGateway	= GetGatewayName();
	local szOutFile = "\\girlvoteladder2012\\girlvotehonor_" .. szGateway .. ".txt";
	local szContext = "GatewayId\tAccount\tRoleName\tTicket\tRank\tFaction\tRoute\tLevel\tKin\tTong\tFansName\tFansTicket\tSex\n";
	KFile.WriteFile(szOutFile, szContext);
	local tbBuf = self:GetGblBuf();
	if tbBuf then
		for szName, tbInBuf in pairs(tbBuf) do
			local tbInfo = GetPlayerInfoForLadderGC(szName);
			if tbInfo then
				local nRank  = GetPlayerHonorRankByName(szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);	
				local nHonor = PlayerHonor:GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);
				local szKin  = tbInfo.szKinName;
				local szTong = tbInfo.szTongName;
				local szFansName 	= tbInBuf[1];
				local nFansTickets	= tbInBuf[2];
				local nFansSex		= tbInBuf[3];
				local szFansSex	 	= Player.SEX[nFansSex]
				if szFansName == "" then
					szFansName = "";
					nFansTickets = 0;
					szFansSex = "";
				end
				if not tbInfo.szKinName or (string.len(tbInfo.szKinName) <= 0) then
					szKin = "无家族";
				end 
				if not tbInfo.szTongName or (string.len(tbInfo.szTongName) <= 0) then
					szTong = "无帮会";
				end
				local szOut = string.format("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
					szGateway,
					tbInfo.szAccount or "",
					szName or "",
					nHonor or 0,
					nRank or 0,
					Player:GetFactionRouteName(tbInfo.nFaction) or "",
					Player:GetFactionRouteName(tbInfo.nFaction, tbInfo.nRoute) or "",
					tbInfo.nLevel or 0,
					szKin or "",
					szTong or "",
					szFansName or "",
					nFansTickets or 0,
					szFansSex or "");
				KFile.AppendFile(szOutFile, szOut);	
			else
				Dbg:WriteLog("SpecialEvent.Girl_Vote","找不到该玩家数据:", szName);
			end
		end
	end
end

local function OnSort(tbA, tbB)
	if tbA[1] == tbB[1] then
		return tbA[1] > tbB[1]
	end 
	return tbA[1] < tbB[1];
end

function tbGirl:LoadPassGirlFile(szPath)
	local tbBuf = self:GetGblBuf();
	local tbFile = Lib:LoadTabFile(szPath)
	if not tbFile then
		print("【LoadPassGirlFile】找不到该路径文件", szPath);
		return 0;
	end

	local nGateway	= tonumber(string.sub(GetGatewayName(), 5, 6));
	local tbFinishGirl = {};
	for _, tbTemp in pairs(tbFile) do
		local nRank = tonumber(tbTemp.Rank) or 0;
		if nRank > 0 and nRank <= 20 then
			tbFinishGirl[tbTemp.GatewayId] = tbFinishGirl[tbTemp.GatewayId] or {};
			table.insert(tbFinishGirl[tbTemp.GatewayId], {nRank, tbTemp});
		end
		if tonumber(string.sub(tbTemp.GatewayId, 5, 6)) == nGateway then
			if tbBuf[tbTemp.RoleName] then
				self:SetPassGirl(tbTemp.RoleName, 1);
			end
		end
	end
	
	for _, tbGate in pairs(tbFinishGirl) do
		table.sort(tbGate, OnSort);
		local nCount = 0;
		for i, tbTemp in ipairs(tbGate) do
			local bPicture = tonumber(tbTemp[2].bPicture)  or 0;		--加条件：必须上传照片才能进决赛(上传照片的前10个)
			if nCount < 10 and bPicture == 1 then
				nCount = nCount + 1;
				self:SetPassState2Girl(tbTemp[2]);
				if tonumber(string.sub(tbTemp[2].GatewayId, 5, 6)) == nGateway then
					if tbBuf[tbTemp[2].RoleName] then
						self:SetPassGirl(tbTemp[2].RoleName, 2);
					end
				end
			end
		end
	end
	
	SetGblIntBuf(GBLINTBUF_GIRL_VOTE, 0, 1, tbBuf);
	
	local tbBuf2 = self:GetGblBuf2();
	SetGblIntBuf(GBLINTBUF_GIRL_VOTE2, 0, 1, tbBuf2);
end

--ke上传美女认证文件
function tbGirl:LoadGirlLogoFile(szPath)
	local tbFile = Lib:LoadTabFile(szPath)
	if not tbFile then
		print("【LoadPassGirlFile】找不到该路径文件", szPath);
		return 0;
	end
	for i, tbTemp in ipairs(tbFile) do
		local szGateway = tbTemp.GateWay or "";
		local szAccount = tbTemp.Account or "";
		local szRoleName = tbTemp.Name or "";
		local nTypeLogo = tonumber(tbTemp.Type) or 0;
		if szGateway == GetGatewayName() and szAccount ~= "" and szRoleName ~= "" then
			local szScript = string.format([=[
				if me.GetTask(2189, 522) <= 0 then
					return 0;
				end
				local nTypeLogo = %s;
				me.SetTask(2189, 522, 0);
				me.SetTask(2189, 521, 3);
				me.SetTask(2189, 523, nTypeLogo);
				me.SetTask(2189, 524, GetTime());
				me.AddSkillState(2763, 1, 1, 15 * 24 * 3600 * 18, 1,0,1);
				local szMsg = "恭喜你，你的美女认证信息已通过审核，将得到以下美女认证专享奖励：<color=green>玲珑玉匣、绝代佳人1级、美女认证特殊标识（重新登录有效）<color>。";				
				KPlayer.SendMail(me.szName, "美女认证特别奖励",szMsg, 0, 0, 1, 18, 1, 1707, 1);
				me.Msg('恭喜您获得绝代佳人1级状态及美女认证标志资格标识（重新登录有效）。');
			]=], nTypeLogo);
			SpecialEvent.CompensateGM:AddOnLine(szGateway, szAccount, szRoleName, 0, 0, szScript, 1);
		end
	end
end

function tbGirl:RankAndWriteFile2()
	local tbBuf = self:GetGblBuf2();
	SetGblIntBuf(GBLINTBUF_GIRL_VOTE2, 0, 1, tbBuf);
	local szGateway	= GetGatewayName();
	local szOutFile = "\\girlvoteladder2012\\girlvote2honor_" .. szGateway .. ".txt";
	local szContext = "GatewayId\tAccount\tRoleName\tTicket\tRank\tFaction\tRoute\tLevel\tKin\tTong\tFans1Name\tFans1Ticket\tFans1Gateway\tFans2Name\tFans2Ticket\tFans2Gateway\tFans3Name\tFans3Ticket\tFans3Gateway\tFans4Name\tFans4Ticket\tFans4Gateway\tFans5Name\tFans5Ticket\tFans5Gateway\n";
	KFile.WriteFile(szOutFile, szContext);
	if tbBuf and tbBuf.tPList then
		for szGateWayId, tbInBuf in pairs(tbBuf.tPList) do
			for szRoleName, tbPInfor in pairs(tbInBuf) do
				local szAccount = tbPInfor[4] or "";
				local nTicket = tbPInfor[2] or 0;
				local tbFans = {};
				for i=1, 5 do
					tbFans[i] = {"",0,""};
					if tbPInfor[3] and tbPInfor[3][i] then
					 	tbFans[i][1] = tbPInfor[3][i][1] or "";
					 	tbFans[i][2] = tbPInfor[3][i][2] or 0;
					 	tbFans[i][3] = tbPInfor[3][i][3] or "";
					end
				end
				local szFaction = "";
				local szRoute = "";
				local nLevel = 0;
				local szKin = "";
				local szTong = "";
				if szGateWayId == szGateway then
					local tbInfo = GetPlayerInfoForLadderGC(szRoleName);
					if tbInfo then
						szKin  = tbInfo.szKinName;
						szTong = tbInfo.szTongName;
						if not tbInfo.szKinName or (string.len(tbInfo.szKinName) <= 0) then
							szKin = "无家族";
						end
						if not tbInfo.szTongName or (string.len(tbInfo.szTongName) <= 0) then
							szTong = "无帮会";
						end
						szFaction = Player:GetFactionRouteName(tbInfo.nFaction) or "";
						szRoute	= Player:GetFactionRouteName(tbInfo.nFaction, tbInfo.nRoute) or "";
						nLevel = tbInfo.nLevel or 0;
					end
				end
				local szOut = string.format("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
					szGateWayId,
					szAccount,
					szRoleName,
					nTicket,
					0,
					szFaction,
					szRoute,
					nLevel,
					szKin,
					szTong,
					tbFans[1][1],
					tbFans[1][2],
					tbFans[1][3],
					tbFans[2][1],
					tbFans[2][2],
					tbFans[2][3],
					tbFans[3][1],
					tbFans[3][2],
					tbFans[3][3],
					tbFans[4][1],
					tbFans[4][2],
					tbFans[4][3],
					tbFans[5][1],
					tbFans[5][2],
					tbFans[5][3]);
				KFile.AppendFile(szOutFile, szOut);	
			end
		end
	end
end

--统计当天被投的玫瑰花数
function SpecialEvent:CalcDayAward_Girl_2012()
	local tbBuf = SpecialEvent.Girl_Vote:GetGblBuf();
	local tbBuf2 = SpecialEvent.Girl_Vote:GetGblBuf2();
	local szGateWay = GetGatewayName();
	--3月18号清一次buff
	if tonumber(GetLocalDate("%Y%m%d")) == 20120318 then
		SpecialEvent.Girl_Vote.tbGblBuf3 = {};
		SetGblIntBuf(GBLINTBUF_GIRL_VOTE3, 0, 1, {});
	end
	local tbBuf3 = SpecialEvent.Girl_Vote.tbGblBuf3 or {};
	local nFlag = 0;
	if tonumber(GetLocalDate("%Y%m%d")) > 20120331 then
		return;
	end
	--如果有决赛名单就取决赛的数据
	local bSate2 = SpecialEvent.Girl_Vote:CheckState(5, 6);
	--决赛赛投票完最后一天也统计数据
	if tbBuf2 and tbBuf2.tPList and (bSate2 == 1 or tonumber(GetLocalDate("%Y%m%d")) == 20120331) then
		for szGateWayId, tbInBuf in pairs(tbBuf2.tPList) do
			if szGateWayId == szGateWay then		--只保存本服数据
				for szRoleName, tbPInfor in pairs(tbInBuf) do
					local nTicket = tbPInfor[2] or 0;
					local nDayTicket = nTicket;
					if tbBuf3[szRoleName] then
						nDayTicket = nDayTicket - tbBuf3[szRoleName][1];
					end
					tbBuf3[szRoleName] = {nTicket, nDayTicket};
				end
			end
		end
	end
	local bSate1 = SpecialEvent.Girl_Vote:CheckState(2, 4);
	--初赛投票完最后一天也统计数据
	if tbBuf and (bSate1 == 1 or tonumber(GetLocalDate("%Y%m%d")) == 20120317) then
		for szName, tbInBuf in pairs(tbBuf) do
			local nTickets = PlayerHonor:GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);
			local nDayTicket = nTickets;
			if tbBuf3[szName] then
				nDayTicket = nDayTicket - tbBuf3[szName][1];
			end
			tbBuf3[szName] = {nTickets, nDayTicket};
		end
	end
	
	SetGblIntBuf(GBLINTBUF_GIRL_VOTE3, 0, 1, tbBuf3);
	GlobalExcute({"SpecialEvent.Girl_Vote:LoadGblBuf"});
end

function tbGirl:RegisterScheduleTask_GC()
	local nTaskId1 = KScheduleTask.AddTask("SpecialEvent", "SpecialEvent", "CalcDayAward_Girl_2012");
	KScheduleTask.RegisterTimeTask(nTaskId1, 0001, 1);
end

GCEvent:RegisterGCServerStartFunc(SpecialEvent.Girl_Vote.StartEvent, SpecialEvent.Girl_Vote);
GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.Girl_Vote.RankAndWriteFile, SpecialEvent.Girl_Vote)
GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.Girl_Vote.RankAndWriteFile2, SpecialEvent.Girl_Vote)
