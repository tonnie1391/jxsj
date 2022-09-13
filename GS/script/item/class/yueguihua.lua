-- 文件名　：yueguihua.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-09-07 14:13:54
-- 描  述  ：

local tbItem = Item:GetClass("yueguihua");
function tbItem:OnUse()
	local nFlag = Player:AddRepute(me, 10, 1, 10);
	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		me.Msg("您已经达到民族大团圆声望最高等级，将无法使用月桂花");
		return;
	end	
	me.Msg("您获得<color=yellow>10点<color>民族大团圆声望。");
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "使用月桂花获得10点声望");
	Dbg:WriteLog("UseItem","使用月桂花获得10点声望",me.szName);	
	return 1;
end

