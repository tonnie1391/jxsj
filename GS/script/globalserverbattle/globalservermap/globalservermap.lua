-- 文件名　：globalservermap.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-08-24 20:23:32
-- 描  述  ：
-- me.NewWorld(1609, 1648, 3377)

local tbMapId ={{1609, 1615}, {1644, 1650}};

local tbMap = {};

function tbMap:OnEnter2()
	me.SetRevivePos(me.nMapId, 1);
end

for _, varMap in pairs(tbMapId) do
	for nMapId = varMap[1], varMap[2] do
		local tbBattleMap = Map:GetClass(nMapId);
		for szFnc in pairs(tbMap) do
			tbBattleMap[szFnc] = tbMap[szFnc];
		end
	end
end
