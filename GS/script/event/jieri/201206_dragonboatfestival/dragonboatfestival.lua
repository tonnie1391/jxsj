-- 文件名　：dragonboatfestival.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-06-08 09:31:54
-- 功能    ：

SpecialEvent.tbDragonBoatFestival2012 = SpecialEvent.tbDragonBoatFestival2012 or {};
local tbDragonBoatFestival2012 = SpecialEvent.tbDragonBoatFestival2012;
tbDragonBoatFestival2012.tbGetItem = tbDragonBoatFestival2012.tbGetItem or {};

function tbDragonBoatFestival2012:GetItem(dwKinId, nPlayerId)
	if (MODULE_GAMESERVER) then
		if me.nKinFigure ~= 1 and me.nKinFigure ~= 2 then
			Dialog:Say("只有家族的族长和副族长才能领取家族团圆锅。");
			return;
		end
		if me.CountFreeBagCell() < 1 then
			Dialog:Say("Hành trang không đủ 1 ô.");
			return;
		end
		me.AddWaitGetItemNum(1);
		GCExcute({"SpecialEvent.tbDragonBoatFestival2012:GetItem", me.dwKinId, me.nId});
	else
		local nDate = tonumber(GetLocalDate("%Y%m%d"));
		if self.tbGetItem[dwKinId] == nDate then
			GlobalExcute({"SpecialEvent.tbDragonBoatFestival2012:GetLost", nPlayerId});
		else
			self.tbGetItem[dwKinId] = nDate;
			GlobalExcute({"SpecialEvent.tbDragonBoatFestival2012:GetFinish", nPlayerId});
		end
	end
end

function tbDragonBoatFestival2012:Msg2Kin(dwKinId, szMapName)
	if not dwKinId or not szMapName or dwKinId <= 0 or szMapName == "" then
		return;
	end
	KKin.Msg2Kin(dwKinId, string.format("家族成员在<color=green>%s<color>煮的美味的团圆粽出锅咯，大家快来尝尝！", szMapName), 1);
end

function tbDragonBoatFestival2012:GetLost(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.AddWaitGetItemNum(-1);
		Dialog:SendBlackBoardMsg(pPlayer, "你们家族今天已经领取过了。");
	end
end

function tbDragonBoatFestival2012:GetFinish(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.AddWaitGetItemNum(-1);
		local pItem = pPlayer.AddItem(unpack(self.tbGItem));
		if pItem then
			pItem.Bind(1);
			pPlayer.SetItemTimeout(0,Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d"))) + 24*3600-1);
			Dialog:SendBlackBoardMsg(pPlayer, "你领取到了[雕纹石锅]，快召集家族成员一同来煮粽子吧！");
			Player:SendMsgToKinOrTong(pPlayer, "得到了一个[雕纹石锅]，所有家族成员可以一起去煮粽子哦！", 0);
			StatLog:WriteStatLog("stat_info", "duanwujie2012", "kin_item", pPlayer.nId, 1);
		end
	end
end

function tbDragonBoatFestival2012:FinishFire(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbDragonB2012 then
		return 0;
	end
	tbTemp.tbDragonB2012.nTimerId1 = nil;
	local cKin = KKin.GetKin(tbTemp.tbDragonB2012.dwKinId)
	if not cKin then
		return 0
	end
	GlobalExcute({"Dialog:GlobalMsg2SubWorld_GS", string.format("<color=yellow>%s<color>家族成员在<color=green>%s<color>煮出了一锅美味的团圆粽，特邀各位侠士前来品尝！", cKin.GetName(), GetMapNameFormId(pNpc.nMapId))});
	GCExcute({"SpecialEvent.tbDragonBoatFestival2012:Msg2Kin", tbTemp.tbDragonB2012.dwKinId, GetMapNameFormId(pNpc.nMapId)});
	return 0;
end

function tbDragonBoatFestival2012:RandomAward(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbDragonB2012 then
		return 0;
	end
	tbTemp.tbDragonB2012.nFireCount = tbTemp.tbDragonB2012.nFireCount or 0;
	if not tbTemp.tbDragonB2012.dwKinId or tbTemp.tbDragonB2012.dwKinId < 0 then
		tbTemp.tbDragonB2012.nTimerId2 = nil;
		return 0;
	end
	if tbTemp.tbDragonB2012.nFireCount < self.nMaxFireCount then
		local tbPlayer = KNpc.GetAroundPlayerList(pNpc.dwId, 40);
		local tbRandomList = {};
		for _, pPlayer in ipairs(tbPlayer) do
			if pPlayer.dwKinId == tbTemp.tbDragonB2012.dwKinId and (not tbTemp.tbDragonB2012.tbRandPlayer or not tbTemp.tbDragonB2012.tbRandPlayer[pPlayer.szName]) then
				table.insert(tbRandomList, pPlayer);
			end
		end
		if #tbRandomList > 0 then
			local pRandPlayer = tbRandomList[MathRandom(#tbRandomList)];
			self:GiveRandomAward(pRandPlayer, pNpc);
		end
		tbTemp.tbDragonB2012.nFireCount = tbTemp.tbDragonB2012.nFireCount + 1;
		return;
	end
	tbTemp.tbDragonB2012.nTimerId2 = nil;
	return 0;
end

function tbDragonBoatFestival2012:GiveRandomAward(pPlayer, pNpc)
	local nServerValue = tbDragonBoatFestival2012:GetServerValue();
	local tbAward = Lib._CalcAward:RandomAward(3, 3, 2, 30000, nServerValue, {0,5,5});
	local nMaxBindMoney = tbDragonBoatFestival2012:GetMaxBandMoney(tbAward);
	if pPlayer.GetBindMoney() + nMaxBindMoney > pPlayer.GetMaxCarryMoney() then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbDragonB2012 then
		return 0;
	end
	self:RandomItem(pPlayer, tbAward, 3);
	tbTemp.tbDragonB2012.tbRandPlayer = tbTemp.tbDragonB2012.tbRandPlayer or {};
	tbTemp.tbDragonB2012.tbRandPlayer[pPlayer.szName] = 3;
	pNpc.SendChat(string.format("锅里蹦出了个粽子砸到了<color=green>%s<color>的脑袋上。", pPlayer.szName));
	Dialog:SendBlackBoardMsg(pPlayer, "你幸运的在雕纹石锅旁获得了一份惊喜。");
	Player:SendMsgToKinOrTong(pPlayer, "在雕纹石锅旁获得了一份意外惊喜。", 0);
end

function tbDragonBoatFestival2012:RandomExp(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc then
		return 0;
	end	
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp.tbDragonB2012 then
		return 0;
	end
	--已经煮熟了就不在发经验奖励了
	if not tbTemp.tbDragonB2012.nTimerId1 then
		return 0;
	end
	local tbPlayer = KNpc.GetAroundPlayerList(pNpc.dwId, 40);
	for _, pPlayer in ipairs(tbPlayer) do
		if pPlayer.dwKinId == tbTemp.tbDragonB2012.dwKinId  then
			pPlayer.CastSkill(377, 10, -1, pPlayer.GetNpc().nIndex);
			pPlayer.AddExp(pPlayer.GetBaseAwardExp());
		end
	end
	return;
end

function tbDragonBoatFestival2012:RandomItem(pPlayer, tbAward, nEvent)
	local nRate = MathRandom(1000000);
	local nTotalCount = 0;
	for _, tb in ipairs(tbAward) do
		nTotalCount = nTotalCount + tb[3];
		if nRate <= nTotalCount then
			local nType = 0;
			if  tb[1] == "玄晶" then
				pPlayer.AddItemEx(18,1,114, tb[2],nil);
				nType = 1;
			elseif tb[1] == "绑金" then
				pPlayer.AddBindCoin(tb[2]);
				nType = 2;
			elseif tb[1] == "绑银" then
				pPlayer.AddBindMoney(tb[2]);
				nType = 3;
			end
			StatLog:WriteStatLog("stat_info", "duanwujie2012", "open_box", pPlayer.nId, string.format("%s,%s,%s",nEvent,nType,tb[2]));
			return;
		end
	end
end

--获取随即表，最大绑银值
function tbDragonBoatFestival2012:GetMaxBandMoney(tbAward)
	local nMaxValue = 0;
	for _, tb in ipairs(tbAward or {}) do
		if tb.type == "绑银" and nMaxValue < tb.value then
			nMaxValue = tb.value;
		end
	end
	return nMaxValue;
end

function tbDragonBoatFestival2012:GetServerValue()
	local nDate = TimeFrame:GetServerOpenDay();
	if nDate <= 60 then
		return 1;
	elseif nDate <= 183 then
		return 2;
	end
	return 3;
end

function tbDragonBoatFestival2012:ChangeTask(pPlayer)
	if not pPlayer then
		return 0;
	end
	local nDayNow = tonumber(GetLocalDate("%Y%m%d"));
	local nDay = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_TIME);
	if nDay ~= nDayNow then
		for i = self.TASKID_POSITION_START, self.TASKID_TIME - 1 do
			pPlayer.SetTask(self.TASKID_GROUP, i, 0);
		end
		pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_TIME, nDayNow);
	end
	return 1;
end

function tbDragonBoatFestival2012:ExpAwrd(pPlayer)
	local nRate = MathRandom(10000);
	for _, tb in ipairs(self.tbExp) do
		if nRate <= tb[1] then
			pPlayer.AddExp(pPlayer.GetBaseAwardExp() * tb[2]);
			return;
		end
	end
end

function tbDragonBoatFestival2012:BuyItem(nFlag, nNum, bBuy)
	if me.IsAccountLock() ~= 0 then
		Dialog:Say( "你的账号处于锁定状态，无法进行该操作。", {{"我知道啦"}});
		return ;	
	end
	if not nFlag then
		Dialog:AskNumber("请输入您要购买物品的数量", 10, self.BuyItem, self, 1);
		return;
	end	
	if me.nCoin < 30 * nNum then
		Dialog:Say("您的金币不足！", {{"我知道啦"}});
		return;
	end
	if me.CountFreeBagCell() < nNum then
		Dialog:Say("Hành trang không đủ chỗ trống.", {{"我知道啦"}});
		return;
	end
	if not bBuy then
		Dialog:Say(string.format("您确定花费<color=yellow>%s金币<color>购买%s个<color=green>莲子粽<color>？", 30*nNum, nNum), {{"确认", self.BuyItem, self, 1,nNum,1},{"Để ta suy nghĩ thêm"}});
		return;
	end
	me.ApplyAutoBuyAndUse(616, nNum, 0);
	return;
end
