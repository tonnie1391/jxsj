-------------------------------------------------------
-- 文件名　：wldh_songjin.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-10-15 09:49:03
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbNpc = Npc:GetClass("wldh_songjin");

function tbNpc:OnDialog()
	
	local tbOpt	= 	
	{
		{"加入<color=orange>宋<color>军", self.OnJoin, self, 1},
		{"加入<color=pink>金<color>军", self.OnJoin, self, 2},
		{"返回英雄岛", self.OnLeaveHere, self},
		{"Để ta suy nghĩ thêm"},
	};

	Dialog:Say("您好，这里可以参加宋金战场。", tbOpt);
end

function tbNpc:OnJoin(nCamp)
	
	local tbMapId = 
	{
		[1] = 182,
		[2] = 185,
	};
	
	local tbNpc	= Npc:GetClass("mubingxiaowei");
	local tbNpcBase = tbNpc.tbMapNpc[tbMapId[nCamp]];
	
	tbNpcBase:OnDialog();
end

function tbNpc:OnLeaveHere()
	
	local nGateWay = Transfer:GetTransferGateway();
	if not Wldh.Battle.tbLeagueName[nGateWay] then
		me.NewWorld(1609, 1648, 3377);
		return;
	end
	
	local nMapId = Wldh.Battle.tbLeagueName[nGateWay][2];
	if nMapId then
		me.NewWorld(nMapId, 1648, 3377);
	end
end