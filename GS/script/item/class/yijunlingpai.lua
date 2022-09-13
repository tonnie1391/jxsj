-- 文件名　：yijunlingpai.lua
-- 创建者　：zhouchenfei
-- 创建时间：2008-03-11 20:50:21
-- modify by zhangjinpin@kingsoft

local tbYiJun	= Item:GetClass("yijunlingpai");

function tbYiJun:OnUse()

	local pPlayer 		= me;
	local nShengWang 	= 20;
	local szSeries		= Env.SERIES_NAME[pPlayer.nSeries];
	local nValue		= pPlayer.GetWeekRepute(1,1);

	-- zhengyuhua:庆公测活动临时内容	
	local nBufLevel = me.GetSkillState(881)
	local nBufLevel_vn = me.GetSkillState(2211)	--越南声望令牌
	if nBufLevel > 0 or nBufLevel_vn > 0 then
		nShengWang = nShengWang * 1.5
	end
	
	local nTimes = tonumber(it.GetExtParam(1));
	if nTimes > 0 then
		nShengWang = nShengWang * nTimes;
	end
	
	local nFlag = Player:AddRepute(pPlayer, 1, 1, nShengWang);
	
	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		pPlayer.Msg("您已经达到义军声望（" .. szSeries .. "）最高等级，将无法使用义军令牌");
		return;
	end
	
	return 1;	
end
