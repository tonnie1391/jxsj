-------------------------------------------------------
-- 文件名　：wlls_shangren.lua
-- 创建者　：zhouchenfei
-- 创建时间：2009-12-24 14:58:48
-- 文件描述：
-------------------------------------------------------

local tbNpc	= Npc:GetClass("wlls_yaoshang");

-- 和NPC对话
function tbNpc:OnDialog(szCamp)
	local szMsg = "";
	local tbOpt	= {};
	if (GLOBAL_AGENT) then
		szMsg	= "您好，这里可以使用跨服活动专用银两来购买药品。";
		tbOpt	= 	
		{
			{"购买道具", self.OnBuySpeYao, self},
			{"Để ta suy nghĩ lại"},
		};
	else
		szMsg = "当下武林各路英雄汇聚于此，争夺武林至高荣誉，令我的生意大有起色，实在是甚慰我心啊！";
		tbOpt = 
		{
			{"<color=gold>【绑定银两】<color>药品", self.OnBuyYaoByBind, self},
			{"药品", self.OnBuyYao, self},
			{"食物", self.OnBuyCai, self},
		};
	end

	Dialog:Say(szMsg, tbOpt);
end

-- 买药
function tbNpc:OnBuySpeYao()
	me.OpenShop(164,7);
end

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
