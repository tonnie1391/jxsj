-- 文件名　：dragonboatfestival_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-06-07 11:14:08
-- 功能    ：

SpecialEvent.tbDragonBoatFestival2012 = SpecialEvent.tbDragonBoatFestival2012 or {};
local tbDragonBoatFestival2012 = SpecialEvent.tbDragonBoatFestival2012;
----------------------------------------------------------------------------------------------------
--材料
local tbMaterial  = Item:GetClass("DragonB2012_material");

function tbMaterial:OnUse()
	if me.CountFreeBagCell() < 1 then
		Dialog:SendBlackBoardMsg(me, "Hành trang không đủ 1 ô.");
		return;
	end
	for _, tbItem in ipairs(tbDragonBoatFestival2012.tbItemList) do
		local tbFind = me.FindItemInBags(unpack(tbItem));
		if #tbFind < 1 then
			Dialog:SendBlackBoardMsg(me, string.format("您身上的材料<color=yellow>%s<color>不足。", KItem.GetNameById(unpack(tbItem))));
			return;
		end
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
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
	}
	GeneralProcess:StartProcess("制作中...", 5* Env.GAME_FPS, {self.OnUseEx, self, it.dwId}, nil, tbEvent);
end

function tbMaterial:OnUseEx(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end
	for _, tbItem in ipairs(tbDragonBoatFestival2012.tbItemList) do
		local szGDPL = string.format("%s,%s,%s,%s", unpack(tbItem));
		if pItem.SzGDPL() == szGDPL then
			if pItem.nCount > 1 then
				pItem.nCount = pItem.nCount - 1;
			else
				if pItem.Delete(me) == 0 then
					return;
				end
			end
		else
			if me.ConsumeItemInBags2(1, unpack(tbItem)) == 1 then
				return;
			end
		end
	end
	local tbItem = tbDragonBoatFestival2012.tbItem;
	me.AddItemEx(tbItem[1], tbItem[2], tbItem[3], tbItem[4], {bForceBind=1});
	Dialog:SendBlackBoardMsg(me, "恭喜您成功制作了一个莲子粽。");
	StatLog:WriteStatLog("stat_info", "duanwujie2012", "item_pro", me.nId, 1);
	return 1;
end

function tbMaterial:InitGenInfo()
	it.SetTimeOut(0, Lib:GetDate2Time(GetLocalDate("%Y%m%d")) + 24 * 3600 - 1);
	return {};
end

----------------------------------------------------------------------------------------------------
--粽子
local tbItem  = Item:GetClass("DragonB2012_item");
tbItem.nLiveTime = 5 * 60 * Env.GAME_FPS;
tbItem.nTempNpcId = 10233;

function tbItem:OnUse()
	local tbPosition = tbDragonBoatFestival2012.tbPosition;
	local tbItemEx = tbDragonBoatFestival2012.tbItem;
	local nMapId, nX, nY = me.GetWorldPos();
	local nIndex = 0;
	for  i, tb in ipairs(tbPosition) do
		if nMapId == tb[1] and (nX - tb[2]) *(nX - tb[2]) + (nY - tb[3])*(nY - tb[3]) <= 400 then
			nIndex = i;
			break;
		end
	end
	local nRet, szErrorMsg = tbDragonBoatFestival2012:CheckTime();
	if nRet == 0 then
		Dialog:Say(szErrorMsg);
		return;
	end
	if not tbPosition[nIndex] then
		Dialog:SendBlackBoardMsg(me, "请从[爱吃粽子的丫宝]上找到正确地点才可以投粽子。");
		return;
	end
	local tbAward = nil;
	local nServerValue = tbDragonBoatFestival2012:GetServerValue();
	local tbMemberId, nMemberCount = KTeam.GetTeamMemberList(me.nTeamId);
	if nMemberCount > 1 then
		if me.IsLeader() == 0 then
			Dialog:SendBlackBoardMsg(me, "您不是队长，请队长投粽子吧。");
			return;
		end
		local tbAward = Lib._CalcAward:RandomAward(3, 3, 1.2, 12000*(1+0.1*(nMemberCount - 1)), nServerValue, {0,5,5});
		local nMaxBindMoney = tbDragonBoatFestival2012:GetMaxBandMoney(tbAward);
		for  _, nId in ipairs(tbMemberId) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				local nMapId1, nX1, nY1 = pPlayer.GetWorldPos();
				if nMapId1 ~= tbPosition[nIndex][1] or (nX1 - tbPosition[nIndex][2]) *(nX1 - tbPosition[nIndex][2]) + (nY1 - tbPosition[nIndex][3])*(nY1 - tbPosition[nIndex][3]) > 400 then
					Dialog:SendBlackBoardMsg(me, string.format("玩家<color=yellow>%s<color>不在跟前。", pPlayer.szName));
					return;
				end
				tbDragonBoatFestival2012:ChangeTask(pPlayer);
				local nCount = pPlayer.GetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_COUNT);
				if nCount >= tbDragonBoatFestival2012.nTotalCount then
					Dialog:SendBlackBoardMsg(me, string.format("玩家<color=yellow>%s<color>今天已经投了够多的粽子了。", pPlayer.szName));
					return;
				end
				local bActionEx = pPlayer.GetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_POSITION_START + nIndex - 1);
				if bActionEx == 1 then
					Dialog:SendBlackBoardMsg(me,  string.format("玩家<color=yellow>%s<color>在这个地点好像已经投过粽子了。", pPlayer.szName));
					return;
				end
				local tbFind = pPlayer.FindItemInBags(unpack(tbItemEx));
				if #tbFind <= 0 then
					Dialog:SendBlackBoardMsg(me, string.format("玩家<color=yellow>%s<color>身上没有携带莲子粽。", pPlayer.szName));
					return;
				end
				if pPlayer.CountFreeBagCell() < 1 then
					Dialog:SendBlackBoardMsg(me, string.format("玩家<color=yellow>%s<color>背包空间不足1 ô.", pPlayer.szName));
					return;
				end
				if pPlayer.GetBindMoney() + nMaxBindMoney > pPlayer.GetMaxCarryMoney() then
					Dialog:SendBlackBoardMsg(me, string.format("玩家<color=yellow>%s<color>身上的绑定银两将达上限。", pPlayer.szName));
					return;
				end
			else
				Dialog:SendBlackBoardMsg(me, string.format("玩家<color=yellow>%s<color>不在跟前。", KGCPlayer.GetPlayerName(nId)));
				return;
			end
		end
		local szLog = me.szName..",";
		for  i, nId in ipairs(tbMemberId) do
			if nId ~= me.nId then
				local pPlayer = KPlayer.GetPlayerObjById(nId);
				if pPlayer then
					if pPlayer.ConsumeItemInBags2(1, unpack(tbItemEx)) == 0 then
						self:GiveAward(pPlayer, nMemberCount - 1, nIndex);
						if i < nMemberCount then
							szLog = szLog..pPlayer.szName..",";
						else
							szLog = szLog..pPlayer.szName;
						end
					end
				end
			end
		end
		self:GiveAward(me, nMemberCount - 1, nIndex);
		StatLog:WriteStatLog("stat_info", "duanwujie2012", "item_use", me.nId, szLog);
	else
		tbDragonBoatFestival2012:ChangeTask(me);
		local nCount = me.GetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_COUNT);
		if nCount >= tbDragonBoatFestival2012.nTotalCount then
			Dialog:SendBlackBoardMsg(me, "您今天已经投了够多的粽子了。");
			return;
		end
		local bAction = me.GetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_POSITION_START + nIndex - 1);
		if bAction == 1 then
			Dialog:SendBlackBoardMsg(me, "这个地点您好像已经投过粽子了。");
			return;
		end
		tbAward = Lib._CalcAward:RandomAward(3, 3, 1.2, 12000, nServerValue, {0,5,5});
		local nMaxBindMoney = tbDragonBoatFestival2012:GetMaxBandMoney(tbAward);
		if me.CountFreeBagCell() < 1 then
			Dialog:SendBlackBoardMsg(me, "对不起，您背包空间不足1 ô.");
			return;
		end
		if me.GetBindMoney() + nMaxBindMoney > me.GetMaxCarryMoney() then
			Dialog:SendBlackBoardMsg(me, "对不起，您身上的绑定银两将达上限。");
			return;
		end
		self:GiveAward(me, 0, nIndex);
		StatLog:WriteStatLog("stat_info", "duanwujie2012", "item_use", me.nId, me.szName);
	end	
	self:AddNpc(tbPosition[nIndex]);
	return 1;
end

function tbItem:GiveAward(pPlayer, nPlayerCount, nIndex)
	local nCount = pPlayer.GetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_COUNT);
	if nCount > 0 and math.fmod(nCount + 1, 5) == 0 then
		pPlayer.AddItemEx(unpack(tbDragonBoatFestival2012.tbRandomBox));
		Dialog:SendBlackBoardMsg(pPlayer, "恭喜你获得了一盆菖蒲花，快找个好地方摆出来吧。");
	end
	local nServerValue = tbDragonBoatFestival2012:GetServerValue();
	local tbAward = Lib._CalcAward:RandomAward(3, 3, 1.2, 12000*(1+0.1*nPlayerCount), nServerValue, {0,5,5});
	tbDragonBoatFestival2012:RandomItem(pPlayer, tbAward, 1);
	tbDragonBoatFestival2012:ExpAwrd(pPlayer);
	pPlayer.SetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_COUNT, nCount + 1);
	pPlayer.SetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_POSITION_START + nIndex - 1, 1);
end

function tbItem:AddNpc(tbPosition)
	local nRandX = 3 - MathRandom(6);
	local nRandY = 3 - MathRandom(6);
	local pNpc = KNpc.Add2(self.nTempNpcId, 1, -1, tbPosition[1], tbPosition[2] + nRandX, tbPosition[3] +nRandY);
	if pNpc then
		pNpc.SetLiveTime(self.nLiveTime);
	end
end

function tbItem:InitGenInfo()
	it.SetTimeOut(0, Lib:GetDate2Time(GetLocalDate("%Y%m%d")) + 24 * 3600 - 1);
	return {};
end
----------------------------------------------------------------------------------------------------
--锅
local tbGItem  = Item:GetClass("DragonB2012_G");
tbGItem.nTempNpcId = 10229;
tbGItem.nLiveTime = 10 * 60 * Env.GAME_FPS;

function tbGItem:OnUse()
	local nRet, szErrorMsg = tbDragonBoatFestival2012:CheckTime();
	if nRet == 0 then
		Dialog:Say(szErrorMsg);
		return;
	end
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		Dialog:SendBlackBoardMsg(me, "该物品只能在各大新手村和城市使用。");
		return 0;
	end
	if me.dwKinId <= 0 then
		Dialog:SendBlackBoardMsg(me, "您好像没有家族。");
		return 0;
	end
	local tbNpcList = KNpc.GetAroundNpcList(me, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			Dialog:SendBlackBoardMsg(me, "这里会把<color=green>".. pNpc.szName.."<color>给挡住了，换个地方吧。");
			return 0;
		elseif pNpc.nKind == 8 then
			Dialog:SendBlackBoardMsg(me, "这里太拥挤了，还是换个地方摆吧。");
			return 0;
		end
	end
	Dialog:Say("端午节家族团圆粽锅，你们家族准备好开始煮粽子了吗？\n", {{"开始", self.OnUseEx, self, it.dwId},{"还没准备好"}});
	return;
end

function tbGItem:OnUseEx(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end
	local nMapId, nX, nY = me.GetWorldPos();
	local pNpc = KNpc.Add2(self.nTempNpcId, 1, -1, nMapId, nX, nY);
	if pNpc then
		local cKin = KKin.GetKin(me.dwKinId);
		if cKin then
			pNpc.SetTitle("<color=green>"..cKin.GetName().."<color>");
		end
		local tbTemp = pNpc.GetTempTable("Npc");
		tbTemp.tbDragonB2012 = {};
		tbTemp.tbDragonB2012.dwKinId = me.dwKinId;
		tbTemp.tbDragonB2012.nStarTime = GetTime();
		pNpc.SetLiveTime(self.nLiveTime);
		pItem.Delete(me);
		Player:SendMsgToKinOrTong(me, string.format("在<color=yellow>%s<color>摆出了[雕纹石锅]，大家快来一起煮粽子啦！", GetMapNameFormId(me.nMapId)), 0);
		Dialog:SendBlackBoardMsg(me, "你成功摆出了[雕纹石锅]，快召集家族成员一同来煮粽子吧~");
		StatLog:WriteStatLog("stat_info", "duanwujie2012", "kin_item", me.nId, 2);
	end
end

function tbGItem:InitGenInfo()
	it.SetTimeOut(0, Lib:GetDate2Time(GetLocalDate("%Y%m%d")) + 24 * 3600 - 1);
	return {};
end

---------------------------------------------------------------------
--册子
local tbBook = Item:GetClass("DragonB2012_book");

function tbBook:InitGenInfo()
	it.SetTimeOut(0, Lib:GetDate2Time(20120626) - 1);
	return {};
end

---------------------------------------------------------------------
--家族团圆粽
local tbKinItem = Item:GetClass("DragonB2012_Kinitem");

function tbKinItem:InitGenInfo()
	it.SetTimeOut(0, Lib:GetDate2Time(GetLocalDate("%Y%m%d")) + 24 * 3600 - 1);
	return {};
end
-----------------------------------------------------------------------------
local tbBox = Item:GetClass("DragonB2012_box")
tbBox.nTempNpcId = 10232;
tbBox.nLiveTime = 15 * 60 * Env.GAME_FPS;

function tbBox:OnUse()
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		Dialog:SendBlackBoardMsg(me, "该物品只能在各大新手村和城市使用。");
		return 0;
	end
	local nServerValue = tbDragonBoatFestival2012:GetServerValue();
	local tbAward = Lib._CalcAward:RandomAward(4, 3, 2, 240000, nServerValue, {20,2,2});
	local nMaxBindMoney = tbDragonBoatFestival2012:GetMaxBandMoney(tbAward);
	local tbNpcList = KNpc.GetAroundNpcList(me, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			Dialog:SendBlackBoardMsg(me, "这里会把<color=green>".. pNpc.szName.."<color>给挡住了，换个地方吧。");
			return 0;
		elseif pNpc.nKind == 8 then
			Dialog:SendBlackBoardMsg(me, "这里太拥挤了，还是换个地方摆吧。");
			return 0;
		end
	end
	if me.CountFreeBagCell() < 3 then
		Dialog:SendBlackBoardMsg(me, "对不起，您背包空间不足3 ô.");
		return;
	end
	if me.GetBindMoney() + nMaxBindMoney > me.GetMaxCarryMoney() then
		Dialog:SendBlackBoardMsg(me, "您身上的绑定银两将达上限。");
		return;
	end
	tbDragonBoatFestival2012:RandomItem(me, tbAward, 2);
	local nMapId, nX, nY = me.GetWorldPos();
	local pNpc = KNpc.Add2(self.nTempNpcId, 1, -1, nMapId, nX, nY);
	if pNpc then
		pNpc.SetLiveTime(self.nLiveTime);
		Dialog:SendBlackBoardMsg(me, "恭喜你摆出了一盆美丽的菖蒲花。");
		Player:SendMsgToKinOrTong(me, "在城中摆出了一盆菖蒲花，也带来了一份端午的祈福。", 1);
		me.SendMsgToFriend("Hảo hữu ["..me.szName.."]在城中摆出了一盆菖蒲花，也带来了一份端午的祈福。");
	end
	--额外玉如意
	if MathRandom(10000) <= 1000 and IpStatistics:CheckStudioRole(me) == 0 then
		me.AddItemEx(unpack(tbDragonBoatFestival2012.tbSpeItem2));
		Player:SendMsgToKinOrTong(me, "在[端午节活动]中获得了<color=green>玉如意<color>。", 1);
		me.SendMsgToFriend("Hảo hữu ["..me.szName.."]在[端午节活动]中获得了<color=green>玉如意<color>。");	
		StatLog:WriteStatLog("stat_info", "duanwujie2012", "open_box", me.nId, "2,5,1");
	end
	
	--随即额外宠物
	local nOpenCount = me.GetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_OPENBOX);
	me.SetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_OPENBOX, nOpenCount + 1);
	local bGet = me.GetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_GETSPEITEM);
	if bGet == 1 then
		return 1;
	end
	local nRate = 7 * nOpenCount;
	if MathRandom(100) <= nRate then
		local pItem  = me.AddItemEx(unpack(tbDragonBoatFestival2012.tbSpeItem));
		if pItem then
			pItem.Bind(1);
			me.SetItemTimeout(pItem,  10*24*60, 0);
			me.SetTask(tbDragonBoatFestival2012.TASKID_GROUP, tbDragonBoatFestival2012.TASKID_GETSPEITEM, 1);
			KDialog.NewsMsg(1,3,"恭喜["..me.szName.."]在[端午节活动]中获得了<color=green>经验跟宠【葫小芦】<color>。");	
			Player:SendMsgToKinOrTong(me, "在[端午节活动]中获得了<color=green>经验跟宠【葫小芦】<color>。", 1);
			me.SendMsgToFriend("Hảo hữu ["..me.szName.."]在[端午节活动]中获得了<color=green>经验跟宠【葫小芦】<color>。");		
			StatLog:WriteStatLog("stat_info", "duanwujie2012", "open_box", me.nId, string.format("2,4,%s",nOpenCount));
		end
	end
	return 1;
end

-----------------------------------------------------------------------------
local tbBox2 = Item:GetClass("DragonB2012_box2")

function tbBox2:OnUse()
	local nServerValue = tbDragonBoatFestival2012:GetServerValue();
	local tbAward = Lib._CalcAward:RandomAward(4, 3, 2, 80000, nServerValue, {20,2,2});
	local nMaxBindMoney = tbDragonBoatFestival2012:GetMaxBandMoney(tbAward);
	if me.CountFreeBagCell() < 1 then
		Dialog:SendBlackBoardMsg(me, "对不起，您背包空间不足1 ô.");
		return 0;
	end
	if me.GetBindMoney() + nMaxBindMoney > me.GetMaxCarryMoney() then
		Dialog:SendBlackBoardMsg(me, "您身上的绑定银两将达上限。");
		return 0;
	end
	tbDragonBoatFestival2012:RandomItem(me, tbAward, 4);
	return 1;
end

