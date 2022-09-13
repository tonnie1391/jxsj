-------------------------------------------------------
-- 文件名　：newland_npc_trader.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-09-06 17:50:21
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\newland\\newland_def.lua");

local tbNpc = Npc:GetClass("newland_npc_trader");

function tbNpc:OnDialog()
	local szMsg = "这里可以购买铁浮城药品和道具。";
	local tbOpt =
	{
		{"<color=yellow>购买药品<color>", self.BuyYao, self},
		{"<color=yellow>购买图腾<color>", self.BuyItem, self},
		{"Ta hiểu rồi"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:BuyYao()
	me.OpenShop(164,7);
end

function tbNpc:BuyItem()
	me.OpenShop(225,7);
end
