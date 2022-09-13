-- 文件名　：huatuanjincu.lua
-- 创建者　：zhongjunqi
-- 创建时间：2011-06-20 09:46:10
-- 描  述  ：周年庆花团锦簇道具

Require("\\script\\event\\specialevent\\zhounianqing2011\\zhounianqing2011_def.lua");
SpecialEvent.ZhouNianQing2011 = SpecialEvent.ZhouNianQing2011 or {};
local ZhouNianQing2011 = SpecialEvent.ZhouNianQing2011 or {};

-- 材料
local tbMaterial = Item:GetClass("zhounianqing2011_flower_material");

function tbMaterial:OnUse()
	-- 检测玩家是否能够做花，需要3个道具加上2个月影
	local bRet, szMsg = ZhouNianQing2011:CheckCanMakeFlower();
	if (bRet == 0) then
		Dialog:Say(szMsg);
		return 0;
	end
	local szMsg;
	if TimeFrame:GetState("OpenLevel150") == 1 then
	 	szMsg = string.format("制作<color=yellow>3簇庆典鲜花<color>需要花费<color=yellow>3个美丽花束<color>以及<color=yellow>1个月影之石<color>。\n将庆典鲜花放在城市的花童附近可获得丰厚回报。每天每位侠客可摆放6簇庆典鲜花。\n\n确定制作？");
	else
		szMsg = string.format("制作<color=yellow>3簇庆典鲜花<color>需要花费<color=yellow>3个美丽花束<color>以及<color=yellow>1个周年庆绿叶<color>。\n将庆典鲜花放在城市的花童附近可获得丰厚回报。每天每位侠客可摆放6簇庆典鲜花。\n\n确定制作？");
	end
	local tbOpt = 
	{
		{"确定制作", self.ConfirmMakeFlower, self},
		{"Để ta suy nghĩ thêm"},	
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

-- 确认做花
function tbMaterial:ConfirmMakeFlower()
	local bRet, szMsg = ZhouNianQing2011:CheckCanMakeFlower();
	if (bRet == 0) then
		Dialog:Say(szMsg);
		return;
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
		
	GeneralProcess:StartProcess("制作庆典鲜花中", 5 * Env.GAME_FPS, 
		{ZhouNianQing2011.MakeFlower, ZhouNianQing2011, me.nId}, nil, tbEvent);
	
end

-- 庆典献花
local tbFlower = Item:GetClass("zhounianqing2011_flower");

function tbFlower:OnUse()
	local nRet, szMsg = ZhouNianQing2011:CheckCanShowFlower(me);
	if nRet ~= 1 then
		Dialog:Say(szMsg);
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
		
	GeneralProcess:StartProcess("摆放庆典鲜花中", 5 * Env.GAME_FPS, 
		{ZhouNianQing2011.ShowFlower, ZhouNianQing2011, me.nId, it.dwId}, nil, tbEvent);	-- 没有使用鲜花id
	return 0;
end

