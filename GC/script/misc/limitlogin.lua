-------------------------------------------------------------------
--File: LimitLogin.lua
--Author: luobaohang
--Date: 2008-12-9 19:48
--Describe: 反外挂脚本(GS、GC)
-------------------------------------------------------------------

LimitLogin.tbLoginLimit = {};
LimitLogin.nNumLimit = 4;

function LimitLogin:LoginCalculate(nPlayerId, dwIp)
	local nCount = 0;
	local nResult = 0;
	local szName	= KGCPlayer.GetPlayerName(nPlayerId);
	local nPlayerServer = GCGetPlayerOnlineServer(szName);
	
	table.insert(self.tbLoginLimit, dwIp);
	for _, szIp in pairs (self.tbLoginLimit) do
		if szIp == dwIp then
			nCount = nCount + 1
		end
	end
	if nCount <= self.nNumLimit then
		nResult = 1
	end
	GSExcute(nPlayerServer, {"LimitLogin:OnResult", szName, nResult, nCount});
end

function LimitLogin:LogoutCalculate(nPlayerId, dwIp)
	for nIndex, szIp in pairs (self.tbLoginLimit) do
		if szIp == dwIp then
			table.remove(self.tbLoginLimit, nIndex);
			break
		end
	end
end

function LimitLogin:OnLoginDo(bExchangeServer)
	-- if (bExchangeServer ~= 1) then
		GCExcute({"LimitLogin:LoginCalculate", me.nId, me.dwIp})
	-- end
end

function LimitLogin:OnLogoutDo(szLogoutReason)
	-- if (szLogoutReason ~= "SwitchServer") then 
		GCExcute({"LimitLogin:LogoutCalculate", me.nId, me.dwIp})
	-- end
end

function LimitLogin:OnResult(szName, nResult, nCount)
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if nResult == 1 then
		-- pPlayer.Msg("Đây là tài khoản thứ <color=yellow>"..nCount.."<color> đăng nhập vào máy chủ!")
	else
		pPlayer.Msg("Đăng nhập nhiều hơn số lượng tài khoản cho phép!")
		Player:RegisterTimer(18 * 3, LimitLogin.DoKickOut, LimitLogin, szName)
	end
end

function LimitLogin:DoKickOut(szName)
	local pPlayer = KPlayer.GetPlayerByName(szName);
	pPlayer.KickOut();
	return 0;
end

if (MODULE_GAMESERVER) then
	PlayerEvent:RegisterGlobal("OnLogout", "LimitLogin:OnLogoutDo");
	PlayerEvent:RegisterGlobal("OnLogin", "LimitLogin:OnLoginDo");
end
