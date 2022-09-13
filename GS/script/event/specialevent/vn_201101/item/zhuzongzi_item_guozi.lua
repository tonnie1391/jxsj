-- 文件名　：zhuzongzi_item_guozi.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-21 16:10:10
-- 描  述  ：


SpecialEvent.ZongZi2011 = SpecialEvent.ZongZi2011 or {};
local tbZongZi = SpecialEvent.ZongZi2011 or {};

local tbItem	= Item:GetClass("guozi201101_vn");

function tbItem:OnUse()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < tbZongZi.OPEN_DAY or nDate > tbZongZi.CLOSE_DAY then
		Dialog:Say("不在活动期间内！", {"知道了"});
		return 0;
	end
	if me.nLevel < tbZongZi.LEVEL_LIMIT then
		Dialog:Say("您等级不足60级，无法煮粽子！",{"知道了"});
		return 0;
	end
	if "city" ~= GetMapType(me.nMapId) then
		Dialog:Say("该物品只能在各大主城使用。", {"知道了"});
		return 0;
	end
	
	local szMsg = "煮粽子可能需要花大量的时间和木柴，你确定在这里煮粽子吗？";
	local tbOpt = 
	{
		{"激活煮粽子", self.Boil, self, it.dwId},
		{"我在考虑下"},
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end


function tbItem:Boil(nItemId)
	local nRes, szMsg = tbZongZi:CheckCanBoil(me);
	if nRes == 0 then
		Dialog:Say(szMsg, {"知道了"});
		return 0;
	end
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	}
		
	GeneralProcess:StartProcess("激活中", 5 * Env.GAME_FPS, 
		{SpecialEvent.ZongZi2011.StartBoil, SpecialEvent.ZongZi2011, me.nId, nItemId}, nil, tbEvent);
end