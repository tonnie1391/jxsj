-- 文件名　：childrenday_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-05-11 17:49:11
-- 功能    ：

SpecialEvent.tbChildrenDay2012 = SpecialEvent.tbChildrenDay2012 or {};
local tbChildrenDay2012 = SpecialEvent.tbChildrenDay2012;

local tbItem = Item:GetClass("childrenday_book_2012");
function tbItem:OnUse(nNpcId)
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate < tbChildrenDay2012.nStartDay or nNowDate > tbChildrenDay2012.nEndDay  then
		Dialog:Say("好像不在活动期间。");
		return;
	end
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		Dialog:Say("该物品只能在各大新手村和城市使用。");
		return 0;
	end
	if self:CheckIsFinish() == 1 then
		self:GetAward(it.dwId);
		return;
	end
	self:ChangePlayer(nNpcId);
	return;
end

function tbItem:GetAward(dwId)
	local pItem  = KItem.GetObjById(dwId);
	if not pItem then
		return;
	end
	if me.CountFreeBagCell() < 6 then
		Dialog:Say("Hành trang không đủ 6 ô.");
		return;
	end
	local tbAward = tbChildrenDay2012.tbAwardItem;
	--me.AddStackItem(tbAward[1], tbAward[2], tbAward[3], tbAward[4], {bForceBind = 1}, 5);
	for i = 1, 5 do
		me.AddItemEx(tbAward[1], tbAward[2], tbAward[3], tbAward[4], {bForceBind}, nil, Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d"))) + 24*3600 - 1);
	end
	me.AddItem(tbAward[1], tbAward[2], tbAward[3] - 1, tbAward[4]);
	pItem.Delete(me);
	--变量全清掉
	for i = tbChildrenDay2012.TASKID_FACTION_START, tbChildrenDay2012.TASKID_FACTION_END do
		me.SetTask(tbChildrenDay2012.TASKID_GROUP, i, 0);
	end
	StatLog:WriteStatLog("stat_info", "kid_2012", "use_book", me.nId, 1);
end

function tbItem:CheckIsFinish()
	local nDate = me.GetTask(tbChildrenDay2012.TASKID_GROUP, tbChildrenDay2012.TASKID_TIME);
	if nDate ~= tonumber(GetLocalDate("%Y%m%d")) then
		for i = tbChildrenDay2012.TASKID_FACTION_START, tbChildrenDay2012.TASKID_FACTION_END do
			me.SetTask(tbChildrenDay2012.TASKID_GROUP, i, 0);
		end
		me.SetTask(tbChildrenDay2012.TASKID_GROUP, tbChildrenDay2012.TASKID_TIME, tonumber(GetLocalDate("%Y%m%d")));
		return 0;
	end
	for i = tbChildrenDay2012.TASKID_FACTION_START, tbChildrenDay2012.TASKID_FACTION_END do
		if me.GetTask(tbChildrenDay2012.TASKID_GROUP, i) ~= 1 then
			return 0;
		end
	end
	return 1;
end

function tbItem:CheckSelectPlayer(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end

	if pNpc.nKind == 1 then
		local pPlayer = pNpc.GetPlayer();
		if pPlayer then
			return pPlayer;
		end
	end
	return;
end

function tbItem:ChangePlayer(nNpcId, bProcesss)
	local pPlayer = self:CheckSelectPlayer(nNpcId);
	if not pPlayer then
		Dialog:SendBlackBoardMsg(me, "请选择一位侠士。");
		return;
	end
	if pPlayer.nLevel < tbChildrenDay2012.nPlayerLevel then
		Dialog:SendBlackBoardMsg(me, string.format("您选择的侠士不足%s级。", tbChildrenDay2012.nPlayerLevel));
		return;
	end
	if pPlayer.nFaction <= 0 then
		Dialog:SendBlackBoardMsg(me, "您选择的侠士还是小白。");
		return;
	end
	local pItem = pPlayer.GetItem(0,11,0);
	if pItem then
		Dialog:SendBlackBoardMsg(me, "带着面具的人是无法被变身哦。");
		return;
	end
	if pPlayer.GetSkillState(tbChildrenDay2012.nSkillId) > 0 then
		Dialog:SendBlackBoardMsg(me, "对方已经够可怜了，还是再找找其他人吧！");
		return;
	end
	local mapId1, x1, y1 = me.GetWorldPos();
	local mapId, x, y = pPlayer.GetWorldPos();
	if nMapId ~= nMapId1 or (x -x1)*(x -x1) + (y -y1)*(y -y1) > 100 then
		Dialog:SendBlackBoardMsg(me, string.format("玩家<color=yellow>%s<color>好像离你太远了。", pPlayer.szName));
		return;
	end
	local nTaskId = tbChildrenDay2012.TASKID_FACTION_START + pPlayer.nFaction - 1;
	if me.GetTask(tbChildrenDay2012.TASKID_GROUP, nTaskId) == 1 then
		Dialog:SendBlackBoardMsg(me, "你已对该门派其他弟子变过身，还是找找其他人吧！");
		return;
	end
	
	if not bProcesss then
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
				};
			GeneralProcess:StartProcess("念咒中...", 5* Env.GAME_FPS, {self.ChangePlayer, self, nNpcId, 1}, nil, tbEvent);
			return;
		end
	
	local nLevel  = MathRandom(tbChildrenDay2012.nMaxSkillLevel);
	pPlayer.CastSkill(tbChildrenDay2012.nSkillId, nLevel, x, y);
	pPlayer.SetTask(tbChildrenDay2012.TASKID_GROUP, tbChildrenDay2012.TASKID_CHANGE_TIME, GetTime());
	pPlayer.SetTask(tbChildrenDay2012.TASKID_GROUP, tbChildrenDay2012.TASKID_CHANGE_TYPE, nLevel);
	
	me.SetTask(tbChildrenDay2012.TASKID_GROUP, nTaskId, 1);
	if self:CheckIsFinish() == 0 then
		Dialog:SendBlackBoardMsg(me, "对方泪汪汪的看着你说道：不要再整我了，你这个调皮的坏蛋！！！");
	else
		Dialog:SendBlackBoardMsg(me, "你完成了整蛊任务，快点击[变身咒]领奖吧！");
	end
	Dialog:SendBlackBoardMsg(pPlayer, "你被神秘人物施了咒语，变成了一副奇怪的样子…");
end

function tbItem:InitGenInfo()
	it.SetTimeOut(0, Lib:GetDate2Time(tonumber(GetLocalDate("%Y%m%d"))) + 3600*24 - 60);
	return {};
end

-----------------------------------------------------------------------------------------------
--喔喔奶糖
local tbBox = Item:GetClass("childrenday_box_2012");

function tbBox:OnUse()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô.");
		return 0;	
	end
	local tbAward, nSelect, nMaxBindMoney = self:CaleBindValue();
	local szType	= tbAward[nSelect].szType;
	local varValue	= tbAward[nSelect].varValue;
	if (szType == "bindcoin") then
		me.AddBindCoin(varValue);
	elseif (szType == "bindmoney") then
		if me.GetBindMoney() + nMaxBindMoney > me.GetMaxCarryMoney() then
			Dialog:Say("背包携带绑定银两达上限，请整理下。");
			return 0;
		end
		me.AddBindMoney(varValue);
	elseif (szType == "item") then
		if me.CountFreeBagCell() < 1 then
			Dialog:Say("Hành trang không đủ 1 ô.");
			return 0;	
		end
		me.AddStackItem(varValue[1], varValue[2], varValue[3], varValue[4], {bForceBind = varValue[5]}, varValue[6]);
	end
	Player:SendMsgToKinOrTong(me, "完成了调皮葫芦娃的整蛊任务，正美滋滋的吃着奖励的喔喔奶糖。", 1);
	me.SendMsgToFriend("Hảo hữu ["..me.szName.."]完成了调皮葫芦娃的整蛊任务，正美滋滋的吃着奖励的喔喔奶糖。");	
	return 1;
end

function tbBox:CaleBindValue()
	local nMaxValue = self:ValueMax();
	local nBindMoney1 = math.floor(nMaxValue * 0.8 / 100) * 100;
	local nBindMoney2 = math.floor(nMaxValue * 1.2 / 100) * 100;
	local nBindCoin1 = math.floor(nMaxValue * 0.8 / 1000) * 10;
	local nBindCoin2 = math.floor(nMaxValue * 1.2 / 1000) * 10;
	local nXuanJing = 0;
	local n = math.floor(10000 * 1/6);
	local tbRandom = {n, 2*n, 3*n, 4*n}
	for i, nValue in ipairs(tbChildrenDay2012.tbXuanJingValue) do
		if nMaxValue >= nValue and nMaxValue < tbChildrenDay2012.tbXuanJingValue[i + 1] then
			local nRate = math.floor((tbChildrenDay2012.tbXuanJingValue[i + 1] - nMaxValue) / (tbChildrenDay2012.tbXuanJingValue[i + 1] - tbChildrenDay2012.tbXuanJingValue[i]) * 100);
			table.insert(tbRandom, tbRandom[4] + math.floor(100 * 1/3 * nRate));
			table.insert(tbRandom, tbRandom[5] + math.floor(100 * 1/3 * (100 - nRate)));
			nXuanJing = i;
			break;
		end
	end
	local tbAward = {
			{["szType"] = "bindmoney", 	["varValue"] = nBindMoney1},
			{["szType"] = "bindmoney", 	["varValue"] = nBindMoney2},
			{["szType"] = "bindcoin", 		["varValue"] = nBindCoin1},
			{["szType"] = "bindcoin", 		["varValue"] = nBindCoin2},
			{["szType"] = "item", 		["varValue"] = {18,1,114,nXuanJing,1,1}},
			{["szType"] = "item", 		["varValue"] = {18,1,114,nXuanJing + 1,1,1}},
		}
	local nRate= MathRandom(tbRandom[6]);
	for i, nCount in ipairs(tbRandom) do
		if nCount >= nRate then
			return tbAward, i, nBindMoney2;
		end
	end
end

function tbBox:ValueMax()
	local nBack = 0;
	local nOpenDay = tonumber(os.date("%Y%m", tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME))));
	for _, tb in ipairs(tbChildrenDay2012.tbFrameDay) do
		if nOpenDay < tb[1] then
			nBack = tb[2];
			break;
		end
	end
	return   math.floor(100000 *(nBack / 363));
end

-----------------------------------------------------------------------------------------------
--小葫芦
local tbAward = Item:GetClass("childrenday_Award_2012");

function tbAward:OnUse()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate < tbChildrenDay2012.nStartDay or nNowDate > tbChildrenDay2012.nEndDay  then
		Dialog:Say("好像不在活动期间。");
		return;
	end
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		Dialog:Say("该物品只能在各大新手村和城市使用。");
		return 0;
	end
	tbChildrenDay2012:OnFirst();
	return 0;
end

