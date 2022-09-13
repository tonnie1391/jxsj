-- 文件名　：recover.lua
-- 创建者　：houxuan
-- 创建时间：2008-12-22 08:54:07

Require("\\script\\player\\antibot\\antibot.lua");

local tbRecover = Player.tbAntiBot.tbRecover or {};
Player.tbAntiBot.tbRecover = tbRecover;

tbRecover.tbTimeList = {
	};

--根据玩家被判定为外挂的日期，将玩家从天牢中释放出来
function tbRecover:RecoverPlayer(pPlayer)
	local tbAnti = Player.tbAntiBot;
	local nDay = pPlayer.GetTask(tbAnti.TSKGID, tbAnti.TSK_CRITICAL_TIME);
	if (self.tbTimeList[nDay]) then
		Player:SetFree(pPlayer.szName);
	end
	return 0;
end
