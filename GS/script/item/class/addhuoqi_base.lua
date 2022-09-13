-- 文件名　：addhuoqi_base.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-11-11 14:46:47
-- 描  述  ：增加活力通用
-- ExtParam1:活力


local tbBase = Item:GetClass("addhuoqi_base");

function tbBase:OnUse()
	local nValue  = it.GetExtParam(1);
	me.ChangeCurGatherPoint(nValue);
	me.Msg(string.format("你获得了%s点活力", nValue));
	local szLog = string.format("%s获得了%s活力", me.szName, nValue);
	Dbg:WriteLog("UseItem",  szLog);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
	return 1;
end

