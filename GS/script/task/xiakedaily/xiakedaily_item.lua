-- 文件名　：xiakedaily_item.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-03-17 09:33:21
-- 描  述  ：
local tbClass = Item:GetClass("xiakegift")

tbClass.tbAward = 
{
	-- g,d,p,l,bind,num,bags
	{18, 1, 114, 9, 1, 1, 1, "Huyền tinh Vô hạ (cấp 9)"}	
};

function tbClass:OnUse()
	local nNeedFreeBag = 0;
	for _, tbTemp in ipairs(self.tbAward) do
		nNeedFreeBag = nNeedFreeBag + tbTemp[7];
	end
	if me.CountFreeBagCell() < nNeedFreeBag then
		local szMsg = string.format("Hành trang không đủ <color=yellow>%s<color> ô trống.", nNeedFreeBag);
		me.Msg(szMsg)
		--Dialog:Say(szMsg)
		return 0;
	end
	local szMsg = "Thành công Sử dụng hiệp nghĩa lễ bao, thu được"
	for nIndex, tbTemp in ipairs(self.tbAward) do
		szMsg = szMsg .. string.format("<color=yellow>%s<color> %s", tbTemp[6], tbTemp[8]);
		for i = 1, tbTemp[6] do
			local pItem = me.AddItem(tbTemp[1], tbTemp[2], tbTemp[3], tbTemp[4]);
			if pItem then
				pItem.Bind(tbTemp[5]);
			end
		end
		if nIndex < #self.tbAward then
			szMsg = szMsg .. "，";
		else
			szMsg = szMsg .. "。"
		end
	end
	me.Msg(szMsg);
	return 1;
end
