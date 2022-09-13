-- 文件名　：addrepute_base.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-11-11 09:27:38
-- 描  述  ：增加声望通用
-- ExtParam1:声望Class
-- ExtParam2:声望Camp
-- ExtParam3:声望值

local tbBase = Item:GetClass("addrepute_base");

function tbBase:OnUse()
	
	local nCamp  = it.GetExtParam(1);
	local nClass = it.GetExtParam(2);
	local nValue = it.GetExtParam(3);
	local szSeries = Env.SERIES_NAME[me.nSeries];
	local nFlag, nReputeExt = Player:AddReputeWithAccelerate(me, nCamp, nClass, nValue);
	
	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		me.Msg("您已经达到该令牌声望（" .. szSeries .. "）最高等级，将无法使用该令牌");
		return;
	end	
	
	local szLog = string.format("%s获得了%s声望(Camp:%s,Class:%s)", me.szName, nValue + nReputeExt, nCamp, nClass);
	Dbg:WriteLog("UseItem",  szLog);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
	return 1;
end

