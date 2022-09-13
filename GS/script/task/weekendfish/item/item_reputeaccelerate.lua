Require("\\script\\task\\weekendfish\\weekendfish_def.lua")
-- 声望加速道具
local tbClass = Item:GetClass("reputeaccelerate");

tbClass.nTask_GroupId = 2184;
tbClass.tbItemInfo =
{
	-- nParticular, 1:nTaskId, 2:nValue(放大100倍存), 3:声望名字, 4:声望阵营，5:声望种类, 6:最低开始吃的等级，7:声望最高级，8：声望类型标记
	[1526] = {1, 35196, "Danh vọng Lãnh thổ", 8, 1, 4, 6, 1},
	[1527] = {2, 62123, "Danh vọng Liên đâí", 7, 1, 4, 6, 2},
	[1528] = {3, 5143, "Dah vọng Chúc phúc", 5, 4, 3, 5, 3},	
};

tbClass.nTask_Day	= 4;
tbClass.nTask_Count	= 5;
tbClass.nMaxCount	= 7;	-- 最多累积7次
tbClass.nDayCount	= 1;	-- 每天累1次
tbClass.nExtTimes	= 9;	-- 额外获得的倍数


function tbClass:OnUse()
	local nParticular = it.nParticular;
	if not self.tbItemInfo[nParticular] then
		return;
	end
	local nTaskCount = self:GetUseCount();
	if nTaskCount <= 0 then
		Dialog:Say("Danh vọng tăng tốc hôm nay đã hết.");
		return 0;
	end
	local tbInfo = self.tbItemInfo[nParticular];
	local nReputeLevel = me.GetReputeLevel(tbInfo[4], tbInfo[5]);
	if nReputeLevel >= tbInfo[7] then
		Dialog:Say(string.format("Danh vọng %s của ngươi đã đạt mức tối đa.", tbInfo[3]));
		return 0;
	end
	if nReputeLevel < tbInfo[6] then
		Dialog:Say(string.format("<color=yellow>%s<color> phải đến <color=yellow>cấp %s<color> mới có thể sử dụng số tăng tốc này",tbInfo[3], tbInfo[6]));
		return 0;
	end
	local nReputeValue = me.GetTask(self.nTask_GroupId, tbInfo[1]);
	local nAssumeLevel = Player:GetReputeLevelByAddValue(tbInfo[4], tbInfo[5], math.floor(nReputeValue / 10 / self.nExtTimes));
	if nAssumeLevel >= tbInfo[7] then
		Dialog:Say("Danh vọng phần thưởng tích lũy đã có thể giúp ngươi đạt đến cấp cao nhất.");
		return 0;
	end
	local nTotal = nReputeValue + tbInfo[2];
	me.Msg(string.format("Sử dụng <color=yellow>%s<color> thành công, tích lũy phần thưởng tăng <color=yellow>%s điểm<color>Danh vọng <color=yellow>(%s) hiện tại %s điểm<color>. Hôm nay, có thể sử dụng <color=yellow>%s<color> để tăng tốc.", it.szName, tbInfo[2]/100, tbInfo[3], nTotal/100, nTaskCount - 1));
	me.SendMsgToFriend(string.format("Hảo hữu [<color=yellow>%s<color>] sử dụng %s。", me.szName, it.szName));		
	Player:SendMsgToKinOrTong(me, string.format(" sử dụng %s。", it.szName), 1);
	me.SetTask(self.nTask_GroupId, tbInfo[1], nTotal);
	me.SetTask(self.nTask_GroupId, self.nTask_Count, nTaskCount - 1);
	StatLog:WriteStatLog("stat_info", "repute_trans", "use", me.nId, tbInfo[8]);
	return 1;
end

-- 可使用次数
function tbClass:GetUseCount()
	if TimeFrame:GetServerOpenDay() <= WeekendFish.ACCELERATE_DAYLIMIT then
		return 0;
	end
	local nDay = Lib:GetLocalDay();
	local nTaskDay = me.GetTask(self.nTask_GroupId, self.nTask_Day);
	local nTaskCount = me.GetTask(self.nTask_GroupId, self.nTask_Count);
	if nTaskDay == 0 then
		me.SetTask(self.nTask_GroupId, self.nTask_Day, nDay);
		me.SetTask(self.nTask_GroupId, self.nTask_Count, self.nDayCount);
		nTaskCount = self.nDayCount;
	elseif nDay > nTaskDay then
		nTaskCount = (nDay - nTaskDay) * self.nDayCount + nTaskCount;
		if nTaskCount > self.nMaxCount then
			nTaskCount = self.nMaxCount;
		end
		me.SetTask(self.nTask_GroupId, self.nTask_Day, nDay);
		me.SetTask(self.nTask_GroupId, self.nTask_Count, nTaskCount);
	end
	return nTaskCount;
end

-- 上线和过天的时候设置一下次数
PlayerEvent:RegisterOnLoginEvent(tbClass.GetUseCount, tbClass);
PlayerSchemeEvent:RegisterGlobalDailyEvent({tbClass.GetUseCount, tbClass});

-- 外部统一获取额外声望接口
function tbClass:GetAndUseExtRepute(pPlayer, nCampId, nClassId, nRepute, nUse)
	-- 没到时间不给予额外声望
	if TimeFrame:GetServerOpenDay() <= WeekendFish.ACCELERATE_DAYLIMIT then
		return 0;
	end
	local nParticular = 0;
	for i, tbTemp in pairs(self.tbItemInfo) do
		if tbTemp[4] == nCampId and tbTemp[5] == nClassId then
			nParticular = i;
			break;
		end
	end
	if not self.tbItemInfo[nParticular] then
		return 0;
	end
	local tbInfo = self.tbItemInfo[nParticular];
	local nReputeExt = nRepute * self.nExtTimes * 100; -- 任务变量是放大一百倍存的
	local nTaskRepute = pPlayer.GetTask(self.nTask_GroupId, tbInfo[1]);
	if nReputeExt > nTaskRepute then
		if nUse == 1 then
			local nTaskRemainRepute = math.mod(nTaskRepute, 100);
			pPlayer.SetTask(self.nTask_GroupId, tbInfo[1], nTaskRemainRepute);
			pPlayer.Msg(string.format("Sử dụng <color=yellow>%s điểm<color> tích lũy %s, hiện tại còn <color=yellow>%s điểm<color>", math.floor(nTaskRepute/100), tbInfo[3], nTaskRemainRepute / 100));
		end
		return math.floor(nTaskRepute/100);
	end
	if nUse == 1 then
		local nTaskRemainRepute =  nTaskRepute - nReputeExt;
		pPlayer.SetTask(self.nTask_GroupId, tbInfo[1], nTaskRemainRepute);
		pPlayer.Msg(string.format("Sử dụng <color=yellow>%s điểm<color> tích lũy %s, hiện tại còn <color>%s điểm<color>", nReputeExt / 100, tbInfo[3], nTaskRemainRepute / 100));
	end
	return nReputeExt / 100;
end
