-- 文件名　：girl_vote_gc.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-06-04 17:49:23
-- 描  述  ：

SpecialEvent.Girl_Vote = SpecialEvent.Girl_Vote or {};
local tbGirl = SpecialEvent.Girl_Vote;

function tbGirl:IsOpen()
	return Task.IVER_nEvent_GirlVote or 0;
end

function tbGirl:CheckState(nSTState, nEDState)
	if self:IsOpen() ~= 1 then
		return 0;
	end
	
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if not self.STATE[nEDState] then
		return 0;
	end
	
	if nCurDate >= (self.STATE[nSTState] or 0) and  nCurDate <= self.STATE[nEDState] then
		return 1;
	end
	return 0;
end

function tbGirl:GetGblBuf()
	return self.tbGblBuf or {};
end

function tbGirl:SetGblBuf(tbBuf)
	self.tbGblBuf = tbBuf;
end

function tbGirl:IsHaveGirl(szName)
	local tbBuf = self:GetGblBuf();
	if tbBuf[szName] then
		return 1;
	end
	return 0;
end

function tbGirl:SignUpBuf(szName)
	local tbBuf = self:GetGblBuf();
	if tbBuf[szName] then
		return 1;
	end
	tbBuf[szName] = {"",0,0};
	if (MODULE_GC_SERVER) then
		KGblTask.SCSetDbTaskInt(DBTASK_GIRL_VOTE_MAX, (KGblTask.SCGetDbTaskInt(DBTASK_GIRL_VOTE_MAX) + 1));
		GlobalExcute({"SpecialEvent.Girl_Vote:SignUpBuf", szName});
	end
	self:SetGblBuf(tbBuf);
end

function tbGirl:BufVoteTicket(szName, nTickets, tbFans)
	local tbBuf = self:GetGblBuf();
	if tbBuf[szName] then
		if szName ~= tbFans.szFansName then
			if tbBuf[szName][2] < (tbFans.nTotleTickets + nTickets) then
				tbBuf[szName][2] 	= (tbFans.nTotleTickets + nTickets);
				tbBuf[szName][1] 	= tbFans.szFansName;
				tbBuf[szName][3] 	= tbFans.nFansSex
			end
		end
	end
	if (MODULE_GC_SERVER) then 
		local nCurHonor = PlayerHonor:GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);
		PlayerHonor:SetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0, nCurHonor + nTickets)
		GlobalExcute({"SpecialEvent.Girl_Vote:BufVoteTicket", szName, nTickets, tbFans});
	end
	if (not MODULE_GC_SERVER) then 
		local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.Msg(string.format("<color=yellow>%s<color>被你的魅力所倾倒，给你投了<color=yellow>%s<color>朵玫瑰！", tbFans.szFansName, nTickets));
		end
	end
	self:SetGblBuf(tbBuf);
	Dbg:WriteLog("SpecialEvent.Girl_Vote", tbFans.szFansName.."投了"..nTickets.."票给"..szName);
end

function tbGirl:SetPassGirl(szName, nFlag)
	local tbBuf = self:GetGblBuf();
	if not tbBuf[szName] then
		return 1;
	end
	tbBuf[szName][4] = nFlag;
	if (MODULE_GC_SERVER) then
		GlobalExcute({"SpecialEvent.Girl_Vote:SetPassGirl", szName});
	end
end

function tbGirl:RandSendMsgWorld(szName, szSendName, nType, nTickets)
	local szWorldMsg = "<color=green>【%s】<color>";
	local szMsg = "";
	local szWorld = "";
	local bSelf = 0;
	if nType == 1 then
		if szName == szSendName then
			szWorld = "给自己投票<color=pink>%s朵玫瑰<color>，";
			szMsg = "为自己投了<color=pink>%s朵玫瑰<color>，一起去为她呐喊加油吧！";
			bSelf = 1;
		else
			szWorld = "给美女<color=green>【%s】<color>投票<color=pink>%s朵玫瑰<color>，";
			szMsg = "给美女<color=green>【%s】<color>送出了<color=pink>%s朵玫瑰<color>和一段火热的告白，大家快去围观!";
		end
	elseif nType == 2 then
		if szName == szSendName then
			szMsg = "召唤玫瑰精灵为自己助战，" .. self.tbWorldMsg[1];
			szWorld = "召唤玫瑰精灵为自己助战，";
			bSelf = 1;
		else
			szMsg = "召唤玫瑰精灵助战美女<color=green>【%s】<color>，" .. self.tbWorldMsg[1];
			szWorld = "召唤玫瑰精灵助战美女<color=green>【%s】<color>，";
		end
	end
	local nCount = Lib:CountTB(self.tbWorldMsg);
	if nCount <= 0 then
		return 0;
	end
	local nRandCount = MathRandom(nCount);
	if bSelf == 0 then
		szWorldMsg  = string.format(szWorldMsg..szWorld, szSendName, szName, nTickets or 0)..self.tbWorldMsg[nRandCount];
		szMsg = string.format(szMsg, szName, nTickets);
	else
		szWorldMsg  = string.format(szWorldMsg..szWorld, szSendName, nTickets or 0)..self.tbWorldMsg[nRandCount];
		szMsg = string.format(szMsg, nTickets);
	end
	Player:SendMsgToKinOrTong(me, szMsg, 1);
	Player:SendMsgToKinOrTong(me, szMsg, 0);
	me.SendMsgToFriend("Hảo hữu ["..me.szName.."]"..szMsg);
	KDialog.NewsMsg(1,3,szWorldMsg);
end
