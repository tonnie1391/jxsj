-------------------------------------------------------------------
--File: gouhuo.lua
--Author: sunduoliang
--Date: 2007-12-21 21:59
--Describe: 篝火物品脚本
-------------------------------------------------------------------

-- 功能:	call出篝火Npc
-- 参数:	nX, nY	被拾取的篝火的坐标
Task.TbTaskGouHuo = {};
local TbTaskGouHuo = Task.TbTaskGouHuo;
TbTaskGouHuo.GOUHUO_TRAPTXT = "\\setting\\task\\gouhuo.txt";
function TbTaskGouHuo:Init()
	self:LoadGouHuoTrap();
	local tbNpc	= Npc:GetClass("gouhuonpc");
	local nBaseMultip = 300;
	for _, tbMapPos in pairs(self.tbMapTrap) do
		local nMapId		= tbMapPos[1];
		local nPosX			= tbMapPos[2];
		local nPosY			= tbMapPos[3];
		if SubWorldID2Idx(nMapId) >= 0 then
			local pNpc	= KNpc.Add2(tbNpc.nTaskNpcId, 1, -1, nMapId, nPosX , nPosY);		-- 获得篝火Npc
			if pNpc ~= nil then
				tbNpc:InitGouHuo(pNpc.dwId, 4,	-1, 5, 50, nBaseMultip, 0);
				tbNpc:StartNpcTimer(pNpc.dwId);
			end
		end
	end
end

function TbTaskGouHuo:LoadGouHuoTrap()
	local tbFile	= Lib:LoadTabFile(self.GOUHUO_TRAPTXT);
	if tbFile == nil then
		return 0;
	end
	self.tbMapTrap = {};
	for _,tbItem in pairs(tbFile) do
		local nMapId	= tonumber(tbItem.MAPID) or 0;
		local nPosX		= tonumber(tbItem.POSX) or 0;
		local nPosY		= tonumber(tbItem.POSY) or 0;
		if nMapId > 0 then
			table.insert(self.tbMapTrap, {nMapId, nPosX, nPosY});
		end
	end
end
