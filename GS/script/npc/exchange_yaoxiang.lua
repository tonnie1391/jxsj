
--3种100级药箱的自由兑换，仅限无使用时限的满药箱

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\item\\class\\xiang.lua");

local tbYX = {};
Npc.tbExchangeYaoXiang = tbYX;

tbYX.tbRed		= { 18, 1, 241, 1 };	--100级红药箱
tbYX.tbBlue		= { 18, 1, 242, 1 };	--100级蓝药箱
tbYX.tbYellow	= { 18, 1, 243, 1 };	--100级黄药箱

local tbXiang = Item:GetClass("xiang");

--dialognpc.txt的入口
function Npc:ExchangeYaoXiang()
	local szMsg = "年轻人，在我这里买药也能以物换物。\n如果你有用不上的极品回复药物，我可以用等量的丹药和你对换。\n不过，零碎的小生意我可不做，最少也得是成箱的。\n那些快要过期变质的药我可不收哟！\n\n看看你要兑换哪一种呢？";
	local tbOpt = 
	{
		{ "<color=red>灵芝续命丸·箱<color>",	tbYX.ExchangeYaoXiang, tbYX, tbYX.tbRed },
		{ "<color=blue>雪参返气丸·箱<color>",	tbYX.ExchangeYaoXiang, tbYX, tbYX.tbBlue },
		{ "<color=orange>瑶池大还丹·箱<color>",	tbYX.ExchangeYaoXiang, tbYX, tbYX.tbYellow },
		{ "让Để ta suy nghĩ thêm" },
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbYX:ExchangeYaoXiang(tbGDPL)
	local szMsg = "请任意放入以下三种药箱：\n<color=red>灵芝续命丸·箱<color>\n<color=blue>雪参返气丸·箱<color>\n<color=orange>瑶池大还丹·箱<color>\n\n药箱必须是满的，\n而且不能有使用时限。";
	Dialog:OpenGift(szMsg, nil, { tbYX.OnExchangeYaoXiang, tbYX, tbGDPL });
end

local tbItemType = { tbYX.tbRed, tbYX.tbBlue, tbYX.tbYellow };
function tbYX:CheckItemType(pItem)
	for _, tbType in ipairs(tbItemType) do
		if pItem.nGenre		 == tbType[1] and
		   pItem.nDetail	 == tbType[2] and
		   pItem.nParticular == tbType[3] and
		   pItem.nLevel		 == tbType[4]
		then
		   	return 1;
		end
	end

	return 0;
end

--服务端主逻辑
function tbYX:OnExchangeYaoXiang(tbGDPL, tbItemObj)
	if self:DoCheck(tbItemObj) ~= 1 then
		return;
	else
		self:DoExchange(tbGDPL, tbItemObj);
	end
end

function tbYX:DoCheck(tbItemObj)
	--物品数量校验
	local nCount = #tbItemObj;
	if nCount == 0 then
		Dialog:Say("唉，世风日下，人心不古啊！现在的年轻人都在想些什么？难道你想空手套白狼吗？", {"我错了，这就回去反省"});
		return 0;
	end
	
	local pItem;
	for i = 1, nCount do
		pItem = tbItemObj[i][1];
		
		--物品类型校验
		if self:CheckItemType(pItem) ~= 1 then
			Dialog:Say("都说了只能兑换药箱，你怎么还给我其他东西呢？", {"好吧，我错了"});
			return 0;
		end
		
		--药箱是否满
		if tbXiang:IsFull(pItem) ~= 1 then
			Dialog:Say("我这里只能帮你整箱兑换，那些不满的药箱就不要给我啦。", {"好吧，我错了"});
			return 0;
		end
		
		--药箱有效期
		local nTimeoutType, nTimeout = pItem.GetTimeOut();
		if nTimeoutType and nTimeout > 0 then
			Dialog:Say("我这里只能帮你兑换没有使用时限的药箱，那些快要过期变质的药我可不收。", {"好吧，我错了"});
			return 0;
		end
	end
	
	return 1;
end

function tbYX:DoExchange(tbGDPL, tbItemObj)
	local nItemCount = #tbItemObj;
	local pItem, bBind, pNewItem;
	local nCount = 0;
	for i = 1, nItemCount do
		pItem = tbItemObj[i][1];
		
		--相同类型的药箱避免delete/add操作
		if pItem.nGenre		 ~= tbGDPL[1] or
		   pItem.nDetail	 ~= tbGDPL[2] or
		   pItem.nParticular ~= tbGDPL[3] or
		   pItem.nLevel		 ~= tbGDPL[4]
		then
			bBind = pItem.IsBind();
			pItem.Delete(me);
			pNewItem = me.AddItem(tbGDPL[1], tbGDPL[2], tbGDPL[3], tbGDPL[4]);
			if pNewItem then
				nCount = nCount + 1;
				if bBind == 1 then
					pNewItem.Bind(1);
				end
			end
		end
	end
	
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[100级药箱兑换]扣除%d个,获得%d个", nItemCount, nCount));
end
