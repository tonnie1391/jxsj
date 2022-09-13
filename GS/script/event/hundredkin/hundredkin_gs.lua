------
-- zhengyuhua
-- 百大家族评选
if not SpecialEvent.HundredKin then
	SpecialEvent.HundredKin = {}
end

local HundredKin = SpecialEvent.HundredKin;

function HundredKin:CheckEventTime(szEvent)
	if not self.EVENT_TIME[szEvent] then
		return 0
	end
	local nCurDate = tonumber(os.date("%Y%m%d",GetTime()));
--	if nCurDate < self.EVENT_TIME["score"][1] then
--		return -1;
--	end
--	if nCurDate >= self.EVENT_TIME["score"][2] then
--		return 0;
--	end
	if nCurDate >= self.EVENT_TIME[szEvent][1] and nCurDate < self.EVENT_TIME[szEvent][2] then 
		return 1;
	end
	return 0;
end

function HundredKin:CheckEventTime2(szEvent)
	if not self.EVENT_TIME2[szEvent] then
		return 0
	end
	local nCurDate = tonumber(os.date("%Y%m%d",GetTime()));
	if self.EVENT_TIME2[szEvent][1] > nCurDate then 
		return -1;
	elseif nCurDate >= self.EVENT_TIME2[szEvent][2] then
		return 0;
	end
	return 1;
end

function HundredKin:AddHundredKinScore(pPlayer, nScore, szEvent)
	local nType = self:CheckEventTime(szEvent);
	if nType <= 0 then
		return 0;
	end
	nScore = math.ceil(nScore / nType);
	
	if szEvent == "songjin" then
		local nNum = pPlayer.GetTask(self.TASK_GROUP, self.TASK_SONGJIN_NUM);
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_SONGJIN_NUM, nNum + 1);
	end
	
	if szEvent == "xoyogame" then	
		local nNum = pPlayer.GetTask(self.TASK_GROUP, self.TASK_XOYO_SOCRE);
		if nNum >= self.TAKE_SOCRE_MAX_XOYO then
			pPlayer.Msg(string.format("你本周参加逍遥谷获得盛夏积分已满，每人在逍遥谷周最多只能获得%s分。", self.TAKE_SOCRE_MAX_XOYO));
			return 0;
		end
		if nNum + nScore > self.TAKE_SOCRE_MAX_XOYO then
			nScore = self.TAKE_SOCRE_MAX_XOYO - nNum;
		end
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_XOYO_SOCRE, nNum + nScore);		
	end
	
	local nKinId, nMemberId = pPlayer.GetKinMember();
	local nRet, pKin = Kin:HaveFigure(nKinId, nMemberId, Kin.FIGURE_REGULAR);
	if nRet ~= 1 then
		return 0;
	end
	if not pKin then
		return 0;
	end
	local nCurScore = pPlayer.GetTask(self.TASK_GROUP, self.TASK_SCORE_ID);
	pPlayer.SetTask(self.TASK_GROUP, self.TASK_SCORE_ID, nCurScore + nScore);
	GCExcute{"SpecialEvent.HundredKin:AddHundredKinScore_GC", nKinId, pPlayer.nId, nScore, (nCurScore + nScore)}
end

function HundredKin:AddHundredKinScore_GS2(nKinId, nPlayerId, nCurKinScore, nPlusScore, nJour, nMyScore)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	pKin.SetHundredKinScore(nCurKinScore);
	pKin.SetHundredKinJour(nJour);
	self:UpdateHundredKin(nKinId);
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	KKinGs.KinClientExcute(nKinId, {"KKin.ShowKinMsg", string.format("通过<color=white>%s<color>的努力，您的家族获得了%s点盛夏活动家族积分！（总共贡献了%s点盛夏积分）", szPlayerName, nPlusScore, nMyScore)});
end

function HundredKin:SetHundredKinAward_GS2(nKinId, nRet)
	local pKin = KKin.GetKin(nKinId)
	if not pKin then
		return 0;
	end
	pKin.SetHundredKinAward(nRet);		-- 标记已经领过族长的奖励了
end

function HundredKin:SetHundredKinAwardCount_GS2(nKinId, nRet)
	local pKin = KKin.GetKin(nKinId)
	if not pKin then
		return 0;
	end
	pKin.SetHundredKinAwardCount(nRet);		-- 标记已经领过族长的奖励了
end
