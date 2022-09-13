-- zhouchenfei
-- 新手礼包改版
-- 2012/8/20 0:02:08

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\minievent\\playerlevelupgift.lua");

SpecialEvent.PlayerLevelUpGift = SpecialEvent.PlayerLevelUpGift or {};
local PlayerLevelUpGift = SpecialEvent.PlayerLevelUpGift;

function PlayerLevelUpGift:GetAwardLibao(nAwardIndex, nClass, dwItemId)
	if self.IS_OPEN ~= 1 then
		return 0;
	end
	if not dwItemId then
		return;
	end
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		return ;
	end
	local nRes, szMsg = self:GetAward(me, nAwardIndex, nClass, pItem);
	if szMsg then
		me.Msg(szMsg);
	end
	if (nRes == 2) then
		Dialog:Say(string.format("您充值不足%s元，不能领取充值新手礼包奖励！", self.LIMIT_MONTH_PAY), 
			{
				{"现在就去充值", self.OpenChongZhi, self},
				{"Để ta suy nghĩ thêm"},
			});
		return 0;
	end
end

function PlayerLevelUpGift:CanGetAward(pPlayer, nAwardIndex, nClass)
	local tbOneAwardInfo = self.tbAwardInfo[nAwardIndex];
	if (not tbOneAwardInfo) then
		return 0, "礼包里的奖励不存在。";
	end
	
	local tbAwardClass = tbOneAwardInfo.tbAwardClass[nClass];
	local nLevel = tbOneAwardInfo.nLevel;
	if (not tbAwardClass) then
		return 0, "奖励不存在。";
	end

	local nIsGetAll = self:IsGetAllAward(pPlayer);
	if nIsGetAll == 1 then
		return 0, "你已经领到这个礼包里面的所有礼物啦！";
	end

	if me.nFaction <= 0 or me.nRouteId <= 0 then
		return 0, "请加入门派并选定路线。";
	end	
	
	local nFlag, szMsg = self:IsCanGetAward(pPlayer, nAwardIndex, nClass);
	if (0 == nFlag) then
		return 0, szMsg;
	end
	
	if (self.INDEX_AWARD_CLASS_PAY == nClass) then
		if (pPlayer.GetExtMonthPay() < self.LIMIT_MONTH_PAY) then
			return 2;
		end
	end
	
	if me.nLevel < nLevel then
		return 0, string.format("你需要达到%d级才能再领礼物。", nLevel);
	end
	
	if me.CountFreeBagCell() < tbAwardClass.nNeedFreeBag then
		return 0, string.format("Hành trang không đủ chỗ trống，请空出%d格之后再开启", tbAwardClass.nNeedFreeBag);
	end
	--特殊做法
	if me.GetBindMoney() + tbAwardClass.nMaxBindMoney > me.GetMaxCarryMoney() then
		return 0, "你的绑定银两携带达上限了，无法获得绑定银两。";
	end
	return 1;
end

function PlayerLevelUpGift:OpenChongZhi()
	c2s:ApplyOpenOnlinePay();
end

function PlayerLevelUpGift:GetAwardItemList(nAwardIndex, nClass)
	local tbOneAwardInfo = self.tbAwardInfo[nAwardIndex];
	if (not tbOneAwardInfo) then
		return;
	end
	
	local tbAwardClass = tbOneAwardInfo.tbAwardClass[nClass];
	local nLevel = tbOneAwardInfo.nLevel;
	if (not tbAwardClass) then
		return;
	end
	
	return tbAwardClass.tbAwardList, tbOneAwardInfo.nLevel;
end

function PlayerLevelUpGift:GetAward(pPlayer, nAwardIndex, nClass, pItem)
	local nRes, szMsg = self:CanGetAward(pPlayer, nAwardIndex, nClass);
	if nRes == 0 or nRes == 2 then
		return nRes, szMsg;
	end
	
	local nMaxIndex = self:GetMaxAwardIndex();
	local tbItems, nLevel = self:GetAwardItemList(nAwardIndex, nClass);
	if (not tbItems) then
		return 0, "礼包异常！";
	end
	local tbAddedItem = {};
	local szAward = "";

	if (self.INDEX_AWARD_CLASS_PAY == nClass) then
		self:SetPayAwardFlag(pPlayer, nAwardIndex, 1);
	elseif (self.INDEX_AWARD_CLASS_FREE == nClass) then
		nAwardIndex = nAwardIndex + 1;
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX, nAwardIndex);
	end	
	
	for _, tbItem in ipairs(tbItems) do
		if tbItem.szType == "BindCoin" then
			pPlayer.AddBindCoin(tbItem.nValue, Player.emKBINDCOIN_ADD_EVENT);
			szAward = szAward .. "绑定".. IVER_g_szCoinName .. tbItem.nValue .. ",";
		elseif tbItem.szType == "BindMoney" then
			pPlayer.AddBindMoney(tbItem.nValue, Player.emKBINDMONEY_ADD_EVENT);
			szAward = szAward .. "绑银" .. tbItem.nValue .. ",";
		elseif tbItem.szType == "CustomEquip" then
			local tbCustomItem = SpecialEvent.ActiveGift:GetCustomItem(pPlayer, tbItem.nValue);
			if tbCustomItem then
				local pItem = pPlayer.AddItem(unpack(tbCustomItem));
				if pItem then
					pItem.Bind(1);
					szAward = szAward .. pItem.szName .. ",";
				end
			end
		elseif tbItem.szType == "Title" then
			pPlayer.AddTitle(unpack(tbItem.tbTitle));
			pPlayer.SetCurTitle(unpack(tbItem.tbTitle));
		elseif (tbItem.szType == "SpeTitle") then
			pPlayer.AddSpeTitle(tbItem.szTitle, tbItem.tbTitleParam[1], tbItem.tbTitleParam[2]);
		else
			local nSex = pPlayer.nSex;
			local tbSexItem = tbItem.tbItemList[nSex + 1];
			for i = 1, tbSexItem[5] do
				local pItem = pPlayer.AddItem(tbSexItem[1], tbSexItem[2], tbSexItem[3], tbSexItem[4]);
				if pItem then
					if tbSexItem[7] and tbSexItem[7] ~= 0 then
						pPlayer.SetItemTimeout(pItem, tbSexItem[7], 0)
					end
					pItem.Bind(1);
					pItem.Sync();
					szAward = szAward .. pItem.szName .. ",";
				end
			end
		end
	end
	
	Dbg:WriteLog("SpecialEvent.PlayerLevelUpGift", string.format("%s 获得新手礼包%d级物品：%s", me.szName, nLevel, szAward));

	if (self.INDEX_AWARD_CLASS_FREE == nClass) then
		local nNowLevel = self:GetAwardInfoPlayerLevel(nAwardIndex);
		if pItem then
			if (nNowLevel) then
				pItem.SetGenInfo(1, nNowLevel);
				pItem.Sync();			
			end
		end
	end

	local nIsGetAll = self:IsGetAllAward(pPlayer);
	if (nIsGetAll == 1) then
		pItem.Delete(pPlayer);
		pPlayer.Msg("恭喜你已经领到这个礼包里面的所有礼物！");
	end	
	
	return 1;
end

function PlayerLevelUpGift:GiveGift()
	if self.IS_OPEN ~= 1 then
		return 0;
	end
	
	if me.GetTask(self.TASK_GROUP_ID, self.TASK_GET_BAG) == 1 then
		return 0, "您已经获得过新手礼包了。";
	end
	
	if me.CountFreeBagCell() < 1 then
		return 0, "Hành trang không đủ chỗ trống，请空出一格之后再来"
	end
	
	local pItem = me.AddItem(18, 1, 1509, 1);
	if pItem then
		me.SetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX, 1);
		me.SetTask(self.TASK_GROUP_ID, self.TASK_GET_BAG, 1);
		local nNowLevel = self:GetAwardInfoPlayerLevel(1);
		pItem.SetGenInfo(1, nNowLevel);
		pItem.Sync();
		Dbg:WriteLog("SpecialEvent.PlayerLevelUpGift", string.format("%s 获得新手礼包", me.szName));
	end
	
	return 1;
end

function c2s:GetLevelUpGiftGift(nAwardIndex, nClass, dwItemId)
	if GLOBAL_AGENT then
		return 0;
	end
	
	if (type(nAwardIndex) ~= "number" or type(nAwardIndex) ~= "number" or
		type(dwItemId) ~= "number") then
		return 0;
	end
	SpecialEvent.PlayerLevelUpGift:GetAwardLibao(nAwardIndex, nClass, dwItemId)
end

local tbGift = Item:GetClass("playerlevelupgift");

function tbGift:OnUse()
	local nIsGetAll = SpecialEvent.PlayerLevelUpGift:IsGetAllAward(me);
	if (nIsGetAll == 1) then
		Dialog:Say("Đã lấy hết phần thưởng trong hộp. Hộp tự động xóa!");
		it.Delete(me);
		return 0;
	end
	me.CallClientScript({"SpecialEvent.PlayerLevelUpGift:OpenWindow", me.GetExtMonthPay(), it.dwId});
end

