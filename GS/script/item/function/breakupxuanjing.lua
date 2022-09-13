
-- 玄晶拆分
-- 
------------------------------------------------------------------------------------------
Require("\\script\\lib\\gift.lua");
Item.tbGift = Gift:New();
local tbGift = Item.tbGift;
tbGift.ITEM_CLASS = "xuanjing";
tbGift.LAYER = 3;
tbGift.NEEDLEVEL_MIN	= 10;	-- 至少要10级的玄晶才能拆
tbGift.NEEDLEVEL_MAX	= 12;	-- 12级以上的玄晶不能拆（目前玄晶等级最高12级）


function tbGift:OnOK(tbParam)
	local pItem = self:First();
	local tbLogItem = {}
	if not pItem then
		me.Msg("请放入要拆解的绑定的玄晶。")
		return 0;
	end
	
	while pItem do
		if pItem.szClass ~= self.ITEM_CLASS or pItem.nLevel < self.NEEDLEVEL_MIN
			or pItem.nLevel > self.NEEDLEVEL_MAX or pItem.IsBind() ~= 1 then
		   	me.Msg("只能放10级至12级的绑定玄晶！");
		   	return 0;
		else
			if not tbLogItem[pItem.nLevel] then 
				tbLogItem[pItem.nLevel] = 0;
			end
			tbLogItem[pItem.nLevel] = tbLogItem[pItem.nLevel] + 1;
			pItem = self:Next();
		end
	end
	
	local pFind = self:First();
	local tbBreakUpItem = Item:ValueToItem(pFind.nValue, self.LAYER, 1);	-- 最后一个参数是标志位，表示是拆玄
	local nNum = 0;
	for nItemLevel, nItemNum in pairs(tbBreakUpItem) do
		nNum = nNum + nItemNum;
	end
	
	if me.CountFreeBagCell() < nNum then
		me.Msg(string.format("Hành trang không đủ ，您需要%s个空间格子。", nNum));
		return 0;
	end
	
	-- 删除物品
	local nTimeType, nTime = pFind.GetTimeOut();
	if nTimeType and nTimeType == 0 and nTime > 0 then
		Dbg:WriteLog("breakupxuanjing",  me.szName, "扣除物品:", pFind.szName, "时限为："..os.date("%Y/%m/%d/%H/%M/00", nTime));
	elseif nTimeType and nTimeType == 1 and nTime > 0 then
		Dbg:WriteLog("breakupxuanjing",  me.szName, "扣除物品:", pFind.szName, "时限还有："..Lib:TimeDesc(nTime));
	else
		Dbg:WriteLog("breakupxuanjing",  me.szName, "扣除物品:", pFind.szName);
	end
	
	if me.DelItem(pFind, Player.emKLOSEITEM_BREAKUP) ~= 1 then
		Dbg:WriteLog("breakupxuanjing",  me.szName, "扣除物品失败, 要扣除的物品为:", pFind.szName);
		return 0;
	end
	
	-- 添加物品
	local szLogMsg = "["..me.szName.."]获得了："; 
	for nItemLevel, nItemNum in pairs(tbBreakUpItem) do
		for i = 1, nItemNum do
			local pItem = me.AddItemEx(Item.SCRIPTITEM, 1, 114, nItemLevel, nil, Player.emKITEMLOG_TYPE_BREAKUP);
			if nTimeType and nTime and nTime ~= 0 then
				if nTimeType == 0 then
					me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/00", nTime), 1);
				elseif nTimeType == 1 then
					me.SetItemTimeout(pItem, math.ceil(nTime / 60), 0);
				end
				pItem.Sync();
			end
		end
		szLogMsg = szLogMsg..nItemLevel.."级玄晶"..nItemNum.."个 ";
	end
	
	if nTimeType and nTimeType == 0 and nTime > 0 then
		szLogMsg = szLogMsg.."时限为："..os.date("%Y/%m/%d/%H/%M/00", nTime);
	elseif nTimeType and nTimeType == 1 and nTime > 0 then
		szLogMsg = szLogMsg.."时限还有："..Lib:TimeDesc(nTime);
	end
	Dbg:WriteLog("breakupxuanjing", szLogMsg);
end

function tbGift:OnSwitch(pPickItem, pDropItem, nX, nY)
	if (not pDropItem) then
		return 1;
	end
	
	local pFind = self:First();
	if (pFind) then
		me.Msg("<color=red>一次只能放一个10级至12级的绑定玄晶！<color>");
		return 0;
	end

	if pDropItem.szClass ~= self.ITEM_CLASS or pDropItem.nLevel < self.NEEDLEVEL_MIN 
		or pDropItem.nLevel > self.NEEDLEVEL_MAX or pDropItem.IsBind() ~= 1 then
		me.Msg("<color=red>只能放10级至12级的绑定玄晶！<color>");
		return 0;
	end
	return	1;
end

function tbGift:OnUpdate()
	self._szTitle = "拆解玄晶";
	local pItem = self:First();
	if not pItem then
		self._szContent = "请放入要拆解的玄晶。只能放10级至12级的绑定玄晶。";
		return 0;
	end

	local pFind = self:First();
	local tbBreakUpItem = Item:ValueToItem(pFind.nValue, self.LAYER, 1);	-- 最后一个参数是标志位，表示是拆玄
	local nNum = 0;
	local szMsg = ""; 
	for i = 1, 12 do  
		if tbBreakUpItem[i] and tbBreakUpItem[i] > 0 then
			szMsg = szMsg.."    "..i.."级玄晶"..tbBreakUpItem[i].."个\n";
			nNum = nNum + tbBreakUpItem[i];
		end
	end

	self._szContent = "您可以拆解成：\n<color=yellow>"..szMsg.."<color>需要"..nNum.."个空间来存放。";
end
