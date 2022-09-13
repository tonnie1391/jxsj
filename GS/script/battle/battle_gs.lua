-- 战役

if not MODULE_GAMESERVER then
	return;
end


-- 战局启动
function Battle:RoundStart_GS(nBattleId, nBattleLevel, tbMapId, szMapName, nRuleType, nMapNpcNumType, nSeqNum)
	if (not tbMapId) then
		assert(tbMapId);
		return;
	end
	local szMsg = string.format("Chiến trường Mông Cổ-Tây Hạ đang bước vào giai đoạn đăng ký, các nhân sỹ hãy đến ghi danh chiến trường ở 7 thành thi, thời gian còn lại: %d phút. Điều kiện: đẳng cấp trên %d.", self.TIMER_SIGNUP / (Env.GAME_FPS * 60), self.LEVEL_LIMIT[1]);
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
	local szBattleTime = GetLocalDate("%y%m%d%H");
	
	local nOpenCount = #tbMapId;
	
	if (EventManager.IVER_bOpenTiFu == 1) then
		nOpenCount = self:GetOpenCount(nBattleLevel, #tbMapId);
	else
		if (nSeqNum == 1 and nOpenCount > 1) then -- 如果是今天的第一场比赛，那么就只开一场
			nOpenCount = 1;
		else
			nOpenCount = self:GetOpenCount(nBattleLevel, #tbMapId);
		end	
	end

	
	for i=1, nOpenCount do
		local nMapId = tbMapId[i];
		Battle:OpenBattle(nBattleId, nBattleLevel, nMapId, szMapName, nRuleType, nMapNpcNumType, nSeqNum, i, szBattleTime);
	end
	--Battle:RoundEnd_GS(nBattleId, nBattleLevel, MathRandom(0, 1));
end


--战场开启场次调整为跟时间轴相关：
--时间轴开放99级后,扬州战场调整为只开放战场一、战场二；
--时间轴开放150级后，扬州战场调整为只开放战场一；
--时间轴开放150级后150天之后，凤翔战场调整为只开放战场一；

function Battle:GetOpenCount(nBattleLevel, nCount)
	
	if GLOBAL_AGENT then
		return 1;
	end
	
	if (EventManager.IVER_bOpenTiFu == 1) then
		return 3;
	end
	
	local nOpenCount = nCount;	
	if (nBattleLevel == 1) then
		if (TimeFrame:GetStateGS("OpenLevel150") == 1) then
			nOpenCount = 1;
		elseif (TimeFrame:GetStateGS("OpenLevel99") == 1) then
			nOpenCount = 2;
		end
	elseif (nBattleLevel == 2) then
		if (TimeFrame:GetStateGS("OpenOneFengXiangBattle") == 1) then
			nOpenCount = 1;
		end
		if (SpecialEvent.HundredKin:CheckEventTime("songjin") == 1) then
			nOpenCount = 2;
		end
	end	
	return nOpenCount;
end

-- 战局结束
-- nSongResult 参见：Battle.RESULT_XXX
function Battle:RoundEnd_GS(nBattleId, nBattleLevel, nSongResult, tbPlayerList)
	GCExcute({"Battle:RoundEnd_GC", nBattleId, nBattleLevel, nSongResult, tbPlayerList});
end

function Battle:ReceiveGongRank_GS(tbPlayerGongRank)
	self.tbGongRank = tbPlayerGongRank;
end

function Battle:GetPlayerRankInfo(pPlayer)
	if (not self.tbGongRank) then
		self.tbGongRank = {};
	end
	return self.tbGongRank[pPlayer.szName];
end

