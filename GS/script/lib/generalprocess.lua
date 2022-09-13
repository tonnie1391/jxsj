function GeneralProcess:GetPlayerProcessData(pPlayer)
	local tbPlayerData		= pPlayer.GetTempTable("GeneralProcess");
	local tbProcessData		= tbPlayerData.tbProcessData;
	if (not tbProcessData) then
		tbProcessData	= {
		};
		tbPlayerData.tbProcessData	= tbProcessData;
	end;
	
	return tbProcessData;
end;

-- S,c
function GeneralProcess:StartProcess(szTxt, nIntervalTime, tbSucCallBack, tbBreakCallBack, tbEvent)
	if MODULE_GAMECLIENT then
		me.CallServerScript({"StartProcess", szTxt, nIntervalTime, tbEvent});
		local tbProcessData = self:GetPlayerProcessData(me);
		tbProcessData.tbSucCallBack_C = tbSucCallBack;
		tbProcessData.tbBreakCallBack_C = tbBreakCallBack;
		return 0;
	end
	assert(nIntervalTime > 0);
	assert(szTxt)
	me.CloseGenerProgress();
	local tbProcessData = self:GetPlayerProcessData(me);
	tbProcessData.tbSucCallBack = tbSucCallBack;
	tbProcessData.tbBreakCallBack = tbBreakCallBack;
	
	me.StartGenerProgress(szTxt, nIntervalTime, unpack(tbEvent));
end;

-- S 对某个玩家执行进度条
function GeneralProcess:StartProcessOnPlayer(pPlayer, szTxt, nIntervalTime, tbSucCallBack, tbBreakCallBack, tbEvent)
	assert(nIntervalTime > 0);
	assert(szTxt)
	pPlayer.CloseGenerProgress();
	local tbProcessData = self:GetPlayerProcessData(pPlayer);
	tbProcessData.tbSucCallBack = tbSucCallBack;
	tbProcessData.tbBreakCallBack = tbBreakCallBack;
	
	pPlayer.StartGenerProgress(szTxt, nIntervalTime, unpack(tbEvent));
end;

-- S
function GeneralProcess:OnProgressFull()
	local tbCallBack = self:GetPlayerProcessData(me).tbSucCallBack;
	
	if (not tbCallBack) then
		return;
	end
	
	Lib:CallBack(tbCallBack);
end;

-- S
function GeneralProcess:OnBreak()
	local tbCallBack = self:GetPlayerProcessData(me).tbBreakCallBack;
	
	if (not tbCallBack) then
		return;
	end
	
	Lib:CallBack(tbCallBack);
end

-- S
function GeneralProcess:StartProcessByClient(szText, nIntervalTime, tbEvent)
	nIntervalTime = tonumber(nIntervalTime) or 0;
	szText = szText or "启动中...";
	tbEvent = tbEvent or {};
	if nIntervalTime <= 0 then
		return;
	end
	GeneralProcess:StartProcess(szText, nIntervalTime, {self.StartProcessByClientSucess, self}, {self.StartProcessByClientFail, self}, tbEvent);
end

-- S
function GeneralProcess:StartProcessByClientSucess()
	me.CallClientScript({"GeneralProcess:StartProcessClientSucess"});
end

-- S
function GeneralProcess:StartProcessByClientFail()
	me.CallClientScript({"GeneralProcess:StartProcessClientFail"});
end

-- C
function GeneralProcess:StartProcessClientSucess()
	local tbProcessData = self:GetPlayerProcessData(me);
	local tbSucCallBack = tbProcessData.tbSucCallBack_C;
	if tbSucCallBack and tbSucCallBack[1] then
		Lib:CallBack(tbSucCallBack);
	end
end

-- C
function GeneralProcess:StartProcessClientFail()
	local tbProcessData = self:GetPlayerProcessData(me);
	local tbBreakCallBack = tbProcessData.tbBreakCallBack_C;
	if tbBreakCallBack and tbBreakCallBack[1] then
		Lib:CallBack(tbBreakCallBack);
	end	
end
