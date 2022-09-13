-------------------------------------------------------------------
--File: 	factionshop_gs.lua
--Author: 	sunduoliang
--Date: 	2008-3-14
--Describe:	门派掌门人处购买门派竞技装备
-------------------------------------------------------------------
local tbFactionShop	= {};	-- 	门派战休息时间活动
FactionBattle.tbFactionShop = tbFactionShop;

tbFactionShop.tbFactionShopID =
{
	[Env.FACTION_ID_SHAOLIN]		= 25, -- 少林
	[Env.FACTION_ID_TIANWANG]		= 26, --天王掌门
	[Env.FACTION_ID_TANGMEN]		= 27, --唐门掌门
	[Env.FACTION_ID_WUDU]			= 29, --五毒掌门
	[Env.FACTION_ID_EMEI]			= 31, --峨嵋掌门
	[Env.FACTION_ID_CUIYAN]			= 32, --翠烟掌门
	[Env.FACTION_ID_GAIBANG]		= 34, --丐帮掌门
	[Env.FACTION_ID_TIANREN]		= 33, --天忍掌门
	[Env.FACTION_ID_WUDANG]			= 35, --武当掌门
	[Env.FACTION_ID_KUNLUN]			= 36, --昆仑掌门
	[Env.FACTION_ID_MINGJIAO]		= 28, --明教掌门
	[Env.FACTION_ID_DALIDUANSHI]	= 30, --大理段氏掌门
	[Env.FACTION_ID_GUMU]			= 290, --古墓掌门
}

function tbFactionShop:OpenShop(nFaction)
	me.OpenShop(self.tbFactionShopID[nFaction], 1) --使用声望购买
end
