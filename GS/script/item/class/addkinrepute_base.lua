-- 文件名　：addkinrepute_base.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-11-11 09:25:36
-- 描  述  ：增加江湖威望通用
-- ExtParam1:多少江湖威望


local tbBase = Item:GetClass("addkinrepute_base");

function tbBase:OnUse()
	local nValue = it.GetExtParam(1);
	me.AddKinReputeEntry(nValue);
	--me.Msg(string.format("您获得了<color=yellow>%s点<color>江湖威望",nValue))
	local szLog = string.format("%s获得了%s江湖威望", me.szName, nValue);
	Dbg:WriteLog("UseItem",  szLog);			
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);		
	
	return 1;
end

