local tbTongJiang = Item:GetClass("chongzhitongjiang");

tbTongJiang.TYPE_BINDCOIN	= 1;
tbTongJiang.TYPE_ITEM		= 2;

tbTongJiang.tbAwardList = {
		[1] = {
				{
					szName	= "4888绑金",
					nType	= tbTongJiang.TYPE_BINDCOIN, 
					tbItem = {4888},
					nNeedFree = 0,	
				},
				{
					szName	= "1本六韬辑注（绑定）",
					nType	= tbTongJiang.TYPE_ITEM, 
					tbItem	= {18,1,320,1},
					nCount	= 1,
					nBind	= 1,
					nNeedFree = 1,
				},
				{
					szName	= "6个五行魂石箱（绑定）",
					nType	= tbTongJiang.TYPE_ITEM, 
					tbItem	= {18,1,244,1},
					nCount	= 6,
					nBind	= 1,
					nNeedFree = 6,
				},
				{
					szName	= "1个秘境套装（大）（绑定）",
					nType	= tbTongJiang.TYPE_ITEM, 
					tbItem	= {18,1,494,1},
					nCount	= 1,
					nBind	= 1,
					nNeedFree = 1,
				},
		},
		[2] = {
				{
					szName	= "4888绑金",
					nType	= tbTongJiang.TYPE_BINDCOIN, 
					tbItem = {4888},
					nNeedFree = 0,
				},
				{
					szName	= "2个战书·游龙密室（箱）（绑定）",
					nType	= tbTongJiang.TYPE_ITEM, 
					tbItem	= {18,1,524,2},
					nCount	= 2,
					nBind	= 1,
					nNeedFree = 2,
				},
				{
					szName	= "10个穿珠银帖（绑定）",
					nType	= tbTongJiang.TYPE_ITEM, 
					tbItem	= {18,1,541,6},
					nCount	= 10,
					nBind	= 1,
					nNeedFree = 1,
				},
				{
					szName	= "1个秘境套装（大）（绑定）",
					nType	= tbTongJiang.TYPE_ITEM, 
					tbItem	= {18,1,494,1},
					nCount	= 1,
					nBind	= 1,
					nNeedFree = 1,
				},
				{
					szName	= "5个特别的精魄（绑定）",
					nType	= tbTongJiang.TYPE_ITEM, 
					tbItem	= {18,1,544,6},
					nCount	= 5,
					nBind	= 1,
					nNeedFree = 1,
				},
		},
	};

function tbTongJiang:OnUse()
	local nIndex = it.GetExtParam(1);
	local tbItemList = self.tbAwardList[nIndex];
	
	if (not tbItemList) then
		Dialog:Say("道具异常！");
		return 0;
	end
	
	local szMsg = "参加本月充值优惠抽奖获得的幸运奖章。可以获得绑金，五行魂石，中级阵法册及秘境套装（大）其中之一！您想选择哪个：";
	if (nIndex == 2) then
		szMsg = "参加本月充值优惠抽奖获得的幸运奖章。可以获得绑金，特别的精魄，穿珠银帖，战书·游龙密室（箱）及秘境套装（大）其中之一！您想选择哪个：";
	end
	local tbOpt = {};
	for i, tbItem in pairs(tbItemList) do
		local tbInfo = {tbItem.szName, self.GetAward, self, it.dwId, i};
		table.insert(tbOpt, tbInfo);
	end
	
	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
	
	Dialog:Say(szMsg, tbOpt);
	return;
end

function tbTongJiang:GetAward(dwId, nIndex, nCheck)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		Dialog:Say("道具奖励异常");
		return 0;
	end
	local nId = pItem.GetExtParam(1);
	local tbItemList = self.tbAwardList[nId];
	
	if (not tbItemList) then
		Dialog:Say("道具异常！");
		return 0;
	end
	
	local tbAward = tbItemList[nIndex];
	if (not tbAward) then
		Dialog:Say("奖励异常！");
		return 0;
	end
	
	local nNeedFree = 0;
	
	if (tbAward.nType == self.TYPE_ITEM) then
		nNeedFree = nNeedFree + tbAward.nNeedFree;
	end

	if (nNeedFree > me.CountFreeBagCell()) then
		Dialog:Say(string.format("您的背包剩余空间不足%s，请整理后再来领取！", nNeedFree));
		return 0;
	end
	
	if (not nCheck or nCheck ~= 1) then
		Dialog:Say(string.format("确定领取<color=yellow>%s<color>吗？", tbAward.szName),
			{
				{"Xác nhận", self.GetAward, self, dwId, nIndex, 1},
				{"Để ta suy nghĩ thêm"},	
			});
		return 0;
	end

	local nRet = pItem.Delete(me);
	if nRet ~= 1 then
		return 0;
	end
	
	if (tbAward.nType == self.TYPE_BINDCOIN) then
		local tbItemId = tbAward.tbItem
		me.AddBindCoin(tbItemId[1], Player.emKBINDCOIN_ADD_EVENT);
		Dbg:WriteLog("chongzhitongjiang", "角色名:"..me.szName, "帐号:"..me.szAccount, "获得绑金：" .. tbItemId[1]);
		StatLog:WriteStatLog("stat_info", "award_choose", "choose", me.nId, tbAward.szName);
	elseif (tbAward.nType == self.TYPE_ITEM) then
		local tbItemInfo ={};
		if tbAward.nBind > 0 then
			tbItemInfo.bForceBind = tbAward.nBind;
		end	

		local tbItemId = tbAward.tbItem
		local nAddCount = me.AddStackItem(tonumber(tbItemId[1]) or 0, tonumber(tbItemId[2]) or 0, tonumber(tbItemId[3]) or 0, tonumber(tbItemId[4]) or 0, tbItemInfo, tbAward.nCount);
		if nAddCount > 0 then
			Dbg:WriteLog("chongzhitongjiang", "角色名:"..me.szName, "帐号:"..me.szAccount, string.format("成功获得：%s,%s,%s", tbAward.szName, nId, nIndex));
			StatLog:WriteStatLog("stat_info", "award_choose", "choose", me.nId, tbAward.szName);
		end		
	end

	return 1;
end
