-- 九龙项链宝箱
-- zhouchenfei
-- 2010-10-19 14:33:38

local tbItem = Item:GetClass("jiulongxianglianbox");

tbItem.tbItemList = {
			[Env.SERIES_METAL]	= {2,5,341,10},
			[Env.SERIES_WOOD]	= {2,5,342,10},
			[Env.SERIES_WATER]	= {2,5,343,10},
			[Env.SERIES_FIRE]	= {2,5,344,10},
			[Env.SERIES_EARTH]	= {2,5,345,10},
	};

function tbItem:OnUse()
	
	local szMsg = "通过九龙项链宝箱你将获得下列项链中的一种请选择：";
	local tbOpt = {};
	
	for nIndex, tbInfo in pairs(tbItem.tbItemList) do
		table.insert(tbOpt, {string.format("<color=yellow>%s（%s）<color>", KItem.GetNameById(unpack(tbInfo)), Env.SERIES_NAME[nIndex]), self.OnSureGetYaodai, self, nIndex, it.dwId});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:OnSureGetYaodai(nIndex, nItemId, nFlag)
	local tbSeriesItem = self.tbItemList;

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
		Dbg:WriteLog("Item", "Jiulongxianglianbox", me.szName, szItemName, "Get Failed!!!!!!!!!!!!!");
	end
	pItem.Delete(me);
end

