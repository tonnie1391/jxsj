local tbItem = Item:GetClass("zhanchanglingpai")

function tbItem:OnUse()
	local pPlayer		= me;
--	local nLimit 		= 4000;
	local nShengWang	= 40;
	local nLevel 		= it.nLevel;
	local szSeries		= Env.SERIES_NAME[pPlayer.nSeries];
	
	if (nLevel == 2) then	-- 凤翔战场声望为100
		nShengWang = 100;
	end

	local nValue		= pPlayer.GetWeekRepute(2,nLevel);
--	if (nLimit <= nValue) then
--		pPlayer.Msg("您本周获得的战场声望已达上限，不能使用战场令牌！");
--		return;
--	end	
	-- zhengyuhua:庆公测活动临时内容	
	local nBufLevel = me.GetSkillState(881)
	local nBufLevel_vn = me.GetSkillState(2211)	--越南声望令牌
	if nBufLevel > 0 or nBufLevel_vn > 0 then
		nShengWang = nShengWang * 1.5
	end
	
	local nFlag = Player:AddRepute(pPlayer, 2, nLevel, nShengWang);
	
	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		local szName = Battle.NAME_GAMELEVEL[nLevel];
		pPlayer.Msg("您已经达到" .. szName .. "声望（" .. szSeries .. "）最高等级，将无法使用战场令牌");
		return;
	end
	
	return 1; 
end
