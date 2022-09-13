-------------------------------------------------------
-- 文件名　：kinbattle_npc_trader.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-07 16:39:15
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\mission\\kinbattle\\kinbattle_def.lua");

local tbNpc = Npc:GetClass("kinbattle_npc_trader");

function tbNpc:OnDialog(szCamp)
	local szMsg			= "您好，想买些什么？";
	local tbOpt			= {};
	tbOpt = {
		{"<color=gold>[绑定银两]<color>我要买药", self.OnBuyYaoByBind, self},
		{"我要买药", self.OnBuyYao, self},
		{"<color=gold>[绑定银两]<color>我要买菜", self.OnBuyCaiByBind, self},
		{"我要买菜", self.OnBuyCai, self},
		{"Để ta suy nghĩ lại"},
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 买药
function tbNpc:OnBuyYao()
	me.OpenShop(14,1);
end

function tbNpc:OnBuyYaoByBind()
	me.OpenShop(14,7);
end

-- 买菜
function tbNpc:OnBuyCai()
	me.OpenShop(21,1);
end

function tbNpc:OnBuyCaiByBind()
	me.OpenShop(21,7);
end
