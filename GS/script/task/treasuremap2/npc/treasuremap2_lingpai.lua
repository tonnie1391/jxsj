-- 文件名  : treasuremap2_lingpai.lua
-- 创建者  : zounan
-- 创建时间: 2010-08-26 10:34:37
-- 描述    : 


function TreasureMap2:OnLingpaiDialog()
	local szMsg = "Mỗi tuần, Nghĩa Quân cung cấp 2 lượt khiêu chiến Tàng Bảo Đồ cho nhân sĩ võ lâm. Ngươi muốn nhận không?"
	local tbOpt = 
	{
		--{"领取碧落谷挑战令牌", TreasureMap2.AddBiluoguLingP, TreasureMap2},
		{"Nhận lệnh bài hàng tuần", TreasureMap2.AddLingpai, TreasureMap2},
		{"Để ta suy nghĩ lại"},
	};
	Dialog:Say(szMsg, tbOpt); -- 去掉每周藏宝图令牌领取
end

function TreasureMap2:CanAddLingpai()
	local nPlayerLevel = self:GetPresentLingPaiLevel(me);
	if nPlayerLevel == 0 then
		return 0, "Cấp độ không đủ";
	end
	
	if me.nFaction == 0 then
		return 0, "Chưa gia nhập môn phái";
	end	
	
	local nCurWeek = tonumber(GetLocalDate("%Y%W"));
	if me.GetTask(self.TSK_GROUP, self.TSK_ADDLINGPAI_WEEK) == nCurWeek then
		return 0, "Tuần này ngươi đã nhận rồi.";
	end	
	
	return 1;
end


function TreasureMap2:AddLingpai()
	local nRes ,szMsg = self:CanAddLingpai();
	if nRes == 0 then
		Dialog:Say(szMsg);
		return;
	end

	local nPlayerLevel   = self:GetPresentLingPaiLevel(me);
	local tbAwardLingpai = self.LINGPAI_PRESENT[nPlayerLevel];
	local nNeedCount = 0;
	for _, tbInfo in ipairs(tbAwardLingpai) do
		nNeedCount = nNeedCount + tbInfo.nCount;
	end
	
	local nFreeCell = me.CountFreeBagCell();
	if nFreeCell < nNeedCount then
		Dialog:Say(string.format("Hành trang không đủ <color=yellow>%d ô<color> trống!",nNeedCount));
		return;
	end;	
	
	local nCurWeek = tonumber(GetLocalDate("%Y%W"));	
	me.SetTask(self.TSK_GROUP, self.TSK_ADDLINGPAI_WEEK, nCurWeek);
	
	local szItemName = "";	
	for _, tbInfo in ipairs(tbAwardLingpai) do
		for i = 1, tbInfo.nCount do
			local pItem = me.AddItem(unpack(tbInfo.tbItem));
			if pItem then
				pItem.Bind(1);	
				szItemName = pItem.szName;
				-- 7天？
				--me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 3600 * 24 * 7));
				pItem.Sync();			
			end
		end
	 -- log 	
		TreasureMap2:WriteLog("令牌产出情况",string.format("%s,%s,系统,%d",me.szName,szItemName, tbInfo.nCount));			
	end	
end
