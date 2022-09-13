--竞技赛(基本公用类)
--孙多良,麦亚津
--2008.12.25

--开启界面
function TowerDefence:OpenSingleUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

--关闭界面
function TowerDefence:CloseSingleUi(pPlayer)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--更新界面时间
function TowerDefence:UpdateTimeUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
end

--更新界面信息
function TowerDefence:UpdateMsgUi(pPlayer, szMsg)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SendBattleMsg(pPlayer, szMsg);
end

--参加一次比赛
function TowerDefence:ConsumeTask(pPlayer)
	--总场次＋1
	pPlayer.SetTask(self.TSK_GROUP, self.TSK_ATTEND_TOTAL, pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_TOTAL) + 1);
	
	--次数－1
	local nCount = pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT);
	local nExCount = pPlayer.GetTask(self.TSK_GROUP, self.TSK_ATTEND_EXCOUNT)
	if nCount > 0 then
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT, nCount - 1);
		return 1;
	end
	if nExCount > 0 then
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_ATTEND_EXCOUNT, nExCount - 1);
		return 1;
	end	
	return 0;
end

function TowerDefence:TaskDayEvent()
	if self:CheckState() == 0 then
		return 0;
	end
	
	local nNowDay 	=  Lib:GetLocalDay(GetTime())
	local nKeepDay  =  me.GetTask(self.TSK_GROUP, self.TSK_ATTEND_DAY);
		
	if me.nLevel < self.DEF_PLAYER_LEVEL or me.nFaction <= 0 then
		if me.nLevel < self.DEF_PLAYER_LEVEL then
			me.SetTask(self.TSK_GROUP, self.TSK_ATTEND_DAY, (nNowDay - 1));
			me.SetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT, 0);
		end
		return 0;
	end

	if nKeepDay <= 0 then
		nKeepDay = Lib:GetLocalDay(Lib:GetDate2Time(self.SNOWFIGHT_STATE[1])) - 1;
	end
	if (nNowDay - nKeepDay) > 0 then
	local nCount = me.GetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT) + self.DEF_PLAYER_COUNT * (nNowDay - nKeepDay);
		if nCount > self.DEF_PLAYER_KEEP_MAX then
			nCount = self.DEF_PLAYER_KEEP_MAX;
		end
		me.SetTask(self.TSK_GROUP, self.TSK_ATTEND_COUNT, nCount);
		me.SetTask(self.TSK_GROUP, self.TSK_ATTEND_DAY, nNowDay);
		self:WriteLog("增加次数："..nCount, me.nId);
	end
end

if (MODULE_GAMESERVER) then
--玩家登陆执行后次数增加

PlayerEvent:RegisterOnLoginEvent(TowerDefence.TaskDayEvent, TowerDefence);

end
