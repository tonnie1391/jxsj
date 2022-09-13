-- 文件名　：plantform_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-10-10 19:23:10
-- 功能    ：
local tbYinPiao = Item:GetClass("newplantform_yinpiao");

function tbYinPiao:OnUse()
	local bWorker = IpStatistics:IsStudioRole(me);
	if bWorker then
		return Item:GetClass("randomitem"):SureOnUse(244, 0, 0, 0, 0, 0, 0, 0, 0, it);
	else
		return Item:GetClass("randomitem"):SureOnUse(243, 0, 0, 0, 0, 0, 0, 0, 0, it);
	end
end

local tbLiBao = Item:GetClass("newplantform_libao");
tbLiBao.tbRate = {25,30,31};
tbLiBao.nRateAll = 31;
tbLiBao.tbParticularType = {1, 5, 9, 13, 17};
tbLiBao.tbItem = {
	[16] = {4,5,6},
	[29] = {5,6,7},
	[53] = {6,7,8},	
	};

function tbLiBao:OnUse()
	if me.CountFreeBagCell() < 1 then
		me.Msg("Hành trang không đủ 1 ô chỗ trống");		
		return 0;
	end
	local nRateNow = MathRandom(self.nRateAll);
	local nLevelNum = 0;
	for i, nRate in ipairs(self.tbRate) do
		if nRateNow <= nRate then
			nLevelNum = i;
			break;
		end
	end
	local nServerDay = TimeFrame:GetServerOpenDay();
	local tbSelItem = {7,8,9};
	for i, tbLevel in pairs(self.tbItem) do
		if nServerDay <= i then
			tbSelItem = tbLevel;
			break;
		end
	end
	if nLevelNum > 3 or nLevelNum < 1 or not tbSelItem then
		Dialog:Say("该道具有问题，请联系GM。");
		return 0;
	end
	local nLevel = tbSelItem[nLevelNum];
	local nParticularType = self.tbParticularType[MathRandom(5)];
	me.AddItemEx(22, 1, nParticularType, nLevel, {bForceBind = 1});
	return 1;
end

function tbLiBao:InitGenInfo()
	it.SetTimeOut(0, GetTime() + 24 * 3600);
	return {};	
end

--道具之间转换
function NewEPlatForm:ItemChange(pItem)
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		Dialog:Say("Chỉ có thể thao tác tại Tân Thủ Thôn và Thành Thị.");
		return;
	end
	if not pItem then
		Dialog:Say("Đạo cụ không tồn tại.");
		return;
	end
	local szGdpl = pItem.SzGDPL();
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô.");
		return;
	end
	if not self.tbItemChange[szGdpl] then
		Dialog:Say("Đạo cụ không chính xác.");
		return;
	end
	local tbOpt = {{"Để ta suy nghĩ thêm"}}
	for szKey, nType in pairs(self.tbItemChange) do
		if szKey ~= szGdpl and self.tbItemChange[szGdpl] == nType then
			local tb = Lib:SplitStr(szKey);
			if #tb ~= 4 then
				print("Hệ thống lỗi!!!");
				return;
			end
			local szName = KItem.GetNameById(tonumber(tb[1]),tonumber(tb[2]),tonumber(tb[3]),tonumber(tb[4]));
			local szTip = "<item=".. szKey..">"
			table.insert(tbOpt, 1, {"Đổi <color=yellow>"..szName.."<color>"..szTip, self.ItemChangeEx, self, tb, pItem});
		end
	end
	Dialog:Say(string.format("Vật phẩm <color=yellow>%s<color> có thể đổi thành vật phẩm sau.\n<color=red>Lưu ý: Các thuộc tính sẽ không được giữ lại.<color>", pItem.szName), tbOpt);
	return;
end

--道具之间转换
function NewEPlatForm:ItemChangeEx(tbGDPL, pItem)
	if not pItem then
		Dialog:Say("Vật phẩm không tồn tại.");
		return;
	end
	if #tbGDPL ~= 4 then
		Dialog:Say("Vật phẩm bất thường.");
		return;
	end
	local nGenInfo = pItem.GetGenInfo(1);
	local nBind = pItem.IsBind();
	local szItemName = pItem.szName;
	if pItem.Delete(me) == 1 then
		local pItemEx = me.AddItemEx(tonumber(tbGDPL[1]), tonumber(tbGDPL[2]), tonumber(tbGDPL[3]), tonumber(tbGDPL[4]),{bForceBind = nBind}, 1);
		if pItemEx then
			pItemEx.SetGenInfo(1, nGenInfo);
			pItemEx.Sync();
			Dbg:WriteLog("转换道具%s->%s", szItemName, pItemEx.szName);
		end
	end
end

--花费金币升级
function NewEPlatForm:ItemUpdate(pItem, nFlag)
	local nRet, szErrorMsg = self:CheckCanUpdate(pItem);
	if nRet == 0 then
		Dialog:Say(szErrorMsg);
		return;
	end
	if me.nCoin < self.tbBuyItem[2] then
		Dialog:Say("Ngươi không đủ "..self.tbBuyItem[2].."!");
		return;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống 1 ô.");
		return;
	end
	if not nFlag then
		Dialog:Say(string.format("Sử dụng <color=yellow>%s đồng<color> để nâng cấp?",self.tbBuyItem[2]), {{"Đồng ý nâng cấp", self.ItemUpdate, self, pItem, 1},{"Để ta suy nghĩ thêm"}});
		return;
	end
	local bBuy = me.ApplyAutoBuyAndUse(self.tbBuyItem[1], 1);
	if bBuy == 1 then
		local tbItem = self.tbItemUpdateList[pItem.SzGDPL()];
		local szItemName = pItem.szName;
		if pItem.Delete(me) == 1 then
			local pItemEx = me.AddItemEx(tbItem[1], tbItem[2], tbItem[3], tbItem[4], nil, 1);
			if pItemEx then
				StatLog:WriteStatLog("stat_info", "kin_sports", "update", me.nId, string.format("%s_%s_%s_%s", unpack(Lib:SplitStr(pItemEx.SzGDPL()))));
				Dbg:WriteLog("升级道具%s->%s", szItemName, pItemEx.szName);
			end
		end
	end
end

--检查道具是否可以升级
function NewEPlatForm:CheckCanUpdate(pItem)
	if not pItem then
		return 0, "Vật phẩm không tồn tại.";
	end
	local tbUp = self.tbItemUpdateList[pItem.SzGDPL()];
	if not tbUp then
		return 0, "Vật phẩm không thể nâng cấp.";
	end
	if pItem.GetGenInfo(1) > 0 then
		return 0, "Vật phẩm chưa sử dụng mới có thể nâng cấp.";
	end
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		return 0, "Chỉ có thể thao tác tại Tân Thủ Thôn và Thành Thị.";
	end
	return 1, string.format("%s,%s,%s,%s", unpack(tbUp));
end

--道具之间转换
function NewEPlatForm:ItemChangeOther(pItem, nFlag)
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		Dialog:Say("Chỉ có thể thao tác tại Tân Thủ Thôn và Thành Thị.");
		return;
	end
	if not pItem then
		Dialog:Say("Vật phẩm không đúng.");
		return;
	end
	local szGdpl = pItem.SzGDPL();
	
	if not self.tbItemChangeOther[szGdpl] then
		Dialog:Say("Vật phẩm không đúng, hãy thử lại với vật phẩm khác!");
		return;
	end
	local tbItem = self.tbItemChangeOther[pItem.SzGDPL()];
	local tb = {};
	for i= 1, 5 do
		table.insert(tb, pItem.GetGenInfo(i));
	end
	local nNeedBag = math.ceil((10 - tb[1]) * 2 / 10);
	if nNeedBag <= 0 then
		Dialog:Say("Vật phẩm không đúng, hãy thử lại với vật phẩm khác!");
		return;
	end
	if me.CountFreeBagCell() < nNeedBag  then
		Dialog:Say("Hành trang không đủ "..nNeedBag.." ô.");
		return;
	end
	if not nFlag then
		Dialog:Say(string.format("Vật phẩm <color=yellow>%s<color> có thể đổi thành <color=yellow>%s<color> %s, ngươi muốn đổi không?\n<color=red>Vật phẩm đổi lại sẽ được tăng gấp đôi<color>",pItem.szName, KItem.GetNameById(unpack(tbItem)), nNeedBag), {{"Đồng ý đổi", self.ItemChangeOther, self, pItem, 1},{"Để ta suy nghĩ thêm"}});
		return;
	end
	local szItemName = pItem.szName;
	if pItem.Delete(me) == 1 then
		for i =1, nNeedBag do
			local pItemEx = me.AddItemEx(tbItem[1], tbItem[2], tbItem[3], tbItem[4], nil, 1);
			if pItemEx then
				if i == nNeedBag then
					local nCount = math.mod((10 - tb[1]) * 2 , 10);
					if nCount ~= 0 then
						pItemEx.SetGenInfo(1, 10 - nCount);
					end
				end
				for j= 2, 5 do
					pItemEx.SetGenInfo(j, tb[j]);
				end
				pItemEx.Sync();
			end
		end
	end
end

local tbRepute = Item:GetClass("newplantform_repute");
tbRepute.nMakeCount = 10;

function tbRepute:OnUse()
	Dialog:Say("Ngươi có thể đổi 10 mảnh vỡ lấy 1 Ngọc Như Ý\n<color=red>Lưu ý: Mảnh vỡ (khóa) sẽ đổi ra Ngọc Như Ý (khóa)\nMảnh vỡ (không khóa) sẽ đổi ra Ngọc Như Ý (không khóa)\nVừa có (khóa và không khóa) sẽ đổi ra Ngọc Như Ý (khóa)<color>", {{"Đồng ý", self.ChangeSignt, self}, {"Để ta suy nghĩ thêm"}});
end

function tbRepute:ChangeSignt()
	Dialog:OpenGift("Hãy đặt <color=yellow>Mảnh vỡ Ngọc Như Ý<color>, ta sẽ giúp ngươi ghép lại thành <color=yellow>Ngọc Như Ý<color>。", nil ,{self.OnOpenGiftOk, self});
end

function tbRepute:OnOpenGiftOk(tbItemObj)
	local nCount = 0;
	local bBind = 0;
	for _, pItem in pairs(tbItemObj) do
		if pItem[1].szClass ~= "newplantform_repute" then
			Dialog:Say("Vật phẩm bỏ vào không đúng.");
			return 0;
		end;
		if pItem[1].IsBind() == 1 then
			bBind = 1;
		end
		nCount = nCount + pItem[1].nCount;
	end
	-- 扣除物品
	local bFinish = 0;
	if nCount < self.nMakeCount then
		Dialog:Say("Số lượng không đủ.");
		return;
	end
	local nCanGetNum = math.floor(nCount / self.nMakeCount);
	nCount = nCanGetNum * self.nMakeCount;
	local nNeedBag = KItem.GetNeedFreeBag(18,1,475,1, nil, nCanGetNum);
	if me.CountFreeBagCell() < nNeedBag then
		Dialog:Say("Hành trang không đủ "..nNeedBag.." ô trống");
		return;
	end
	local nUseBindCount = 0;	--使用的绑定数量物品
	local nUseCount = 0;	--使用的非绑定数量物品
	for _, pItem in ipairs(tbItemObj) do
		local nItemCount = pItem[1].nCount;
		local nUsed = 0;
		if nItemCount >= nCount then
			pItem[1].SetCount(nItemCount - nCount);
			nUsed = nCount;
		else
			pItem[1].Delete(me);
			nUsed = nItemCount;
		end
		if pItem[1].IsBind() == 1 then
			nUseBindCount = nUseBindCount + nUsed;
		else
			nUseCount = nUseCount + nUsed;
		end
		nCount = nCount - nItemCount;
		if nCount <= 0 then
			bFinish = 1;
			break;
		end
	end
	if bFinish == 1 then
		me.AddStackItem(18,1,475,1, {bForceBind = bBind}, nCanGetNum);
		StatLog:WriteStatLog("stat_info", "kin_sports", "repute_trans", me.nId, string.format("%s,%s,18_1_475_1,%s", nUseCount, nUseBindCount, nCanGetNum));
		Dbg:WriteLog("玩家["..me.szName.."]兑换了玉如意。"..nCanGetNum.."个。");
	end
end

local tbItemEx = Item:GetClass("newplantform_ItemEx")

function tbItemEx:OnUse()
	return 1;
end
