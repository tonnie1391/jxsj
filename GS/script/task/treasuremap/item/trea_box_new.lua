--新的箱子
--产出的玄晶都绑定，其他物品不绑

local tbItem	= Item:GetClass("treasurebox_new");

tbItem.tbUseKey = {
	[1] = {tbKey={18, 1, 77,  1}, szAward="tbAwardTreaBox"},
	[2] = {tbKey={18, 1, 82,  1}, szAward="tbAwardTreaBox_Level2"},
	[3] = {tbKey={18, 1, 187, 1}, szAward="tbAwardTreaBox_Level3"},
}

function tbItem:OnUse()
	if not self.tbUseKey[it.nLevel] then
		return 0; 
	end
	local nKeys	= me.GetItemCountInBags(unpack(self.tbUseKey[it.nLevel].tbKey));
	
	if nKeys <=0 then
		Dialog:SendInfoBoardMsg(me, string.format("<color=red>必须有<color><color=yellow>%s<color><color=red>才能打开这个%s！<color>", KItem.GetNameById(unpack(self.tbUseKey[it.nLevel].tbKey)), it.szName));
		return 0;
	end;
	
	local tbRate	= TreasureMap[self.tbUseKey[it.nLevel].szAward];
	
	local nRow = #tbRate;
	local nRandom = 0;
	local nAdd = 0;
	local i=0;
	local nSelect = 0;

	for i=1, nRow do
		nAdd = nAdd + tbRate[i].Rate;
	end;

	nRandom = MathRandom(1, nAdd);

	nAdd = 0;

	for i=1, nRow do
		nAdd = nAdd + tbRate[i].Rate;
		if nAdd>=nRandom then
			nSelect = i;
			break;
		end;
	end;
	
	if nSelect == 0 then
		me.Msg("选择奖励错误！");
		return;
	end;
	
	-- 删盒子删钥匙
	me.ConsumeItemInBags(1, unpack(self.tbUseKey[it.nLevel].tbKey));
	
	local pItem = me.AddItem(tbRate[nSelect].Genre,
								tbRate[nSelect].Detail,
								tbRate[nSelect].Particular,
								tbRate[nSelect].Level,
								tbRate[nSelect].Five);
	if pItem then
		
		if tbRate[nSelect].Genre == 18 and tbRate[nSelect].Detail == 1 and tbRate[nSelect].Particular == 1 then
			pItem.Bind(1); --如果是玄晶进行绑定
		end
		
		Item:CheckXJRecord(Item.emITEM_XJRECORD_EVENT, it.szName, pItem);
		me.Msg("您用钥匙打开盒子，惊喜的发现了：<color=yellow>"..pItem.szName.."<color>");
	end
	return 1;
	
end;
