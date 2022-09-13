Require("\\script\\task\\weekendfish\\weekendfish_def.lua")

-- 洞玄寒铁
local tbClass = Item:GetClass("weekendfish_dongxuanhantie");

-- 产出的物品
tbClass.tbItemProduce =
{
	{18, 1, 1526, 1}, -- 领土
	{18, 1, 1527, 1}, -- 联赛
	{18, 1, 1528, 1}  -- 祈福
};
tbClass.nTime = 5;

function tbClass:OnUse()
	local nCount = self:GetMaxMakeNum(me.nId);
	if nCount <= 0 then
		Dialog:Say("你身上没有月影石，加工1个洞玄寒铁需要消耗1个月影石。");
		return 0;
	end
	local szMsg = string.format("你背包里的材料足够你加工<color=yellow>%s个<color>洞玄寒铁。\n请选择你需要的声望加速令符种类：", nCount);
	local tbOpt = {};
	for nIndex, tbId in ipairs(self.tbItemProduce) do
		local szName = KItem.GetNameById(unpack(self.tbItemProduce[nIndex]));
		if szName then
			table.insert(tbOpt, {szName, self.MakeDongxuanhantieDlg, self, nIndex});
		end
	end
	table.insert(tbOpt, "Để ta suy nghĩ lại");
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbClass:GetMaxMakeNum(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return -1;
	end
	local nMaterialCount = pPlayer.GetItemCountInBags(unpack(WeekendFish.ITEM_DONGXUANHANTIE));
	local nYueyingCount = pPlayer.GetItemCountInBags(unpack(WeekendFish.ITEM_YUEYING));
	local nMaxCount = 100;	-- 一次最多做一百个，方便判断背包以及防止玩家输错过大数字
	if nMaxCount > nMaterialCount then
		nMaxCount = nMaterialCount;
	end
	if nMaxCount > nYueyingCount then
		nMaxCount = nYueyingCount;
	end
	return nMaxCount;
end

function tbClass:MakeDongxuanhantieDlg(nIndex, nCount)
	if nIndex <= 0 or nIndex > #self.tbItemProduce then
		return;
	end
	local szProductName = KItem.GetNameById(unpack(self.tbItemProduce[nIndex]));
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống，至少需要1格背包空间。");
		return;
	end
	local nMaxCount = self:GetMaxMakeNum(me.nId);
	if nMaxCount <= 0 then
		return;
	end
	if not nCount then
		Dialog:AskNumber("请输入制作的数量：", nMaxCount, self.MakeDongxuanhantieDlg, self, nIndex);
		return;
	end
	if nCount > nMaxCount then
		Dialog:Say(string.format("你输入的数量过大，当前你只能制作%s个%s。", nMaxCount, szProductName));
		return;
	end
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	}
	GeneralProcess:StartProcess(szProductName .. "加工", self.nTime * Env.GAME_FPS, 
		{self.MakeDongxuanhantie, self, me.nId, nIndex, nCount}, nil, tbEvent);
end

function tbClass:MakeDongxuanhantie(nPlayerId, nIndex, nCount)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	if nIndex <= 0 or nIndex > #self.tbItemProduce then
		return;
	end
	if pPlayer.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống，至少需要<color=yellow>1格<color>背包空间。");
		return;
	end
	local nMaxCount = self:GetMaxMakeNum(nPlayerId);
	if nMaxCount <= 0 then
		return;
	end
	local szProductName = KItem.GetNameById(unpack(self.tbItemProduce[nIndex]));
	if nCount > nMaxCount then
		Dialog:Say(string.format("你输入的数量过大，当前你只能制作%s个%s。", nMaxCount, szProductName));
		return;
	end
	local nRemainMaterialCount = pPlayer.ConsumeItemInBags(nCount, WeekendFish.ITEM_DONGXUANHANTIE[1], WeekendFish.ITEM_DONGXUANHANTIE[2], WeekendFish.ITEM_DONGXUANHANTIE[3], WeekendFish.ITEM_DONGXUANHANTIE[4], -1);
	if nRemainMaterialCount > 0 then -- 实际消耗数小于目标数
		Dbg:WriteLog("WeekendFish", "consume_dongxuanhantie", pPlayer.szName, nCount, nRemainMaterialCount);
		nCount = nCount - nRemainMaterialCount;
	end
	local nRemainYueyingCount = pPlayer.ConsumeItemInBags(nCount, WeekendFish.ITEM_YUEYING[1], WeekendFish.ITEM_YUEYING[2], WeekendFish.ITEM_YUEYING[3], WeekendFish.ITEM_YUEYING[4], -1);
	if nRemainYueyingCount > 0 then -- 实际消耗数小于目标数
		Dbg:WriteLog("WeekendFish", "consume_yueying", pPlayer.szName, nCount, nRemainYueyingCount);
		nCount = nCount - nRemainYueyingCount;
	end
	if nCount > 0 then
		pPlayer.AddStackItem(self.tbItemProduce[nIndex][1], self.tbItemProduce[nIndex][2], self.tbItemProduce[nIndex][3], self.tbItemProduce[nIndex][4], {}, nCount);
		StatLog:WriteStatLog("stat_info", "repute_trans", "repute_type", nPlayerId, nIndex, nCount);
	end
end