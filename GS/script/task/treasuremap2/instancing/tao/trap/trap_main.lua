
-- ====================== 文件信息 ======================

-- 陶朱公疑冢副本 TRAP 点脚本
-- Edited by peres
-- 2008/03/04 PM 08:26

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbMap			= Map:GetClass(1738);

local tbLevel_1		= tbMap:GetTrapClass("to_level2");
local tbLevel_2		= tbMap:GetTrapClass("to_level3");

-- 从第一层上到第二层的 Trap 点
function tbLevel_1:OnPlayer()
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	if not (tbInstancing) then
		return;
	end
	
	local nNum = 0;
	
	if tbInstancing.tbLightOpen then
		for j, i in pairs(tbInstancing.tbLightOpen) do
		--	print ("The tomb pillar: ", j, i);
			nNum = nNum + i;
		end;
		-- 四栈灯都开了，可以通过
		if nNum == 4 then
			return;
		end;
	end;
	
	-- 弹回原处
	nNum = 0;
	me.NewWorld(nMapId, 1612, 3129);
	Dialog:SendInfoBoardMsg(me, "<color=red>Bạn phải hóa giải bùa chú hết 4 cột mới được qua!<color>");

end;

-- 从第二层上到第三层的 Trap 点
function tbLevel_2:OnPlayer()
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	if not (tbInstancing) then
		return;
	end
	
	if not tbInstancing.nSmallBoss_1 or not tbInstancing.nSmallBoss_2 then
		me.NewWorld(nMapId, 1659, 3062);
		return;
	end;
	
--	print("The tomb boss 1 & 2: ", tbInstancing.nSmallBoss_1, tbInstancing.nSmallBoss_2);
	
	-- 两个 BOSS 都杀了，可以通过
	if tbInstancing.nSmallBoss_1 == 1 and tbInstancing.nSmallBoss_2 == 1 then
		return;
	else
		-- 弹回原处
		me.NewWorld(nMapId, 1659, 3062);
		Dialog:SendInfoBoardMsg(me, "<color=red>Một sức mạnh vô hình đã đẩy lui bạn trở lại!<color>");
	end;
end;
