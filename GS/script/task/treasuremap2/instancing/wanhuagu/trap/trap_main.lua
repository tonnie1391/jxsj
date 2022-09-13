
-- ====================== 文件信息 ======================

-- 万花谷副本 TRAP 点脚本
-- Edited by peres
-- 2008/11/10 PM 03:03

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbMap			= Map:GetClass(1741);

local tbTrap_1		= tbMap:GetTrapClass("trap_1");
local tbTrap_2		= tbMap:GetTrapClass("trap_2");

function tbTrap_1:OnPlayer()
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	
	if tbInstancing.nDoorOpen ~= 1 then
		me.NewWorld(nMapId, 1666, 3053);
	end;
end;


function tbTrap_2:OnPlayer()
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	
	if tbInstancing.nBoss_3 ~= 1 then
		me.NewWorld(nMapId, 1676, 2975);
		Dialog:SendInfoBoardMsg(me, "<color=red>Những chiếc gai tím ngăn cản không cho bạn vượt qua.<color>");
	end;
end;