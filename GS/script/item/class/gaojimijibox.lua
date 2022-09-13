-- 高级秘籍宝箱
-- zhouchenfei
-- 2010-10-19 14:33:38

local tbItem = Item:GetClass("gaojimijibox");

tbItem.tbGDPL = {
			[1] = {
					[1] = {1,14,1,3},			-- 刀少林
					[2] = {1,14,2,3}, 			-- 棍少林
				},
			[2]	= {
					[1] = {1,14,3,3}, 			-- 枪天王
					[2] = {1,14,4,3}, 			-- 锤天王
				},
			[3] = {
					[1] = {1,14,5,3},			-- 陷阱唐门
					[2] = {1,14,6,3},			-- 袖箭唐门
				},
			[4] = {
					[1] = {1,14,7,3},			-- 刀五毒
					[2] = {1,14,8,3}, 			-- 掌五毒
				},
			[5] = {
					[1] = {1,14,9,3},			-- 掌峨嵋
					[2] = {1,14,10,3}, 			-- 辅助峨嵋
				},
			[6]	= {
					[1] = {1,14,11,3},			-- 剑翠烟
					[2] = {1,14,12,3}, 			-- 刀翠烟	
				},
			[7] = {
					[1] = {1,14,13,3},			-- 掌丐
					[2] = {1,14,14,3},			-- 棍丐帮		
				},
			[8] = {
					[1] = {1,14,15,3},			-- 战天忍
					[2] = {1,14,16,3}, 			-- 魔天忍
				},
			[9] = {
					[1] = {1,14,17,3},			-- 气武当
					[2] = {1,14,18,3},			-- 剑武当	
				},
			[10] = {
					[1] = {1,14,19,3},			-- 刀昆仑
					[2] = {1,14,20,3}, 			-- 剑昆仑		
				},
			[11] = {
					[1] = {1,14,21,3},			-- 锤明
					[2] = {1,14,22,3},			-- 剑明
				},
			[12] = {
					[1] = {1,14,23,3},			-- 指段
					[2] = {1,14,24,3}, 			-- 气段		
				},
			[13] = {
					[1] = {1,14,25,3},			-- 剑古墓
					[2] = {1,14,26,3}, 			-- 针古墓	
				},
	};

function tbItem:OnUse()
	local nFaction = me.nFaction;
	if (nFaction <= 0) then
		Dialog:Say("您还没加入门派，无法获取高级秘籍，请尽快加入门派！");
		return;
	end
	
	local tbItem = self.tbGDPL[nFaction];
	
	local szMsg = "通过高级秘籍宝箱你将获得下列高级秘籍：";
	local tbOpt = {};
	
	for nIndex, tbInfo in pairs(tbItem) do
		table.insert(tbOpt, {string.format("<color=yellow>%s<color>", KItem.GetNameById(unpack(tbInfo))), self.OnSureGetMiji, self, nIndex, it.dwId});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:OnSureGetMiji(nIndex, nItemId, nFlag)
	local nFaction = me.nFaction;
	if (nFaction <= 0) then
		Dialog:Say("您还没加入门派，无法获取高级秘籍，请尽快加入门派！");
		return;
	end

	if me.CountFreeBagCell() < 1 then
		Dialog:Say((string.format("你的背包不足，需要%s格背包空间。", 1)));
		return 0;
	end

	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	
	local tbInfo = self.tbGDPL[nFaction][nIndex];
	
	local szItemName = KItem.GetNameById(unpack(tbInfo));
	if (not nFlag or nFlag ~= 1) then
		Dialog:Say(string.format("您选择获取<color=yellow>%s<color>，确定吗？", szItemName), 
			{
				{"Xác nhận", self.OnSureGetMiji, self, nIndex, nItemId, 1},
				{"Để ta suy nghĩ thêm"},	
			});
		return;
	end
	
	local pIt = me.AddItem(unpack(tbInfo));
	if (not pIt) then
		Dbg:WriteLog("Item", "GaoJiMiJiBox", me.szName, szItemName, "Get Failed!!!!!!!!!!!!!");
	end
	pItem.Delete(me);
end

