
-- ====================== 文件信息 ======================

-- 大漠古城副本 TRAP 点脚本
-- Edited by peres
-- 2008/03/04 PM 08:26

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbMap			= Map:GetClass(1739);

local tbTrap_1		= tbMap:GetTrapClass("to_lock");
local tbTrap_2		= tbMap:GetTrapClass("to_finalboss");

function tbTrap_1:OnPlayer()
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local nCaptainId = me.GetTempTable("TreasureMap2").nCaptainId;
	if not nCaptainId then
		print("ERROR,damogucheng trap1");
		return;
	end

	local tbInstancing = TreasureMap2:GetInstancingByPlayerId(nCaptainId);
	if not (tbInstancing) then
		return;
	end

	if tbInstancing.nGateLock ~=1 then
		me.NewWorld(nMapId, 1714, 3297);
		Dialog:SendInfoBoardMsg(me, "<color=red>Phải phá phong ấn mới có thể vượt qua!<color>");
		return;
	end;
end;

function tbTrap_2:OnPlayer()
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local nCaptainId = me.GetTempTable("TreasureMap2").nCaptainId;
	if not nCaptainId then
		print("ERROR,damogucheng trap2");
		return;
	end

	local tbInstancing = TreasureMap2:GetInstancingByPlayerId(nCaptainId);
	if not (tbInstancing) then
		return;
	end
	if tbInstancing.nBoss_3_call == 1 and tbInstancing.nBoss_3_kill == 0 then
		me.NewWorld(nMapId, 1904, 3322);		
		return;
	end;
end;
