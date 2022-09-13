--
-- FileName: tequan.lua
-- Author: hanruofei
-- Time: 2011/4/13 14:35
-- Comment: 月充值超过指定额度的玩家拥有的特权
--
SpecialEvent.tbTequan = SpecialEvent.tbTequan or {};
local tbTequan = SpecialEvent.tbTequan;
tbTequan.nFreeDay = 7;	--免费天数

function tbTequan:OpenPayOnline()
	c2s:ApplyOpenOnlinePay();
end

function tbTequan:CheckFreeTeQuan()
	local nDate = me.GetTask(2181,3);
	local nDisDate = math.floor((Lib:GetDate2Time(os.date("%Y%m%d",GetTime())) - Lib:GetDate2Time(nDate))/86400);
	if (self.nFreeDay - nDisDate) > 0 then
		return 1;
	end
	return 0;
end

function tbTequan:FreeUseModel(tbTequanSelf, szErrorMsg)
	local tbOpt = {"Kết thúc đối thoại"};
	local nFreeUse = 0;
	szErrorMsg = szErrorMsg ..string.format("\n\n你本月已充值<color=yellow>%s元<color>。",me.GetExtMonthPay());
	table.insert(tbOpt, 1, {"<color=yellow>我要充值<color>",self.OpenPayOnline, self}); 
	local nDate = me.GetRoleCreateDate();
	local nDisDate = math.floor((Lib:GetDate2Time(os.date("%Y%m%d",GetTime())) - Lib:GetDate2Time(nDate))/86400);
	if (self.nFreeDay - nDisDate) > 0 then
		nFreeUse = 1;
		szErrorMsg = szErrorMsg ..string.format("\n\n你还<color=yellow>剩余%s天<color>可以免费使用本特权功能，想继续使用请进行充值。",self.nFreeDay - nDisDate);
		table.insert(tbOpt, 1, {"<color=yellow>免费使用特权功能<color>",tbTequanSelf.Executor, tbTequanSelf, 1}); 
	end	
	return nFreeUse, szErrorMsg, tbOpt;
end

tbTequan["getcai"] = {};
local tbTequanItem = tbTequan["getcai"];
tbTequanItem.tbCondition = {nMoney=EventManager.IVER_nPlayerFuli_Cai, nMaxTimes = 5};
tbTequanItem.nTask_Group	= 2038;
tbTequanItem.nTask_Day		= 10;	-- 领菜的日期
tbTequanItem.nTask_Times	= 11;	-- 领菜的个数
tbTequanItem.tbCaiLevel		=
{	-- G,D,P,L,Level
	{19, 3, 1, 1, 30},
	{19, 3, 1, 2, 50},
	{19, 3, 1, 3, 70},
	{19, 3, 1, 4, 90},
	{19, 3, 1, 5, 200},
};
function tbTequanItem:Check(nPlayerId)
	if (GLOBAL_AGENT) then
		return 2, "该地图不允许领取菜！";
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	local nMapId = pPlayer.GetMapId();
	local nFlag = KItem.CheckLimitUse(nMapId, "REMOTE_CHUANGSONG");
	if nFlag ~= 1 then
		return 2, "该地图不允许领取菜！";
	end
	local nTaskDay = pPlayer.GetTask(self.nTask_Group, self.nTask_Day);
	local nDay = Lib:GetLocalDay();
	if nDay > nTaskDay then
		pPlayer.SetTask(self.nTask_Group, self.nTask_Day, nDay);
		pPlayer.SetTask(self.nTask_Group, self.nTask_Times, 0);
	end
	local tbCondition = self.tbCondition;
	local nTimes = pPlayer.GetTask(self.nTask_Group, self.nTask_Times);
	if nTimes >= tbCondition.nMaxTimes then
		return 2, "您今日可领取的练级菜已领完，快去<color=yellow>【酒楼老板】<color>处看看吧。";
	end
	if pPlayer.CountFreeBagCell() < 1 then
		return 2, "Hành trang không đủ chỗ trống，请整理出1格背包空间";
	end
	
	if pPlayer.GetExtMonthPay() < tbCondition.nMoney then
		return 3, string.format("本月充值<color=yellow>%s元及以上<color>玩家可以领取！", EventManager.IVER_nPlayerFuli_Cai);
	end 
	return 1;
end
function tbTequanItem:Executor(nFreeUse)
	local nFlag, szErrorMsg = self:Check(me.nId);
	if nFlag == 3 then -- flag等于的3的判断一定要放在最下面，否则会绕过
		local nSure, szErrorMsg2, tbOpt = tbTequan:FreeUseModel(self, szErrorMsg);
		if nFreeUse ~= 1 or nSure ~= 1 then
			Dialog:Say(szErrorMsg2, tbOpt);
			return;
		end
	elseif nFlag ~= 1 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return;
	end
	local tbCondition = self.tbCondition;
	local nLevel = me.nLevel;
	for i = 1, #self.tbCaiLevel do
		if nLevel < self.tbCaiLevel[i][5] then
			local pItem = me.AddItem(self.tbCaiLevel[i][1], self.tbCaiLevel[i][2], self.tbCaiLevel[i][3], self.tbCaiLevel[i][4]);
			if pItem then
				local nTimes = me.GetTask(self.nTask_Group, self.nTask_Times) + 1;
				me.SetTask(self.nTask_Group, self.nTask_Times,  nTimes);
				Dialog:Say(string.format("你成功领取了一个%s, 今日已经领取了<color=yellow>%s/%s<color>个菜。", pItem.szName, nTimes, tbCondition.nMaxTimes));
				
				if (SpecialEvent.tbTequan:CheckFreeTeQuan() == 1) then
					me.CallClientScript({"Tutorial:ProcessTeQuan_Cai",1});
				end
				
			else
				Dialog:Say("领取失败！");
			end
			return;
		end
	end
end

tbTequan["getchuansongfu"] = {};
local tbTequanItem = tbTequan["getchuansongfu"];
tbTequanItem.nTaskGroup = 2038;
tbTequanItem.nTaskId	= 7;
tbTequanItem.tbCondition = {nMoney=EventManager.IVER_nPlayerFuli_Chuansong};
function tbTequanItem:Check(nPlayerId)

	if (GLOBAL_AGENT) then
		return 2, "该地图不允许领取传送符！";
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbCondition = self.tbCondition;
	if pPlayer.GetExtMonthPay() < tbCondition.nMoney then
		return 0, string.format("本月充值%s元及以上玩家可以领取！", EventManager.IVER_nPlayerFuli_Chuansong);
	end
	
	local nMapId = pPlayer.GetMapId();
	local nFlag = KItem.CheckLimitUse(nMapId, "REMOTE_CHUANGSONG");
	if nFlag ~= 1 then
		return 2, "该地图不允许领取传送符！";
	end
		
	return 1;
end
function tbTequanItem:Executor()
	if (GLOBAL_AGENT) then
		Dialog:Say("该地图不允许领取和使用传送符！");
		return;
	end
	local nCurDate = tonumber(GetLocalDate("%y%m%d"));
	if math.floor(me.GetTask(self.nTaskGroup, self.nTaskId)/100) >= math.floor(nCurDate/100) then
		local nFlag = KItem.CheckLimitUse(me.nMapId, "chuansong");
		if nFlag ~= 1 then
			me.Msg("该地图禁止使用传送功能！");
			return;
		end
		SpecialEvent.tbTequan.tbChuansong:OnUse();
	else
		local nFlag, szErrorMsg = self:Check(me.nId);
		if nFlag ~= 1 then
			if szErrorMsg then
				Dialog:Say(szErrorMsg);
			end
			return;
		end
		
		StatLog:WriteStatLog("stat_info", "link_open", "use", me.nId, "1," .. tostring(me.GetMapId()));
		
		local _, szMsg = SpecialEvent.ChongZhiYouHui48:GetItemEx(1);
		Dialog:Say(szMsg);
	end
end

tbTequan["getqiankunfu"] = {};
local tbTequanItem = tbTequan["getqiankunfu"];
tbTequanItem.tbCondition = {nMoney=EventManager.IVER_nPlayerFuli_Qiankunfu};
function tbTequanItem:Check(nPlayerId)
	if (GLOBAL_AGENT) then
		return 2, "该地图不允许领取乾坤符！";
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbCondition = self.tbCondition;
	if pPlayer.GetExtMonthPay() < tbCondition.nMoney then
		return 0, string.format("本月充值%s元及以上玩家可以领取！", EventManager.IVER_nPlayerFuli_Qiankunfu);
	end 
	
	local nMapId = pPlayer.GetMapId();
	local nFlag = KItem.CheckLimitUse(nMapId, "REMOTE_CHUANGSONG");
	if nFlag ~= 1 then
		return 2, "该地图不允许领取乾坤符！";
	end
	
	return 1;
end
function tbTequanItem:Executor()
	local nFlag, szErrorMsg = self:Check(me.nId);
	if nFlag ~= 1 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return;
	end
	
	StatLog:WriteStatLog("stat_info", "link_open", "use", me.nId, "2," .. tostring(me.GetMapId()));
	local _, szMsg = SpecialEvent.ChongZhiYouHui48:GetItemEx(2);
	Dialog:Say(szMsg);
end

tbTequan["getfulimedic"] = {};
local tbTequanItem = tbTequan["getfulimedic"];
tbTequanItem.tbCondition = {nMoney=EventManager.IVER_nPlayerFuli_Task};
function tbTequanItem:Check(nPlayerId)
	if (GLOBAL_AGENT) then
		return 2, "该地图不允许免费药！";
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	local nMapId = pPlayer.GetMapId();
	local nFlag = KItem.CheckLimitUse(nMapId, "REMOTE_GETMEDICINE");
	if nFlag ~= 1 then
		return 2, "该地图不允许领取免费药！";
	end
	
	return 1;
end
function tbTequanItem:Executor()
	local nFlag, szErrorMsg = self:Check(me.nId);
	if nFlag ~= 1 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return;
	end
	SpecialEvent.tbMedicine_2012:GetMedicine();
end

-- 合玄特权
tbTequan["openhexuan"] = {};
local tbTequanItem = tbTequan["openhexuan"];
tbTequanItem.tbCondition = {nMoney=EventManager.IVER_nPlayerFuli_Hexuan}; 
function tbTequanItem:Check(nPlayerId)

	if (GLOBAL_AGENT) then
		return 2, "该地图不允许打开随身玄晶熔炉！";
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	local nMapId = pPlayer.GetMapId();
	local nFlag = KItem.CheckLimitUse(nMapId, "REMOTE_MERCHXUAN");
	if nFlag ~= 1 then
		return 2, "该地图不允许打开随身玄晶熔炉！";
	end
	local tbCondition = self.tbCondition;
	if pPlayer.GetExtMonthPay() < tbCondition.nMoney then
		return 3, string.format("这是本月充值%s元及以上玩家特权！", EventManager.IVER_nPlayerFuli_Hexuan);
	end 
	
	return 1;
end


function tbTequanItem:Executor(nFreeUse)
	local nFlag, szErrorMsg = self:Check(me.nId);
	if nFlag == 3 then
		local nSure, szErrorMsg2, tbOpt = tbTequan:FreeUseModel(self, szErrorMsg);
		if nFreeUse ~= 1 or nSure ~= 1 then
			Dialog:Say(szErrorMsg2, tbOpt);
			return;
		end
	elseif nFlag ~= 1 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return;
	end
	
	StatLog:WriteStatLog("stat_info", "link_open", "use", me.nId, "5," .. tostring(me.GetMapId()));
	
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return;
	end	
	-- 打开强化界面，并只能允许 玄晶合成
	me.OpenEnhance(Item.ENHANCE_MODE_COMPOSE, Item.BIND_MONEY);
end

-- 打开仓库特权
tbTequan["opencangku"] = {};
local tbTequanItem = tbTequan["opencangku"];
tbTequanItem.tbCondition = {nMoney=EventManager.IVER_nPlayerFuli_Cangku,}; 
function tbTequanItem:Check(nPlayerId)

	if (GLOBAL_AGENT) then
		return 2, "该地图不允许打开随身储物箱！";
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	local nMapId = pPlayer.GetMapId();
	local nFlag = KItem.CheckLimitUse(nMapId, "REMOTE_ITEMROOM");
	if nFlag ~= 1 then
		return 2, "该地图不允许打开随身储物箱！";
	end
	local tbCondition = self.tbCondition;
	if pPlayer.GetExtMonthPay() < tbCondition.nMoney then
		return 3, string.format("这是本月充值%s元及以上玩家特权！", EventManager.IVER_nPlayerFuli_Cangku);
	end 
	return 1;
end

tbTequanItem.szMsg = "打开仓库...";
tbTequanItem.nDuration = 10 * Env.GAME_FPS;
tbTequanItem.tbBreakEvent = 
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
	Player.ProcessBreakEvent.emEVENT_ATTACKED,
	Player.ProcessBreakEvent.emEVENT_DEATH,
	Player.ProcessBreakEvent.emEVENT_LOGOUT,
};

function tbTequanItem:ActualExecutor(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	StatLog:WriteStatLog("stat_info", "link_open", "use", pPlayer.nId, "6," .. tostring(pPlayer.GetMapId()));
	pPlayer.OpenRepository();
end

function tbTequanItem:Executor(nFreeUse)
	local nFlag, szErrorMsg = self:Check(me.nId);
	if nFlag == 3 then
		local nSure, szErrorMsg2, tbOpt = tbTequan:FreeUseModel(self, szErrorMsg);
		if nFreeUse ~= 1 or nSure ~= 1 then
			Dialog:Say(szErrorMsg2, tbOpt);
			return;
		end
	elseif nFlag ~= 1 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return;
	end
	if me.nFightState ~= 0 then
		local tbCallBack = {self.ActualExecutor, self, me.nId};
		GeneralProcess:StartProcess(self.szMsg, self.nDuration, tbCallBack, nil, self.tbBreakEvent);
	else
		self:ActualExecutor(me.nId)
	end
end

-- 打开拍卖行特权
tbTequan["openauction"] = {};
local tbTequanItem = tbTequan["openauction"];
tbTequanItem.tbCondition = {nMoney=EventManager.IVER_nPlayerFuli_Paimai, }; 
function tbTequanItem:Check(nPlayerId)

	if (GLOBAL_AGENT) then
		return 2, "该地图不允许打开随身拍卖行！";
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	local nMapId = pPlayer.GetMapId();
	local nFlag = KItem.CheckLimitUse(nMapId, "REMOTE_AUCTION");
	if nFlag ~= 1 then
		return 2, "该地图不允许打开随身拍卖行！";
	end
	local tbCondition = self.tbCondition;
	if pPlayer.GetExtMonthPay() < tbCondition.nMoney then
		return 3, string.format("这是本月充值%s元及以上玩家特权！", EventManager.IVER_nPlayerFuli_Paimai);
	end 
	return 1;
end
function tbTequanItem:Executor(nFreeUse)
	local nFlag, szErrorMsg = self:Check(me.nId);
	if nFlag == 3 then
		local nSure, szErrorMsg2, tbOpt = tbTequan:FreeUseModel(self, szErrorMsg);
		if nFreeUse ~= 1 or nSure ~= 1 then
			Dialog:Say(szErrorMsg2, tbOpt);
			return;
		end
	elseif nFlag ~= 1 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return;
	end
	StatLog:WriteStatLog("stat_info", "link_open", "use", me.nId, "3," .. tostring(me.GetMapId()));
	me.CallClientScript({"UiManager:SwitchWindow", "UI_AUCTIONROOM", 1});
end

-- 打开任务平台特权
tbTequan["opentaskexp"] = {};
local tbTequanItem = tbTequan["opentaskexp"];
tbTequanItem.tbCondition = {nMoney=EventManager.IVER_nPlayerFuli_Task,};
function tbTequanItem:Check(nPlayerId)

	if (GLOBAL_AGENT) then
		return 2, "该地图不允许打开随身任务平台！";
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	local nMapId = pPlayer.GetMapId();
	local nFlag = KItem.CheckLimitUse(nMapId, "REMOTE_TASKEXP");
	if nFlag ~= 1 then
		return 2, "该地图不允许打开随身任务平台！";
	end
	local tbCondition = self.tbCondition;
	if pPlayer.GetExtMonthPay() < tbCondition.nMoney then
		return 3, string.format("这是本月充值%s元及以上玩家特权！", EventManager.IVER_nPlayerFuli_Task);
	end 
	return 1;
end

function tbTequanItem:Executor(nFreeUse)
	local nFlag, szErrorMsg = self:Check(me.nId);
	if nFlag == 3 then
		local nSure, szErrorMsg2, tbOpt = tbTequan:FreeUseModel(self, szErrorMsg);
		if nFreeUse ~= 1 or nSure ~= 1 then
			Dialog:Say(szErrorMsg2, tbOpt);
			return;
		end
	elseif nFlag ~= 1 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return;
	end
	StatLog:WriteStatLog("stat_info", "link_open", "use", me.nId, "4," .. tostring(me.GetMapId()));	
	me.CallClientScript({"UiManager:SwitchWindow", "UI_EXPTASK", 1});
end


tbTequan["payerlottery"] = {};
local tbTequanItem = tbTequan["payerlottery"];
tbTequanItem.tbCondition = {nMoney=EventManager.IVER_nPlayerFuli_Lottery}; -- 这个nMoney是月消耗的数值，单位金币
function tbTequanItem:Check(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	Setting:SetGlobalObj(pPlayer);
	local nConsumed = Spreader:IbShopGetConsume();
	Setting:RestoreGlobalObj();
	
	local tbCondition = self.tbCondition;
	if nConsumed < tbCondition.nMoney then
		return 0;
	end

	return 1;
end

function tbTequanItem:Executor()
	StatLog:WriteStatLog("stat_info", "link_open", "use", me.nId, "7," .. tostring(me.GetMapId()));
	Npc:GetClass("tuiguangyuan"):AboutConsume(1)
end

-- 领取每月修炼时间
tbTequan["getxiuliantime"] = {};
local tbTequanItem = tbTequan["getxiuliantime"];
tbTequanItem.tbCondition = {nMoney=IVER_g_nPayLevel2,};

function tbTequanItem:Check(nPlayerId)
	if (GLOBAL_AGENT) then
		return 0, "该地图不允许领取本月额外修炼时间！";
	end
	if EventManager.IVER_bOpenChongZhiHuoDong ~= 1 then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local tbFind = pPlayer.FindItemInBags(18, 1, 16, 1);
	if not tbFind or #tbFind <= 0 then
		return 0, "你的身上没有修炼珠，无法领取。";
	end
	local nMapId = pPlayer.GetMapId();
	local nFlag = KItem.CheckLimitUse(nMapId, "REMOTE_CHUANGSONG");
	if nFlag ~= 1 then
		return 0, "该地图不允许领取本月额外修炼时间！";
	end
	local tbCondition = self.tbCondition;
	if pPlayer.GetExtMonthPay() < tbCondition.nMoney then
		return 0, string.format("当前角色本月充值不足%s元，无法领取。", tbCondition.nMoney);
	end
	return 1;
end

function tbTequanItem:Executor()
	local nFlag, szErrorMsg = self:Check(me.nId);
	if nFlag ~= 1 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return 0;
	end
	Item:GetClass("xiulianzhu"):CheckAddablePreMonth(1);
end

-- 领取每周威望
tbTequan["getprestige"] = {};
local tbTequanItem = tbTequan["getprestige"];

function tbTequanItem:Check(nPlayerId)
	if (GLOBAL_AGENT) then
		return 0, "该地图不允许领取江湖威望！";
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nMapId = pPlayer.GetMapId();
	local nFlag = KItem.CheckLimitUse(nMapId, "REMOTE_CHUANGSONG");
	if nFlag ~= 1 then
		return 0, "该地图不允许领取江湖威望！";
	end
	return 1;
end

function tbTequanItem:Executor()
	local nFlag, szErrorMsg = self:Check(me.nId);
	if nFlag ~= 1 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return 0;
	end
	SpecialEvent.ChongZhiRepute:OnDialog();
end

-- 12w绑银兑换18w银两
tbTequan["coinexchange"] = {};
local tbTequanItem = tbTequan["coinexchange"];

function tbTequanItem:Check(nPlayerId)
	if (GLOBAL_AGENT) then
		return 0, "该地图不允许此操作！";
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nMapId = pPlayer.GetMapId();
	local nFlag = KItem.CheckLimitUse(nMapId, "REMOTE_CHUANGSONG");
	if nFlag ~= 1 then
		return 0, "该地图不允许此操作！";
	end
	return 1;
end

function tbTequanItem:Executor()
	local nFlag, szErrorMsg = self:Check(me.nId);
	if nFlag ~= 1 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return 0;
	end
	SpecialEvent.CoinExchange:OnDialog();
end

-- 领取工资
tbTequan["getsalary"] = {};
local tbTequanItem = tbTequan["getsalary"];

function tbTequanItem:Check(nPlayerId)
	if (GLOBAL_AGENT) then
		return 0, "该地图不允许此操作！";
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nMapId = pPlayer.GetMapId();
	local nFlag = KItem.CheckLimitUse(nMapId, "REMOTE_CHUANGSONG");
	if nFlag ~= 1 then
		return 0, "该地图不允许此操作！";
	end
	return 1;
end

function tbTequanItem:Executor()
	local nFlag, szErrorMsg = self:Check(me.nId);
	if nFlag ~= 1 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return 0;
	end
	SpecialEvent.Salary:GetSalary();
end

tbTequan.tbExceptions = {tbExceptions=true, Do=true, DoCheck=true, GetValue=true, OnIbShopConsumed=true};

-- 行使特权
-- szType: 特权类型
function tbTequan:Do(szType)

	if not szType then
		return;
	end
	
	if self.tbExceptions[szType] then
		return;
	end
	
	local tbTequanItem = tbTequan[szType];
	if type(tbTequanItem) ~= "table" then
		return;
	end
	local fnExecutor = tbTequanItem.Executor
	if type(fnExecutor) ~= "function" then
		return;
	end
	fnExecutor(tbTequanItem);
end

-- 检查me可以拥有哪些充值后的福利
function tbTequan:GetValue()
	me.CallClientScript({" UiManager:Update", "UI_PAYERFULI", me.GetExtMonthPay(), Spreader:IbShopGetConsume()});
end

-- 奇珍阁消费后调用,用于更新客户端的领奖按钮
function tbTequan:OnIbShopConsumed(nAddedConsumed)
	local nCurMonthConsumed = Spreader:IbShopGetConsume();
	local nConditionConsumed = self["payerlottery"].tbCondition.nMoney;
	if nCurMonthConsumed >= nConditionConsumed and nCurMonthConsumed - nAddedConsumed < nConditionConsumed then
		self:GetValue();
	end
end
