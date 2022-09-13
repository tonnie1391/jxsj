-- 文件名　：sellitem.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-04-22 16:11:11
-- 描  述  ：把不绑定的物品卖成绑定银两


Shop.SellItem = Shop.SellItem or {};
local tbSell = Shop.SellItem;
tbSell.nGroupId 	= 2050;
tbSell.nTaskId		= 51;
tbSell.nTaskIdWeek 	= 52;
tbSell.nMaxSell 	= 300000;	--最多兑换30万；

function tbSell:OnOpenSell()
	local nBindMoney = self:GetRestMoney();
	local nMoney = (self.nMaxSell - nBindMoney);
	if nMoney <= 0 then
		Dialog:Say("一周最多只能兑换<color=yellow>30万绑定银两<color>，你本周已经兑换了<color=yellow>30万绑定银两<color>。");
		return 0;
	end
	Dialog:OpenGift(string.format("放入换取绑定银两的物品\n\n你本周还可兑换<color=yellow>%s绑定银两\n\n请打开帮助锦囊的详细帮助查看可以换取绑银的物品列表<color>", nMoney), {"Shop.SellItem:CheckGiftSwith"}, {self.OnOpenGiftOk, self});
end

function tbSell:GetRestMoney()
	
	local nWeek = me.GetTask(self.nGroupId, self.nTaskIdWeek);
	local nCurWeek = tonumber(GetLocalDate("%y%W"));
	if nCurWeek > nWeek then
		me.SetTask(self.nGroupId, self.nTaskIdWeek, nCurWeek);
		me.SetTask(self.nGroupId, self.nTaskId, 0);
	end
	local nMoney = me.GetTask(self.nGroupId, self.nTaskId);
	return nMoney;
end


function tbSell:OnOpenGiftOk(tbItemObj)
	local nAddBindMoney = 0;
	for _, tbItem in pairs(tbItemObj) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s",pItem.nGenre,pItem.nDetail,pItem.nParticular,pItem.nLevel);
		local nBind = pItem.IsBind();
		if self.SellList[szKey] and self.SellList[szKey][nBind] then
			nAddBindMoney = nAddBindMoney + self.SellList[szKey][nBind] * pItem.nCount;
		end
	end
	
	local nBindMoney = self:GetRestMoney();
	local nMoney = (self.nMaxSell - nBindMoney);
	
	if nAddBindMoney > nMoney then
		Dialog:Say(string.format("一周最多只能兑换<color=yellow>30万绑定银两<color>，你本周已经兑换了<color=yellow>%s绑定银两<color>，你放入的兑换额度将超过30万，不能进行兑换。", nBindMoney));
		return 0;
	end
	
	if me.GetBindMoney() + nAddBindMoney > me.GetMaxCarryMoney() then
		Dialog:Say(string.format("您身上的绑定银两将要达到上限，请整理后再来领取。"));
		return 0
	end
	
	nAddBindMoney = 0;
	for _, tbItem in pairs(tbItemObj) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s",pItem.nGenre,pItem.nDetail,pItem.nParticular,pItem.nLevel);
		local nBind = pItem.IsBind();
		if self.SellList[szKey] and self.SellList[szKey][nBind] then
			local nCount = pItem.nCount;
			if me.DelItem(pItem) ~= 1 then
				Dbg:WriteLog("XoyoGame", me.szName.."材料换绑银", "删除失败", szKey);
			else
				nAddBindMoney = nAddBindMoney + self.SellList[szKey][nBind] * nCount;
			end
		end
	end
	me.SetTask(self.nGroupId, self.nTaskId, me.GetTask(self.nGroupId, self.nTaskId) + nAddBindMoney);
	me.AddBindMoney(nAddBindMoney, Player.emKBINDMONEY_ADD_SHANGHUI);
	Dbg:WriteLog("XoyoGame", me.szName.."材料换绑银成功", nAddBindMoney);
	KStatLog.ModifyAdd("bindjxb", "[产出]商会商人兑换", "总量", nAddBindMoney);
end

function tbSell:CheckGiftSwith(tbGiftSelf, pPickItem, pDropItem, nX, nY)
	tbGiftSelf.nOnSwithItemCount = tbGiftSelf.nOnSwithItemCount or 0;
	local nMoney = me.GetTask(self.nGroupId, self.nTaskId);
	local nRestMoney = self.nMaxSell - nMoney;
	if pDropItem then
		local szPutParam = string.format("%s,%s,%s,%s",pDropItem.nGenre,pDropItem.nDetail,pDropItem.nParticular,pDropItem.nLevel);
		local nBind = pDropItem.IsBind();
		if not self.SellList[szPutParam] or not self.SellList[szPutParam][nBind] then
			me.Msg("该物品不能兑换绑定银两，请打开帮助锦囊的详细帮助查看可以换取绑银的物品列表。");
			return 0;
		end
		if tbGiftSelf.nOnSwithItemCount + self.SellList[szPutParam][nBind] * pDropItem.nCount > nRestMoney then
			me.Msg(string.format("一周最多只能兑换<color=yellow>30万<color>，你本周已兑换<color=yellow>%s<color>数额，你放入的兑换数额将会超过30万。", nMoney));
			return 0;
		end
		tbGiftSelf.nOnSwithItemCount = tbGiftSelf.nOnSwithItemCount + self.SellList[szPutParam][nBind] * pDropItem.nCount;
	end
	if pPickItem then
		local szPutParam = string.format("%s,%s,%s,%s",pPickItem.nGenre,pPickItem.nDetail,pPickItem.nParticular,pPickItem.nLevel);
		local nBind = pPickItem.IsBind();
		tbGiftSelf.nOnSwithItemCount = tbGiftSelf.nOnSwithItemCount - self.SellList[szPutParam][nBind] * pPickItem.nCount;
	end
	tbGiftSelf:UpdateContent(string.format("您放入的物品现在可换取<color=yellow>%s绑定银两<color>", tbGiftSelf.nOnSwithItemCount));
	return 1;	
end

function tbSell:LoadSellList()
	self.SellList = {};
	local tbFile = Lib:LoadTabFile("\\setting\\shop\\sellitem.txt");
	if not tbFile then
		return 0;
	end
	for i, tbItem in ipairs(tbFile) do
		local szName 			= 	tbItem.Name;
		local nGenre 			= 	tonumber(tbItem.Genre) or 0;
		local nDetailType 		= 	tonumber(tbItem.DetailType) or 0;
		local nParticularType 	= 	tonumber(tbItem.ParticularType) or 0;
		local nLevel 			= 	tonumber(tbItem.Level) or 0;
		local nBind 			= 	tonumber(tbItem.Bind) or -1;
		local nSellBindMoney 	= 	tonumber(tbItem.SellBindMoney) or 0;
		local szKey = string.format("%s,%s,%s,%s", nGenre, nDetailType, nParticularType, nLevel);
		self.SellList[szKey] = self.SellList[szKey] or {};
		if self.SellList[szKey][nBind] then
			print("【\\setting\\xoyogame\\sellitem.txt】出现重复物品"..szKey..","..nBind);
		end
		if nBind == -1 then
			self.SellList[szKey][0] = nSellBindMoney;
			self.SellList[szKey][1] = nSellBindMoney;
		else
			self.SellList[szKey][nBind] = nSellBindMoney;
		end
	end
end

tbSell:LoadSellList();