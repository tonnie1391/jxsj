
-- ====================== 文件信息 ======================

-- 陶朱公疑冢传送出口脚本
-- Edited by peres
-- 2008/03/11 AM 11:38

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbNpc = Npc:GetClass("tao2_tomb_door");

function tbNpc:OnDialog()	
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local nCaptainId = me.GetTempTable("TreasureMap2").nCaptainId;
	if not nCaptainId then
		print("ERROR,tao npc dlg");
		return;
	end

	local tbInstancing = TreasureMap2:GetInstancingByPlayerId(nCaptainId);
	if not tbInstancing then
		return;
	end
end

