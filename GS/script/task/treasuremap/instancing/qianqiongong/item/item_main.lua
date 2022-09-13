
-- ====================== 文件信息 ======================

-- 千琼宫副本 ITEM 脚本
-- Edited by peres
-- 2008/08/07 PM 02:30

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbItem_Chip 	= Item:GetClass("purepalace_chip");		-- 碎片
local tbItem_Plate	= Item:GetClass("purepalace_plate");	-- 令牌

local CHIP_NUM		= 5;	-- 合成一张令牌需要的碎片

function tbItem_Chip:OnUse()
	local nChips		= me.GetItemCountInBags(18, 1, 185, 1);
	
	if nChips < CHIP_NUM then
		Dialog:SendInfoBoardMsg(me, "<color=red>必须有<color><color=yellow>"..CHIP_NUM.."块碎片<color><color=red>才能合成令牌！<color>");
		return;
	else
		me.ConsumeItemInBags(CHIP_NUM, 18, 1, 185, 1);
		me.AddItem(18, 1, 186, 1);
		me.Msg("您得到了一块<color=yellow>千琼宫令牌<color>！");
	end;
end;


function tbItem_Plate:OnUse()
	local nMapId, nMapX, nMapY	= me.GetWorldPos();
	
	if nMapId ~= 39 then
		Dialog:SendInfoBoardMsg(me, "<color=red>你必须前往<color><color=yellow>祁连山<color><color=red>才能使用这张令牌！<color>");
		return;
	end;

	if (me.nTeamId == 0) then
		me.Msg("只有组队才能开启千琼宫的入口！");
		return;
	end

	Dialog:Say("您现在想要开启千琼宫的入口吗？<enter><enter><color=yellow>建议您组成有 6 名达到 85 级或更高成员的队伍来挑战这个副本<color>。", {
			  {"是的",		self.OpenInstancing, self, me, it},
			  {"再等等"},
			});

end;


function tbItem_Plate:OpenInstancing(pPlayer, pItem)
	
	if not pPlayer or not pItem then
		return;
	end;
	
	-- 临时写法
	if (pPlayer.GetTask(2066, 287)>=6) then
		Dialog:SendInfoBoardMsg(me, "该副本一周只能进入 <color=yellow>6<color> 次！");
		return;
	end;
	
	if (pPlayer.nTeamId == 0) then
		pPlayer.Msg("只有组队才能开启千琼宫的入口！");
		return;
	end

	if pPlayer.GetItemCountInBags(18, 1, 186, 1) < 1 then
		return;
	end;
	
--	pPlayer.ConsumeItemInBags(1, 18, 1, 186, 1);
	pItem.Delete(me);
	TreasureMap:AddInstancing(pPlayer, 43);
	TreasureMap:NotifyAroundPlayer(pPlayer, "<color=yellow>"..pPlayer.szName.."打开了一个通往千琼宫的入口！<color>");
end;