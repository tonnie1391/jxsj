-------------------------------------------------------------------
--File: customercmd_gs.lua
--Author: zouying
--Date: 2009-4-28 10:08
--Describe:  gs处理平台发来的gm指令
-------------------------------------------------------------------

-- 由gc用的gs执行指令接口
function GmCmd:OnCallGS(nRegId, ...)
	GCExcute({"GmCmd:OnCallGC", nRegId, GetServerId(), Lib:PCall(...)});
end

-- 由gc用的gs执行玩家指令接口
function GmCmd:OnCallPlayer(nRegId, szPlayerName, szCmd)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if (not pPlayer) then
		GCExcute({"GmCmd:OnCallGC", nRegId, GetServerId(), false});
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	GCExcute({"GmCmd:OnCallGC", nRegId, GetServerId(), Lib:PCall("GM:DoCommand", szCmd)});
	Setting:RestoreGlobalObj();
end

-- 由gc用的执行客户端指令接口
function GmCmd:OnCallClient(nRegId, szPlayerName, ...)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if (not pPlayer) then
		GCExcute({"GmCmd:OnCallGC", nRegId, GetServerId(), false});
		return;
	end
	local tbPlayerGmCmd = self:GetPlayerTempTable(pPlayer);
	tbPlayerGmCmd.nRegId = nRegId;
	pPlayer.CallClientScript({"GM:OnCallClient", nRegId, "GM:DoCommand", ...});
end

-- 客户端回调接口
function GmCmd:OnClientCallBack(nRegId, bOk, tbRet, nRetCount)
	local tbPlayerGmCmd = self:GetPlayerTempTable(me);
	if (nRegId ~= tbPlayerGmCmd.nRegId) then
		return;
	end
	-- 参数安全检查
	if (bOk) then
		if (type(nRetCount) ~= "number" or type(tbRet) ~= "table") then
			return;
		end
		if (nRetCount < 0 or nRetCount > 100) then
			return;
		end
		nRetCount = math.floor(nRetCount);
		local tbOld = tbRet;
		tbRet = {};
		for i = 1, nRetCount do
			if (tbOld[i] ~= nil) then
				tbRet[i] = tostring(tbOld[i]);
			end
		end
	else
		tbRet = tostring(tbRet);
		nRetCount = nil;
	end
	GCExcute({"GmCmd:OnCallGC", nRegId, GetServerId(), bOk, tbRet, nRetCount});
	tbPlayerGmCmd.nRegId = nil;
end

-- 【查询玩家GS信息】_GS
function GmCmd:GetPlayerInfo_GS(szName)
	local pPlayer	= KPlayer.GetPlayerByName(szName);
	if (not pPlayer) then
		return;
		
	end
	
	local tbText	= {
		{"名称", pPlayer.szName},
		{"账号", pPlayer.szAccount},
		{"位置", string.format("%s<pos=%d,%d,%d>", GetMapNameFormId(pPlayer.nTemplateMapId), pPlayer.GetWorldPos())},
		{"金币", pPlayer.nCoin},
		{"绑金", pPlayer.nBindCoin},
		{"银两", pPlayer.nTotalMoney},
		{"绑银", pPlayer.GetBindMoney()},
	}
	local szMsg	= "";
	for _, tb in ipairs(tbText) do
		szMsg	= szMsg .. "\n" .. tb[1] .. "\t" .. tostring(tb[2]);
	end
	return szMsg;
end

function GmCmd:KickOut(szCallBackFun, nSession, nAsker, szName, nConnectId)
	
	local pPlayer = KPlayer.GetPlayerByName(szName);
	local bRet = pPlayer and pPlayer.KickOut() or self.GMCMD_RESULT_PLAYER_NOT_ONLINE;
		if (nSession ~= 0) then
			_G.GCExcute({szCallBackFun, nSession, 0, nAsker, bRet, nConnectId});
	end
end

function GmCmd:PlayerFly_GS(nSession, nAsker, szName, nMapId, nX, nY)
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (pPlayer) then
		local bRet = pPlayer.NewWorld(nMapId, nX, nY);
		_G.GCExcute({"GmCmd:ReportCmdResult", nSession, 0, nAsker, bRet});
	end
end

function GmCmd:OnPlayerLogin()
	local nUnBanChatTime = me.GetTask(self.TASK_CUSTOMER_ID, self.SUBTASKID_UNBANCHAT);
	
	if (nUnBanChatTime ~= 0 and nUnBanChatTime <= GetTime()) then
		me.SetForbidChat(0);
		me.Msg("您已经解除禁言了。");
		me.SetTask(self.TASK_CUSTOMER_ID, self.SUBTASKID_UNBANCHAT, 0);
	end
	local nFreeTime = me.GetTask(self.TASK_CUSTOMER_ID, self.SUBTASKID_FREEPRISON);
	
	if (nFreeTime ~= 0 and nFreeTime <= GetTime()) then
		Player:SetFree(me.szName);
		me.Msg("你自由了，释放出大牢了。");
		me.SetTask(self.TASK_CUSTOMER_ID, self.SUBTASKID_FREEPRISON, 0);
	end
end

PlayerEvent:RegisterGlobal("OnLogin", GmCmd.OnPlayerLogin, GmCmd);