-- 文件名　：addbindmoneyex_base.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-11-11 09:19:45
-- 描  述  ：增加绑定银两通用

local tbBase = Item:GetClass("addbindmoneyex_base");

function tbBase:OnUse()
	local nValue = it.GetGenInfo(1);	
	if me.GetBindMoney() + nValue > me.GetMaxCarryMoney() then
		Dialog:Say("你的绑定银两携带达上限了，请先整理背包的绑定银两。");
		return 0;
	end
	me.AddBindMoney(nValue, Player.emKBINDMONEY_ADD_YOULONG_ITEM);
	local szLog = string.format("%s获得了%s绑定银两", me.szName, nValue);
	Dbg:WriteLog("UseItem",  szLog);			
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
	return 1;
end

function tbBase:GetTip()
	local nValue = it.GetGenInfo(1);
	return "使用可以获得<color=gold>绑定银两"..nValue.."<color>。";
end
