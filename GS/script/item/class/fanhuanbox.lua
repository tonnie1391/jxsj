-- zhouchenfei
-- 2012/9/13 11:19:12
-- 返还宝箱

local tbFanHuan = Item:GetClass("fanhuanbox");

tbFanHuan.tbFanHuanList = {
	szName = "玲珑宝盒",
	tbChooseList = {
		-- szName, {g,d,p,l}, nCount, nBind, nTime
			{ "5000绑金返利", { 18, 1, 1309, 3 }, 1, 1, 30 * 24 * 60 * 60, "绑定金币返还券（5000点）"},
			{ "500万绑银返利", { 18, 1, 1352, 3}, 5, 1, 30 * 24 * 60 * 60, "绑定银两返还券（100万点）"},
		},
	};

function tbFanHuan:OnUse()
	local tbOpt = {};
	local tbOneFanHuanBox = self.tbFanHuanList;
	
	if (not tbOneFanHuanBox) then
		Dialog:Say("返还宝箱异常，请联系客服！");
		return 0;
	end
	
	local szMsg = string.format("恭喜你即将获得<color=yellow>奇珍阁5000金币道具购买<color>的超值返利券，请选择你需要的返利类型：", tbOneFanHuanBox.szName);

	for i, tbItem in pairs(tbOneFanHuanBox.tbChooseList) do
		local tbOneItem = tbItem[2];
		local szTip = "<item=".. tbOneItem[1] .. "," .. tbOneItem[2] .. "," .. 
					tbOneItem[3] .. "," .. tbOneItem[4]..">"
		local tbInfo = {"选择<color=yellow>" .. tbItem[1] .. "<color>" .. szTip, self.OnGetItem, self, it.dwId, i};
		table.insert(tbOpt, tbInfo);
	end	
	
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	
	Dialog:Say(szMsg, tbOpt);
	
	return 0;
end

function tbFanHuan:OnGetItem(dwId, nIndex, nCheck)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		Dialog:Say("你的返还券宝箱已过期。");
		return 0;
	end
	
	local tbOneFanHuanBox = self.tbFanHuanList;
	if (not tbOneFanHuanBox) then
		Dialog:Say("你的返还券宝箱异常，请联系客服！");
		return 0;
	end

	local tbItem = tbOneFanHuanBox.tbChooseList[nIndex];
	
	if (not tbItem) then
		Dialog:Say("道具异常");
		return 0;
	end
	
	local nNeedFree = tbItem[3];	
	
	if (nNeedFree > me.CountFreeBagCell()) then
		Dialog:Say(string.format("您的背包剩余空间不足<color=yellow>%s<color>格，请整理后再来领取！", nNeedFree));
		return 0;
	end
	
	local szOpName = "";
	if (1 == nIndex) then
		szOpName = tbOneFanHuanBox.tbChooseList[2][1];
	else
		szOpName = tbOneFanHuanBox.tbChooseList[1][1];
	end
	if (not nCheck or nCheck ~= 1) then
		Dialog:Say(string.format("您即将获得<color=yellow>%s<color>，你还可以选择领取获得<color=yellow>%s<color>，确认领取吗？", tbItem[1], szOpName), {
				{string.format("确定领取<color=yellow>%s<color>", tbItem[1]), self.OnGetItem, self, dwId, nIndex, 1},
				{"Để ta suy nghĩ thêm"},
			});
		return 0;
	end

	local nRet = pItem.Delete(me);
	if nRet ~= 1 then
		Dbg:WriteLog("fanhuanbox", string.format("%s 扣除%s失败", me.szName, tbOneFanHuanBox.szName));
		return 0;
	end

	StatLog:WriteStatLog("stat_info", "award_choose", "linglong_box", me.nId, string.format("%s,%s", tbItem[6], nNeedFree));

	for i = 1, nNeedFree do
		local pOneItem = me.AddItem(tbItem[2][1], tbItem[2][2], tbItem[2][3], tbItem[2][4]);
		if (pOneItem) then
			if (tbItem[4] == 1) then
				pOneItem.Bind(1);
			end
			me.SetItemTimeout(pOneItem,os.date("%Y/%m/%d/%H/%M/00", GetTime() + tbItem[5])); -- 领取当天有效
			pOneItem.Sync();
			Dbg:WriteLog("fanhuanbox", string.format("%s 获得%s成功", me.szName, tbItem[1]));
		else
			Dbg:WriteLog("fanhuanbox", string.format("%s 获得%s失败", me.szName, tbItem[1]));
		end
	end
	
	return 1;
end

