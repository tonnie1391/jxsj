-- 礼花

local tbItem = Item:GetClass("gbwlls_staraward");

tbItem.tbAward = {
		[1] = {
				effect = {
					{880,3,2,32400,1,0,1},  -- 幸运
					{879,8,2,64800,1,0,1}, 	-- 打怪经验
					{385,7,2,64800,1,0,1}, 	-- 7级套
					{386,7,2,64800,1,0,1}, 
					{387,7,2,64800,1,0,1}, 
				},
				binditem = {
					{18,1,80,1},
					{18,1,80,1},
				},
				fourtime = {5},	-- 0.5小时4倍时间
			},
		[2] = {
				effect = {
					{880,1,2,32400,1,0,1},  -- 幸运
					{879,7,2,64800,1,0,1}, 	-- 打怪经验
					{385,6,2,64800,1,0,1}, 	-- 6级套
					{386,6,2,64800,1,0,1}, 
					{387,6,2,64800,1,0,1}, 
				},
				binditem = {
					{18,1,80,1},
				},
				fourtime = {5},	-- 0.5小时4倍时间
			},
		[3] = {
				effect = {
					{880,1,2,32400,1,0,1},  -- 幸运
					{879,7,2,64800,1,0,1}, 	-- 打怪经验
					{385,6,2,64800,1,0,1}, 	-- 6级套
					{386,6,2,64800,1,0,1}, 
					{387,6,2,64800,1,0,1}, 
				},
				binditem = {
					{18,1,80,1},
				},
				fourtime = {5},	-- 0.5小时4倍时间	
			},
		[4] = {
				effect = {
					{880,1,2,32400,1,0,1},  -- 幸运
					{879,7,2,64800,1,0,1}, 	-- 打怪经验
				},
				binditem = {
					{18,1,80,1},
				},
			},
	};

function tbItem:OnUse()
	local nStarFlag = it.GetGenInfo(1);
	if (nStarFlag <= 0 or nStarFlag > 4) then
		Dialog:Say("礼花物品出问题，请联系管理员！");
		return 0;
	end

	local nNeedFree = GbWlls.Fun:GetNeedFree(self.tbAward[nStarFlag]);

	if me.CountFreeBagCell() < nNeedFree then
		Dialog:Say(string.format("您的背包空间不够,请整理%s格背包空间.", nNeedFree));
		return 0;
	end	
	GbWlls.Fun:DoExcute(me, self.tbAward[nStarFlag]);
	me.CastSkill(307, 1, -1, me.GetNpc().nIndex);
	return 1;
end
