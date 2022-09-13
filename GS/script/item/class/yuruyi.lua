-- zhouchenfei
-- 2009-9-21 20:45:31
-- 玉如意脚本

local tbYuruyi = Item:GetClass("yuruyi");

function tbYuruyi:OnUse()
	local pPlayer 		= me;
	local nShengWang 	= 1;
	local nFlag			= Player:AddRepute(pPlayer, 10, 1, nShengWang);
	
	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		pPlayer.Msg("您已经达到民族大团圆声望最高等级，将无法使用玉如意");
		return;
	end
	
	return 1;	
end
