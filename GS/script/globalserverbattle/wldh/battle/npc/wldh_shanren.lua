-------------------------------------------------------
-- 文件名　：wldh_shanren.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-02 20:14:02
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbNpc	= Npc:GetClass("wldh_shanren");

-- 和NPC对话
function tbNpc:OnDialog(szCamp)

	local tbOpt	= 	
	{
		{"购买道具", self.OnBuyYao, self},
		{"Để ta suy nghĩ lại"},
	};

	Dialog:Say("您好，这里可以使用武林大会专用银两来购买药品。", tbOpt);
end

-- 买药
function tbNpc:OnBuyYao()
	me.OpenShop(164,7);
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
