-- 文件名　：addjingqi_base.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-11-11 14:48:58
-- 描  述  ：增加精力通用
-- ExtParam1:精力

local tbBase = Item:GetClass("addjingqi_base");

function tbBase:OnUse()
	local nValue  = it.GetExtParam(1);
	me.ChangeCurMakePoint(nValue);
	me.Msg(string.format("你获得了%s点精力", nValue));
	local szLog = string.format("%s获得了%s精力", me.szName, nValue);
	Dbg:WriteLog("UseItem",  szLog);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
	return 1;
end

