-------------------------------------------------------------------
--File: gouhuo.lua
--Author: sunduoliang
--Date: 2007-12-21 21:59
--Describe: 篝火物品脚本
-------------------------------------------------------------------

-- 功能:	call出篝火Npc
-- 参数:	nX, nY	被拾取的篝火的坐标
Task.TbEventGouHuo = {};
local TbEventGouHuo = Task.TbEventGouHuo;
TbEventGouHuo.GOUHUO_TRAPTXT = "\\setting\\task\\gouhuo_event.txt";
function TbEventGouHuo:Init()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate > Esport.SNOWFIGHT_STATE[2] then
		return 0;
	end
	
	self:LoadGouHuoTrap();
	local tbNpc	= Npc:GetClass("gouhuonpc");
	local nBaseMultip = 100;
	for _, tbMapPos in pairs(self.tbMapTrap) do
		local nMapId		= tbMapPos[1];
		local nPosX			= tbMapPos[2];
		local nPosY			= tbMapPos[3];
		local nNpcId		= tbMapPos[4];
		if SubWorldID2Idx(nMapId) >= 0 then
			local pNpc	= KNpc.Add2(nNpcId, 1, -1, nMapId, nPosX , nPosY);
			if pNpc ~= nil then
				tbNpc:InitGouHuo(pNpc.dwId, 5,	-1, 6, 50, nBaseMultip, 0, 0);
				tbNpc:StartNpcTimer(pNpc.dwId);
			end
		end
	end
end

function TbEventGouHuo:LoadGouHuoTrap()
	local tbFile	= Lib:LoadTabFile(self.GOUHUO_TRAPTXT);
	if tbFile == nil then
		return 0;
	end
	self.tbMapTrap = {};
	for _,tbItem in pairs(tbFile) do
		local nNpcId	= tonumber(tbItem.NPCID) or 0;
		local nMapId	= tonumber(tbItem.MAPID) or 0;
		local nPosX		= tonumber(tbItem.POSX) or 0;
		local nPosY		= tonumber(tbItem.POSY) or 0;
		if nMapId > 0 then
			table.insert(self.tbMapTrap, {nMapId, nPosX, nPosY, nNpcId});
		end
	end
end

ServerEvent:RegisterServerStartFunc(Task.TbEventGouHuo.Init, Task.TbEventGouHuo);
