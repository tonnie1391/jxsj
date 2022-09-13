-- zhouchenfei
-- 2012/8/23 11:19:19
-- 苏清泠

local tbSuQingLing = Npc:GetClass("suqingling");

tbSuQingLing.tbMantuoluoZhizhong	= {18,1,1781,1};
tbSuQingLing.tbMantuoluo			= {18,1,1782,1};
tbSuQingLing.nBaseRepute			= 5;
tbSuQingLing.nBaseDieCount			= 50;
tbSuQingLing.nMaxRepute				= 3000;

function tbSuQingLing:OnDialog()
	if (Faction:IsOpenGumuFuXiu() == 0) then
		Dialog:Say("欢迎来到古墓派。");
		return 0;
	end

	local szMsg = "欢迎来到古墓派。我这儿可以接取古墓友好度任务，兑换曼陀罗花，购买古墓友好度坐骑。";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = { "上交曼陀罗花", self.OnGiveFlower, self};
	tbOpt[#tbOpt + 1] = { "购买古墓坐骑", self.OnOpenShop, self};
	tbOpt[#tbOpt + 1] = { "Ta chỉ đến xem" };
	Dialog:Say(szMsg, tbOpt);
end

function tbSuQingLing:OnOpenShop()
	if (me.nFaction ~= Env.FACTION_ID_GUMU) then
		Dialog:Say("你当前门派不是古墓派，无法开启商店！");
		return 0;
	end
	me.OpenShop(289, 3);
end

function tbSuQingLing:OnGiveFlower()
	if (Faction:IsOpenGumuFuXiu() == 0) then
		Dialog:Say("古墓派辅修未开放！");
		return 0;
	end
	
	if (me.CheckLevelLimit(1,4) == 1) then
		Dialog:Say("您的古墓友好度已经达到上限，不用再送我东西了！",
			{
				{"返回上一页", self.OnDialog, self},
				{"Để ta suy nghĩ lại"},
			});
		return 0;
	end

	local nValue = me.GetReputeValue(1,4);
	local nDet = self.nMaxRepute - nValue;
	
	if (nDet < 0) then
		nDet = 0;
	end
	local nNeedMaxCount = math.ceil(nDet / self.nBaseRepute);	
	Dialog:OpenGift(string.format("把收集到的曼佗罗花放进来吧，你将得到我们的友谊。\n你最多还可以上交%s朵。", nNeedMaxCount), nil, {self.OnOpenGiftOk, self});
end

function tbSuQingLing:OnOpenGiftOk(tbItemObj)
	local nSum = 0;
	local tbItemList = {};
	local tbpItem = {};
	local tbGiveItem = self.tbMantuoluo;
	local szItemParam = string.format("%s,%s,%s,%s",unpack(self.tbMantuoluo));
	local nTotalCount = 0;
	for _, tbItem in pairs(tbItemObj) do
		local szPutParam = string.format("%s,%s,%s,%s",tbItem[1].nGenre,tbItem[1].nDetail,tbItem[1].nParticular,tbItem[1].nLevel);
		if szItemParam ~= szPutParam then
			me.Msg(string.format("我只需要曼佗罗花，请不要放入其他物品。"));
			return 0;
		end
		nTotalCount = nTotalCount + tbItem[1].nCount;
		if (not tbpItem[szPutParam]) then
			tbpItem[szPutParam] = {};
		end
		table.insert(tbpItem[szPutParam], tbItem[1]);
	end

	local nRemainCount = 0;
	if (me.CheckLevelLimit(1,4) == 1) then
		me.szMsg("您的古墓友好度已达到上限，无法兑换！");
		return 0;
	end
	
	local nValue = me.GetReputeValue(1,4);
	local nDet = self.nMaxRepute - nValue;
	if (nDet < 0) then
		nDet = 0;
	end	
	local nNeedMaxCount = math.ceil(nDet / self.nBaseRepute);
	local nMinNum = math.min(nTotalCount, nNeedMaxCount);
	
	if (0 >= nMinNum) then
		me.Msg("兑换物品所需材料数量不足，不能兑换。");
		return 0;
	end
	
	local nNeedFreeBag = math.ceil(nMinNum / self.nBaseDieCount);
	
	if (me.CountFreeBagCell() < nNeedFreeBag) then
		me.Msg(string.format("Hành trang không đủ %s格，请清理后再来兑换。", nNeedFreeBag));
		return 0;
	end
	
	local nDelCount = 0;

	local szSucLog = me.szName .. "Del success";
	local nResultNum = self:__RemoveItem(me, nMinNum, tbpItem[szItemParam]);
	if (nMinNum ~= nResultNum) then
		local szErrorLog = string.format("%s, %s,num is wrong %s, %s", me.szName, szItemParam, nMinNum, nResultNum);
		Dbg:WriteLogEx(Dbg.LOG_INFO, "suqingling", "OnOpenGiftOk", szErrorLog);
		return 0;
	end
	szSucLog = string.format("%s,%s,%s,%s", szSucLog, szItemParam, nMinNum, nResultNum);

	Dbg:WriteLogEx(Dbg.LOG_INFO, "suqingling", "OnOpenGiftOk", me.szName, szSucLog);	
	
	local nFlag = Player:AddRepute(me, 1, 4, nMinNum * self.nBaseRepute);
	
	if (2 == nFlag) then
		me.Msg(string.format("您获得<color=yellow>%s点<color>古墓友好度。", nMinNum * self.nBaseRepute));
	elseif (1 == nFlag) then
		me.Msg("您已经达到古墓友好度最高等级，将无法使用兑换曼陀罗花！");
	end
	
	Dbg:WriteLog("suqingling", "OnOpenGiftOk", "增加古墓友好度记录", me.szName, string.format("%s,%s", nMinNum, nMinNum * self.nBaseRepute));

	StatLog:WriteStatLog("stat_info", "gumu_fuxiu", "item_give", me.nId, nMinNum);
	-- StatLog:WriteStatLog("stat_info", "yueyingxiaohao", "exchange", me.nId, nResultCount * 50, tbGiveItem[5], nResultCount);
end

function tbSuQingLing:__RemoveItem(pPlayer, nNeededNum, tbItem)
	local nDeletedNum = 0;
	while nDeletedNum < nNeededNum do
		local pItem = table.remove(tbItem);
		local nCanDelete = math.min(nNeededNum - nDeletedNum, pItem.nCount);
		local nNewCount = pItem.nCount - nCanDelete;
		if nNewCount == 0 then
			pItem.Delete(pPlayer);
		else
			pItem.SetCount(nNewCount, Item.emITEM_DATARECORD_REMOVE);
			table.insert(tbItem,pItem);
		end
		assert(nCanDelete > 0);
		nDeletedNum = nDeletedNum + nCanDelete;
	end
	return nDeletedNum;
end

