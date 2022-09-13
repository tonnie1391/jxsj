
-- ====================== 文件信息 ======================

-- 千琼宫副本 TRAP 点脚本
-- Edited by peres
-- 2008/07/25 AM 11:39

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbMap			= Map:GetClass(287);

local tbTrap_1		= tbMap:GetTrapClass("trap_1");		-- 打败第一个 BOSS 后开启
local tbTrap_2		= tbMap:GetTrapClass("trap_2");		-- 打败第二个 BOSS 后开启
local tbTrap_3		= tbMap:GetTrapClass("trap_3");		-- 打败第三个 BOSS 后开启
local tbTrap_4		= tbMap:GetTrapClass("trap_4");		-- 打败第四个 BOSS 后开启

local tbTrap_Start	= tbMap:GetTrapClass("trap_start");	-- 一开始触发兔子行走的脚本


function tbTrap_Start:OnPlayer()
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	local pRabbit		= KNpc.GetById(tbInstancing.tbNpcIndex[1]);
	
	local tbRabbitRun	= {
		{1589, 3211},
		{1603, 3197},
		{1617, 3182},
		{1664, 3138},
		{1668, 3123},
		{1684, 3119},
	}
	
	if pRabbit then
		pRabbit.AI_ClearPath();
		for _,Pos in ipairs(tbRabbitRun) do
			if (Pos[1] and Pos[2]) then
				pRabbit.AI_AddMovePos(tonumber(Pos[1])*32, tonumber(Pos[2])*32)
			end
		end;
		pRabbit.SetNpcAI(9, 0,  1, -1, 25, 25, 25, 0, 0, 0, me.GetNpc().nIndex);
	end;
end;


function tbTrap_1:OnPlayer()
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if tbInstancing.tbBossDown[1]~=1 then
		-- 弹回原处
		me.NewWorld(nMapId, 1693, 3140);
		Dialog:SendInfoBoardMsg(me, "<color=red>一股莫名的力量把你推了回来！<color>");
	end;
end;

function tbTrap_2:OnPlayer()
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if tbInstancing.tbBossDown[2]~=1 then
		-- 弹回原处
		me.NewWorld(nMapId, 1552, 2935);
		Dialog:SendInfoBoardMsg(me, "<color=red>一股莫名的力量把你推了回来！<color>");
	end;
end;

function tbTrap_3:OnPlayer()
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if tbInstancing.tbBossDown[3]~=1 then
		-- 弹回原处
		me.NewWorld(nMapId, 1605, 2837);
		Dialog:SendInfoBoardMsg(me, "<color=red>一股莫名的力量把你推了回来！<color>");
	end;
end;

function tbTrap_4:OnPlayer()
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if tbInstancing.tbBossDown[4]~=1 then
		-- 弹回原处
		me.NewWorld(nMapId, 1776, 2721);
		Dialog:SendInfoBoardMsg(me, "<color=red>一股莫名的力量把你推了回来！<color>");
	end;
end;
