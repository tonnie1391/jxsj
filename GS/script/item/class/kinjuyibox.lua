-- 文件名　：kinjuyibox.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-03-21 17:22:49
-- 功能    ：家族聚义礼包

local tbItem = Item:GetClass("kinjuyibox");
tbItem.nServerStarLimit = 20120322;	--这个日期后开放的服务器才开启此活动
tbItem.tbTime = {};
tbItem.szAward = "您将获得额外两次祈福机会，额外5次购买四折精活机会，500绑定金币，10000绑定银两，1张3折7玄优惠券的奖励。";

tbItem.Task_GroupId 	=  2176;	
tbItem.Task_TempSubId = 127;	--开始的id(127-130)

function tbItem:OnUse()
	if self:CaleDate() == 1 then
		return;
	end
	local szMsg = [[
	我们都是来自五湖四海,为了一个共同的目标走到一起来。
	
	<color=yellow>已加入家族的玩家可在下列日期区间内领取相应奖励。江湖威望排名前5000名的玩家在领取购买额外4折精活机会后，可点击背包中的修炼珠进行购买4折精力活力散。<color>
	]]
	local tbOpt = {"Để ta suy nghĩ thêm"};
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H"));
	print(nNowDate, Lib:CountTB(self.tbTime))
	for i, tbInfo in pairs(self.tbTime) do
		local szColor = "gray";
		if nNowDate >= tbInfo[2] and nNowDate < tbInfo[3] and me.GetTask(self.Task_GroupId, self.Task_TempSubId + i - 1) == 0 then
			szColor = "green";
		end
		table.insert(tbOpt, #tbOpt, {string.format("<color=%s>%s<color>", szColor, tbInfo[1]), self.GetAward, self, i, me.nId, it.dwId});
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:GetAward(nIndex, nPlayerId, nItemId, nFlag)
	if nIndex > 4 or nIndex < 0 then
		return;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end
	local bGet = me.GetTask(self.Task_GroupId, self.Task_TempSubId + nIndex - 1);
	if bGet == 1 then
		me.Msg("您已经领取了该奖励。");
		return 0;
	end
	if me.nKinFigure <= 0 then
		me.Msg("你需要加入一个家族才能领取该奖励。");
		return 0;
	end
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H"));
	if nNowDate < self.tbTime[nIndex][2] or nNowDate > self.tbTime[nIndex][3] then
		me.Msg("时间没到，不能领取该奖励。");
		return 0;
	end	
	if me.CountFreeBagCell() < 1 then
		me.Msg("Hành trang không đủ chỗ trống，需要1格背包空间。");
		return 0;
	end
	if not nFlag then
		Dialog:Say(self.szAward, {{"确定领取", self.GetAward, self, nIndex, nPlayerId, nItemId, 1}, {"Để ta suy nghĩ thêm"}});
		return;
	end
	
	Task.tbPlayerPray:AddExPrayCount(me, 2);	--祈福
	me.AddBindCoin(500);
	me.AddBindMoney(10000);
	me.AddItemEx(18,1,394,1, {bForceBind = 1});
	SpecialEvent.BuyItem:AddCount(22, 1);
	SpecialEvent.BuyItem:AddCount(23, 1);
	Item:GetClass("jingqisan"):AddExUseCount(5);
	Item:GetClass("huoqisan"):AddExUseCount(5);
	me.Msg("恭喜你领取额外2次祈福机会。");
	me.SetTask(self.Task_GroupId, self.Task_TempSubId + nIndex - 1, 1);
	--检查已经领取完所有奖励了，就删掉道具
	for i=1, 4 do
		if me.GetTask(self.Task_GroupId, self.Task_TempSubId + i - 1) == 0 then
			return;
		end
	end
	pItem.Delete(me);
end

--计算活动开启的四个周时间
function tbItem:CaleDate()
	local tbWeek = {6, 5, 4, 3, 2, 1, 7} --日期矫正到下周六
	local nServerStarTime = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nServerStartDay = tonumber(os.date("%Y%m%d", nServerStarTime));
	local nWeek = tonumber(os.date("%w", nServerStarTime));
	if nServerStartDay >= self.nServerStarLimit then
		if Lib:CountTB(self.tbTime) == 0 then	--只做一次
			for i = 1, 4 do
				local nStarTime = nServerStarTime + (tbWeek[nWeek + 1] + (i - 1) * 7)  * 24 * 3600;
				local nEndTime = nStarTime + 24*3600;
				local nStartDate = tonumber(os.date("%Y%m%d", nStarTime)) * 100;
				local nEndDate = tonumber(os.date("%Y%m%d", nEndTime)) * 100 + 24;
				local szSelect = "【聚义】"..os.date("%m月%d", nStarTime).."-"..os.date("%m月%d", nEndTime);
				table.insert(self.tbTime, {szSelect, nStartDate, nEndDate, nStartTime, nEndTime});
			end
		end
		return 0;
	else
		return 1;
	end
end

--初始化直接活动结束最后一天消失道具
function tbItem:InitGenInfo()
	self:CaleDate();
	if not self.tbTime[4] then
		return {};
	end
	it.SetTimeOut(0, Lib:GetDate2Time(self.tbTime[4][3]));
	return {};
end
