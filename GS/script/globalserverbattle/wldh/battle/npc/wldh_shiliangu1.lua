-------------------------------------------------------
-- 文件名　：wldh_shiliangu1.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-02 15:49:49
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

-- 试炼谷接引人，英雄岛 to 试炼谷
local tbNpc = Npc:GetClass("wldh_shiliangu1");

function tbNpc:OnDialog()

	local tbOpt = {};
	for i, nMapId in ipairs(Wldh.Battle.tbShiliangu) do
		table.insert(tbOpt, {string.format("我想前往试炼谷（%s）", Lib:Transfer4LenDigit2CnNum(i)), self.TransToShiLian, self, nMapId});
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	
	local szMsg = "你好！我可以带你前往试炼谷。在那里，你可以见到来自不同地方的其他参赛选手。在试炼谷内，你可以和他们一些切磋武艺。";
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:TransToShiLian(nMapId)
	me.NewWorld(nMapId, 1597, 3190);
end
