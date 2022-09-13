-------------------------------------------------------
-- 文件名　：marry_map.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-05 01:21:21
-- 文件描述：
-------------------------------------------------------

Require("\\script\\marry\\logic\\marry_def.lua");

if (not MODULE_GAMESERVER) then
	return 0;
end

-- map
local tbMap = Marry.Map or {};
Marry.Map = tbMap;

function tbMap:OnEnter(szParam)
	me.SetLogoutRV(1);
end;

function tbMap:OnLeave(szParam)

end;
-- end

-- trap
local tbTrap = Marry.Trap or {};
Marry.Trap = tbTrap;

-- on player trap
function tbTrap:OnPlayer()
	if self.nMapX and self.nMapY and self.nLimit then
		local nLevel = Marry:GetWeddingPlayerLevel(me.nMapId, me.szName);
		if nLevel < self.nLimit then
			me.NewWorld(me.nMapId, self.nMapX, self.nMapY);
		elseif self.nLimit == 4 then
			if Marry:CheckPlayerOnStage(me.nMapId, me.szName) == 1 then
				Marry:RemovePlayerOnStage(me.nMapId, me.szName);
				me.NewWorld(me.nMapId, self.nMapX, self.nMapY);
			else
				Marry:AddPlayerOnStage(me.nMapId, me.szName);
				local nMapLevel = Marry:GetWeddingMapLevel(me.nMapId, me.szName);
				me.NewWorld(me.nMapId, unpack(Marry.MAP_STAGE_POS[nMapLevel]));
			end
		end
	end
end
-- end

-- 地图和trap挂接
function Marry:LinkMapTrap(nLevel, nMapId)
	-- 地图模板
	local tbDynMap = Map:GetClass(nMapId);
	-- 设置等级
	tbDynMap.nMapLevel = nLevel;
	for szFnc in pairs(Marry.Map) do
		-- 复制函数
		tbDynMap[szFnc] = Marry.Map[szFnc];
	end
	-- 遍历trap名字
	for nIndex, szTrapName in pairs(Marry.MAP_TRAP_NAME) do
		-- 根据等级生成
		local tbDynTrap = tbDynMap:GetTrapClass(string.format(szTrapName, nLevel));
		-- 设置坐标
		tbDynTrap.nMapX = Marry.MAP_TRAP_POS[nLevel][nIndex][1];
		tbDynTrap.nMapY = Marry.MAP_TRAP_POS[nLevel][nIndex][2];
		tbDynTrap.nLimit = Marry.MAP_TRAP_POS[nLevel][nIndex][3];
		for szFncTrap in pairs(Marry.Trap) do
			-- 复制函数
			tbDynTrap[szFncTrap] = Marry.Trap[szFncTrap];
		end
	end
end
