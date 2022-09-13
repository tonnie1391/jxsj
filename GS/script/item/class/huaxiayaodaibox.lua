-- 华夏腰带宝箱
-- zhouchenfei
-- 2010-10-19 14:33:38

local tbItem = Item:GetClass("huaxiayaodaibox");

tbItem.tbItemList = {
		[0] = {
				[Env.SERIES_METAL]	= {2,8,651,10},
				[Env.SERIES_WOOD]	= {2,8,652,10},
				[Env.SERIES_WATER]	= {2,8,653,10},
				[Env.SERIES_FIRE]	= {2,8,654,10},
				[Env.SERIES_EARTH]	= {2,8,655,10},
			},
		[1]	= {
				[Env.SERIES_METAL]	= {2,8,656,10},
				[Env.SERIES_WOOD]	= {2,8,657,10},
				[Env.SERIES_WATER]	= {2,8,658,10},
				[Env.SERIES_FIRE]	= {2,8,659,10},
				[Env.SERIES_EARTH]	= {2,8,660,10},
			},
	};

function tbItem:OnUse()
	local nSex = me.nSex;
	local tbSeriesItem = self.tbItemList[nSex];
	if (not tbSeriesItem) then
		Dialog:Say("没有性别不可能吧！");
		return;
	end
	
	local szMsg = "通过华夏腰带宝箱你将获得下列腰带中的一种请选择：";
	local tbOpt = {};
	
	for nIndex, tbInfo in pairs(tbSeriesItem) do
		table.insert(tbOpt, {string.format("<color=yellow>%s（%s）<color>", KItem.GetNameById(unpack(tbInfo)), Env.SERIES_NAME[nIndex]), self.OnSureGetYaodai, self, nIndex, it.dwId});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:OnSureGetYaodai(nIndex, nItemId, nFlag)
	local nSex = me.nSex;
	local tbSeriesItem = self.tbItemList[nSex];
	if (not tbSeriesItem) then
		Dialog:Say("没有性别不可能吧！");
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
	
	local tbInfo = tbSeriesItem[nIndex];
	
	local szItemName = KItem.GetNameById(unpack(tbInfo));
	if (not nFlag or nFlag ~= 1) then
		Dialog:Say(string.format("您选择获取<color=yellow>%s（%s）<color>，确定吗？", szItemName, Env.SERIES_NAME[nIndex]), 
			{
				{"Xác nhận", self.OnSureGetYaodai, self, nIndex, nItemId, 1},
				{"Để ta suy nghĩ thêm"},	
			});
		return;
	end
	
	local pIt = me.AddItem(unpack(tbInfo));
	if (not pIt) then
		Dbg:WriteLog("Item", "HuaXiaYaoDai", me.szName, szItemName, "Get Failed!!!!!!!!!!!!!");
	end
	pItem.Delete(me);
end

