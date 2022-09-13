-- 文件名　：chenchongzhen_trap.lua
-- 创建者　：zhangjunjie
-- 创建时间：2012-02-21 15:29:03
-- 描述：trap

Require("\\script\\boss\\chenchongzhen\\chenchongzhen_def.lua")

local tbMap = {};

--初始化地图trap，没有特殊的trap点，通用处理
function ChenChongZhen:InitTrap(nMapId)
	local tbMapTrap = Map:GetClass(nMapId);
	for szTrapName, _ in pairs(ChenChongZhen.tbMapTrapName) do
		local tbTrap  = tbMapTrap:GetTrapClass(szTrapName);
		tbTrap.szName = szTrapName;
		for szFnc in pairs(tbMap) do		-- 复制函数
			tbTrap[szFnc] = tbMap[szFnc];
		end
	end
end

-- 定义玩家Trap事件
function tbMap:OnPlayer()
	local pGame = ChenChongZhen:GetGameObjByMapId(me.nMapId) --获得对象
	if not pGame then
		return 0;
	end
	pGame:ProcessTrap(self.szName);
	return 0;
end

ChenChongZhen:InitTrap(ChenChongZhen.nTemplateMapId);