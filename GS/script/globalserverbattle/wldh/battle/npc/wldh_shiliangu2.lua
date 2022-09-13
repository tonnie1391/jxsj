-------------------------------------------------------
-- 文件名　：wldh_shiliangu2.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-02 15:59:00
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

-- 英雄岛接引人，试炼谷 to 英雄岛
local tbNpc = Npc:GetClass("wldh_shiliangu2");

function tbNpc:OnDialog()

	local tbOpt = 
	{
		{"我想离开试炼谷", self.TransToYingxiong, self},	
		{"Để ta suy nghĩ lại"},
	};
		
	local szMsg = "你好！我可以带你离开试炼谷，回到英雄岛。";
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:TransToYingxiong()
	Transfer:NewWorld2GlobalMap(me);	
--	local nGateWay = Transfer:GetTransferGateway();
--	
--	if not Wldh.Battle.tbLeagueName[nGateWay] then
--		me.NewWorld(1609, 1680, 3269);
--		return 0;
--	end
--	
--	local nMapId = Wldh.Battle.tbLeagueName[nGateWay][2];
--	
--	if nMapId then
--		me.NewWorld(nMapId, 1680, 3269);
--	end
end
