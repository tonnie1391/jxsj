
-- ====================== 文件信息 ======================

-- 陶朱公疑冢传送出口脚本
-- Edited by peres
-- 2008/03/11 AM 11:38

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbNpc = Npc:GetClass("tao_tomb_door");

function tbNpc:OnDialog()
	
	local nTreasureId			= TreasureMap:GetMyInstancingTreasureId(me);
		if not nTreasureId or nTreasureId <= 0 then
			me.Msg("读取进入点时出错，请直接使用回程符返回！");
			return;
		end;
	local tbInfo				= TreasureMap:GetTreasureInfo(nTreasureId);
	local nMapId, nMapX, nMapY	= tbInfo.MapId, tbInfo.MapX, tbInfo.MapY;
	
	Dialog:Say(
		"你现在要离开这里吗？",
		{"是的", self.SendOut, self, me, nMapId, nMapX, nMapY},
		{"暂不"}
	);
end

function tbNpc:SendOut(pPlayer, nMapId, nMapX, nMapY)
	pPlayer.NewWorld(nMapId, nMapX, nMapY);
end
