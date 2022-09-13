-- yelanguanmaskbox.lua
-- zhouchenfei
-- 2010-12-27 15:37:43
-- 夜岚关面具宝箱

local tbItem = Item:GetClass("yelanguanmaskbox");

tbItem.tbItemList = {
		[Env.SEX_MALE]		= {1,13,132,1},
		[Env.SEX_FEMALE]	= {1,13,133,1},
	};
	
tbItem.nMaskTime = 3600 * 24 * 30;

function tbItem:OnUse()
	local szMsg = "通过夜岚关面具宝箱你将获得下列面具中的一种请选择：";
	local tbOpt = {};
	
	for nIndex, tbInfo in pairs(self.tbItemList) do
		table.insert(tbOpt, {string.format("<color=yellow>%s（%s）<color>", KItem.GetNameById(unpack(tbInfo)), Env.SEX_NAME[nIndex]), self.OnSureGetMask, self, nIndex, it.dwId});
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:OnSureGetMask(nIndex, nItemId, nFlag)

	if me.CountFreeBagCell() < 1 then
		Dialog:Say((string.format("你的背包不足，需要%s格背包空间。", 1)));
		return 0;
	end

	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	
	local tbInfo = self.tbItemList[nIndex];
	
	local szItemName = KItem.GetNameById(unpack(tbInfo));
	if (not nFlag or nFlag ~= 1) then
		Dialog:Say(string.format("您选择获取<color=yellow>%s<color>，确定吗？", szItemName), 
			{
				{"Xác nhận", self.OnSureGetMask, self, nIndex, nItemId, 1},
				{"Để ta suy nghĩ thêm"},	
			});
		return;
	end
	
	local pIt = me.AddItem(unpack(tbInfo));
	if (not pIt) then
		Dbg:WriteLog("Item", "YeLanGuanMaskBox", me.szName, szItemName, "Get Failed!!!!!!!!!!!!!");
	end

	local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + self.nMaskTime);
	me.SetItemTimeout(pIt,szDate);
	
	pItem.Delete(me);
end